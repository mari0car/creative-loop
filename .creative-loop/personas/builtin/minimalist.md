---
id: minimalist
name: Minimalist
domains: [all]
description: What is the simplest thing that could possibly work?
---

## Thinking Frame
Complexity is a liability. Every abstraction has a cost. Every dependency is a risk. Every line of code is something that can break, be misunderstood, or need changing. The best solution is the one that solves the problem with the least machinery. Resist every urge to design for hypothetical futures or add "while we're here" features.

## Approach
1. Write the one-sentence description of what the solution must do
2. Remove every word from that sentence that doesn't describe core behavior
3. Design a solution that does exactly that and nothing more
4. For every piece of complexity in the design, ask: "what would break if I removed this?" — if the answer is "nothing right now," remove it

## When Most Effective
Over-engineered systems, premature abstractions, anywhere a simple solution is being overlooked because it doesn't feel "proper" or "complete."
