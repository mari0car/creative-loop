#!/bin/bash
# Creative Loop — Install Script
#
# WHAT THIS DOES:
#   1. Copies all canonical files from this repo into ~/.claude/skills/creative/
#      — SKILL.md, all builtin personas, and the default config.
#   2. If run from a project directory (not this repo), also resets that
#      project's .creative-loop/personas/builtin/ from the global install.
#
# This means running install.sh at any time reverts your local environment
# to the repo's current state. After a git pull, run it to pick up changes.
# From another project, run it to reset that project's builtins.
#
# GLOBAL INSTALL LOCATION:
#   ~/.claude/skills/creative/
#   ├── SKILL.md                 ← the /creative slash command
#   ├── personas/builtin/        ← canonical persona definitions
#   └── config-default.json      ← default .creative-loop/config.json
#
# USAGE:
#   bash install.sh
#     Install/update from this repo. If run from a project with .creative-loop/,
#     also resets that project's builtin personas.
#
#   cd /other/project && bash /path/to/creative-loop/install.sh
#     Resets /other/project/.creative-loop/personas/builtin/ to canonical versions.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$HOME/.claude/skills/creative"
CWD="$(pwd)"

# ── Validate repo ─────────────────────────────────────────────────────────────

if [ ! -f "$REPO_DIR/SKILL.md" ]; then
  echo "Error: SKILL.md not found at $REPO_DIR/SKILL.md"
  exit 1
fi

if [ ! -d "$REPO_DIR/.creative-loop/personas/builtin" ]; then
  echo "Error: $REPO_DIR/.creative-loop/personas/builtin not found"
  exit 1
fi

# ── Step 1: Install globally ──────────────────────────────────────────────────

mkdir -p "$SKILL_DIR/personas/builtin"

cp "$REPO_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
echo "Installed: $SKILL_DIR/SKILL.md"

cp "$REPO_DIR/.creative-loop/personas/builtin/"*.md "$SKILL_DIR/personas/builtin/"
echo "Installed: $SKILL_DIR/personas/builtin/ ($(ls "$SKILL_DIR/personas/builtin/" | wc -l | tr -d ' ') personas)"

cp "$REPO_DIR/.creative-loop/config.json" "$SKILL_DIR/config-default.json"
echo "Installed: $SKILL_DIR/config-default.json"

# ── Step 2: Reset project .creative-loop/ if running from another project ─────

if [ "$CWD" != "$REPO_DIR" ] && [ -d "$CWD/.creative-loop/personas/builtin" ]; then
  echo ""
  echo "Found .creative-loop/ in current directory: $CWD"
  cp "$SKILL_DIR/personas/builtin/"*.md "$CWD/.creative-loop/personas/builtin/"
  echo "Reset: $CWD/.creative-loop/personas/builtin/ (reverted to canonical versions)"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "/creative is now available in all Claude Code sessions on this machine."
echo ""
echo "Usage in this repo (already initialized — .creative-loop/ is in the repo):"
echo "  /creative <any problem>"
echo "  /creative optimize"
echo "  /creative sync        ← pull improvements back into this repo, then git push"
echo ""
echo "Usage in a different project:"
echo "  1. Open the project in Claude Code"
echo "  2. /creative init     ← creates .creative-loop/ from the installed templates"
echo "  3. /creative <your problem>"
echo ""
echo "To reset any project's builtin personas to this repo's versions:"
echo "  cd /path/to/project && bash $REPO_DIR/install.sh"
echo ""
echo "To pick up changes after git pull:"
echo "  bash install.sh"
