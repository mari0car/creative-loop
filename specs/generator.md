# Generator Specification

## 1 Purpose

Generator agents produce diverse candidate ideas by exploring a problem from fundamentally different angles. The key insight: **diversity of perspective matters more than volume**. Five ideas from five different thinking frames beat twenty ideas from the same frame.

## 2 Persona System

Each generator sub-agent is assigned a **persona** — a specific thinking frame that shapes how it approaches the problem. Personas are not characters or roleplay; they are structured cognitive strategies.

### 2.1 Built-in Personas

| Persona | Thinking Frame | Strength |
|---|---|---|
| **First Principles** | Decompose to fundamentals, rebuild from scratch | Breaks assumptions |
| **Devil's Advocate** | Challenge every assumption, find weaknesses | Prevents groupthink |
| **Cross-Domain Analogist** | Find parallel problems in unrelated fields | Novel combinations |
| **Naive Questioner** | Ask "why?" at every level, question the obvious | Uncovers hidden complexity |
| **Constraint Inverter** | What if we removed the main constraint? What if we made it harder? | Reframes the problem space |
| **User Empathist** | Think from the end-user's lived experience | Grounds in real needs |
| **Minimalist** | What's the simplest thing that could possibly work? | Fights over-engineering |
| **Futurist** | How would this be solved in 5 years? What's the trend line? | Forward-looking solutions |
| **Integrator** | What existing pieces can be combined in new ways? | Practical synthesis |
| **Provocateur** | Propose something deliberately controversial or counterintuitive | Expands solution space |

### 2.2 Custom Personas

Projects can define custom personas in `.creative-loop/personas/custom/`. Each is a markdown file:

```markdown
---
id: security_hardener
name: Security Hardener
domain: security
---

## Thinking Frame
Analyze every proposal through the lens of attack surface, threat models,
and defense in depth. Assume adversarial users. Find the failure modes
that optimistic thinking misses.

## When to Activate
- API design decisions
- Authentication/authorization flows
- Data handling and storage
- Any user-facing input processing
```

### 2.3 Persona Selection

Not all personas are relevant for every problem. The meta-controller selects 4-6 personas per iteration based on:
- **Problem domain**: Security-related tasks get the Security Hardener; UX tasks get the User Empathist
- **Phase**: Early exploration favors Provocateur and Cross-Domain Analogist; refinement favors Minimalist and First Principles
- **Memory**: If previous iterations showed certain personas producing low-value ideas for this problem type, they're deprioritized

## 3 Generator Prompt Template

Each generator sub-agent receives a structured prompt:

```
## Your Creative Persona: {persona_name}

### Thinking Frame
{persona_thinking_frame}

### The Problem
{creative_brief}

### Project Context
{relevant_project_context}

### Prior Ideas (if iteration > 1)
{summary_of_prior_ideas_and_evaluations}

### Creative Memory
{relevant_patterns_from_memory}

### Your Task
Generate 2-4 candidate ideas for solving this problem. For each idea:

1. **Title**: A clear, descriptive name
2. **Core Idea**: What is this approach? (2-3 sentences)
3. **Mechanism**: How would it work technically? (3-5 sentences)
4. **Why This is Different**: What makes this non-obvious? What assumption does it challenge?
5. **Risks**: What could go wrong? (1-3 items)
6. **Confidence**: How confident are you this is worth exploring? (0.0-1.0)

Think deeply from your persona's perspective. Don't hedge toward safe,
conventional answers. The evaluation phase will filter — your job is to
explore boldly.

Return your ideas as a JSON array.
```

## 4 Diversity Enforcement

To prevent convergence on obvious ideas:

1. **Persona isolation**: Generators run in parallel and cannot see each other's output
2. **Anti-priming**: The prompt explicitly asks generators NOT to produce conventional/obvious solutions first
3. **Constraint injection**: Some generators receive additional random constraints ("what if it had to work offline?", "what if you couldn't use a database?") to force creative detours
4. **Combination round**: After initial generation, a dedicated sub-agent looks for unexpected combinations across different generators' outputs

## 5 Output Format

Each generator returns:
```json
{
  "persona": "cross_domain_analogist",
  "ideas": [
    {
      "id": "gen_{persona}_{n}",
      "title": "...",
      "core_idea": "...",
      "mechanism": "...",
      "novelty_claim": "...",
      "risks": ["..."],
      "confidence": 0.7,
      "inspiration_source": "Optional: what analogy or insight drove this"
    }
  ],
  "meta": {
    "thinking_process": "Brief description of the reasoning path taken",
    "dead_ends": ["Ideas considered and rejected, with reasons"]
  }
}
```

The `meta` field is important for the learning system — understanding *how* generators think helps improve future prompts.

## 6 Configuration

```json
{
  "generator": {
    "default_persona_count": 5,
    "ideas_per_persona": 3,
    "max_parallel_agents": 6,
    "include_combination_round": true,
    "constraint_injection_probability": 0.3
  }
}
```
