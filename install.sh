#!/bin/sh
# Install these skills into opencode and/or Claude Code.
# Usage: ./install.sh [--opencode-only] [--claude-only] [--symlink] [--list] [--dry-run] [--diff] [--backup] [--prune]
# Default: copy every <skill>/ with a SKILL.md into both locations.
set -eu
SRC="$(cd "$(dirname "$0")" && pwd)"
OPENCODE_DIR="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}"
CLAUDE_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
MODE="copy"
TARGETS="both"
DRY_RUN=0
SHOW_DIFF=0
DO_BACKUP=0
PRUNE=0
for a in "$@"; do
  case "$a" in
    --opencode-only) TARGETS="opencode" ;;
    --claude-only) TARGETS="claude" ;;
    --symlink) MODE="symlink" ;;
    --dry-run) DRY_RUN=1 ;;
    --diff) SHOW_DIFF=1 ;;
    --backup) DO_BACKUP=1 ;;
    --prune) PRUNE=1 ;;
    --list) ls -1 "$SRC" | while read -r d; do [ -f "$SRC/$d/SKILL.md" ] && echo "$d"; done; exit 0 ;;
    *) echo "unknown flag: $a" >&2; exit 1 ;;
  esac
done
install_one() {
  dest_root="$1"; name="$2"
  if [ "$SHOW_DIFF" = "1" ] && [ -d "$dest_root/$name" ] && [ "$MODE" = "copy" ]; then
    diff -rq "$dest_root/$name" "$SRC/$name" || true
  fi
  if [ "$DRY_RUN" = "1" ]; then
    echo "dry-run $MODE -> $dest_root/$name"
    return
  fi
  mkdir -p "$dest_root"
  if [ "$MODE" = "symlink" ]; then
    ln -sfn "$SRC/$name" "$dest_root/$name"
  else
    if [ "$DO_BACKUP" = "1" ] && [ -d "$dest_root/$name" ]; then
      cp -R "$dest_root/$name" "$dest_root/$name.bak.$(date +%s)"
    fi
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
prune_one() {
  dest_root="$1"
  [ -d "$dest_root" ] || return 0
  for t in "$dest_root"/*/; do
    [ -d "$t" ] || continue
    tname="$(basename "$t")"
    case "$tname" in *.bak.*) continue ;; esac
    [ -f "$SRC/$tname/SKILL.md" ] && continue
    if [ "$DRY_RUN" = "1" ]; then
      echo "dry-run prune -> $dest_root/$tname"
      continue
    fi
    rm -rf "$dest_root/$tname"
    echo "prune -> $dest_root/$tname"
  done
}
if [ "$PRUNE" = "1" ]; then
  [ "$TARGETS" = "both" ] || [ "$TARGETS" = "opencode" ] && prune_one "$OPENCODE_DIR"
  [ "$TARGETS" = "both" ] || [ "$TARGETS" = "claude" ] && prune_one "$CLAUDE_DIR"
fi
