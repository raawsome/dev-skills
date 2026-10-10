#!/bin/sh
# Install these skills into opencode and/or Claude Code.
# Usage: ./install.sh [--opencode-only] [--claude-only] [--symlink] [--list]
# Default: copy every <skill>/ with a SKILL.md into both locations.
set -eu
SRC="$(cd "$(dirname "$0")" && pwd)"
OPENCODE_DIR="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}"
CLAUDE_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
MODE="copy"
TARGETS="both"
for a in "$@"; do
  case "$a" in
    --opencode-only) TARGETS="opencode" ;;
    --claude-only) TARGETS="claude" ;;
    --symlink) MODE="symlink" ;;
    --list) ls -1 "$SRC" | while read -r d; do [ -f "$SRC/$d/SKILL.md" ] && echo "$d"; done; exit 0 ;;
    *) echo "unknown flag: $a" >&2; exit 1 ;;
  esac
done
install_one() {
  dest_root="$1"; name="$2"
  mkdir -p "$dest_root"
  if [ "$MODE" = "symlink" ]; then
    ln -sfn "$SRC/$name" "$dest_root/$name"
  else
    rm -rf "$dest_root/$name"
    cp -R "$SRC/$name" "$dest_root/$name"
  fi
  echo "$MODE -> $dest_root/$name"
}
for d in "$SRC"/*/; do
  name="$(basename "$d")"
  [ -f "$SRC/$name/SKILL.md" ] || continue
  [ "$TARGETS" = "both" ] || [ "$TARGETS" = "opencode" ] && install_one "$OPENCODE_DIR" "$name"
  [ "$TARGETS" = "both" ] || [ "$TARGETS" = "claude" ] && install_one "$CLAUDE_DIR" "$name"
done
