# Creative Loop for Claude Code

## 1 Vision

Make Claude Code genuinely creative — not just competent at executing instructions, but capable of divergent thinking, novel idea generation, self-critique, experimentation, and iterative refinement. The system should be activatable in any project whenever creative problem-solving is needed.

## 2 Core Insight

Creativity isn't a model parameter (temperature). It's a **thinking structure**: deliberately generating diverse perspectives, evaluating them critically, combining unexpected elements, testing assumptions, and learning from outcomes. Claude Code already has the primitives to do this — sub-agents for parallel diverse thinking, file memory for learning, Bash for experimentation. What's missing is the **orchestration** that ties them into a creative loop.

## 3 The Creative Loop

```
┌─────────────┐
│   DIVERGE    │  Launch parallel sub-agents with diverse creative personas
│  (Generate)  │  Each explores the problem from a different angle
└──────┬───────┘
       ▼
┌─────────────┐
│  EVALUATE    │  Independent evaluator agents score ideas on
│  (Critique)  │  novelty, feasibility, relevance, risk
└──────┬───────┘
       ▼
┌─────────────┐
│   SELECT     │  Meta-controller picks top candidates
│  (Converge)  │  Identifies promising combinations
└──────┬───────┘
       ▼
┌─────────────┐
│   REFINE     │  Deepen selected ideas with targeted sub-agents
│  (Develop)   │  Combine elements, resolve contradictions
└──────┬───────┘
       ▼
┌─────────────┐
│  EXPERIMENT  │  Build prototypes, run tests, validate
│  (Test)      │  Use Bash/tools to ground ideas in reality
└──────┬───────┘
       ▼
┌─────────────┐
│   CAPTURE    │  Store outcomes, patterns, and insights
│  (Learn)     │  Update creative memory for future cycles
└──────┬───────┘
       ▼
┌─────────────┐
│   HUMAN      │  Present findings, get feedback
│  (Review)    │  Human steers direction for next cycle
└──────┬───────┘
       │
       └──────── Loop back to DIVERGE with new context
```

## 4 Architecture — Mapped to Claude Code Primitives

| Component | Claude Code Primitive | How It Works |
|---|---|---|
| **Generator Agents** | Sub-agents (Agent tool) launched in parallel | Each gets a different creative persona prompt (devil's advocate, domain analogist, naive questioner, etc.) |
| **Evaluator Agents** | Sub-agents with evaluation prompts | Score ideas on defined axes; return structured JSON ratings |
| **Meta-Controller** | Main conversation thread | Orchestrates phases, makes selection decisions, manages the loop |
| **Experiment Runner** | Bash tool + file system | Run code prototypes, tests, simulations, data analysis |
| **Creative Memory** | File-based memory (markdown + JSON) | Store successful patterns, failed approaches, creative insights, persona effectiveness |
| **Human-in-the-Loop** | Natural conversation + AskUserQuestion | Present ranked ideas, get steering input, approval gates |

## 5 What This Is NOT

- **Not fine-tuning** — We don't train models. We structure thinking.
- **Not a vector database** — We use file-based memory with structured metadata. Retrieval is by explicit lookup, not embedding similarity.
- **Not autonomous** — Human stays in the loop for direction and approval.
- **Not a separate product** — This is a mode/capability that activates within normal Claude Code sessions.

## 6 Activation Model

The creative loop activates when a task benefits from creative problem-solving:
- Architecture decisions with many valid approaches
- Novel feature design
- Debugging intractable problems (need fresh perspectives)
- Naming, API design, UX decisions
- Any task where the user explicitly asks for creative exploration

Activation can be:
1. **Explicit** — User invokes a slash command or says "think creatively about this"
2. **Suggested** — Claude Code recognizes a task that would benefit and offers to activate
3. **Configured** — Project CLAUDE.md enables creative mode for certain task types

## 7 Design Principles

1. **Diverge then converge** — Generate broadly before filtering. Resist the urge to jump to the first good idea.
2. **Structured diversity** — Don't just "brainstorm." Use specific persona frames that guarantee different angles of attack.
3. **Grounded experimentation** — Ideas are cheap. Test them. Build quick prototypes. Run the code.
4. **Transparent provenance** — Every idea tracks which persona generated it, how it scored, and why it was selected or rejected.
5. **Cumulative learning** — Creative memory persists across sessions. The system gets better at creative thinking for this specific project over time.
6. **Human sovereignty** — The human decides what's worth pursuing. The system expands the option space; the human narrows it.

## 8 Component Specs

Detailed specifications for each component:

- [specs/architecture.md](architecture.md) — System architecture, data flow, integration points
- [specs/generator.md](generator.md) — Generator agents, personas, prompt templates
- [specs/evaluator.md](evaluator.md) — Evaluation framework, scoring axes, calibration
- [specs/meta-controller.md](meta-controller.md) — Orchestration logic, phase management, selection
- [specs/memory.md](memory.md) — Creative memory structure, storage, retrieval
- [specs/experiment-runner.md](experiment-runner.md) — Prototyping, testing, validation
- [specs/integration.md](integration.md) — Activation, configuration, project integration
- [specs/human-oversight.md](human-oversight.md) — Review gates, feedback loops, governance
