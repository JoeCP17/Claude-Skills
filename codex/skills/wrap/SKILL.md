---
name: wrap
description: Save the current Codex session's work summary before ending a conversation. Use when the user says /wrap, wrap, 세션 정리, 세션 저장, 작업 내용 저장, 메모리 저장, 세션 마무리, 오늘 여기까지, or asks to preserve progress for the next Codex session.
---

# Codex Session Wrap-up

Persist a concise summary of the current session so the next Codex conversation can resume with less rediscovery. This complements automatic Codex session history; it records intent, decisions, verification, and follow-up work in project-readable files.

## Storage Targets

Prefer project-local storage when the current directory is a repository:

```text
.codex/session-notes/session-YYYY-MM-DD-topic.md
```

Also append a short entry to OMX notepad when `.omx/` exists or the project already uses OMX:

```text
.omx/notepad.md
```

If neither project-local target is available, save under:

```text
~/.codex/memories/session-YYYY-MM-DD-topic.md
```

## Workflow

1. Inspect current context and recent local evidence before writing:
   - `git status --short --untracked-files=all` when inside a git repository
   - relevant changed files or verification outputs already produced in the session
2. Classify the session:
   - Completed work
   - In-progress work
   - Decisions made
   - Verification evidence
   - Known blockers or risks
   - Next steps
3. Use an absolute date in the filename and body. Do not write "today", "tomorrow", or "yesterday".
4. Keep the note concise. Do not paste large diffs, logs, secrets, tokens, or private credentials.
5. Create or update the target files with the summary.
6. Report saved paths and remaining follow-up items.

## Note Template

```markdown
---
name: YYYY-MM-DD topic session summary
description: One-line summary of the saved context
type: codex-session
---

## Session Summary (YYYY-MM-DD)

### Completed
- item

### In Progress
- item

### Decisions
- decision — Why: reason

### Verification
- command/result or "Not run — reason"

### Risks / Blockers
- item

### Next Steps
- [ ] item
```

## OMX Notepad Entry

Append a brief entry rather than duplicating the full note:

```markdown
## YYYY-MM-DD — topic

- Saved: `.codex/session-notes/session-YYYY-MM-DD-topic.md`
- Summary: one sentence
- Next: one or two follow-up bullets
```

## Output

Report:

```markdown
Saved:
- path

Summary:
- completed: N
- in progress: N
- next steps: N
```
