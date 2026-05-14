# Issue tracker: GitHub

Issues and PRDs for this repo (`esqLABS/osp.snapshots`) live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --comments`. Per the project's CLAUDE.md, always pass `--comments` so you see the full thread.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

The repo is inferred automatically from `git remote -v` when `gh` runs inside this clone.

## Triage labels

This repo deliberately does not use the five-role triage label system. When a skill says "apply the `needs-triage` / `needs-info` / `ready-for-agent` / `ready-for-human` label", skip the label step. `wontfix` exists and can be applied as-is.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments`.
