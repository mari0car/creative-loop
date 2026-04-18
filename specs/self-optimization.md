# Self-Optimization Specification

## 1 Purpose

The creative loop can improve itself. After each session, the meta-controller evaluates prompt quality and can propose — and apply — improvements to persona prompts, evaluation instructions, and selection logic. Since all "code" is plain text files, Claude Code can edit them directly. The system evolves through use.

## 2 The Core Idea

The creative loop's behavior is defined entirely by text files:
- Persona prompts (`.creative-loop/personas/`)
- Phase prompt templates (`.creative-loop/prompts/`)
- Config (`.creative-loop/config.json`)

When the loop runs a session, it generates quality signals:
- Which personas produced ideas that scored highly?
- Which evaluator scores were later confirmed correct by experimentation?
- Were the generated ideas truly diverse, or did they cluster?
- Did the refiner deepen ideas or just paraphrase them?

These signals can be used to edit the prompt files — making personas more provocative, making evaluators better calibrated, improving the refiner's depth. **Claude Code edits its own creative prompts.** No fine-tuning, no external system — just file edits.

## 3 Quality Signals

At session end, the meta-controller computes these signals:

| Signal | How It's Measured | What It Improves |
|---|---|---|
| **Persona diversity** | Cross-idea similarity score (do ideas look alike?) | Persona prompts — push harder for differentiation |
| **Evaluator calibration** | Did evaluation predict experimental outcomes? | Evaluator prompt — improve scoring guidance |
| **Idea adoption rate** | Did the user pick any ideas? | Persona prompts — improve relevance framing |
| **Refinement depth** | Did refinement add new information or just restate? | Refiner prompt — push for concrete mechanisms |
| **Brief accuracy** | Did user amend the brief? | Brief generation prompt — capture requirements better |
| **Iteration count** | How many loops before a satisfying result? | Selection policy — improve convergence |

## 4 Optimization Triggers

### 4.1 Session-End Review (Automatic)
After every session, the meta-controller performs a lightweight self-assessment:
- Flag prompts that showed weakness signals
- Propose specific edits (not vague "be better" — concrete changes)
- Store proposals in `.creative-loop/patterns/prompt_evolution.json`

### 4.2 Explicit Optimization Run (Manual)
```
/creative optimize
```
Reviews the last N sessions, identifies systemic patterns, proposes a batch of improvements across all prompts, and applies them after human approval.

### 4.3 Triggered by Poor Session
If a session scores below a threshold (e.g., user says "none of these are useful"):
- Automatically surface the question: "What was missing?"
- Use the answer to propose targeted persona/prompt improvements

## 5 How Edits Are Applied

### 5.1 With Human Review (Default)
The meta-controller proposes changes as a diff:

```
## Proposed Improvement: Devil's Advocate Persona

Current first line:
  "Challenge every assumption and find weaknesses in the approach."

Proposed:
  "Your job is to be the most rigorous critic in the room. Attack every
   assumption. Find the edge case that breaks the design. Produce the
   uncomfortable question nobody wants to ask."

Reason: The current prompt produces polite critique. Sessions 3 and 5
showed the devil's advocate generating ideas indistinguishable from
the minimalist. Stronger language should increase true differentiation.

Apply this change? [Yes / No / Modify]
```

### 5.2 Autonomous Mode
If `self_optimization.require_approval = false`, changes are applied automatically and logged to `.creative-loop/patterns/prompt_evolution.json`. Not recommended until the system has proven reliability.

## 6 Version Control for Prompts

Every prompt edit is versioned:

**`.creative-loop/patterns/prompt_evolution.json`**:
```json
[
  {
    "id": "evo_001",
    "timestamp": "2024-03-15T14:23:00Z",
    "target": "personas/builtin/devils-advocate.md",
    "change_type": "strengthening",
    "before": "Challenge every assumption...",
    "after": "Your job is to be the most rigorous critic...",
    "reason": "Persona was producing ideas indistinguishable from minimalist",
    "evidence": ["session_20240313", "session_20240315"],
    "outcome": null
  }
]
```

The `outcome` field is updated in a future session when we can assess whether the change helped.

## 7 Safety Constraints

Self-optimization never:
- Modifies the **goal** of a persona (the devil's advocate stays a critic, never becomes a cheerleader)
- Changes the **evaluation axes** — these are stable by design
- Modifies files outside `.creative-loop/`
- Applies changes mid-session — only between sessions

The meta-controller keeps a "mutation limit" — no single persona prompt changes by more than 30% of its token count in one evolution step. Radical rewrites require human initiation.

## 8 The Meta-Loop

This creates a meta-loop: the creative loop optimizes the creative loop.

```
Run session → Capture signals → Propose prompt improvements
     ↑                                       ↓
Use improved prompts ← Apply improvements ← Review & approve
```

Over time, the creative loop should:
1. Produce more diverse ideas per session (persona divergence improves)
2. Need fewer iterations to reach high-quality results (evaluator calibration improves)
3. Develop project-specific creative styles (custom persona evolution)
4. Build a vocabulary of what "works" for this codebase and domain

## 9 Portability of Evolved Prompts

When a project's prompts have been evolved significantly, they represent **learned creative capital**. The patterns and evolved personas can be:
- Committed to version control (prompt evolution is diffs, just like code)
- Shared across team members
- Exported as a "creative profile" for related projects

## 10 Configuration

```json
{
  "self_optimization": {
    "enabled": true,
    "require_approval": true,
    "auto_assess_after_session": true,
    "explicit_optimize_command": "/creative optimize",
    "mutation_limit_fraction": 0.3,
    "min_sessions_before_optimize": 3
  }
}
```
