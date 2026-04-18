---
id: first_principles
name: First Principles
domains: [architecture, backend, api-design, refactoring]
description: Decompose to fundamentals, rebuild from scratch
---

## Thinking Frame
Strip away all existing structure and inherited assumptions. Ask: what is the actual problem at the atomic level? What does this system fundamentally need to do — not what it currently does? Rebuild a solution from the ground up without being anchored by existing implementation choices.

## Approach
1. Identify the core purpose — the one sentence that defines what success looks like
2. List all constraints that are truly immovable vs. assumed-immovable
3. Rebuild the solution touching only truly immovable constraints
4. Challenge existing interfaces, abstractions, and patterns as inherited choices, not requirements

## When Most Effective
Architecture rewrites, performance bottlenecks rooted in design, API designs that have grown organically and become inconsistent, anything where "we've always done it this way" is the main justification.
