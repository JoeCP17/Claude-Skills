---
name: commit-push
description: "Create a git commit and push to remote in one step. Use this skill whenever the user says /commit-push, '커밋하고 푸시', 'commit and push', 'push it up', '올려줘', '푸시해줘', or any request that implies both committing and pushing. Also trigger on 'cp' shorthand when in a git context, or casual phrases like '커밋 푸시 한번에', 'save and push'."
---

# Git Commit + Push

Commit current changes and push to the remote branch in a single workflow.

## Steps

### 1. Gather context (run in parallel)

```bash
git status                          # working tree state
git diff                            # unstaged changes
git diff --cached                   # staged changes
git log --oneline -10               # recent commit style
git branch -vv                      # current branch + tracking info
```

### 2. Analyze and stage

Same rules as the `commit` skill:
- Stage specific files by name (not `git add -A` unless explicitly asked)
- Skip `.env`, credentials, large binaries
- Stop if there's nothing to commit

### 3. Commit

Conventional commit format:

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

Use HEREDOC for the message. Attribution is disabled — no Co-Authored-By.

### 4. Push

Determine the right push command:

| Situation | Command |
|-----------|---------|
| Branch tracks a remote | `git push` |
| New branch, no upstream | `git push -u origin <branch>` |
| Branch is behind remote | **Stop and ask the user** — force-push is destructive |

Never force-push without explicit user approval. If the branch is behind, explain the situation and offer options (pull + push, rebase + push, or force-push).

### 5. Verify

Run `git status` and confirm the push succeeded. Report the remote branch name so the user knows where the code went.
