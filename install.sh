#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}/.claude"
SKILLS_TARGET="${TARGET_HOME}/skills"
RULES_TARGET="${TARGET_HOME}/rules/ba-kit"
AGENTS_TARGET="${TARGET_HOME}/agents"
TEMPLATES_TARGET="${TARGET_HOME}/templates"
CORE_SOURCE="${ROOT_DIR}/core"
CORE_TARGET="${TARGET_HOME}/ba-kit"
# Antigravity targets
AGY_HOME="${HOME}/.gemini/antigravity"
AGY_SKILLS_TARGET="${AGY_HOME}/skills"
AGY_RULES_TARGET="${AGY_HOME}/rules/ba-kit"
AGY_AGENTS_TARGET="${AGY_HOME}/agents"
AGY_TEMPLATES_TARGET="${AGY_HOME}/templates"
AGY_CORE_TARGET="${AGY_HOME}/ba-kit"
LOCAL_BIN_TARGET="${HOME}/.local/bin"
STATE_TARGET="${HOME}/.local/share/ba-kit/installations"
STALE_TEMPLATE_FILES=(
  "wireframe-input-template.md"
  "wireframe-map-template.md"
)
STALE_CORE_PATHS=(
  "references"
)
MANAGED_SKILL_DIRS=(
  "ba-*"
  "brainstorm"
  "reverse-web"
  "qc-uc-review"
)

# ── python3 bootstrap (cross-platform) ───────────────────────────────
# On macOS/Linux, python3 is the system Python 3 binary.
# On Windows (Git Bash), python3 may resolve to a non-functional
# Microsoft Store stub. This ensures python3 always points to a real
# Python 3 interpreter so generated hooks and scripts work correctly.
bootstrap_python3() {
  # Already a working python3? Nothing to do.
  if command -v python3 >/dev/null 2>&1 && python3 --version >/dev/null 2>&1; then
    return 0
  fi

  local real_python=""
  # Try common candidates
  for _c in python py python3.12 python3.13 python3.14; do
    if command -v "${_c}" >/dev/null 2>&1 && "${_c}" --version >/dev/null 2>&1; then
      real_python="${_c}"
      break
    fi
  done

  # Scan Windows Python install paths as last resort
  if [[ -z "${real_python}" ]]; then
    for _p in /c/Python313/python /c/Python312/python /c/Python314/python; do
      if [[ -x "${_p}" ]]; then
        real_python="${_p}"
        break
      fi
    done
  fi

  if [[ -z "${real_python}" ]]; then
    echo "WARNING: python3 not found and no real Python detected." >&2
    echo "BA-kit hooks requiring Python will not function." >&2
    return 1
  fi

  mkdir -p "${HOME}/bin"
  local wrapper="${HOME}/bin/python3"
  cat > "${wrapper}" <<WRAPEOF
#!/usr/bin/env bash
# BA-kit python3 bootstrap wrapper
exec ${real_python} "\$@"
WRAPEOF
  chmod +x "${wrapper}"

  # Ensure ~/bin is in PATH so the wrapper takes priority over
  # broken python3 stubs (e.g. Microsoft Store redirect on Windows)
  export PATH="${HOME}/bin:${PATH}"

  # Persist in shell profile so future sessions also find it
  local path_line="export PATH=\"\${HOME}/bin:\${PATH}\""
  local profile_target=""
  for _pf in "${HOME}/.bashrc" "${HOME}/.bash_profile" "${HOME}/.profile" "${HOME}/.zshrc"; do
    if [[ -f "${_pf}" ]] && grep -qF '${HOME}/bin' "${_pf}" 2>/dev/null; then
      profile_target=""
      break  # already configured
    fi
    if [[ -z "${profile_target}" ]]; then
      profile_target="${_pf}"
    fi
  done
  if [[ -n "${profile_target}" ]]; then
    mkdir -p "$(dirname "${profile_target}")"
    { echo ""; echo "# BA-kit python3 bootstrap"; echo "${path_line}"; } >> "${profile_target}"
  fi

  # Verify the wrapper works
  if ! "${wrapper}" --version >/dev/null 2>&1; then
    echo "WARNING: python3 wrapper created but non-functional." >&2
    rm -f "${wrapper}"
    return 1
  fi

  echo "Bootstrap: created python3 → ${real_python}"
  return 0
}

cleanup_managed_skill_dirs() {
  local pattern path

  mkdir -p "${SKILLS_TARGET}"
  shopt -s nullglob
  for pattern in "${MANAGED_SKILL_DIRS[@]}"; do
    for path in "${SKILLS_TARGET}"/${pattern}; do
      [[ -e "${path}" ]] || continue
      rm -rf "${path}"
    done
  done
  shopt -u nullglob
}

cleanup_managed_agent_files() {
  local agent_path

  mkdir -p "${AGENTS_TARGET}"
  shopt -s nullglob
  for agent_path in "${ROOT_DIR}"/agents/*; do
    [[ -f "${agent_path}" ]] || continue
    rm -f "${AGENTS_TARGET}/$(basename "${agent_path}")"
  done
  shopt -u nullglob
}

cleanup_managed_template_files() {
  local template_path

  mkdir -p "${TEMPLATES_TARGET}"
  shopt -s nullglob
  for template_path in "${ROOT_DIR}"/templates/*; do
    [[ -f "${template_path}" ]] || continue
    rm -f "${TEMPLATES_TARGET}/$(basename "${template_path}")"
  done
  shopt -u nullglob
}

cleanup_previous_install() {
  cleanup_managed_skill_dirs
  cleanup_managed_agent_files
  cleanup_managed_template_files
  rm -rf "${RULES_TARGET}" "${CORE_TARGET}"
  rm -rf "${TARGET_HOME}/core"
}

cleanup_previous_agy_install() {
  local target_home="$1"
  rm -rf "${target_home}/rules/ba-kit" "${target_home}/ba-kit"
  rm -rf "${target_home}/skills"/ba-* 2>/dev/null || true
  rm -rf "${target_home}/skills"/brainstorm 2>/dev/null || true
  rm -rf "${target_home}/skills"/reverse-web 2>/dev/null || true
  rm -rf "${target_home}/skills"/qc-uc-review 2>/dev/null || true
  rm -rf "${target_home}/core"
  for agent_path in "${ROOT_DIR}"/agents/*; do
    [[ -f "${agent_path}" ]] || continue
    rm -f "${target_home}/agents/$(basename "${agent_path}")"
  done
  for template_path in "${ROOT_DIR}"/templates/*; do
    [[ -f "${template_path}" ]] || continue
    rm -f "${target_home}/templates/$(basename "${template_path}")"
  done
}

detect_antigravity() {
  [[ -d "${AGY_HOME}" ]] && return 0
  [[ -d "${HOME}/.gemini" ]] && return 0
  command -v agy >/dev/null 2>&1 && return 0
  return 1
}

copy_tree() {
  local source_dir="$1"
  local target_dir="$2"

  mkdir -p "$target_dir"
  cp -R "${source_dir}/." "$target_dir/"
}

remove_stale_templates() {
  local target_dir="$1"
  local file_name

  for file_name in "${STALE_TEMPLATE_FILES[@]}"; do
    rm -f "${target_dir}/${file_name}"
  done
}

remove_stale_core_paths() {
  local target_dir="$1"
  local path_name

  for path_name in "${STALE_CORE_PATHS[@]}"; do
    rm -rf "${target_dir}/${path_name}"
  done
}

install_cli() {
  local temp_target
  mkdir -p "${LOCAL_BIN_TARGET}"
  temp_target="$(mktemp "${LOCAL_BIN_TARGET}/ba-kit.tmp.XXXXXX")"
  cp "${ROOT_DIR}/scripts/ba-kit" "${temp_target}"
  chmod +x "${temp_target}"
  mv "${temp_target}" "${LOCAL_BIN_TARGET}/ba-kit"

  # Windows: also install .cmd wrapper so running "ba-kit" from cmd/PowerShell
  # or double-click doesn't trigger "select program" popup
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      cp "${ROOT_DIR}/scripts/ba-kit.cmd" "${LOCAL_BIN_TARGET}/ba-kit.cmd"
      ;;
  esac
}

ensure_path() {
  local local_bin="${LOCAL_BIN_TARGET}"
  local path_line="export PATH=\"\${HOME}/.local/bin:\${PATH}\""

  # Already in the current PATH? Still check shell configs — this install
  # may be the first time it was added, so configs might not reflect it.
  if echo "${PATH}" | tr ':' '\n' | grep -qF "${local_bin}"; then
    return 0
  fi

  # Detect candidate shell profiles
  local profiles=()
  local default_shell
  default_shell="$(basename "${SHELL:-}" 2>/dev/null || echo "")"

  case "$(uname -s)" in
    Darwin)
      # macOS: zsh (default since Catalina) or bash
      profiles+=("${HOME}/.zshrc")
      profiles+=("${HOME}/.zprofile")
      profiles+=("${HOME}/.bash_profile")
      profiles+=("${HOME}/.profile")
      ;;
    MINGW*|MSYS*|CYGWIN*)
      # Windows Git Bash / MSYS2
      profiles+=("${HOME}/.bashrc")
      profiles+=("${HOME}/.bash_profile")
      profiles+=("${HOME}/.profile")
      ;;
    *)
      # Linux / others
      profiles+=("${HOME}/.bashrc")
      profiles+=("${HOME}/.profile")
      # If user runs zsh on Linux
      if [[ "${default_shell}" == "zsh" ]]; then
        profiles+=("${HOME}/.zshrc")
      fi
      ;;
  esac

  # Append to the first writable profile that doesn't already have the entry
  local target=""
  for profile in "${profiles[@]}"; do
    # Create if it doesn't exist; otherwise pick the first we can write to
    if [[ -f "${profile}" ]]; then
      if grep -qF '.local/bin' "${profile}"; then
        continue  # already configured
      fi
      if [[ -w "${profile}" ]]; then
        target="${profile}"
        break
      fi
    else
      # Doesn't exist yet — we'll create it
      target="${profile}"
      break
    fi
  done

  if [[ -z "${target}" ]]; then
    echo ""
    echo "⚠️  Could not find a writable shell profile to add ${local_bin} to PATH."
    echo "   Add this line manually to your shell config:"
    echo "     ${path_line}"
    return 0
  fi

  mkdir -p "$(dirname "${target}")"
  {
    echo ""
    echo "# Added by BA-kit installer"
    echo "${path_line}"
  } >> "${target}"

  echo ""
  echo "✅  Added ${local_bin} to PATH in ${target/$HOME/~}"
  echo "   Restart your terminal or run: source ${target/$HOME/~}"
}

write_manifest() {
  mkdir -p "${STATE_TARGET}"
  cat > "${STATE_TARGET}/claude.env" <<EOF
BA_KIT_RUNTIME=claude
BA_KIT_SOURCE_REPO=${ROOT_DIR}
BA_KIT_INSTALLED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BA_KIT_INSTALLER=install.sh
EOF
}

echo "Installing BA-kit from: ${ROOT_DIR}"
mkdir -p "${TARGET_HOME}"
cleanup_previous_install

mkdir -p "${SKILLS_TARGET}"
for skill_dir in "${ROOT_DIR}"/skills/*; do
  if [[ -d "${skill_dir}" ]]; then
    copy_tree "${skill_dir}" "${SKILLS_TARGET}/$(basename "${skill_dir}")"
  fi
done
copy_tree "${ROOT_DIR}/rules" "${RULES_TARGET}"
copy_tree "${ROOT_DIR}/agents" "${AGENTS_TARGET}"
copy_tree "${ROOT_DIR}/templates" "${TEMPLATES_TARGET}"
remove_stale_templates "${TEMPLATES_TARGET}"
copy_tree "${CORE_SOURCE}" "${CORE_TARGET}"
remove_stale_core_paths "${CORE_TARGET}"
ln -sfn ba-kit "${TARGET_HOME}/core"
install_cli
ensure_path

mkdir -p "${ROOT_DIR}/docs" "${ROOT_DIR}/templates" "${ROOT_DIR}/designs"

echo "Installed skills to ${SKILLS_TARGET}"
echo "Installed rules to ${RULES_TARGET}"
echo "Installed agents to ${AGENTS_TARGET}"
echo "Installed templates to ${TEMPLATES_TARGET}"
echo "Installed BA core to ${CORE_TARGET}"
echo "Installed update CLI to ${LOCAL_BIN_TARGET}/ba-kit"

bootstrap_python3

if [[ -f "${ROOT_DIR}/scripts/install-claude-code-ba-kit.sh" ]]; then
  echo ""
  echo "Executing Claude Code guardrail installation..."
  if bash "${ROOT_DIR}/scripts/install-claude-code-ba-kit.sh"; then
    echo ""
    echo "BA-kit Claude Code installation complete (core + guardrails)."
  else
    rc=$?
    echo "" >&2
    echo "WARNING: Guardrail installation failed (exit code ${rc})." >&2
    echo "BA-kit Claude Code core installed successfully, but guardrail hooks may be incomplete." >&2
    echo "Re-run ./install.sh or check scripts/install-claude-code-ba-kit.sh for errors." >&2
  fi
else
  echo ""
  echo "BA-kit Claude Code installation complete."
fi

# ── Antigravity installation ──────────────────────────────────────────

if detect_antigravity && [[ -f "${ROOT_DIR}/scripts/install-antigravity-ba-kit.sh" ]]; then
  echo ""
  echo "Antigravity detected. Installing BA-kit for active Antigravity runtimes..."
  
  ACTIVE_AGY_HOMES=()
  for dir in "${HOME}/.gemini/antigravity-cli" "${HOME}/.gemini/antigravity" "${HOME}/.gemini/antigravity-ide"; do
    if [[ -d "${dir}" ]]; then
      ACTIVE_AGY_HOMES+=("${dir}")
    fi
  done
  if [[ ${#ACTIVE_AGY_HOMES[@]} -eq 0 ]]; then
    ACTIVE_AGY_HOMES+=("${HOME}/.gemini/antigravity")
  fi

  for target_home in "${ACTIVE_AGY_HOMES[@]}"; do
    echo "Installing assets for Antigravity home: ${target_home}"
    cleanup_previous_agy_install "${target_home}"

    mkdir -p "${target_home}/skills"
    for skill_dir in "${ROOT_DIR}"/skills/*; do
      if [[ -d "${skill_dir}" ]]; then
        copy_tree "${skill_dir}" "${target_home}/skills/$(basename "${skill_dir}")"
      fi
    done
    copy_tree "${ROOT_DIR}/rules" "${target_home}/rules/ba-kit"
    copy_tree "${ROOT_DIR}/agents" "${target_home}/agents"
    copy_tree "${ROOT_DIR}/templates" "${target_home}/templates"
    remove_stale_templates "${target_home}/templates"
    copy_tree "${CORE_SOURCE}" "${target_home}/ba-kit"
    remove_stale_core_paths "${target_home}/ba-kit"
    ln -sfn ba-kit "${target_home}/core"

    echo "Installed BA-kit assets to ${target_home}"
  done

  if bash "${ROOT_DIR}/scripts/install-antigravity-ba-kit.sh"; then
    echo ""
    echo "BA-kit Antigravity installation complete."
  else
    rc=$?
    echo "" >&2
    echo "WARNING: Antigravity guardrail installation failed (exit code ${rc})." >&2
  fi
fi

write_manifest
echo ""
echo "BA-kit installation complete."

