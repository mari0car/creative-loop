# Architecture Specification

## 1 System Overview

The Creative Loop is implemented as an **orchestration layer** within a Claude Code session. It is not a separate service or daemon — it runs inside the normal conversation flow, using Claude Code's existing tools (sub-agents, file I/O, Bash) to create a structured creative thinking process.

```
┌─────────────────────────────────────────────────────────┐
│                   Claude Code Session                    │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │            Meta-Controller (Main Thread)           │  │
│  │                                                   │  │
│  │  Orchestrates phases, manages state, makes        │  │
│  │  selection decisions, interfaces with human        │  │
│  └──────────┬────────────────────────┬───────────────┘  │
│             │                        │                   │
│     ┌───────▼───────┐       ┌───────▼───────┐          │
│     │  Sub-Agent     │       │  Sub-Agent     │          │
│     │  Pool          │       │  Pool          │          │
│     │  (Generators)  │       │  (Evaluators)  │          │
│     └───────┬───────┘       └───────┬───────┘          │
│             │                        │                   │
│     ┌───────▼────────────────────────▼───────┐          │
│     │         Creative Memory (Files)         │          │
│     │  .creative-loop/                        │          │
│     │  ├── sessions/       (session logs)     │          │
│     │  ├── patterns/       (learned patterns) │          │
│     │  ├── personas/       (persona configs)  │          │
│     │  └── artifacts/      (generated ideas)  │          │
│     └────────────────────────────────────────┘          │
│                                                         │
│     ┌────────────────────────────────────────┐          │
│     │      Experiment Sandbox (Bash/FS)       │          │
│     │  Prototypes, tests, code execution      │          │
│     └────────────────────────────────────────┘          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 2 Data Flow

### 2.1 Single Loop Iteration

```
1. TRIGGER
   Input: User request + project context
   Output: Creative brief (structured problem statement)

2. DIVERGE
   Input: Creative brief + persona configs + creative memory
   Process: Launch N sub-agents in parallel, each with a different persona
   Output: Array of candidate ideas (JSON)

3. EVALUATE
   Input: Candidate ideas
   Process: Launch evaluator sub-agents to score each idea
   Output: Scored and ranked ideas (JSON)

4. SELECT
   Input: Scored ideas + selection policy
   Process: Meta-controller applies selection criteria
   Output: Shortlisted ideas (top K) + combination suggestions

5. REFINE
   Input: Shortlisted ideas + refinement prompts
   Process: Sub-agents deepen, combine, and develop selected ideas
   Output: Refined proposals with implementation sketches

6. EXPERIMENT
   Input: Refined proposals
   Process: Build minimal prototypes, run tests, validate assumptions
   Output: Experimental results + feasibility assessments

7. CAPTURE
   Input: All artifacts from this iteration
   Process: Store outcomes, update pattern library, log session
   Output: Updated creative memory

8. PRESENT
   Input: Results summary
   Process: Format findings for human review
   Output: Structured presentation to user
```

### 2.2 Data Formats

All inter-component data uses JSON for structured exchange and Markdown for human-readable summaries.

**Candidate Idea:**
```json
{
  "id": "idea_001",
  "title": "Short descriptive title",
  "description": "What the idea is",
  "mechanism": "How it would work",
  "persona_source": "devil_advocate",
  "novelty_claim": "What makes this different from obvious approaches",
  "risks": ["risk1", "risk2"],
  "connections": ["related_idea_id"],
  "confidence": 0.7
}
```

**Evaluation Score:**
```json
{
  "idea_id": "idea_001",
  "scores": {
    "novelty": {"value": 0.8, "rationale": "..."},
    "feasibility": {"value": 0.6, "rationale": "..."},
    "relevance": {"value": 0.9, "rationale": "..."},
    "risk": {"value": 0.3, "rationale": "..."},
    "elegance": {"value": 0.7, "rationale": "..."}
  },
  "composite": 0.72,
  "evaluator_notes": "..."
}
```

## 3 Component Interaction Patterns

### 3.1 Parallel Fan-Out / Fan-In
Generators and evaluators use a fan-out/fan-in pattern:
- Meta-controller launches N sub-agents simultaneously
- Each sub-agent returns its result independently
- Meta-controller collects and aggregates all results

### 3.2 Sequential Pipeline
The overall loop phases execute sequentially: each phase depends on the previous phase's output.

### 3.3 Memory Read/Write
- **Read**: At the start of each iteration, relevant creative memory is loaded and injected into prompts
- **Write**: At the end of each iteration, outcomes are persisted to the file system

## 4 File System Layout

```
.creative-loop/
├── config.json              # Loop configuration (personas, policies, thresholds)
├── sessions/
│   └── {timestamp}/
│       ├── brief.md         # The creative brief for this session
│       ├── candidates.json  # Generated ideas
│       ├── evaluations.json # Scores and rankings
│       ├── selected.json    # Shortlisted ideas
│       ├── refined.json     # Developed proposals
│       ├── experiments/     # Prototype code and test results
│       └── outcome.md       # Final summary and decisions
├── patterns/
│   ├── successful.json      # Patterns that led to good outcomes
│   ├── failed.json          # Approaches that didn't work (and why)
│   └── combinations.json    # Effective idea combinations
├── personas/
│   ├── builtin/             # Default persona definitions
│   └── custom/              # Project-specific personas
└── artifacts/
    └── {idea_id}/           # Persistent artifacts for ideas that were pursued
```

## 5 Integration Points

### 5.1 Activation
- Slash command (e.g., `/creative`) triggers the loop
- CLAUDE.md configuration for automatic activation on certain task types
- Hooks can trigger creative mode based on patterns in user input

### 5.2 Project Context
The creative loop reads:
- Project files (code, docs, configs)
- Git history (recent changes, patterns)
- CLAUDE.md (project conventions, constraints)
- Existing creative memory from prior sessions

### 5.3 Output
Results flow back into the normal Claude Code conversation:
- Ranked proposals presented to the user
- Selected ideas become actionable implementation plans
- Experimental code can be committed or discarded

## 6 Scaling Considerations

- **Sub-agent count**: Default 4-6 generators, 2-3 evaluators. Configurable per task complexity.
- **Iteration depth**: Most tasks need 1-2 iterations. Complex problems may need 3-5.
- **Memory growth**: Sessions are archived after completion. Pattern library is pruned periodically to keep only high-value entries.
- **Context budget**: Each sub-agent gets a focused prompt. The meta-controller manages the overall context budget, summarizing rather than passing raw data between phases.
