---
name: commit
description: "Analyze the current changes and conversation context, generate an intent-focused Git commit message, and run `git commit`. Use when the user asks to commit changes or wants commit automation around `git commit`, `commit`, `--amend`, `--push`, or `--no-verify`. The skill instructions are in English, but the generated commit message itself must be written in Korean."
---

# Git Commit Automation

Analyze the current changes, generate a commit message using the rules below, and run the commit.

## Workflow

1. Check changed files with `git status`.
2. Read `git diff --cached` first; if nothing is staged, read `git diff`.
3. Identify the nature and scope of the changes.
4. If there is a plan document, compare it against the actual result and update it before committing when needed.
5. Extract the user's intent, background, and goal from the conversation context.
6. If the intent is unclear, ask a short clarification question before committing.
7. Write an intent-focused commit message using the `Message Structure` rules below.
8. Stage changes when needed.
9. Run `git commit` with the generated message.
10. If `--push` is requested, run `git push` after the commit.
11. In the final response, include the full commit message, commit SHA, changed files, change stats, and push result if applicable.

## Options

- `--amend`: amend the previous commit
- `--push`: push automatically after committing
- `--no-verify`: skip pre-commit hooks

Honor these options whenever the user includes them in the request, even if they are not provided as separate arguments.

## When to Ask for Intent

- The reason for the change is not clear from the conversation.
- The changes could be interpreted in multiple ways.
- The user's requirements are still too vague.

Example questions:
- "What is the main goal of this change?"
- "What problem were you trying to solve?"
- "What was the motivation for adding this rule?"

## Commit Message Rules

### Writing Principles

- Explain why the change exists, not just what changed.
- Reflect the background and goal expressed in the conversation.
- Make the user's problem and intent visible.
- Keep the first line within 50 characters.
- Write the actual commit message in Korean.

### Types

- `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Message Structure

```text
type(scope): subject (50자 이내)

본문: 72자로 줄바꿈. 최대 3개의 항목만 기술
- 변경사항의 이유와 영향 설명
- 비즈니스 맥락 중심
- 한글로 의도가 드러나게 작성
```

Keep the final message body wrapped at 72 characters, use no more than three bullets, and keep the body intent-focused and written in Korean.

## Notes

- If nothing is staged, stage all current changes.
- If the intent is unclear, ask before proceeding.
- If `--push` is used, check the remote branch state first.
- If the commit fails, report the error message and the likely cause.
