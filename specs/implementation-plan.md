# Implementation Plan

## Overview

The Creative Loop is implemented as a **Claude Code custom skill** backed by prompt templates, orchestration logic, and file-based storage. No external dependencies. The implementation is phased to deliver value incrementally.

---

## Phase 1: Foundation (Core Loop, Minimal Viable)

**Goal**: Get a working creative loop that can generate diverse ideas and present them. No memory, no experiments — just diverge → evaluate → present.

### 1.1 Project Scaffolding
- Create `.creative-loop/` directory structure
- Write `config.json` with default settings
- Create initialization logic (`/creative init`)

### 1.2 Persona Definitions
- Write the 10 built-in persona prompt templates as markdown files in `.creative-loop/personas/builtin/`
- Each persona file contains: id, name, thinking frame, when to activate
- Test that persona files are readable and parseable

### 1.3 Meta-Controller — Basic Orchestration
- Implement creative brief generation from user input
- Implement persona selection (simple: pick N personas by domain match)
- Implement phase sequencing: brief → generate → evaluate → present
- Write orchestration as a detailed instruction set (the "creative mode prompt") that gets loaded when the loop activates

### 1.4 Generator Implementation
- Build the generator prompt template with persona injection
- Implement parallel sub-agent launch (one per persona)
- Define and validate the candidate idea JSON schema
- Collect and merge results from all generators

### 1.5 Evaluator Implementation
- Build the evaluator prompt template
- Implement evaluation sub-agent launch
- Define scoring axes and composite calculation
- Implement score aggregation (median across evaluators)

### 1.6 Presentation Layer
- Format top-K ideas as readable markdown
- Include scores, rationale, and persona attribution
- Present combination suggestions from evaluators
- Add action prompts (implement / iterate / discard)

### Phase 1 Deliverable
A working `/creative <problem>` command that:
1. Asks the user to confirm the brief
2. Launches 5 generator sub-agents in parallel
3. Launches 2 evaluator sub-agents
4. Presents ranked results with rationale
5. Asks the user what to do next

---

## Phase 2: Depth (Selection, Refinement, Experiments)

**Goal**: Add the middle phases that deepen ideas — selection logic, refinement, and experimental validation.

### 2.1 Selection Logic
- Implement Top-K + Wild Card selection
- Implement selection modes (exploit, explore, balanced, consensus)
- Add evaluator disagreement flagging
- Present selection to user for review before proceeding

### 2.2 Refinement Phase
- Build refinement prompt template (takes selected ideas, asks sub-agents to deepen)
- Implement combination logic (merge complementary ideas)
- Sub-agents produce detailed proposals with implementation sketches

### 2.3 Experiment Runner — Basic
- Implement experiment design template
- Build code prototype execution (write to experiments dir, run via Bash)
- Implement test execution (run project tests)
- Implement static analysis (code reading, dependency tracing)
- Build result reporting format

### 2.4 Iteration Support
- Implement "iterate" flow: feed results back and regenerate
- Implement brief narrowing between iterations
- Implement persona swapping between iterations
- Add iteration counter and max-iterations guard

### Phase 2 Deliverable
Full loop with all phases: generate → evaluate → select → refine → experiment → present. Multiple iterations supported. User can steer between iterations.

---

## Phase 3: Memory (Learning Across Sessions)

**Goal**: Add persistent creative memory so the system gets smarter over time.

### 3.1 Session Logging
- Write all artifacts to `.creative-loop/sessions/{timestamp}/`
- Include brief, candidates, evaluations, selections, refinements, experiments, outcome

### 3.2 Pattern Extraction
- After user selects/implements a proposal, extract successful patterns
- After experiments invalidate ideas, record failed approaches
- Store with domain, tags, confidence, evidence links

### 3.3 Persona Effectiveness Tracking
- Track which personas' ideas pass evaluation per domain
- Update hit rates after each session
- Use effectiveness data in persona selection

### 3.4 Memory Retrieval
- Implement domain + tag matching retrieval
- Inject relevant patterns into generator and evaluator prompts
- Inject relevant failures as "avoid these known-bad approaches"

### 3.5 Memory Maintenance
- Confidence decay/growth based on outcomes
- Pruning of low-confidence patterns
- Session compression after 90 days

### Phase 3 Deliverable
Creative memory that persists across sessions. Generators receive relevant past patterns. Failed approaches are avoided. Persona selection improves over time.

---

## Phase 4: Polish (UX, Configuration, Quick Modes)

**Goal**: Make the system pleasant to use and configurable.

### 4.1 Quick Modes
- `/creative quick <problem>` — Single iteration, 3 personas, no experiments
- `/creative evaluate <idea>` — Evaluate a user-provided idea
- `/creative experiment <idea>` — Test a specific idea

### 4.2 Auto-Activation
- Implement trigger heuristics (detect when creative mode would help)
- Suggest activation with opt-in
- Respect project configuration for auto-triggers

### 4.3 Cost and Time Awareness
- Estimate sub-agent calls before starting
- Allow user to set time/cost budgets
- Support interruption at phase boundaries

### 4.4 Custom Persona Support
- Documentation for creating custom personas
- Validation of persona files
- Hot-loading of new personas without restart

### 4.5 Configuration UI
- `/creative config` — Show/edit configuration
- `/creative status` — Show current loop state
- `/creative history` — Browse past sessions

### Phase 4 Deliverable
Polished UX with quick modes, auto-suggestion, cost awareness, and full configuration support.

---

## Implementation Strategy

### Technology Choices
- **Language**: The creative loop is primarily **prompt engineering** — the "code" is prompt templates and orchestration instructions
- **Data format**: JSON for structured data, Markdown for human-readable content
- **Activation**: Claude Code custom skill (Skill tool) or hook-based trigger
- **Storage**: File system only (`.creative-loop/` directory)

### Key Technical Decisions

1. **Sub-agents, not function calls**: Generators and evaluators run as Claude Code sub-agents (Agent tool). This gives them full Claude capabilities and isolation.

2. **File-based memory, not a database**: All persistence is plain files. This means:
   - No dependencies to install
   - Easy to inspect, edit, and version control
   - Retrieval is by explicit search, not embedding similarity
   - Tradeoff: less sophisticated retrieval, but good enough for project-scoped memory

3. **The meta-controller is the main thread**: No separate orchestration process. The main Claude Code conversation IS the meta-controller. This means:
   - Natural conversation flow with the user
   - No inter-process communication complexity
   - Tradeoff: the meta-controller's logic must fit in the conversation context

4. **Prompt templates, not code**: The creative loop's behavior is defined in prompt templates loaded from files. This means:
   - Easy to iterate and improve without code changes
   - Users can customize by editing text files
   - The "implementation" is primarily writing and refining prompts

### Risk Mitigations

| Risk | Mitigation |
|---|---|
| Sub-agent costs add up | Default to conservative agent counts; show cost estimate; offer quick mode |
| Context window overflow | Aggressive summarization between phases; archive to disk |
| Generated ideas are shallow | Improve persona prompts iteratively; constraint injection for novelty |
| Evaluation scores cluster mid-range | Calibration instructions; full-range examples in evaluator prompts |
| Memory becomes stale | Confidence decay; recency weighting; human curation support |
| Loop takes too long | Time budgets; phase-level interruption; quick modes |

---

## File Inventory (What Gets Built)

```
.creative-loop/
├── config.json                          # Phase 1
├── personas/
│   ├── builtin/
│   │   ├── first-principles.md          # Phase 1
│   │   ├── devils-advocate.md           # Phase 1
│   │   ├── cross-domain-analogist.md    # Phase 1
│   │   ├── naive-questioner.md          # Phase 1
│   │   ├── constraint-inverter.md       # Phase 1
│   │   ├── user-empathist.md            # Phase 1
│   │   ├── minimalist.md               # Phase 1
│   │   ├── futurist.md                  # Phase 1
│   │   ├── integrator.md               # Phase 1
│   │   └── provocateur.md              # Phase 1
│   └── custom/                          # Phase 4
├── prompts/
│   ├── creative-brief.md               # Phase 1
│   ├── generator.md                    # Phase 1
│   ├── evaluator.md                    # Phase 1
│   ├── selector.md                     # Phase 2
│   ├── refiner.md                      # Phase 2
│   └── experimenter.md                 # Phase 2
├── sessions/                            # Phase 3
├── patterns/                            # Phase 3
│   ├── successful.json
│   ├── failed.json
│   ├── combinations.json
│   └── persona_effectiveness.json
└── artifacts/                           # Phase 3

# The orchestration "code" — instructions for Claude Code:
creative-loop.md                         # Phase 1 — Main orchestration instructions
                                         # (loaded as system instructions when creative mode activates)
```

---

## Success Criteria

**Phase 1**: The loop produces ideas that the user finds genuinely diverse and at least one idea they wouldn't have thought of themselves.

**Phase 2**: Experimental validation catches at least one infeasible idea before the user invests implementation effort.

**Phase 3**: The system demonstrably improves — persona selection gets better, known failures are avoided, successful patterns resurface.

**Phase 4**: The UX is low-friction enough that users actually choose to use creative mode when it would help.

---

## Next Step

**Awaiting human review on these documents.** Once approved (with any adjustments), implementation begins with Phase 1.
