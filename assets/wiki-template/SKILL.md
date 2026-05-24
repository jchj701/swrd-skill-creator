---
name: <skill-name>-wiki
description: "Use when building or maintaining the <skill-name> experience knowledge base. Triggers: ingesting experiences into wiki, querying wiki knowledge, linting wiki quality."
---

# <Skill-Name> Experience Wiki

Build and maintain an experience knowledge base for the <skill-name> Skill. You manage two directories: `raw/` (immutable source material) and `wiki/` (compiled knowledge articles). Experiences go into raw/, you compile them into wiki articles, and the wiki compounds over time.

## Architecture

Three layers, all under the wiki root:

**raw/** — Immutable experience material. You read, never modify. Organized by topic subdirectories.

**wiki/** — Compiled knowledge articles. You have full ownership. Organized by topic subdirectories, one level only: `wiki/<topic>/<article>.md`. Contains two special files:
- `wiki/index.md` — Global index
- `wiki/log.md` — Append-only operation log

**SKILL.md** (this file) — Schema layer. Defines structure and workflow rules.

## Ingest

Record a new experience into the wiki:

1. Get the experience content from the Skill's telemetry log or user input
2. Pick a topic directory (reuse existing if close enough)
3. Save as `raw/<topic>/YYYY-MM-DD-descriptive-slug.md`
4. Compile into `wiki/<topic>/<article>.md`
5. Update `wiki/index.md`
6. Append to `wiki/log.md`

## Query

Search the wiki and answer questions:
1. Read `wiki/index.md` to locate relevant articles
2. Read those articles and synthesize an answer
3. Cite sources with markdown links

## Lint

Quality checks:
- Index consistency
- Internal links
- Raw references
- Factual contradictions
- Outdated claims