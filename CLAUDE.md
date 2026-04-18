# Creative Loop — Claude Code Instructions

## About This Project
This project implements the Creative Loop system for Claude Code. It makes Claude Code genuinely creative through structured divergent thinking using sub-agents, file-based memory, and self-optimizing prompts.

## Project Structure
- `SKILL.md` — The skill file; `install.sh` copies this to `~/.claude/skills/creative/SKILL.md`
- `specs/` — Design specifications for all components
- `.creative-loop/` — The active creative loop instance for this project
- `install.sh` — Install script for global setup

## Installation
To install `/creative` globally on a new machine:
```bash
bash install.sh
```
Or manually:
```bash
mkdir -p ~/.claude/skills/creative
cp SKILL.md ~/.claude/skills/creative/SKILL.md
cp .creative-loop/personas/builtin/*.md ~/.claude/skills/creative/personas/builtin/
cp .creative-loop/config.json ~/.claude/skills/creative/config-default.json
```

## Using the Creative Loop
This project is itself a great test case for the creative loop. Try:
```
/creative How should we improve the persona selection algorithm?
/creative What's the best way to implement evaluation score aggregation?
/creative optimize
```

## Key Files
- `SKILL.md` — Master skill file; the loop's entire behavior is defined here
- `.creative-loop/config.json` — Configuration for this project's loop
- `.creative-loop/personas/builtin/` — The 10 built-in creative personas
- `.creative-loop/patterns/` — Creative memory (grows with use)

## Self-Improvement
The system can improve its own prompts. Run `/creative optimize` after a few sessions to let Claude Code propose and apply improvements to persona definitions and phase instructions.

When improving this project specifically, edit `SKILL.md` — it's the canonical source. After improvements, re-run `bash install.sh` to update the global skill.
