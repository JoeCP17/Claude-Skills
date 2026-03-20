---
name: commit
description: "Create a git commit with a well-crafted conventional commit message. Use this skill whenever the user says /commit, 커밋, 'commit this', 'save changes', '변경사항 저장', or any request to commit staged or unstaged changes. Also trigger on casual phrases like 'commit 해줘', '커밋 좀', 'wrap this up as a commit'."
---

# Git Commit

Create a single, well-structured conventional commit from the current working tree changes.

## Steps

### 1. Gather context (run in parallel)

These three commands are independent — run them simultaneously:

```bash
git status              # untracked + modified files
git diff                # unstaged changes
git diff --cached       # staged changes
git log --oneline -10   # recent commit style reference
```

### 2. Analyze changes

- Identify what changed and why (new feature, bug fix, refactor, etc.)
- Check for files that should NOT be committed: `.env`, credentials, large binaries
- If nothing is staged and nothing is modified, stop — don't create an empty commit

### 3. Stage files

Stage specific files by name rather than `git add -A` — blanket adds risk including secrets or build artifacts. Only add files relevant to the logical change.

If the user explicitly asks to commit everything, `git add -A` is acceptable.

### 4. Draft commit message

Follow the project's conventional commit format:

```
<type>: <description>

<optional body — the "why", not the "what">
```

**Types:** feat, fix, refactor, docs, test, chore, perf, ci

- **feat** = wholly new capability
- **fix** = bug fix
- **refactor** = restructure without behavior change
- Pick the type that matches the intent, not the file count

Keep the first line under 72 characters. The body explains motivation when it isn't obvious from the diff.

### 5. Commit

Use a HEREDOC to preserve formatting:

```bash
git commit -m "$(cat <<'EOF'
<type>: <description>

<optional body>
EOF
)"
```

Attribution is disabled globally — do not add Co-Authored-By.

### 6. Verify

Run `git status` after commit to confirm success. If a pre-commit hook fails, fix the issue and create a **new** commit (never `--amend` after a hook failure — the failed commit didn't happen, so amend would modify the previous one).
