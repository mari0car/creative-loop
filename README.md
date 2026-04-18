# Creative Loop for Claude Code

Human creativity is a loop. You generate ideas, evaluate them, get stuck, throw out what doesn't work, and come back at the problem from a different angle — over and over until something clicks. It's iterative, it's messy, and it's irreducibly sequential: humans can't think in parallel.

AI agents have the opposite problem. They don't get stuck — they go straight to an answer. Given a problem, an agent will pick the first plausible solution and execute it. That's efficient, but it's not creative. It skips the loop entirely.

This project puts the loop back in. Instead of one mind cycling through perspectives one at a time, it fans out to multiple parallel agents — each embodying a different thinking persona — then converges: evaluating, selecting, refining, experimenting. The diverge-first structure mimics how human creativity actually works, and the parallelism means it runs as fast as the agents do, not as fast as a single human can think.

The result is a `/creative` slash command for Claude Code that explores the space before committing to a direction.

---

## How It Works

Creativity isn't a temperature parameter — it's a thinking structure. The loop applies that structure:

```
DIVERGE → EVALUATE → SELECT → REFINE → EXPERIMENT → CAPTURE → (repeat)
```

1. **Diverge** — 5 parallel sub-agents each explore the problem through a different creative persona (Devil's Advocate, First Principles, Cross-Domain Analogist, etc.)
2. **Evaluate** — 2 independent evaluator agents score all ideas on novelty, feasibility, relevance, risk, and elegance
3. **Select** — a meta-controller picks the top candidates plus a "wild card" (highest-novelty idea)
4. **Refine** — targeted sub-agents deepen each selected idea into an actionable proposal
5. **Experiment** — code prototypes and tests validate assumptions before committing
6. **Capture** — outcomes are stored in creative memory; the system improves with each session

The human stays in the loop at two gates: confirming the creative brief, and approving the selected ideas before refinement begins.

---

## Installation

```bash
git clone https://github.com/your-username/creative-loop
cd creative-loop
bash install.sh
```

This copies `SKILL.md` and all builtin personas to `~/.claude/skills/creative/`, making `/creative` available in every Claude Code session on the machine.

---

## Usage

### Initialize a project

```
/creative init
```

Creates `.creative-loop/` in the current project with config, personas, and memory files.

### Run the full loop

```
/creative How should we design the pagination API?
/creative What's the best approach to reduce cold-start latency?
/creative We need a better way to handle errors across service boundaries
```

### Quick mode (3 personas, no experiments, faster)

```
/creative quick What should we name this module?
```

### Evaluate a specific idea

```
/creative evaluate Use event sourcing for the audit log
```

### Run experiments on an idea

```
/creative experiment Replace the job queue with a recursive CTE
```

### Improve the loop itself

```
/creative optimize
```

Analyzes recent sessions and proposes improvements to persona prompts and phase instructions.

### Sync improvements back to this repo

```
/creative sync
```

Pulls self-optimized improvements (persona files, `SKILL.md`, prompt evolution log) into the repo so they can be committed and shared.

---

## The 10 Built-in Personas

| Persona | Approach |
|---|---|
| **First Principles** | Strip away all structure; rebuild from atomic requirements |
| **Devil's Advocate** | Find the edge case, scale failure, and uncomfortable assumption |
| **Cross-Domain Analogist** | Find where this problem is already solved in another field |
| **Naive Questioner** | Ask "why?" at every level until reaching bedrock |
| **Constraint Inverter** | Remove the hardest constraint; see what becomes possible |
| **User Empathist** | Walk through the real user journey step by step |
| **Minimalist** | What is the simplest thing that could possibly work? |
| **Futurist** | What will the obvious solution look like in 3–5 years? |
| **Integrator** | What existing tools can be combined with minimal new code? |
| **Provocateur** | Propose the solution that would get you laughed out of a code review — then find its insight |

Personas are domain-matched to the problem. Persona effectiveness is tracked per domain and low-performers are deprioritized automatically.

---

## Configuration

`.creative-loop/config.json` controls everything:

```json
{
  "generator": {
    "default_persona_count": 5,
    "ideas_per_persona": 3,
    "include_combination_round": true
  },
  "evaluator": {
    "evaluator_count": 2,
    "weights": {
      "novelty": 0.25,
      "feasibility": 0.25,
      "relevance": 0.25,
      "risk": 0.15,
      "elegance": 0.10
    }
  },
  "meta_controller": {
    "default_selection_mode": "balanced",
    "top_k": 3,
    "include_wild_card": true
  }
}
```

**Selection modes:**
- `balanced` — top 3 by composite score + 1 wild card (highest novelty)
- `exploit` — top 3 by composite only
- `explore` — top 3 by novelty score
- `consensus` — only ideas both evaluators scored above 0.6

---

## Creative Memory

The loop learns from each session:

- **`successful.json`** — patterns from ideas the user chose to implement
- **`failed.json`** — invalidated approaches with reasons (avoids repeating them)
- **`persona_effectiveness.json`** — which personas produce ideas that make the shortlist, by domain
- **`prompt_evolution.json`** — a log of prompt improvements applied by `/creative optimize`

Memory is per-project and stored in `.creative-loop/patterns/`. It's checked on every run — past failures aren't regenerated, and past successes seed new exploration.

---

## Project Structure

```
creative-loop/
├── SKILL.md                        ← the /creative slash command (canonical source)
├── install.sh                      ← copies skill globally to ~/.claude/skills/creative/
├── .creative-loop/
│   ├── config.json                 ← default config (also serves as project config)
│   ├── personas/
│   │   ├── builtin/                ← 10 built-in personas
│   │   └── custom/                 ← project-specific personas (gitignored template)
│   ├── sessions/                   ← per-session artifacts (brief, ideas, evaluations)
│   ├── patterns/                   ← creative memory (grows with use)
│   └── artifacts/                  ← experiment outputs
└── specs/                          ← component design specifications
```

---

## Adding Custom Personas

Create a markdown file in `.creative-loop/personas/custom/`:

```markdown
---
id: security_auditor
name: Security Auditor
domains: [api-design, backend, infrastructure]
description: Find the vulnerability before an attacker does
---

## Thinking Frame
Every interface is an attack surface. Every input is untrusted. Every assumption is a potential exploit.

## Approach
1. Enumerate the trust boundaries in the proposed design
2. For each boundary, find the data that crosses it and ask: what happens if it's malicious?
3. Find the state that accumulates over time and ask: what happens when it's exhausted?
4. Propose the design that's secure by default, not secure by configuration

## When Most Effective
Any feature involving auth, external input, shared state, or resource allocation.
```

Custom personas are picked up automatically. They take precedence over builtin personas with the same `id`.

---

## Self-Optimization

After a few sessions, `/creative optimize` reads session outcomes and proposes specific improvements:

- **Diversity check** — if ideas from different personas were too similar, persona prompts are strengthened
- **Calibration check** — if evaluator scores didn't predict experiment outcomes, scoring instructions are adjusted
- **Adoption check** — if the user rarely implements proposed ideas, generation prompts are refocused

All changes require approval before being applied. Changes are logged to `prompt_evolution.json`.

To share improvements across machines or with others:

```bash
/creative sync     # pull improvements into the repo
git add SKILL.md .creative-loop/personas/builtin .creative-loop/patterns/prompt_evolution.json
git commit -m "skill: sync improvements"
git push
# --- on another machine ---
git pull
bash install.sh
```

---

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- A Claude account with access to sub-agents (Agent tool)
