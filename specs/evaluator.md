# Evaluator Specification

## 1 Purpose

Evaluator agents provide independent, structured assessment of generated ideas. They prevent the loop from pursuing flashy-but-infeasible ideas or dismissing unconventional-but-valuable ones. Good evaluation is the difference between creative exploration and random brainstorming.

## 2 Evaluation Axes

Each idea is scored on five axes, each 0.0 to 1.0:

### 2.1 Novelty (Weight: 0.25)
*"Is this genuinely different from obvious approaches?"*
- 0.0 — This is the first thing anyone would try
- 0.5 — Has a novel twist on a known approach
- 1.0 — Fundamentally reframes the problem or introduces an approach not seen in this domain

### 2.2 Feasibility (Weight: 0.25)
*"Can this actually be built with available resources and constraints?"*
- 0.0 — Requires technology/resources that don't exist
- 0.5 — Achievable but with significant effort or risk
- 1.0 — Straightforward to implement with current tools and constraints

### 2.3 Relevance (Weight: 0.25)
*"Does this actually solve the stated problem?"*
- 0.0 — Interesting but solves a different problem
- 0.5 — Partially addresses the problem
- 1.0 — Directly and completely addresses the core problem

### 2.4 Risk (Weight: 0.15, inverted — lower risk = higher score)
*"What could go wrong, and how bad would it be?"*
- 0.0 — Catastrophic failure modes, irreversible consequences
- 0.5 — Manageable risks with known mitigations
- 1.0 — Low-risk, easy to roll back or course-correct

### 2.5 Elegance (Weight: 0.10)
*"Is this solution simple, clean, and maintainable?"*
- 0.0 — Rube Goldberg complexity
- 0.5 — Reasonable complexity for the problem
- 1.0 — Beautifully simple, solves multiple problems at once

### 2.6 Composite Score
```
composite = (novelty * 0.25) + (feasibility * 0.25) + (relevance * 0.25)
          + ((1 - risk) * 0.15) + (elegance * 0.10)
```

Weights are configurable per project. Some projects may weight feasibility higher; research-oriented work may weight novelty higher.

## 3 Evaluation Process

### 3.1 Independent Evaluation
Each evaluator sub-agent scores ideas independently. Multiple evaluators provide robustness against individual bias.

### 3.2 Evaluator Prompt Template

```
## Evaluation Task

You are evaluating creative ideas generated for this problem:

### The Problem
{creative_brief}

### Project Context
{relevant_context}

### Ideas to Evaluate
{ideas_json}

### Evaluation Criteria
For each idea, provide scores (0.0-1.0) on these axes:
- **Novelty**: Is this genuinely different from obvious approaches?
- **Feasibility**: Can this be built with available resources?
- **Relevance**: Does this solve the stated problem?
- **Risk**: What could go wrong? (score the severity)
- **Elegance**: Is the solution clean and simple?

For each score, you MUST provide a rationale (1-2 sentences).
Do not inflate scores to be polite. Be honest and calibrated.

Also flag:
- Ideas that should be COMBINED (complementary strengths)
- Ideas that are REDUNDANT (essentially the same approach)
- Ideas with HIDDEN potential (low obvious appeal but interesting kernel)

Return as JSON.
```

### 3.3 Calibration
To keep evaluators calibrated:
- Evaluators see all ideas from all generators (not just one generator's output)
- The prompt instructs evaluators to use the full range of scores (not cluster everything around 0.5-0.7)
- If creative memory contains prior evaluations for similar problems, those are included as calibration anchors

## 4 Aggregation

When multiple evaluators score the same idea:

1. **Median** score is used (robust to outliers)
2. **Disagreement** is flagged: if evaluators differ by >0.3 on any axis, the idea is marked for human review
3. **Combination suggestions** from any evaluator are surfaced

## 5 Anti-Bias Mechanisms

### 5.1 Novelty Bias Protection
Evaluators tend to underrate truly novel ideas because they're unfamiliar. Countermeasures:
- Explicit prompt instruction: "Unconventional is not the same as infeasible. Score novelty and feasibility independently."
- A dedicated "hidden potential" flag for ideas that score low overall but have an interesting kernel

### 5.2 Feasibility Bias Protection
Evaluators tend to overweight near-term feasibility. Countermeasures:
- Separate "can we build this today?" from "could this work in principle?"
- The meta-controller can override low-feasibility scores for ideas with very high novelty (exploration vs. exploitation)

### 5.3 Anchoring Prevention
Ideas presented first tend to anchor scoring. Countermeasures:
- Randomize idea order for each evaluator
- Show all ideas simultaneously, not sequentially

## 6 Output Format

```json
{
  "evaluations": [
    {
      "idea_id": "gen_first_principles_1",
      "scores": {
        "novelty": {"value": 0.8, "rationale": "Challenges the core assumption that..."},
        "feasibility": {"value": 0.6, "rationale": "Requires refactoring X but doable..."},
        "relevance": {"value": 0.9, "rationale": "Directly addresses the stated need..."},
        "risk": {"value": 0.3, "rationale": "Main risk is migration complexity..."},
        "elegance": {"value": 0.7, "rationale": "Clean separation of concerns..."}
      },
      "composite": 0.76,
      "flags": ["hidden_potential"],
      "notes": "The core insight here is strong even if the specific mechanism needs work"
    }
  ],
  "combinations": [
    {
      "ideas": ["gen_first_principles_1", "gen_minimalist_2"],
      "rationale": "The first provides the architecture, the second simplifies the interface"
    }
  ],
  "redundancies": [
    {
      "ideas": ["gen_naive_1", "gen_integrator_2"],
      "rationale": "Both propose essentially the same caching strategy"
    }
  ]
}
```

## 7 Configuration

```json
{
  "evaluator": {
    "evaluator_count": 2,
    "weights": {
      "novelty": 0.25,
      "feasibility": 0.25,
      "relevance": 0.25,
      "risk": 0.15,
      "elegance": 0.10
    },
    "disagreement_threshold": 0.3,
    "aggregation_method": "median"
  }
}
```
