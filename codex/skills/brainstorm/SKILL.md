---
name: brainstorm
description: "Use when the user asks to brainstorm, design before coding, refine requirements, or turn an idea into an approved spec before implementation. This skill explores intent, compares approaches, presents a design, writes a spec to `docs/specs/.local/`, and blocks code changes until the design is approved."
---

# Brainstorm Ideas Into Specs

Turn rough ideas into an approved design and written spec before any implementation work starts.

<HARD-GATE>
Do not write code, scaffold files, invoke implementation-oriented skills, or take any implementation action until you have presented a design and the user has approved it.
</HARD-GATE>

## Anti-Pattern: "This Is Too Small To Design"

Do not skip the design step because the request looks small. A tiny utility, a one-file tweak, or a config change can still hide bad assumptions. The design can be short when the scope is small, but it still needs to be presented and approved before implementation.

## Workflow

Complete these steps in order:

1. Explore the current project context.
2. Offer visual help if the topic is likely to benefit from mockups or diagrams.
3. Ask clarifying questions one at a time.
4. Propose 2-3 approaches with trade-offs and a recommendation.
5. Present the design in short sections and get approval.
6. Write the approved spec to `docs/specs/.local/YYYY-MM-DD-<topic>-design.md`.
7. Self-review the spec before handing it back to the user.
8. Ask the user to review the written spec.
9. If they want implementation next, switch to Plan Mode and write the implementation plan there.

## Process Rules

### 1. Explore first

- Read the relevant code, docs, and config before asking questions.
- Follow the existing repo structure and conventions instead of inventing a new architecture.
- If the request spans multiple independent subsystems, stop and decompose it before going deeper. Each sub-project should get its own spec.

### 2. Ask one question at a time

- Ask exactly one material question per message.
- Prefer concise multiple-choice style questions in plain text when that will speed up the decision.
- In Plan Mode, use `request_user_input` when the decision materially changes the design. In Default mode, ask directly.
- Focus on purpose, constraints, success criteria, non-goals, and key trade-offs.

### 3. Compare approaches before converging

- Always present 2-3 viable approaches unless there is only one realistic option.
- Lead with the recommended option.
- Explain the recommendation in terms of simplicity, fit with the existing codebase, and long-term maintenance.

### 4. Present the design incrementally

- Scale the design to the task. Very small changes can use short sections; larger work should cover architecture, components, state/data flow, failure handling, and testing.
- After each meaningful section, ask whether it still looks right before moving on.
- If the user pushes back, revise the design before writing the spec.
- Break the design into units with clear responsibilities, interfaces, and dependencies.
- Prefer boundaries that keep each unit understandable and testable without reading unrelated internals.

### 5. Keep the design focused

- Apply YAGNI. Remove speculative features, optional abstractions, and unrelated refactors unless they are required for the approved goal.
- When existing code has structural problems that directly affect the work, include targeted improvements in the design.
- Do not broaden scope with cleanup that does not materially help the current task.

### 6. Write the spec only after approval

- Default location: repository root `docs/specs/.local/`.
- If the current directory is not inside a git repository, fall back to `./docs/specs/.local/`.
- Use the filename format `YYYY-MM-DD-<topic>-design.md`.
- Create directories as needed.
- Treat `docs/specs/.local/` as a local-only workspace and keep it ignored by
  VCS.
- If the spec later needs to be shared across machines or committed on purpose,
  move or copy it into `docs/specs/`.
- Do not commit automatically. If the user wants the spec committed, use the separate `commit` skill.

## Spec Template

Use this structure unless the repo already has a stronger house style:

```md
# <Feature or Topic> Design

- Date: YYYY-MM-DD
- Status: Draft

## Context

## Goal

## Non-Goals

## Constraints

## Options Considered

### Option 1

### Option 2

### Recommended Approach

## Architecture

## Components and Responsibilities

## Data or State Flow

## Error Handling and Risks

## Testing and Acceptance

## Open Questions
```

## Self-Review Checklist

Before handing the spec to the user, verify that it:

- reflects the latest approved direction
- names the recommended approach and why it won
- is consistent with the existing codebase and scope
- uses clear component boundaries and responsibilities
- covers failure handling and testing
- avoids speculative features and unrelated refactors

If you find a gap, fix the spec before asking the user to review it.

## User Handoff

After writing the spec, send a short handoff like:

> Spec written to `<path>`. Please review it and tell me what to change, or tell me to switch to Plan Mode and I will turn it into an implementation plan.

Wait for the user's response before doing implementation work. Do not skip directly from brainstorming into code changes. The next step after an approved spec is Plan Mode.

## Visual Topics

If the next decision would be easier to understand visually, offer that in its own short message before continuing. Use browser tooling only when the user would understand the decision better by seeing it than by reading plain text.
