#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  runtime-parity-adapter.sh <claude|codex|antigravity> <fixture.md> <golden.md> <output.json>

Exit codes:
  0  Runtime produced an output artifact
  1  Adapter execution failed
  2  Runtime is pending/manual and no certification artifact exists
EOF
}

if [[ "$#" -ne 4 ]]; then
  usage >&2
  exit 1
fi

RUNTIME="$1"
FIXTURE_PATH="$2"
GOLDEN_PATH="$3"
OUTPUT_PATH="$4"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FIXTURE_ID="$(basename "${FIXTURE_PATH}" | sed 's/-.*//')"
PROMPT_PATH="$(mktemp "${TMPDIR:-/tmp}/ba-kit-parity-prompt.XXXXXX")"
RAW_PATH="$(mktemp "${TMPDIR:-/tmp}/ba-kit-parity-raw.XXXXXX")"

cleanup() {
  rm -f "${PROMPT_PATH}" "${RAW_PATH}"
}
trap cleanup EXIT

python3 "${SCRIPT_DIR}/runtime-parity-normalize.py" prompt \
  --fixture "${FIXTURE_PATH}" \
  --golden "${GOLDEN_PATH}" >"${PROMPT_PATH}"

case "${RUNTIME}" in
  claude)
    if ! command -v claude >/dev/null 2>&1; then
      echo "Claude Code CLI not found on PATH" >&2
      exit 2
    fi
    (
      cd "${REPO_ROOT}"
      claude -p \
        --no-session-persistence \
        --permission-mode dontAsk \
        --tools Read,Grep,Glob \
        --output-format text \
        "$(cat "${PROMPT_PATH}")" >"${OUTPUT_PATH}"
    )
    ;;
  codex)
    if ! command -v codex >/dev/null 2>&1; then
      echo "Codex CLI not found on PATH" >&2
      exit 2
    fi
    codex exec \
      -C "${REPO_ROOT}" \
      --sandbox read-only \
      --ask-for-approval never \
      --ephemeral \
      --output-last-message "${OUTPUT_PATH}" \
      "$(cat "${PROMPT_PATH}")" >"${RAW_PATH}"
    ;;
  antigravity)
    CERT_DIR="${BA_KIT_ANTIGRAVITY_CERT_DIR:-${REPO_ROOT}/tests/runtime-parity/certifications/antigravity}"
    CERT_PATH="${CERT_DIR}/${FIXTURE_ID}.json"
    if [[ ! -f "${CERT_PATH}" ]]; then
      echo "Antigravity manual certification missing: ${CERT_PATH}" >&2
      exit 2
    fi
    cp "${CERT_PATH}" "${OUTPUT_PATH}"
    ;;
  *)
    echo "Unsupported runtime adapter: ${RUNTIME}" >&2
    usage >&2
    exit 1
    ;;
esac

if [[ ! -s "${OUTPUT_PATH}" ]]; then
  echo "Runtime adapter produced no output: ${RUNTIME} ${FIXTURE_ID}" >&2
  exit 1
fi
