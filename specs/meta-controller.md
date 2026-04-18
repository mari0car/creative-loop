# Meta-Controller Specification

## 1 Purpose

The Meta-Controller is the brain of the creative loop. It runs in the main Claude Code conversation thread and orchestrates all phases: deciding which personas to activate, when to switch from divergence to convergence, how to select and combine ideas, and when to stop iterating. It is the only component that has full visibility into the loop state.

## 2 Responsibilities

1. **Problem Framing** — Transform user request into a structured creative brief
2. **Persona Selection** — Choose which generator personas to activate
3. **Phase Orchestration** — Drive the loop through its phases in order
4. **Selection Logic** — Pick which ideas advance past evaluation
5. **Combination Detection** — Identify ideas that are stronger together
6. **Iteration Control** — Decide whether to loop again or present results
7. **Context Management** — Summarize and compress information between phases to stay within context limits
8. **Human Interface** — Present results and incorporate feedback

## 3 Creative Brief Generation

The meta-controller's first job is to convert a user request into a structured creative brief:

```json
{
  "problem_statement": "Clear description of what needs to be solved",
  "constraints": ["Must work with existing API", "No new dependencies"],
  "success_criteria": ["Reduces latency by >50%", "Backwards compatible"],
  "domain": "backend-performance",
  "exploration_budget": "medium",
  "context": {
    "relevant_files": ["src/api/handler.ts", "src/cache/layer.ts"],
    "recent_changes": "Migrated from Redis to in-memory cache last week",
    "known_attempts": ["Tried connection pooling, helped 10% but not enough"]
  }
}
```

The brief is stored in `.creative-loop/sessions/{timestamp}/brief.md` for reference.

## 4 Persona Selection Algorithm

```
function selectPersonas(brief, memory, config):
  # Start with mandatory personas for this problem domain
  required = lookupDomainPersonas(brief.domain)

  # Add personas that performed well for similar problems
  effective = memory.getEffectivePersonas(brief.domain, brief.problem_type)

  # Always include at least one "wild card" persona for diversity
  wildcards = selectRandom(allPersonas - required - effective, count=1)

  # Combine and cap at max_parallel_agents
  selected = (required + effective + wildcards)[:config.default_persona_count]

  return selected
```

## 5 Selection Policy

After evaluation, the meta-controller selects ideas to advance. The policy balances exploitation (high-scoring safe bets) with exploration (high-novelty long shots).

### 5.1 Default Selection: Top-K + Wild Card
- Select the top K ideas by composite score (K = 3 by default)
- Always include 1 "wild card" — the highest-novelty idea not already selected, even if its composite score is lower
- Include any evaluator-suggested combinations

### 5.2 Selection Modes

| Mode | Behavior | When to Use |
|---|---|---|
| **Exploit** | Top-K by composite, no wild card | Late iterations, well-understood problem |
| **Explore** | Top-K by novelty, ignore feasibility | Early iterations, open-ended problems |
| **Balanced** | Top-K by composite + 1 wild card | Default mode, most problems |
| **Consensus** | Only ideas where all evaluators agree (>0.6) | High-stakes decisions |

The meta-controller can switch modes between iterations based on how the loop is progressing.

## 6 Iteration Control

### 6.1 When to Iterate Again
- The top ideas score below the `quality_threshold` (default 0.7)
- The user asks for more exploration
- Experimental results invalidated assumptions — need to regenerate with new constraints
- High evaluator disagreement suggests the problem isn't well-understood yet

### 6.2 When to Stop
- Top ideas score above `quality_threshold` and the user is satisfied
- Maximum iterations reached (default: 3)
- Diminishing returns — current iteration's best ideas are not meaningfully better than the last
- User says "enough, let's go with this"

### 6.3 Iteration Evolution
Each iteration isn't just "try again." The meta-controller evolves the loop:
- **Narrow the brief**: Remove explored dead ends, tighten constraints
- **Shift personas**: Swap out underperforming personas, add specialists
- **Inject learnings**: Feed evaluation feedback and experimental results back into generators
- **Change mode**: Switch from Explore to Balanced to Exploit as the solution space clarifies

## 7 Context Management

Creative loops generate a lot of data. The meta-controller manages context budget:

1. **Summarize between phases**: Raw generator output (could be 15+ ideas) gets summarized to key points before passing to evaluators
2. **Compress between iterations**: Only top ideas and key learnings carry forward; rejected ideas are archived to disk
3. **Selective memory retrieval**: Only pull relevant creative memory, not the entire history
4. **Progressive detail**: Early phases work with summaries; later phases (refine, experiment) work with full detail on selected ideas only

## 8 State Machine

```
IDLE → BRIEFING → GENERATING → EVALUATING → SELECTING → REFINING → EXPERIMENTING → PRESENTING → IDLE
                      ↑                                                    │
                      └────────────── (iterate) ──────────────────────────┘
```

State transitions are logged to `.creative-loop/sessions/{timestamp}/state_log.json`.

## 9 Configuration

```json
{
  "meta_controller": {
    "default_selection_mode": "balanced",
    "top_k": 3,
    "include_wild_card": true,
    "quality_threshold": 0.7,
    "max_iterations": 3,
    "exploration_budget": {
      "low": {"personas": 3, "iterations": 1},
      "medium": {"personas": 5, "iterations": 2},
      "high": {"personas": 7, "iterations": 3}
    }
  }
}
```
