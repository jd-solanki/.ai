---
name: github-labels
description: Select the correct GitHub triage labels for issues and pull requests. Use when creating, updating, or reviewing GitHub issues or PRs, especially from to-prd and to-issues workflows.
---

# GitHub Labels

Use this skill to choose issue and PR labels before publishing or updating GitHub tracker items. Apply the smallest accurate label set, and if a required label does not exist in the repository, create it with GitHub CLI before applying it.

## Quick Start

- PRD issue: apply `PRD` and `ready-for-agent`
- Sub-issue from a PRD: apply `PRD-sub-issue` and either `ready-for-agent` or `ready-for-human`
- Unclear issue: apply `needs-triage`, or `needs-info` when a specific answer is required
- PR ready for maintainer review: apply the same readiness label as the work item when supported by the repo

## Triage Labels

| Label | Meaning |
| --- | --- |
| `PRD` | This issue has a PRD attached |
| `PRD-sub-issue` | This is a sub-issue of a parent PRD issue |
| `needs-triage` | Maintainer needs to evaluate this issue |
| `needs-info` | Waiting on reporter for more information |
| `ready-for-agent` | Fully specified, ready for an AFK agent |
| `ready-for-human` | Requires human implementation |
| `wontfix` | Will not be actioned |

## Labeling Workflow

1. Identify the artifact type: PRD, PRD sub-issue, standalone issue, or PR.
2. Decide whether the work is specified enough to start.
3. Apply one state label: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, or `wontfix`.
4. Add `PRD` or `PRD-sub-issue` only when the artifact actually matches that type.
5. For PRs, mirror the readiness or triage state of the linked issue when the repository supports those labels on PRs.

## Missing Labels

Before applying labels, check whether the repository already has them. If a required label is missing, create it with GitHub CLI:

```sh
gh label create "ready-for-agent" --description "Fully specified, ready for an AFK agent"
```

Use the meanings in the triage label table as label descriptions.

## Guidance

- Use `ready-for-agent` for AFK-friendly work with clear scope, acceptance criteria, and no unresolved human decision.
- Use `ready-for-human` when implementation requires human judgment, design review, stakeholder input, or sensitive access.
- Use `needs-info` when a specific missing answer blocks useful progress.
- Use `needs-triage` when the issue exists but has not yet been evaluated.
- Use `wontfix` only when the decision not to act is explicit.
