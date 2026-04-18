# Experiment Runner Specification

## 1 Purpose

Ideas are hypotheses. The Experiment Runner tests them. It takes refined proposals and validates them against reality by building minimal prototypes, running code, executing tests, and analyzing results. This is what separates creative thinking from mere brainstorming — **grounding ideas in evidence**.

## 2 Experiment Types

### 2.1 Code Prototype
Build a minimal working implementation to test feasibility.

- **When**: The idea proposes a technical approach that can be coded
- **How**: Write code in `.creative-loop/sessions/{timestamp}/experiments/`, run it via Bash
- **Output**: Working/failing code + execution results
- **Example**: "Does this caching strategy actually reduce latency? Let's build a benchmark."

### 2.2 Test Execution
Run existing or new tests to validate that an idea doesn't break things.

- **When**: The idea modifies existing behavior
- **How**: Run the project's test suite or write targeted tests
- **Output**: Test results (pass/fail/performance metrics)
- **Example**: "Will this API change break backward compatibility? Run the integration tests."

### 2.3 Static Analysis
Analyze code structure, dependencies, or patterns without executing.

- **When**: The idea involves architectural changes
- **How**: Read code, trace dependencies, analyze complexity via tools
- **Output**: Structural analysis, dependency maps, complexity metrics
- **Example**: "How many files would this refactor touch? What's the dependency chain?"

### 2.4 Data Analysis
Analyze existing data (logs, metrics, patterns) to validate assumptions.

- **When**: The idea is based on assumptions about data or usage patterns
- **How**: Parse logs, query data, compute statistics via Bash
- **Output**: Statistical evidence for/against the assumption
- **Example**: "The idea assumes reads outnumber writes 10:1. Let's check the logs."

### 2.5 Simulation
Model a scenario to predict outcomes without building the full system.

- **When**: The idea's value depends on scale or timing behavior
- **How**: Write a simulation script, run it, analyze results
- **Output**: Simulation results, predicted performance characteristics
- **Example**: "How would this queue-based approach handle 1000 concurrent requests?"

## 3 Experiment Design

Each experiment follows a structured template:

```json
{
  "experiment_id": "exp_001",
  "idea_id": "gen_first_principles_1",
  "type": "code_prototype",
  "hypothesis": "Separating read/write paths will reduce P95 latency by >40%",
  "method": "Build minimal read/write separation in an isolated module and benchmark",
  "success_criteria": "P95 latency improvement > 40% on synthetic workload",
  "failure_criteria": "Improvement < 20% or increased error rate",
  "estimated_effort": "small",
  "risk_assessment": "None — isolated experiment, no production impact"
}
```

## 4 Execution

### 4.1 Isolation
All experiments run in isolation:
- Code prototypes are written in `.creative-loop/sessions/{timestamp}/experiments/{experiment_id}/`
- They do not modify project source code
- They can read project code but only write to the experiment directory
- Bash commands are scoped to avoid side effects

### 4.2 Effort Budgeting

| Budget | Description | Max Time |
|---|---|---|
| **Small** | Quick script, single file, simple benchmark | ~5 min |
| **Medium** | Multi-file prototype, integration test | ~15 min |
| **Large** | Substantial prototype, requires setup | ~30 min |

The meta-controller assigns effort budgets based on the idea's score and the overall exploration budget.

### 4.3 Sub-Agent Delegation
Complex experiments can be delegated to sub-agents:
- The meta-controller describes the experiment
- A sub-agent (type: `general-purpose`) builds and runs it
- Results are returned to the meta-controller

For simple experiments (run a test, check a file), the meta-controller executes directly.

## 5 Result Format

```json
{
  "experiment_id": "exp_001",
  "idea_id": "gen_first_principles_1",
  "status": "completed",
  "outcome": "success",
  "results": {
    "hypothesis_validated": true,
    "metrics": {
      "p95_latency_before": "450ms",
      "p95_latency_after": "180ms",
      "improvement": "60%"
    },
    "observations": [
      "Write path latency increased by 15% — acceptable tradeoff",
      "Memory usage increased by 20MB due to dual data structures"
    ]
  },
  "artifacts": [
    "experiments/exp_001/benchmark.py",
    "experiments/exp_001/results.json"
  ],
  "recommendation": "Proceed — hypothesis validated. Note the write-path tradeoff for refinement."
}
```

## 6 Failure Handling

Experiments can fail in two ways:

1. **Hypothesis invalidated**: The experiment ran but results don't support the idea. This is a *good* outcome — it saves effort and generates a learning for creative memory.

2. **Execution failure**: The experiment itself broke (syntax error, dependency issue, timeout). The runner retries once with a fix attempt. If it fails again, it reports the failure and the meta-controller decides whether to skip or simplify.

## 7 Configuration

```json
{
  "experiment_runner": {
    "enabled": true,
    "default_effort_budget": "small",
    "max_concurrent_experiments": 2,
    "experiment_directory": ".creative-loop/sessions/{timestamp}/experiments/",
    "isolation_mode": "directory",
    "timeout_seconds": {
      "small": 300,
      "medium": 900,
      "large": 1800
    }
  }
}
```
