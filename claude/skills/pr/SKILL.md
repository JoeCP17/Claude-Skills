---
name: pr
description: "Rebase current branch onto target base branch, analyze full commit history, and create a GitHub Pull Request. Use this skill whenever the user says /pr, 'PR 만들어', 'create a PR', 'pull request', '풀리퀘', 'PR 올려줘', or any request to open a pull request. Also trigger on casual phrases like 'PR 좀', 'open a PR against main', 'merge request'. This skill handles the full workflow: rebase, push, and PR creation with comprehensive summary."
---

# Pull Request

Rebase onto the target branch, analyze the full commit history, and create a well-structured GitHub PR.

## Steps

### 1. Gather context (run in parallel)

```bash
git status                              # any uncommitted changes?
git branch -vv                          # current branch + tracking
git log --oneline -20                   # recent history
git remote -v                           # remote URL → derive owner/repo
```

### 2. Handle uncommitted changes

If there are staged or unstaged changes, ask the user:
- Commit them before creating the PR? (recommended)
- Stash them?
- Ignore them?

Don't silently discard changes.

### 3. Determine base branch

If the user specified a target branch, use it. Otherwise, detect the default:

```bash
git remote show origin | grep 'HEAD branch'
```

Common defaults: `main`, `master`, `develop`.

### 4. Rebase onto base branch

Rebase keeps the commit history clean and linear — merging would create noise in the PR diff.

```bash
git fetch origin <base-branch>
git rebase origin/<base-branch>
```

If conflicts arise, **stop and tell the user**. Don't auto-resolve conflicts — the user needs to decide how to handle them. Show which files conflict and offer guidance.

### 5. Analyze changes

After successful rebase, examine the full scope of the PR:

```bash
git log origin/<base-branch>..HEAD --oneline     # all commits in this PR
git diff origin/<base-branch>...HEAD              # cumulative diff
git diff origin/<base-branch>...HEAD --stat       # file-level summary
```

Look at **all commits**, not just the latest one. The PR summary should reflect the entire branch, not a single commit.

### 6. Push

```bash
git push -u origin <current-branch> --force-with-lease
```

`--force-with-lease` is necessary after rebase (history was rewritten) but safe — it refuses to overwrite commits that aren't in the local history. This is different from `--force` which blindly overwrites.

If the branch doesn't exist on remote yet, `-u` sets tracking.

### 7. Create PR

Draft the title and body, then create via `gh`:

```bash
gh pr create --title "<title>" --base <base-branch> --body "$(cat <<'EOF'
## Summary
<1-3 bullet points covering the full scope of changes>

## Changes
<file-level breakdown of what was modified and why>

## Test Plan
- [ ] test item 1
- [ ] test item 2
EOF
)"
```

**Title rules:**
- Under 70 characters
- Describe the outcome, not the process
- Don't repeat the branch name

**Body rules:**
- Summary covers ALL commits, not just the last one
- Changes section groups related modifications
- Test plan has actionable verification steps

### 8. Report

Print the PR URL so the user can review it in the browser.
