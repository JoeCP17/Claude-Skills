---
name: dev-deploy
description: "Safely merge the current branch into the latest `origin/dev` and push `dev`. Use when the user asks to merge the current branch into dev, update dev from the latest remote first, or deploy changes by pushing the shared dev branch. If a merge conflict occurs, stop and ask the user to choose exactly one option: `1. Recreate origin/dev from origin/main, then merge the current branch.` or `2. Stop.`"
---

# Dev Deploy

Update local `dev` from the latest `origin/dev`, merge the current branch into `dev`, and push `origin/dev`.

## Workflow

1. Check the current branch and working tree.
2. Keep unrelated local edits out of the deploy scope.
3. Run the bundled script with the current branch as the source.
4. If the script reports a merge conflict, stop immediately and ask the user:
   `1. Recreate origin/dev from origin/main, then merge the current branch.`
   `2. Stop.`
5. Do not resolve merge conflicts automatically.
6. If the merge succeeds, report the merge commit or fast-forward result and push status.

## Command

```bash
~/.codex/skills/dev-deploy/scripts/dev-deploy.sh <source-branch>
```

If `<source-branch>` is omitted, the script uses the current branch name.

## Behavior

- Fetch `origin/dev` first.
- Switch to local `dev`.
- Fast-forward local `dev` to `origin/dev`.
- Merge the source branch into `dev` with a non-interactive merge.
- Push `dev` to `origin`.
- On merge conflict, leave the repository in merge state and stop.

## Guardrails

- Never auto-delete or recreate `origin/dev`.
- Never auto-resolve conflicts.
- Never push if the merge step fails.
- Prefer this skill over ad hoc git commands when the user explicitly wants to update and push `dev`.
