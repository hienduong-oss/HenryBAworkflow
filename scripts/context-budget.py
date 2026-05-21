#!/usr/bin/env python3
"""Estimate BA-kit runtime read context size for a command."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

COMMAND_SCOPES = {
    "intake": ["source_summary", "source_chunk_index", "project_memory"],
    "options": ["intake", "plan", "source_chunk_index"],
    "backbone": ["intake", "plan", "options_index", "options_comparison"],
    "frd": ["backbone_index", "plan", "project_memory"],
    "stories": ["backbone_index", "plan", "frd", "project_memory"],
    "srs": ["backbone_index", "stories_index", "frd", "project_memory"],
    "impact": ["intake", "backbone_index", "backbone", "stories_index", "srs_index", "project_memory"],
    "wireframes": ["wireframe_input", "design_doc", "srs_index", "project_memory"],
    "package": ["backbone_index", "stories_index", "srs_index", "memory_index", "wireframe_state"],
    "status": ["project_home", "project_memory", "memory_index"],
}


def render_path(template: str, *, slug: str, date: str, module: str) -> str:
    return (
        template.replace("{slug}", slug)
        .replace("{date}", date)
        .replace("{module_slug}", module)
        .replace("{group}", "*")
        .replace("{option}", "*")
    )


def size_for(root: Path, rel_pattern: str) -> int:
    if "*" in rel_pattern:
        return sum(path.stat().st_size for path in root.glob(rel_pattern) if path.is_file())
    path = root / rel_pattern
    return path.stat().st_size if path.is_file() else 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", default=".")
    parser.add_argument("--command", choices=sorted(COMMAND_SCOPES), default="status")
    parser.add_argument("--slug", default="{slug}")
    parser.add_argument("--date", default="{date}")
    parser.add_argument("--module", default="{module_slug}")
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    contract = json.loads((repo / "core" / "contract.yaml").read_text(encoding="utf-8"))
    paths = contract["paths"]
    profiles = contract.get("artifact_profiles", {})

    rows = []
    total = 0
    for key in COMMAND_SCOPES[args.command]:
        template = paths.get(key)
        if not template:
            continue
        rendered = render_path(template, slug=args.slug, date=args.date, module=args.module)
        size = 0 if "{" in rendered else size_for(repo, rendered)
        total += size
        rows.append((key, profiles.get(key, "unclassified"), rendered, size))

    print(f"Context budget for command: {args.command}")
    print("")
    print("| Path Key | Profile | Resolved Path | Bytes |")
    print("| --- | --- | --- | --- |")
    for key, profile, rendered, size in rows:
        print(f"| {key} | {profile} | `{rendered}` | {size} |")
    print(f"| TOTAL | | | {total} |")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
