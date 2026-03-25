#!/usr/bin/env python3
"""Convert BA markdown documents to HTML with rendered Mermaid diagrams and embedded images.

Usage:
    python scripts/md-to-html.py plans/reports/frd-260325-project.md
    python scripts/md-to-html.py plans/reports/srs-260325-project.md

Works with any BA-kit document: FRD (Mermaid workflows), SRS (wireframe images + diagrams),
user stories, or any markdown file.

Supports:
    - Mermaid diagrams (rendered client-side via mermaid.js CDN)
    - Inline wireframe images from designs/{slug}/*.png (base64 embedded)
    - Page breaks for PDF printing (browser Print → Save as PDF)
    - Table of contents generation
"""

import argparse
import base64
import re
import sys
from pathlib import Path

# Minimal markdown-to-html without external deps.
# Handles: headings, tables, bold, italic, code blocks, lists, blockquotes, links, images.


def embed_image(img_path: str, base_dir: Path) -> str:
    """Convert image path to base64 data URI."""
    full_path = base_dir / img_path
    if not full_path.exists():
        return f'<p class="missing-image">[Missing image: {img_path}]</p>'
    suffix = full_path.suffix.lower()
    mime = {"png": "image/png", "jpg": "image/jpeg", "jpeg": "image/jpeg",
            "webp": "image/webp"}.get(suffix.lstrip("."), "image/png")
    data = base64.b64encode(full_path.read_bytes()).decode()
    return f'<img src="data:{mime};base64,{data}" alt="{full_path.stem}" class="wireframe">'


def md_to_html(md: str, base_dir: Path) -> str:
    """Convert markdown to HTML with embedded images."""
    lines = md.split("\n")
    html_parts = []
    toc = []
    in_code = False
    in_table = False
    in_list = False
    code_lang = ""
    table_rows = []

    def flush_table():
        nonlocal table_rows, in_table
        if not table_rows:
            return ""
        out = '<table>\n<thead>\n<tr>'
        headers = [c.strip() for c in table_rows[0].strip("|").split("|")]
        for h in headers:
            out += f"<th>{inline(h)}</th>"
        out += "</tr>\n</thead>\n<tbody>\n"
        # Skip separator row (index 1)
        for row in table_rows[2:]:
            out += "<tr>"
            cells = [c.strip() for c in row.strip("|").split("|")]
            for c in cells:
                out += f"<td>{inline(c)}</td>"
            out += "</tr>\n"
        out += "</tbody>\n</table>\n"
        table_rows = []
        in_table = False
        return out

    def flush_list():
        nonlocal in_list
        in_list = False
        return "</ul>\n"

    def inline(text: str) -> str:
        """Process inline markdown: bold, italic, code, links, images."""
        # Images: ![alt](path)
        text = re.sub(
            r"!\[([^\]]*)\]\(([^)]+)\)",
            lambda m: embed_image(m.group(2), base_dir),
            text,
        )
        # Links
        text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', text)
        # Bold
        text = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", text)
        # Italic
        text = re.sub(r"\*(.+?)\*", r"<em>\1</em>", text)
        # Inline code
        text = re.sub(r"`([^`]+)`", r"<code>\1</code>", text)
        return text

    for line in lines:
        # Code blocks
        if line.startswith("```"):
            if in_code:
                html_parts.append("</code></pre>\n")
                in_code = False
            else:
                code_lang = line[3:].strip()
                cls = f' class="language-{code_lang}"' if code_lang else ""
                if code_lang == "mermaid":
                    html_parts.append(f'<pre class="mermaid">')
                else:
                    html_parts.append(f"<pre><code{cls}>")
                in_code = True
            continue
        if in_code:
            if code_lang == "mermaid":
                html_parts.append(line + "\n")
            else:
                from html import escape
                html_parts.append(escape(line) + "\n")
            continue

        # Table detection
        if "|" in line and line.strip().startswith("|"):
            if not in_table:
                if in_list:
                    html_parts.append(flush_list())
                in_table = True
                table_rows = []
            table_rows.append(line)
            continue
        elif in_table:
            html_parts.append(flush_table())

        # List items
        if re.match(r"^[-*]\s", line.strip()):
            if not in_list:
                in_list = True
                html_parts.append("<ul>\n")
            item = re.sub(r"^[-*]\s", "", line.strip())
            html_parts.append(f"<li>{inline(item)}</li>\n")
            continue
        elif in_list and line.strip():
            html_parts.append(flush_list())

        # Empty line
        if not line.strip():
            if in_list:
                html_parts.append(flush_list())
            html_parts.append("\n")
            continue

        # Headings
        m = re.match(r"^(#{1,6})\s+(.+)", line)
        if m:
            level = len(m.group(1))
            text = m.group(2)
            slug = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
            toc.append((level, text, slug))
            # Page break before h1 and h2 (except first)
            if level <= 2 and len(toc) > 1:
                html_parts.append('<div class="page-break"></div>\n')
            html_parts.append(f'<h{level} id="{slug}">{inline(text)}</h{level}>\n')
            continue

        # Blockquote
        if line.startswith(">"):
            text = line.lstrip("> ")
            html_parts.append(f"<blockquote>{inline(text)}</blockquote>\n")
            continue

        # Horizontal rule
        if re.match(r"^[-*_]{3,}$", line.strip()):
            html_parts.append("<hr>\n")
            continue

        # Paragraph
        html_parts.append(f"<p>{inline(line)}</p>\n")

    # Flush remaining
    if in_table:
        html_parts.append(flush_table())
    if in_list:
        html_parts.append(flush_list())

    # Build TOC
    toc_html = '<nav class="toc"><h2>Table of Contents</h2>\n<ul>\n'
    for level, text, slug in toc:
        indent = "  " * (level - 1)
        toc_html += f'{indent}<li class="toc-{level}"><a href="#{slug}">{text}</a></li>\n'
    toc_html += "</ul>\n</nav>\n"

    body = "".join(html_parts)
    return toc_html + body


CSS = """
:root {
    --primary: #1a1a2e;
    --accent: #0f3460;
    --bg: #ffffff;
    --text: #1a1a1a;
    --border: #e0e0e0;
    --code-bg: #f5f5f5;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    line-height: 1.6; color: var(--text); max-width: 900px;
    margin: 0 auto; padding: 40px 20px;
}
h1 { font-size: 2em; color: var(--primary); margin: 1.5em 0 0.5em; border-bottom: 2px solid var(--accent); padding-bottom: 0.3em; }
h2 { font-size: 1.5em; color: var(--accent); margin: 1.2em 0 0.4em; }
h3 { font-size: 1.2em; margin: 1em 0 0.3em; }
h4,h5,h6 { margin: 0.8em 0 0.2em; }
p { margin: 0.5em 0; }
table { border-collapse: collapse; width: 100%; margin: 1em 0; font-size: 0.9em; }
th, td { border: 1px solid var(--border); padding: 8px 12px; text-align: left; }
th { background: var(--accent); color: white; font-weight: 600; }
tr:nth-child(even) { background: #f9f9f9; }
pre { background: var(--code-bg); padding: 16px; border-radius: 6px; overflow-x: auto; margin: 1em 0; }
code { font-family: 'SF Mono', Consolas, monospace; font-size: 0.9em; }
blockquote { border-left: 4px solid var(--accent); padding: 0.5em 1em; margin: 1em 0; background: #f0f4ff; font-style: italic; }
ul { margin: 0.5em 0 0.5em 1.5em; }
li { margin: 0.2em 0; }
img.wireframe { max-width: 100%; border: 1px solid var(--border); border-radius: 8px; margin: 1em 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
.missing-image { color: #d32f2f; font-style: italic; padding: 1em; background: #fff3f3; border: 1px dashed #d32f2f; border-radius: 4px; }
.toc { background: #f8f9fa; border: 1px solid var(--border); border-radius: 8px; padding: 1.5em; margin-bottom: 2em; }
.toc h2 { margin-top: 0; font-size: 1.2em; }
.toc ul { list-style: none; margin: 0; padding: 0; }
.toc li { margin: 0.3em 0; }
.toc .toc-1 { font-weight: 600; }
.toc .toc-2 { padding-left: 1.5em; }
.toc .toc-3 { padding-left: 3em; font-size: 0.9em; }
.toc a { color: var(--accent); text-decoration: none; }
.toc a:hover { text-decoration: underline; }
.page-break { page-break-before: always; }
@media print {
    body { max-width: none; padding: 0; }
    .toc { page-break-after: always; }
    .page-break { page-break-before: always; }
    table { page-break-inside: avoid; }
    img.wireframe { page-break-inside: avoid; max-height: 80vh; }
}
"""


def convert(md_path: Path) -> Path:
    """Convert any BA markdown to HTML with embedded images and Mermaid support."""
    base_dir = md_path.parent.parent.parent  # plans/reports/srs.md → project root
    md = md_path.read_text(encoding="utf-8")

    # Replace .pen references with .png (exported wireframes)
    # Pattern: designs/slug/SCR-xx-name.pen → designs/slug/SCR-xx-name.png
    md = re.sub(
        r"(designs/[^)]+)\.pen",
        r"\1.png",
        md,
    )

    # Convert wireframe file references to embedded images
    # Pattern: `designs/slug/SCR-xx-name.png` or designs/slug/SCR-xx-name.png
    md = re.sub(
        r"`(designs/[^`]+\.png)`",
        r"![\1](\1)",
        md,
    )

    body = md_to_html(md, base_dir)

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{md_path.stem}</title>
<style>{CSS}</style>
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
<script>mermaid.initialize({{startOnLoad:true}});</script>
</head>
<body>
{body}
</body>
</html>"""

    out_path = md_path.with_suffix(".html")
    out_path.write_text(html, encoding="utf-8")
    return out_path


def main():
    parser = argparse.ArgumentParser(description="Convert BA markdown to HTML with Mermaid diagrams and embedded images")
    parser.add_argument("input", help="Path to markdown file (FRD, SRS, or any BA document)")
    args = parser.parse_args()

    md_path = Path(args.input)
    if not md_path.exists():
        print(f"Error: {md_path} not found", file=sys.stderr)
        sys.exit(1)

    out = convert(md_path)
    print(f"Generated: {out}")


if __name__ == "__main__":
    main()
