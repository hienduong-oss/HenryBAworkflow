#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "${ROOT_DIR}" "${ROOT_DIR}/core/contract.yaml" "${ROOT_DIR}/templates/manifest.json" <<'PY'
import json
import re
import sys
from pathlib import Path

root_dir = Path(sys.argv[1])
contract = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
manifest = json.loads(Path(sys.argv[3]).read_text(encoding="utf-8"))
source_skill = (root_dir / "skills/ba-start/SKILL.md").read_text(encoding="utf-8")
options_step = root_dir / "skills/ba-start/steps/options.md"
behavior = (root_dir / "core/contract-behavior.md").read_text(encoding="utf-8")
intake_step = (root_dir / "skills/ba-start/steps/intake.md").read_text(encoding="utf-8")
project_home = (root_dir / "templates/project-home-template.md").read_text(encoding="utf-8")
generator = (root_dir / "scripts/generate-codex-assets.sh").read_text(encoding="utf-8")
codex_skill = (root_dir / "codex/skills/ba-start/SKILL.md").read_text(encoding="utf-8")

def fail(message):
    raise SystemExit(message)

def normalize(text):
    return " ".join(text.split()).lower()

def require_all(text, snippets, message):
    normalized = normalize(text)
    missing = [snippet for snippet in snippets if normalize(snippet) not in normalized]
    if missing:
        fail(f"{message}: missing {missing}")

def require_tokens(text, tokens, message):
    normalized = normalize(text)
    missing = [token for token in tokens if normalize(token) not in normalized]
    if missing:
        fail(f"{message}: missing {missing}")

def require_regex(text, pattern, message):
    if not re.search(pattern, text, re.IGNORECASE | re.MULTILINE | re.DOTALL):
        fail(message)

def extract_section(text, heading):
    pattern = rf"^##\s+{re.escape(heading)}\s*$([\s\S]*?)(?=^##\s+|\Z)"
    match = re.search(pattern, text, re.MULTILINE)
    if not match:
        fail(f"Missing section: {heading}")
    return match.group(1)

if "options" not in contract["commands"]:
    fail("Missing commands.options")
if contract["commands"]["options"]["requires"] != ["intake"]:
    fail("options must require intake")
if "options" not in contract["next_step_order"]:
    fail("options missing from next_step_order")
if not (
    contract["next_step_order"].index("intake")
    < contract["next_step_order"].index("options")
    < contract["next_step_order"].index("backbone")
):
    fail("options must sit between intake and backbone")

paths = contract["paths"]
for key in ("options_root", "options_index", "option_item", "options_comparison"):
    if key not in paths:
        fail(f"Missing contract path: {key}")

for template_name in (
    "options-index-template.md",
    "solution-option-template.md",
    "options-comparison-template.md",
):
    if template_name not in manifest:
        fail(f"Missing template manifest entry: {template_name}")

if "/ba-start options --slug <slug>" not in source_skill:
    fail("Missing ba-start options invocation in source skill")
if "| `options` | `steps/options.md` |" not in source_skill:
    fail("Missing ba-start options dispatch row in source skill")
if not options_step.exists():
    fail("Missing ba-start options step")
step_body = options_step.read_text(encoding="utf-8")
if "`impact` -> `impact.md`" not in generator or "`options` -> `options.md`" not in generator:
    fail("Codex asset generator missing options step mapping")
if "`impact` -> `impact.md`" not in codex_skill or "`options` -> `options.md`" not in codex_skill:
    fail("Generated Codex ba-start asset missing options step mapping")

options_index_template = (root_dir / "templates/options-index-template.md").read_text(encoding="utf-8")
solution_option_template = (root_dir / "templates/solution-option-template.md").read_text(encoding="utf-8")
options_comparison_template = (root_dir / "templates/options-comparison-template.md").read_text(encoding="utf-8")

status_tokens = [
    "recommended",
    "in-progress",
    "completed",
    "skipped",
    "not-needed",
]

lifecycle_section = extract_section(behavior, "Canonical Lifecycle Status Mapping")
require_tokens(
    lifecycle_section,
    status_tokens + ["todo", "doing", "done"],
    "contract-behavior lifecycle mapping regressed",
)

options_gate_section = extract_section(behavior, "Options Decision-Ledger Gate")
require_tokens(
    options_gate_section,
    status_tokens
    + [
        "paths.options_root",
        "paths.plan",
        "recommend",
        "strongly recommend",
        "selected option",
        "backbone",
        "options",
    ],
    "contract-behavior options gate guidance regressed",
)
if "plan.md" in options_gate_section:
    fail("Options gate guidance should reference `paths.plan`, not hardcoded plan.md")

require_tokens(
    source_skill,
    [
        "argument-hint: \"[intake|impact|options|backbone|frd|stories|srs|wireframes|package|status|next]",
        "/ba-start options --slug <slug>",
        "/ba-start options --slug <slug> --select option-02",
        "/ba-start options --slug <slug> --skip",
        "/ba-start next --slug <slug>",
    ],
    "ba-start options invocation examples regressed",
)

require_tokens(
    step_body,
    [
        "## Prerequisites",
        "Resolve slug and date using the shared contract",
        "Require `paths.intake`",
        "Read `paths.plan` when it exists",
        "## Supported Intents",
        "generate option pack from intake",
        "select an existing option",
        "skip optioning explicitly",
        "## Generation Rules",
        "Generate 1-3 option artifacts only",
        "Mark each option with `L1`, `L2`, or `L3`",
        "Generate `comparison.md` only when more than one viable option exists",
        "Keep options as solution briefs, not mini-backbones",
        "## Selection / Skip Rules",
        "--select option-02",
        "selected option",
        "options status: completed",
        "--skip",
        "options status: skipped",
        "refresh `paths.project_home`",
    ],
    "options step contract regressed",
)

require_regex(
    behavior,
    r"For `options`, allow `--select <option-id>` and `--skip` as mutually exclusive control arguments\.",
    "contract-behavior must define options control arguments",
)
require_regex(
    behavior,
    r"Stop when:\s*-\s*the requested option file does not exist\s*-\s*multiple options exist but no explicit selection/skip has been approved\s*-\s*a selection request names an unknown option id",
    "contract-behavior must define exact options stop conditions",
)

selection_skip_section = extract_section(step_body, "Selection / Skip Rules")
require_regex(
    selection_skip_section,
    r"`--select option-02`[^\n]*`selected option`[^\n]*`paths\.plan`[^\n]*`options status: completed`",
    "options step must tie selection to both `selected option` and `completed` in `paths.plan`",
)
require_regex(
    selection_skip_section,
    r"`--skip`[^\n]*`paths\.plan`[^\n]*`options status: skipped`",
    "options step must tie skip to `paths.plan` and `skipped`",
)
require_regex(
    options_gate_section,
    r"`completed` once `selected option` is recorded",
    "contract-behavior must tie `completed` to recorded `selected option`",
)
require_regex(
    options_gate_section,
    r"records either `selected option` \(`completed`\) or `skipped`",
    "contract-behavior must tie backbone gate to `selected option` or `skipped`",
)

require_tokens(
    options_index_template,
    [
        "Difference Level",
        "draft/reviewing/selected/rejected/skipped",
        "Recommended option:",
        "Selected option:",
        "Comparison file:",
    ],
    "options index template regressed",
)
require_tokens(
    solution_option_template,
    [
        "## 1. Option Summary",
        "## 2. Business Intent",
        "## 3. Scope Shape",
        "## 4. Interaction View",
        "## 5. Key Constraints And Gaps",
        "## 6. Pros And Cons",
        "## 7. Indicative Assessment",
    ],
    "solution option template regressed",
)
require_tokens(
    options_comparison_template,
    [
        "Difference Level",
        "Time-to-Clarity",
        "Recommended When",
    ],
    "options comparison template regressed",
)

intake_gate_section = extract_section(intake_step, "Step 4.1 - Recommend direct backbone or optioning")
require_tokens(
    intake_gate_section,
    status_tokens + ["paths.plan", "decision ledger", "backbone", "options", "strongly recommend"],
    "intake recommendation gate contract regressed",
)
require_regex(
    intake_gate_section,
    r"direct[^\n`]*`backbone`|`backbone`[^\n]*direct",
    "intake must preserve the direct-to-backbone path",
)
require_regex(
    intake_gate_section,
    r"recommend[^\n`]*`options`|`options`[^\n]*recommend",
    "intake must preserve the recommend-options path",
)
require_regex(
    intake_gate_section,
    r"options status[^\n]*`not-needed`[^\n]*`recommended`",
    "intake must seed options status with `not-needed` or `recommended`",
)
require_regex(
    intake_gate_section,
    r"expected next command[^\n]*`backbone`[^\n]*`options`",
    "intake must map the expected next command to `backbone` or `options`",
)

if "Todo / Doing / Done" in project_home or "Not needed / Todo / Doing / Done" in project_home:
    fail("Project Home still uses legacy Todo/Doing/Done lifecycle labels")

require_tokens(
    project_home,
    status_tokens + ["Trạng thái lifecycle chuẩn", "Decision ledger", "optioning status"],
    "Project Home options lifecycle guidance regressed",
)
require_regex(
    project_home,
    r"^\|\s*Phương án giải pháp\s*\|\s*\[recommended \| in-progress \| completed \| skipped \| not-needed\]\s*\|",
    "Project Home must keep the solution-option lifecycle row",
)
require_regex(
    project_home,
    r"`01_intake/plan\.md`[^\n]*Decision ledger",
    "Project Home must describe `01_intake/plan.md` as the decision ledger",
)
PY
