#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

legacy_hits="$(
  cd "${ROOT_DIR}" &&
    rg -n "artifact-contract\\.md|plans/reports/final|plans/reports/drafts|plans/\\{date\\}-\\{slug\\}" \
      AGENTS.md GEMINI.md CLAUDE.md skills core scripts codex templates \
      --glob '!core/contract.yaml' \
      --glob '!rules/ba-workflow.md' \
      --glob '!scripts/test-contract-sync.sh' \
      || true
)"

if [[ -n "${legacy_hits}" ]]; then
  echo "Unexpected legacy contract references found:" >&2
  echo "${legacy_hits}" >&2
  exit 1
fi

python3 - "${ROOT_DIR}/templates/manifest.json" "${ROOT_DIR}/templates" <<'PY'
import json
import re
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
templates_dir = Path(sys.argv[2])
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
heading_re = re.compile(r"^(#{1,6})\s+(.+)$")

for template_name, info in manifest.items():
    template_path = templates_dir / template_name
    if not template_path.exists():
        raise SystemExit(f"Missing template from manifest: {template_path}")
    headings = {
        line.strip()
        for line in template_path.read_text(encoding="utf-8").splitlines()
        if heading_re.match(line.strip())
    }
    for group_name, group_info in info.get("groups", {}).items():
        for heading in group_info.get("headings", []):
            if heading not in headings:
                raise SystemExit(
                    f"Manifest heading not found: template={template_name} group={group_name} heading={heading}"
                )
PY

python3 - "${ROOT_DIR}/core/contract.yaml" <<'PY'
import json
import sys
from pathlib import Path

contract_path = Path(sys.argv[1])
contract = json.loads(contract_path.read_text(encoding="utf-8"))
activation = contract.get("activation", {})
signals = set(activation.get("signals", {}))
thresholds = activation.get("thresholds", {})
operators = {"gte", "equals"}


def validate_rule(rule, path):
    if not isinstance(rule, dict):
        raise SystemExit(f"Activation threshold rule must be an object: {path}")

    branch_keys = {"any_of", "all_of"} & set(rule)
    if branch_keys:
        if len(branch_keys) != 1 or len(rule) != 1:
            raise SystemExit(f"Activation threshold branch must contain only one branch key: {path}")
        key = next(iter(branch_keys))
        children = rule[key]
        if not isinstance(children, list) or not children:
            raise SystemExit(f"Activation threshold branch must be a non-empty list: {path}.{key}")
        for index, child in enumerate(children):
            validate_rule(child, f"{path}.{key}[{index}]")
        return

    required = {"signal", "operator", "value"}
    if set(rule) != required:
        raise SystemExit(f"Activation threshold leaf must contain exactly signal/operator/value: {path}")
    if rule["signal"] not in signals:
        raise SystemExit(f"Activation threshold references unknown signal '{rule['signal']}': {path}")
    if rule["operator"] not in operators:
        raise SystemExit(f"Activation threshold uses unsupported operator '{rule['operator']}': {path}")
    if rule["operator"] == "gte" and (not isinstance(rule["value"], (int, float)) or isinstance(rule["value"], bool)):
        raise SystemExit(f"Activation threshold gte value must be numeric: {path}")


for level in ("modular", "program"):
    if level not in thresholds:
        raise SystemExit(f"Missing activation threshold level: {level}")
    validate_rule(thresholds[level], f"activation.thresholds.{level}")
PY

python3 -m py_compile \
  "${ROOT_DIR}/scripts/source-extract.py" \
  "${ROOT_DIR}/scripts/design-snapshot.py" \
  "${ROOT_DIR}/scripts/stitch-state.py" \
  "${ROOT_DIR}/scripts/runtime-parity-normalize.py"

bash -n "${ROOT_DIR}/scripts/ba-kit"
bash -n "${ROOT_DIR}/scripts/check-token-budget.sh"
bash -n "${ROOT_DIR}/install.sh"
bash -n "${ROOT_DIR}/scripts/install-codex-ba-kit.sh"
bash -n "${ROOT_DIR}/scripts/install-antigravity-ba-kit.sh"
bash -n "${ROOT_DIR}/scripts/install-plantuml.sh"
bash -n "${ROOT_DIR}/scripts/generate-codex-assets.sh"
bash -n "${ROOT_DIR}/scripts/test-activation-thresholds.sh"
bash -n "${ROOT_DIR}/scripts/test-runtime-parity.sh"
bash -n "${ROOT_DIR}/scripts/runtime-parity-adapter.sh"
bash -n "${ROOT_DIR}/scripts/test-runtime-install-smoke.sh"
bash "${ROOT_DIR}/scripts/check-token-budget.sh" >/dev/null
bash "${ROOT_DIR}/scripts/test-activation-thresholds.sh" >/dev/null
bash "${ROOT_DIR}/scripts/test-runtime-parity.sh" --check-structure >/dev/null
bash "${ROOT_DIR}/scripts/test-runtime-parity.sh" >/dev/null

cp "${ROOT_DIR}/codex/skills/ba-start/SKILL.md" "${TMP_DIR}/ba-start.before"
bash "${ROOT_DIR}/scripts/generate-codex-assets.sh" >"${TMP_DIR}/generator.log"
cmp "${TMP_DIR}/ba-start.before" "${ROOT_DIR}/codex/skills/ba-start/SKILL.md" >/dev/null
bash "${ROOT_DIR}/scripts/test-runtime-install-smoke.sh" >/dev/null

echo "Contract sync checks passed."
