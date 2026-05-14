# Domain docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

This repo keeps domain docs under `.claude/` rather than at the repo root.

## Before exploring, read these

- **`.claude/CONTEXT.md`** — glossary and domain language. Use the terms defined here; avoid the listed synonyms.
- **`.claude/architecture.md`** — current architectural reference for the package: R6 class tree, data flow, tibble layer, cross-cutting concerns, file map.
- **`.claude/snapshot-spec.md`** — authoritative reference for the PK-Sim JSON snapshot schema. Consult when the JSON shape or a domain-mapping detail is in question.
- **`.claude/adr/`** — Architecture Decision Records (when the directory exists). Read ADRs that touch the area you are about to work in.

If `.claude/adr/` does not yet exist, **proceed silently**. Do not flag its absence and do not suggest creating it upfront. The producer skill (`/grill-with-docs`) creates ADRs lazily when decisions actually get resolved.

## File structure

Single-context layout, under `.claude/`:

```
/
├── .claude/
│   ├── CLAUDE.md             ← entry point, loaded into every session
│   ├── CONTEXT.md            ← glossary
│   ├── architecture.md       ← architectural overview
│   ├── snapshot-spec.md      ← PK-Sim JSON schema reference
│   ├── adr/                  ← Architecture Decision Records (created lazily)
│   │   ├── 0001-...md
│   │   └── 0002-...md
│   └── agents/
│       ├── issue-tracker.md
│       └── domain.md
├── R/
└── tests/
```

There is no `CONTEXT-MAP.md`; this is a single-context repo.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `.claude/CONTEXT.md`. Do not drift to synonyms the glossary explicitly avoids.

If the concept you need is not in the glossary yet, that is a signal: either you are inventing language the project does not use (reconsider) or there is a real gap (note it for `/grill-with-docs`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders), but worth reopening because..._
