---
name: jira-kickoff
description: "Confirm or create a Jira issue, validate the target project, update local `main` safely, confirm the branch name, and create the working branch before implementation starts."
---

# Jira Kickoff Workflow

Standardize the setup routine that happens before implementation work begins.

This skill supports two entry paths:

- start from an existing Jira issue
- create a new Jira issue from rough requirements, then start from it

This skill may be used in repositories with Korean users. Draft new Jira issue
titles and descriptions in Korean by default unless the user explicitly asks for
another language.

<HARD-GATE>
Do not start implementation, edit source files, create commits, or open pull
requests. This skill ends after Jira issue setup and branch checkout are
complete.
</HARD-GATE>

## Goal

Finish only after all of the following are true:

- a Jira issue exists and its key is known
- the local repository has been safely updated from `main`
- a branch using the approved naming convention has been created and checked out

## Supported Inputs

### Existing Jira Flow

Expected input:

- Jira key, such as `SR-1137`
- optional short-title override for the branch slug

### New Jira Flow

Expected input:

- project key, such as `SR`, `FO`, or `BO`
- rough requirement text
- optional short-title override for the branch slug

## Workflow

1. Confirm the current directory is inside a Git repository.
2. Resolve the Jira site to use:
   - call `getAccessibleAtlassianResources`
   - if exactly one Jira-capable site is available, use it
   - if multiple Jira-capable sites are available and the user did not specify
     one, stop and ask which site to use
3. Determine whether the request is:
   - existing Jira flow
   - new Jira flow
4. Complete the Jira flow rules below.
5. Build the proposed branch name.
6. Show the full proposed branch name and require explicit confirmation before
   any branch creation command.
7. Run the Git safety gate.
8. Create and check out the branch.
9. Return the Jira key, Jira title, and final branch name.

## Existing Jira Flow Rules

1. Read the issue using `getJiraIssue`.
2. If the issue cannot be read, stop and report the failure.
3. Use the Jira issue as the source of truth for:
   - issue key
   - issue title
   - issue type
4. Map branch prefix from issue type:
   - `Bug` -> `bugfix/`
   - any other type -> `feature/`
5. Generate the branch slug from the Jira title unless the user supplied an
   override.

## New Jira Flow Rules

1. Validate the project key before drafting anything:
   - call `getVisibleJiraProjects`
   - require an exact key match
   - if no exact match exists, stop and report that the project key is invalid
2. Inspect the project's available issue types:
   - call `getJiraProjectIssueTypesMetadata`
   - support only `Task` and `Bug`
   - if one of those names is unavailable, stop and report the available types
3. Infer whether the request should be `Task` or `Bug`.
4. Draft:
   - issue type
   - Jira title
   - Jira description
5. Show the full draft and ask for explicit approval before creating anything.
6. If the user requests changes, revise the draft and ask again.
7. After approval, create the issue with `createJiraIssue`.
8. Use the creation result as the source of truth for:
   - issue key
   - issue title
   - issue type
9. Map branch prefix from issue type:
   - `Bug` -> `bugfix/`
   - any other type -> `feature/`
10. Generate the branch slug from the Jira title unless the user supplied an
    override.

## Jira Draft Rules

Use these rules only in the new Jira flow.

- Default language is Korean unless the user requested another language.
- Support only two issue types:
  - `Task`
  - `Bug`
- Prefer short, practical titles over long sentence titles.
- The description should capture:
  - background or request context
  - the requested change or problem
  - any known timing, rollout, or business impact details from the user
- Never create the Jira issue before the user has approved the type, title, and
  description together.

## Branch Naming Rules

- Format must be exactly:
  - `{prefix}/{jira-key}/{very-short-title}`
- Prefix mapping:
  - `Bug` -> `bugfix/`
  - any other type -> `feature/`
- The short title slug must:
  - be lowercase
  - use kebab-case
  - remove punctuation and separator noise
  - collapse repeated hyphens
  - stay very short and practical
- If the generated slug is empty or unclear, ask the user for an override.
- Even when the generated slug looks correct, always show the full branch name
  and require confirmation before branch creation.

## Git Safety Gate

Run these checks in order. Stop immediately on the first failure.

1. Run `git rev-parse --is-inside-work-tree`.
2. Run `git status --porcelain`.
   - if any output exists, stop and tell the user to clean or commit the working
     tree first
3. Confirm the `origin` remote exists with `git remote get-url origin`.
4. Run `git fetch origin main`.
5. Run `git switch main`.
6. Run `git pull --ff-only`.
7. Check for a local branch collision:
   - `git show-ref --verify --quiet refs/heads/<branch>`
8. Check for a remote branch collision:
   - `git ls-remote --exit-code --heads origin <branch>`
9. If either branch check finds a match, stop and ask the user how to proceed.
   Do not invent a postfix automatically.

## Branch Creation

After the Jira flow is complete, the branch name is approved, and all Git
checks pass:

1. Run `git switch -c <branch>`.
2. Confirm the checked-out branch name matches the approved branch exactly.

## Required Checks

- Git repository exists
- Jira site is unambiguous
- Existing Jira issues are readable before use
- New Jira project key is valid before draft approval
- New Jira issue type is one of `Task` or `Bug` and supported by the target
  project
- Jira creation happens only after explicit draft approval
- Working tree is clean before switching to `main`
- `origin` exists
- `git fetch origin main` succeeds
- `git switch main` succeeds
- `git pull --ff-only` succeeds
- No local or remote branch already exists with the chosen name
- The user has explicitly approved the final branch name

## Final Response

Return a short handoff that includes:

- Jira key
- Jira title
- Jira issue type
- final branch name
- confirmation that the repository is ready for implementation

## Notes

- This skill does not perform implementation work.
- This skill does not create commits or pull requests.
- Report failures with the exact blocking condition instead of continuing
  partially.
