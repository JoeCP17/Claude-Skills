---
name: wrap
description: "Save the current session's work summary to memory before ending a conversation. Use this skill whenever the user wants to wrap up, save progress, or preserve session context — including phrases like /wrap, 세션 정리, 세션 저장, 작업 내용 저장, 메모리 저장, 세션 마무리, wrap-up, '오늘 여기까지', 'save what we did', or any signal that the conversation is ending and work should be recorded."
---

# Session Wrap-up

Analyze the current session and persist a concise summary to memory so the next conversation can pick up seamlessly.

## Steps

### 1. Analyze the session

Classify everything discussed into:
- **Completed work** — implementations, fixes, deployments that are done
- **In-progress work** — started but not finished
- **Discovered issues** — bugs or problems that surfaced
- **Decisions made** — architecture/design choices and their rationale
- **Next steps** — what to do in the follow-up session

### 2. Write a memory file

Save to `~/.claude/projects/{project-path}/memory/session-{YYYY-MM-DD}-{topic}.md`.

Use absolute dates (never "today"/"tomorrow") — relative dates become meaningless once the session ends. Keep it concise; git log covers code details, so focus on context and intent that aren't captured in commits.

```markdown
---
name: {date} {topic} session summary
description: {one-line: what was done and how far it got}
type: project
---

## Session Summary ({date})

### Completed
- item

### In Progress
- item (current state)

### Decisions
- decision — **Why:** reasoning

### Next Steps
- [ ] follow-up task
```

### 3. Update MEMORY.md index

Add a link under `## Sessions`. Create the section if it doesn't exist.

### 4. Update stale memories

If the session changed facts tracked in existing memory files (project status, decisions, etc.), update those files too — stale memories are worse than no memories.

### 5. Report

| Item | Value |
|------|-------|
| Saved file | `session-{date}-{topic}.md` |
| Completed items | N |
| In progress | N |
| Next steps | N |
| Existing memories updated | yes/no |
