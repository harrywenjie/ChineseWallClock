"""Check local Markdown links/anchors and report page capacity.

Usage (from any directory):

    python scripts/check_docs.py

Exit code 0 = no broken local links; 1 = broken links. External URLs are not
fetched. `temp/` and the preserved raw-log directory are skipped because their
contents are not part of the tracked documentation graph.
"""

from pathlib import Path
import re
import sys
import urllib.parse

ROOT = Path(__file__).resolve().parent.parent
SKIP_DIRS = {".git", "temp", "docs/evidence/2026-07-23-fork-build"}

LINK_RE = re.compile(r"!?\[[^\]]*\]\((<[^>]+>|[^)]+)\)")
HTML_ID_RE = re.compile(r"<a\s+[^>]*id=\"([^\"]+)\"[^>]*>")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*)$", re.M)


def github_slug(text: str) -> str:
    text = re.sub(r"<[^>]+>", "", text)
    text = text.strip().lower()
    text = re.sub(r"[^\w\- ]", "", text, flags=re.UNICODE)
    text = text.replace(" ", "-")
    return text


def anchors_for(path: Path) -> set[str]:
    text = path.read_text(encoding="utf-8", errors="replace")
    anchors = set(HTML_ID_RE.findall(text))
    for _, heading in HEADING_RE.findall(text):
        anchors.add(github_slug(heading))
    return anchors


def iter_markdown():
    for p in ROOT.rglob("*.md"):
        rel = p.relative_to(ROOT).as_posix()
        if any(rel == d or rel.startswith(d + "/") for d in SKIP_DIRS):
            continue
        yield p


def clean_target(raw: str) -> str:
    raw = raw.strip()
    if raw.startswith("<") and raw.endswith(">"):
        raw = raw[1:-1]
    # Strip an optional Markdown title.
    if " " in raw and not raw.startswith("http"):
        raw = raw.split(" ", 1)[0]
    return raw


def main() -> int:
    errors = []
    checked = 0
    for md in iter_markdown():
        text = md.read_text(encoding="utf-8", errors="replace")
        # Remove fenced code blocks so examples do not count as links.
        text = re.sub(r"```.*?```", "", text, flags=re.S)
        for match in LINK_RE.finditer(text):
            target = clean_target(match.group(1))
            if not target or target.startswith(("http://", "https://", "mailto:", "tel:", "ftp:")):
                continue
            if target.startswith("#"):
                path_part, anchor = "", target[1:]
            else:
                path_part, _, anchor = target.partition("#")
            path_part = urllib.parse.unquote(path_part)
            if path_part:
                resolved = (md.parent / path_part).resolve()
                try:
                    resolved.relative_to(ROOT)
                except ValueError:
                    errors.append(f"{md.relative_to(ROOT)}: escapes repo: {target}")
                    continue
                checked += 1
                if not resolved.exists():
                    errors.append(f"{md.relative_to(ROOT)}: missing path: {target}")
                    continue
            else:
                resolved = md.resolve()
                checked += 1
            if anchor:
                target_md = resolved if resolved.is_file() and resolved.suffix == ".md" else None
                if target_md is None:
                    errors.append(f"{md.relative_to(ROOT)}: anchor on non-markdown target: {target}")
                    continue
                if anchor not in anchors_for(target_md):
                    errors.append(f"{md.relative_to(ROOT)}: missing anchor: {target}")

    if errors:
        print("BROKEN LINKS/ANCHORS")
        for e in errors:
            print(" -", e)
        return 1

    print(f"OK: {checked} local links checked")

    capacity = [
        "docs/DEVELOPMENT.md",
        "docs/ENGINEERING_DESIGN.md",
        "docs/VALIDATION.md",
        "docs/modules/firmware/README.md",
        "docs/modules/firmware/configuration.md",
        "docs/modules/firmware/display.md",
        "docs/modules/firmware/time.md",
        "docs/modules/firmware/logging.md",
        "docs/modules/hardware/README.md",
        "docs/modules/build-and-flash/README.md",
        "docs/modules/build-and-flash/toolchain-setup.md",
        "docs/modules/deployment/README.md",
        "docs/modules/factory-firmware/README.md",
        "docs/history/README.md",
        "docs/history/fork-operations.md",
    ]
    print("CAPACITY (LF characters)")
    for rel in capacity:
        p = ROOT / rel
        n = len(p.read_text(encoding="utf-8").replace("\r\n", "\n"))
        print(f"{n:6d}  {rel}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
