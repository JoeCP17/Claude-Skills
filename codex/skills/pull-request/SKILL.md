---
name: pull-request
description: "Draft an intent-focused pull request, confirm it with the user, push the current branch when needed, and create a GitHub PR against `main`. The skill instructions are written in English and should explicitly account for Korean-user collaboration context."
---

# GitHub Pull Request Automation

Analyze the current branch, draft an intent-focused pull request, confirm the
draft with the user, and create the PR with GitHub CLI.

This skill may be used in repositories with Korean users. Keep that context in
mind when choosing the PR body language and phrasing, but follow the
repository's dominant documentation language first.

## Workflow

1. Confirm the current directory is inside a Git repository.
2. Read the current branch name.
3. Require the branch to start with `feature/`, `bugfix/`, or `refactor/`.
4. Check `git status --porcelain`. If anything is uncommitted, stop and tell
   the user to commit first.
5. Confirm the `origin` remote exists.
6. Confirm `gh` is installed and authenticated.
7. Run `git fetch origin main`. If it fails, stop and report the failure.
8. Check whether the current branch already has an open PR. If it does, stop,
   show the existing PR URL, and do not create another one.
9. Read the diff and commit range against `origin/main`. If there is no
   meaningful change, stop and say there is nothing to open a PR for.
10. Use the diff and conversation context to infer the PR intent.
11. Draft the PR title and body using the rules below.
12. Show the draft to the user and ask for approval before creating anything.
13. If the user requests edits, revise the draft and ask again.
14. Before creating the PR:
    - if the branch has no upstream on `origin`, run `git push -u origin HEAD`
    - if the branch already exists on `origin` but local HEAD is ahead, run
      `git push`
15. Run `gh pr create --base main --title ... --body ...`.
16. Return the PR URL and the exact title and body that were used.

## Title Rules

- Always use this format: `{{branch_name}} | {{title}}`
- `branch_name` must be the current Git branch name exactly as-is
- Do not rewrite, shorten, or interpret the branch prefix
- `title` must be short, clear, and focused on intent
- Prefer why the PR exists over a list of implementation details

## Body Rules

- Structure the body with `##` section headings
- Always write section headings in English, even when the body language is Korean
- Under each section, use concise bullet points only
- Do not write a flat bullet list without sections
- Keep it short, usually 2-4 sections
- Usually use 1-2 bullets per section
- Select only the sections that materially help the reviewer understand the change
- If the change is small, omit empty, redundant, or low-value sections
- Emphasize intent, motivation, expected effect, or risk reduction
- Do not turn the body into a file list, diff summary, or commit log
- Keep implementation details secondary unless they are necessary for context

## Korean Style Rules

- When writing bullet content in Korean, do not use honorific or polite endings
- Use terse, review-friendly Korean prose
- Prefer short endings such as `추가함`, `수정함`, `정리함`, `줄였음`, `없음`
- Avoid endings such as `했습니다`, `입니다`, `부탁드립니다`, `해주세요`
- Keep each bullet to one line when possible

## Type-Specific Body Templates

Choose the PR body structure from the current branch prefix only.

### `feature/`

Preferred sections:

- `## Background`
- `## What Added`
- `## Expected Impact`
- `## Notes`

Guidance:

- Focus on why the feature is needed
- Explain what capability, behavior, or flow was added
- Highlight the expected user-facing or system-level impact
- Use `## Notes` only when there is a meaningful constraint, rollout note, or follow-up item

For small feature changes, usually keep:

- `## Background`
- `## What Added`
- optionally `## Expected Impact`

### `bugfix/`

Preferred sections:

- `## Problem`
- `## Root Cause`
- `## Fix`
- `## Validation`

Guidance:

- Start from the broken or incorrect behavior
- Explain the root cause when it is clear from the diff or context
- Describe the fix in terms of behavior correction and risk reduction
- Use `## Validation` when verification materially improves reviewer confidence

For small bug fixes, usually keep:

- `## Problem`
- `## Fix`
- optionally `## Validation`

### `refactor/`

Preferred sections:

- `## Motivation`
- `## Scope`
- `## Behavioral Safety`
- `## Expected Benefit`

Guidance:

- Explain why the refactor was worth doing
- Describe what was reorganized, simplified, or clarified
- Explicitly state behavioral stability when appropriate
- Focus on maintainability, clarity, or testability gains

For small refactors, usually keep:

- `## Motivation`
- `## Scope`
- optionally `## Behavioral Safety`

## Body Selection Rules

- Infer the PR type from the branch prefix only
- Do not reclassify the PR type from the diff
- Do not mix templates across multiple types unless the user explicitly asks
- If a section would be empty or redundant, omit it
- Prefer clarity over template completeness

## Language Rules

- Prefer the repository's dominant documentation language
- Determine that language from repository-facing docs and instruction files
- If the dominant language is unclear, default to Korean
- If the user explicitly requests a specific language, follow that request

## Required Checks

- Git repository exists
- Branch prefix is one of `feature/`, `bugfix/`, `refactor/`
- Working tree is clean
- `origin` remote exists
- GitHub CLI is available and authenticated
- `git fetch origin main` succeeds
- No open PR already exists for the current branch
- The branch has meaningful changes relative to `origin/main`
- The user has approved the final draft

## Notes

- Base branch is always `main`
- Never create the PR before showing the draft to the user
- Stop immediately when a required check fails
- When reporting a failure, be specific about the blocking condition
