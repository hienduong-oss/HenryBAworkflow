#!/usr/bin/env python3
"""Prompt and comparison helpers for BA-kit runtime parity adapters."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


SECTION_RE = re.compile(r"^##\s+(.+)$", re.MULTILINE)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def parse_behavior_envelope(markdown: str) -> dict[str, str]:
    in_envelope = False
    values: dict[str, str] = {}

    for raw_line in markdown.splitlines():
        line = raw_line.strip()
        if line == "## Behavior Envelope":
            in_envelope = True
            continue
        if in_envelope and line.startswith("## "):
            break
        if not in_envelope or not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) < 2:
            continue
        field, value = cells[0], cells[1]
        if field in {"Field", "---"} or set(field) == {"-"}:
            continue
        values[field] = value

    if not values:
        raise SystemExit("Could not parse Behavior Envelope from golden file")
    return values


def parse_fixture_runtime_input(markdown: str) -> str:
    sections: dict[str, list[str]] = {}
    current: str | None = None

    for raw_line in markdown.splitlines():
        heading_match = re.match(r"^##\s+(.+)$", raw_line)
        if heading_match:
            current = heading_match.group(1).strip()
            sections[current] = []
            continue
        if current is not None:
            sections[current].append(raw_line)

    wanted = ["Scenario", "Input State", "Input Command"]
    missing = [name for name in wanted if name not in sections]
    if missing:
        raise SystemExit(f"Fixture missing sections: {', '.join(missing)}")

    parts = []
    for name in wanted:
        parts.append(f"## {name}\n" + "\n".join(sections[name]).strip())
    return "\n\n".join(parts)


def build_prompt(fixture_path: Path, golden_path: Path) -> str:
    fixture = read_text(fixture_path)
    golden = read_text(golden_path)
    envelope = parse_behavior_envelope(golden)
    runtime_input = parse_fixture_runtime_input(fixture)
    keys = "\n".join(f"- {key}" for key in envelope)

    return f"""You are executing a BA-kit runtime parity fixture.

Do not modify files. Use the repository contract only as reference:
- core/contract.yaml
- core/contract-behavior.md
- core/workflows/*.md
- skills/ba-start/SKILL.md and its step files when needed

Return only one JSON object. Do not wrap it in markdown. Do not include commentary.
All values must be strings. Include exactly these keys:
{keys}

Derive the normalized behavior envelope from this fixture input. Do not use the fixture's Expected Outcome section.

{runtime_input}
"""


def extract_json_object(text: str) -> dict[str, object]:
    stripped = text.strip()
    if stripped.startswith("{"):
        try:
            value = json.loads(stripped)
            if isinstance(value, dict):
                return value
        except json.JSONDecodeError:
            pass

    decoder = json.JSONDecoder()
    for index, char in enumerate(text):
        if char != "{":
            continue
        try:
            value, _ = decoder.raw_decode(text[index:])
        except json.JSONDecodeError:
            continue
        if isinstance(value, dict):
            return value

    raise SystemExit("Runtime output did not contain a JSON object")


def compare(golden_path: Path, actual_path: Path, runtime: str, fixture_id: str) -> int:
    expected = parse_behavior_envelope(read_text(golden_path))
    actual_raw = read_text(actual_path)
    actual_obj = extract_json_object(actual_raw)
    actual = {key: str(value).strip() for key, value in actual_obj.items()}

    diffs: list[str] = []
    for key, expected_value in expected.items():
        actual_value = actual.get(key)
        if actual_value is None:
            diffs.append(f"- missing key `{key}`")
            continue
        if actual_value != expected_value:
            diffs.append(f"- `{key}` expected `{expected_value}` but got `{actual_value}`")

    if diffs:
        print(f"  {runtime}: FAIL ({fixture_id})")
        for diff in diffs:
            print(f"    {diff}")
        return 1

    print(f"  {runtime}: PASS")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    prompt_parser = subparsers.add_parser("prompt")
    prompt_parser.add_argument("--fixture", required=True, type=Path)
    prompt_parser.add_argument("--golden", required=True, type=Path)

    compare_parser = subparsers.add_parser("compare")
    compare_parser.add_argument("--golden", required=True, type=Path)
    compare_parser.add_argument("--actual", required=True, type=Path)
    compare_parser.add_argument("--runtime", required=True)
    compare_parser.add_argument("--fixture-id", required=True)

    args = parser.parse_args()
    if args.command == "prompt":
        print(build_prompt(args.fixture, args.golden))
        return 0
    if args.command == "compare":
        return compare(args.golden, args.actual, args.runtime, args.fixture_id)
    raise AssertionError(args.command)


if __name__ == "__main__":
    sys.exit(main())
