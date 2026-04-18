# Human Oversight Specification

## 1 Purpose

The human is the ultimate creative director. The loop expands the option space; the human narrows it. This spec defines where humans interact with the loop, what control they have, and how their feedback improves future iterations.

## 2 Oversight Points

### 2.1 Entry — Problem Framing

**What**: The human provides the initial problem or question.
**Control**: The meta-controller generates a creative brief and presents it for confirmation before proceeding.

```
User: /creative How should we handle rate limiting?

Claude: Here's how I'm framing this for creative exploration:

  Problem: Design a rate limiting strategy for the API
  Constraints: Must work with existing Express middleware,
               no external services (Redis is acceptable)
  Success: Handles burst traffic without rejecting legitimate users
  Domain: backend-infrastructure

  Does this capture it, or should I adjust the framing?
```

The user can adjust the brief before generation begins. This prevents the loop from solving the wrong problem.

### 2.2 Mid-Loop — Selection Review

**What**: After evaluation, before deep refinement, the human reviews the shortlist.
**Control**: User can accept, reject, add, or reprioritize ideas.

```
Claude: Here are the top-scoring ideas from this iteration:

  1. Sliding window counter (Score: 0.81)
  2. Token bucket with burst credit (Score: 0.77)
  3. [Wild card] Adaptive rate limits based on client reputation (Score: 0.63)

  I'd like to refine and experiment with these three.
  Want me to proceed, or would you like to adjust the selection?
```

Options:
- "Proceed" — Continue with the selection
- "Drop #3, add the leaky bucket one instead" — Manual override
- "Focus only on #1" — Narrow the exploration
- "Actually, I want to explore distributed rate limiting too" — Expand scope

### 2.3 Exit — Final Review

**What**: After experimentation, the human reviews results and decides next steps.
**Control**: Full decision authority on what to implement.

Options at exit:
- **Implement**: Pick a proposal to build
- **Iterate**: Run another loop with refined constraints
- **Combine**: Merge elements from multiple proposals
- **Shelve**: Save the exploration for later, don't implement now
- **Discard**: Not useful, don't save to patterns

### 2.4 Optional — Deep Dive

At any point, the human can:
- Ask "why did you rank X higher than Y?" — Get evaluation rationale
- Ask "show me the experiment for X" — See experimental details
- Ask "what did the devil's advocate say?" — See specific persona output
- Edit the configuration mid-loop — Change weights, personas, thresholds

## 3 Feedback Integration

### 3.1 Explicit Feedback
When the user rejects or overrides a selection, the system records:
- What was rejected and why (if the user says)
- What was preferred instead
- This feeds into creative memory as a pattern

### 3.2 Implicit Feedback
The system tracks:
- Which proposals the user implements (strong positive signal)
- Which proposals the user ignores (weak negative signal)
- How often the user modifies the brief (indicates framing issues)
- Whether the user uses quick mode vs. full loop (indicates time preference)

### 3.3 Feedback → Memory Pipeline

```
User overrides selection → Record override reason → Update pattern library
User implements proposal → Mark pattern as successful → Boost persona effectiveness
User discards exploration → Mark as low-value → Reduce confidence scores
User edits brief → Record framing adjustment → Improve future brief generation
```

## 4 Safety and Governance

### 4.1 No Autonomous Action
The creative loop NEVER:
- Modifies project source code without human approval
- Pushes to remote repositories
- Creates pull requests or issues
- Makes external API calls (except reading project context)
- Sends messages to external services

The loop is pure exploration. Implementation requires explicit human direction.

### 4.2 Experiment Sandboxing
All experiments run in the `.creative-loop/` directory. They cannot modify project files. If an experiment needs to test against project code, it copies the relevant files into the experiment directory.

### 4.3 Cost Awareness
The loop uses sub-agents, which consume API tokens. The system should surface:
- Estimated cost before starting (rough: number of sub-agents x phases)
- Actual sub-agent count per iteration
- Option to reduce scope if budget is a concern

```
Claude: This creative exploration will launch approximately 12 sub-agent
        calls (5 generators + 2 evaluators + refinement + experiments).
        Want me to run a lighter version (3 generators, 1 evaluator)?
```

### 4.4 Time Awareness
Creative exploration takes longer than direct implementation. The system should:
- Estimate time before starting
- Allow the user to set a time budget
- Support "quick mode" for time-sensitive situations
- Be interruptible at any phase boundary

## 5 Interaction Modes

### 5.1 Interactive (Default)
Human reviews at each oversight point. Best for important decisions.

### 5.2 Autonomous
Human sets constraints upfront, loop runs to completion, presents final results. Good for background exploration.

```
/creative auto "Explore authentication patterns" --budget medium --max-iterations 2
```

### 5.3 Guided
Human is deeply involved — reviewing generator output, adjusting personas mid-loop, steering the direction at each phase. Best for learning how the system works or for highly novel problems.

## 6 Configuration

```json
{
  "human_oversight": {
    "review_brief": true,
    "review_selection": true,
    "review_experiments": false,
    "interaction_mode": "interactive",
    "cost_warning_threshold": 10,
    "time_budget_minutes": null
  }
}
```
