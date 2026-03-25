#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}/.claude"
SKILLS_TARGET="${TARGET_HOME}/skills"
RULES_TARGET="${TARGET_HOME}/rules/ba-kit"
AGENTS_TARGET="${TARGET_HOME}/agents"
TEMPLATES_TARGET="${TARGET_HOME}/templates"

copy_tree() {
  local source_dir="$1"
  local target_dir="$2"

  mkdir -p "$target_dir"
  cp -R "${source_dir}/." "$target_dir/"
}

echo "Installing BA-kit from: ${ROOT_DIR}"
mkdir -p "${TARGET_HOME}"

mkdir -p "${SKILLS_TARGET}"
for skill_dir in "${ROOT_DIR}"/skills/*; do
  if [[ -d "${skill_dir}" ]]; then
    copy_tree "${skill_dir}" "${SKILLS_TARGET}/$(basename "${skill_dir}")"
  fi
done
copy_tree "${ROOT_DIR}/rules" "${RULES_TARGET}"
copy_tree "${ROOT_DIR}/agents" "${AGENTS_TARGET}"
copy_tree "${ROOT_DIR}/templates" "${TEMPLATES_TARGET}"

mkdir -p "${ROOT_DIR}/docs" "${ROOT_DIR}/templates" "${ROOT_DIR}/designs"

echo "Installed skills to ${SKILLS_TARGET}"
echo "Installed rules to ${RULES_TARGET}"
echo "Installed agents to ${AGENTS_TARGET}"
echo "Installed templates to ${TEMPLATES_TARGET}"
echo "BA-kit installation complete."
