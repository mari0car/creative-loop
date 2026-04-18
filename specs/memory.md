# Creative Memory Specification

## 1 Purpose

Creative Memory gives the loop **cumulative intelligence**. Without it, every creative session starts from zero. With it, the system remembers what worked, what failed, which personas were effective, and what patterns emerged — making each session smarter than the last.

This is **not** a vector database. It's structured file-based storage with explicit retrieval logic. Simple, inspectable, and version-controllable.

## 2 Memory Types

### 2.1 Session Logs
Complete records of each creative loop execution. These are the raw material from which patterns are extracted.

**Location**: `.creative-loop/sessions/{timestamp}/`
**Contents**: Brief, candidates, evaluations, selections, refinements, experiments, outcome
**Retention**: All sessions are kept. Old sessions can be archived (compressed) but not deleted — they're the provenance trail.

### 2.2 Pattern Library
Distilled insights from multiple sessions. These are the high-value learnings.

**Location**: `.creative-loop/patterns/`

**Successful Patterns** (`successful.json`):
```json
[
  {
    "id": "pat_001",
    "pattern": "Separating read and write paths",
    "domain": "backend-performance",
    "context": "When dealing with mixed read/write workloads where reads dominate",
    "evidence": ["session_2024_01_15", "session_2024_02_03"],
    "confidence": 0.85,
    "tags": ["architecture", "cqrs", "performance"]
  }
]
```

**Failed Approaches** (`failed.json`):
```json
[
  {
    "id": "fail_001",
    "approach": "Global in-memory cache without invalidation strategy",
    "domain": "backend-performance",
    "why_it_failed": "Stale data issues surfaced in experimentation phase",
    "lesson": "Always pair caching with an explicit invalidation mechanism",
    "evidence": ["session_2024_01_15"],
    "tags": ["caching", "anti-pattern"]
  }
]
```

**Effective Combinations** (`combinations.json`):
```json
[
  {
    "id": "combo_001",
    "ideas": ["Event sourcing", "Materialized views"],
    "synergy": "Event sourcing provides the write path; materialized views provide optimized reads",
    "domain": "backend-architecture",
    "evidence": ["session_2024_02_03"]
  }
]
```

### 2.3 Persona Effectiveness
Tracks which personas produce valuable ideas for which problem types.

**Location**: `.creative-loop/patterns/persona_effectiveness.json`

```json
{
  "cross_domain_analogist": {
    "domains": {
      "backend-performance": {"hit_rate": 0.6, "sessions": 5},
      "ui-design": {"hit_rate": 0.3, "sessions": 3}
    }
  },
  "minimalist": {
    "domains": {
      "api-design": {"hit_rate": 0.8, "sessions": 4},
      "backend-performance": {"hit_rate": 0.5, "sessions": 5}
    }
  }
}
```

`hit_rate` = fraction of ideas from this persona that made it past evaluation in this domain.

## 3 Memory Operations

### 3.1 Write (Capture Phase)

After each loop iteration:

1. **Archive session**: Write all artifacts to `.creative-loop/sessions/{timestamp}/`
2. **Extract patterns**: If a selected idea was validated in experimentation, add to successful patterns
3. **Record failures**: If experimentation invalidated an idea, add to failed approaches with the reason
4. **Update persona stats**: Increment hit/miss counts for each persona based on evaluation results
5. **Record combinations**: If evaluators suggested successful combinations, store them

### 3.2 Read (Diverge and Evaluate Phases)

Before generation:
1. **Retrieve relevant patterns**: Search pattern library by domain and tags matching the creative brief
2. **Retrieve relevant failures**: Prevent regenerating known-bad approaches
3. **Retrieve persona effectiveness**: Inform persona selection
4. **Retrieve prior session summaries**: If this is a follow-up on a previous creative session

### 3.3 Retrieval Logic

Since we don't have vector similarity search, retrieval uses:

1. **Domain match**: Exact match on domain field
2. **Tag intersection**: Ideas/patterns with overlapping tags get higher relevance
3. **Recency weighting**: More recent patterns are preferred (they reflect current project state)
4. **Confidence threshold**: Only retrieve patterns above a minimum confidence

```
function retrievePatterns(brief):
  patterns = loadAll(".creative-loop/patterns/successful.json")
  scored = patterns.map(p => {
    domainMatch = (p.domain == brief.domain) ? 1.0 : 0.0
    tagOverlap = intersect(p.tags, brief.tags).length / union(p.tags, brief.tags).length
    recency = decayFunction(p.last_updated)
    return {pattern: p, score: domainMatch * 0.5 + tagOverlap * 0.3 + recency * 0.2}
  })
  return scored.filter(s => s.score > 0.3).sortByScoreDesc().take(10)
```

## 4 Memory Maintenance

### 4.1 Pruning
- Patterns with `confidence < 0.3` after 5+ evidence sessions are removed
- Failed approaches older than 6 months are archived (not deleted — moved to `patterns/archive/`)
- Session logs older than 3 months are compressed

### 4.2 Confidence Evolution
Pattern confidence is updated with each new evidence point:
```
new_confidence = old_confidence * 0.8 + latest_outcome * 0.2
```
Where `latest_outcome` is 1.0 if the pattern was validated, 0.0 if it failed.

### 4.3 Human Curation
Users can directly edit the pattern library. The system respects manual edits:
- Patterns marked with `"curated": true` are never auto-pruned
- Users can add patterns from their own experience without going through the loop

## 5 Configuration

```json
{
  "memory": {
    "enabled": true,
    "max_patterns_per_retrieval": 10,
    "min_retrieval_confidence": 0.3,
    "session_compression_after_days": 90,
    "pattern_prune_min_sessions": 5,
    "pattern_prune_confidence_threshold": 0.3
  }
}
```
