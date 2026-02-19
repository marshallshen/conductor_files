---
name: document-query-patterns
description: Collect query examples from the user, distill them into named canonical patterns, and produce a Reference doc using the tech-doc-writer agent
tools: Glob, Grep, Read, Write, Bash, Task
user-invocable: true
---

You are documenting query patterns from user-supplied examples, turning raw query code into a clean, canonical reference document.

## Purpose

Query patterns are the specific ways a project queries its data layer. Each pattern serves a distinct purpose—traversing a relationship, applying a quirky filter, or working around a system constraint. Collecting and naming these patterns helps developers (and AI agents) find the right approach without hunting through the codebase.

Your job:

1. **Collect** raw query examples from the user interactively
2. **Distill** them into named, explained, grouped patterns with canonical forms
3. **Ask** where to save the documentation
4. **Delegate** the actual documentation writing to the `tech-doc-writer` agent via the Task tool

---

## Phase 1: Collect Examples

Open by introducing the skill and inviting the first example:

```
📋 Query Pattern Documenter

I'll help you turn your query examples into a clean reference doc.

Paste your first query example. For each one, also tell me:
  - What is this query doing? (one sentence is enough)
  - Is there anything quirky or non-obvious about it?

You can paste examples one at a time or several at once.
Type "done" when you've provided all examples.
```

For each example the user provides, acknowledge it and record:
- The raw query code
- The user's explanation (if given)
- Any context mentioned (table names, relationships, edge cases, quirks)

Continue collecting until the user types "done" or signals they are finished.

---

## Phase 2: Gather System Context

Before distilling, ask for any missing context. Only ask what isn't already clear from the examples:

```
Before I distill these into patterns, a couple of quick questions:

1. What data layer / technology are these queries for?
   (e.g., raw SQL / PostgreSQL, Django ORM, SQLAlchemy, ActiveRecord, Prisma, GraphQL, etc.)

2. Are there any system-wide constraints applied to most queries?
   (e.g., soft deletes via `deleted_at IS NULL`, tenant scoping via `tenant_id = ?`, etc.)

3. Who is the primary audience for this doc?
   (e.g., developers new to the codebase, AI agents, both)
```

Skip questions whose answers are already obvious from the examples.

---

## Phase 3: Distill into Patterns

Analyze all collected examples and produce a **distillation summary**. Apply every rule below to every pattern.

### a) Name & Explain

- Give the pattern a short, descriptive name that says *what* it retrieves, not *how* it does it.
  - Good: `"Active Subscriptions for a User"`, `"Orders with Pending Line Items"`
  - Bad: `"JOIN query"`, `"filter example"`
- Write one sentence explaining what data problem this pattern solves.

### b) Group Similar Queries

- If multiple examples address the same entity relationship or the same business question, group them under one pattern.
- Document intra-group variations as sub-variants (e.g., "with pagination", "eager-loaded", "count only").
- If examples are distinct enough to confuse a developer looking for one vs. the other, keep them separate.

### c) Annotate Data Quirks

- If a query silently requires a system-wide filter (soft delete scope, tenant guard, etc.), call it out with a **⚠️ Quirk** note.
- If the pattern only works correctly under a specific condition (transaction, specific ordering, non-null FK), document it explicitly.
- Do not silently fix a quirk—name it so developers know to replicate it.

### d) Suggest Canonical Form

- Rewrite each example into a clean, minimal, copy-pasteable form:
  - Strip production noise (logging calls, metrics, unrelated filters, commented-out code).
  - Keep the essential structure: the join, the filter, the projection.
  - Use descriptive placeholder names (`user_id`, `tenant_id`) not single-letter variables.
- If the original query has a potential issue (redundant join, missing index hint), note it in a `📝 Note` — do not silently correct it.

### Present Distillation for Review

Show the distillation to the user before writing documentation:

```
📐 Distilled Patterns — N patterns from M examples

──────────────────────────────────────────────────────────
Pattern 1: [Name]
Purpose:   [One sentence]
Group:     [Standalone | grouped with "Pattern X"]
⚠️ Quirk:  [If any — or omit this line]
📝 Note:   [If any — or omit this line]

Canonical form:
```[language]
[clean example]
```
──────────────────────────────────────────────────────────
Pattern 2: [Name]
...
──────────────────────────────────────────────────────────

Does this look right? Any patterns that should be split, merged,
renamed, or corrected before I write the doc?
```

Iterate until the user confirms the patterns are accurate.

---

## Phase 4: Ask Where to Document

```
📁 Where should I save the query patterns reference?

Options:
  1. Tell me a file path  (e.g., docs/reference-query-patterns.md)
  2. I'll detect your docs structure and suggest a location
```

If the user asks for a suggestion:
- Use Glob to detect existing docs: `docs/**/*.md`, `README.md`, `**/*.md`
- Check for Diataxis-style folders (`Reference/`, `HowTo/`, `Tutorial/`, `Explanation/`)
- Match the project's existing naming conventions
- Default suggestion: `reference-query-patterns.md` (or `reference-[entity]-query-patterns.md` when patterns are scoped to one entity)
- Place it in the `Reference/` subfolder if one exists, otherwise alongside other docs

---

## Phase 5: Delegate to tech-doc-writer

Once patterns are confirmed and destination is known, invoke the `tech-doc-writer` agent via the Task tool.

Construct a detailed brief that includes all of the following so the agent needs no follow-up questions:

```
Write a Reference document for query patterns in [project/data layer].

Documentation type: Reference
Audience: [from Phase 2]
Target file: [path from Phase 4]

---

SYSTEM CONTEXT
- Data layer: [e.g., Django ORM / PostgreSQL]
- System-wide constraints: [e.g., "All queries must include `deleted_at IS NULL` unless explicitly querying deleted records. Omitting this filter is a common bug."]
- Additional context: [anything else from Phase 2]

---

DISTILLED PATTERNS

[Paste the full distillation from Phase 3, including:
 - Pattern name
 - Purpose
 - Group membership
 - Quirk annotations
 - Notes
 - Canonical form with language tag]

---

DOCUMENT REQUIREMENTS

1. Start with a quick-lookup table at the top:
   | Pattern | Purpose |
   |---------|---------|
   | [Name]  | [one-line purpose] |

2. Organize patterns by entity/relationship group (not by SQL keyword).

3. For each pattern entry, include:
   - Pattern name as heading
   - Purpose sentence
   - ⚠️ Quirk callout (if any) — make these visually prominent
   - 📝 Note (if any)
   - Canonical code block with syntax highlighting
   - Variants sub-section (if the pattern has intra-group variations)

4. Follow the project's existing documentation conventions:
   - Detect and match naming conventions, frontmatter usage, and heading style
   - If a Reference/ directory exists, follow its patterns exactly
   - Use the doc type prefix "reference-" in the filename

5. Write the file to: [target file path]
```

Announce before invoking:

```
Handing off to the tech-doc-writer agent to write the reference document...
```

---

## Phase 6: Confirm Completion

After the tech-doc-writer agent finishes, confirm with the user:

```
✅ Query patterns documented

File:     [path]
Patterns: [N] (in [K] groups)
Groups:   [list of group names]

Next steps:
  1. Review the document for accuracy
  2. Add it to your docs index if you have one
  3. Commit:
     git add [path]
     git commit -m "docs: add query patterns reference"

Need to add more patterns later? Run this skill again — paste only
the new examples and I'll produce patterns you can merge into the doc.
```

---

## Key Principles

### Strip noise, keep structure
The canonical form should be the minimum query that conveys the pattern. Remove logging, metrics, and unrelated business logic. Keep joins, filters, and projections that define the pattern.

### Name quirks explicitly
A filter that is silently required (e.g., `tenant_id = ?`) is more dangerous undocumented than undocumented code. Name every implicit constraint. Developers who copy a pattern without its quirk will introduce bugs.

### Group by relationship, not by syntax
Organize patterns by the data entity or relationship they address (`User → Subscriptions`, `Order → Line Items`), not by SQL keyword (`JOIN queries`, `subqueries`). This matches how developers think when they need a query.

### One pattern per purpose
If two queries solve the same question in different ways (e.g., ORM vs raw SQL, with vs without eager loading), document them as variants of one pattern. If they solve different questions, keep them as separate patterns.

### Preserve the original intent
If the user's example has a pattern worth noting as potentially problematic, add a `📝 Note` — do not silently rewrite it. Developers need to understand both what the pattern does and any caveats.
