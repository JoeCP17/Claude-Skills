---
name: narrow-upsert-to-update
description: "Use when one Java `ActionSet.newAction(...)` write path in this project still calls a shared `m_*_merge` upsert-like query, and you want to replace that single `actionId(queryId)` with a dedicated `update` query after tracing which DB-read values actually change. This skill is specific to the project's Java service plus SQL XML mapper flow and enforces a mandatory coverage gate before code edits."
---

# Narrow Upsert To Update

Use this skill for one narrow legacy write refactor in this project:

- one user-specified `actionId(queryId)`
- one Java save path using `ActionSet.newAction(...)`
- one new dedicated SQL XML `update` query

The purpose is to remove wasteful "read row, copy row back, overwrite a few fields, call shared merge" behavior without changing shared callers.

Read [references/pattern.md](references/pattern.md) before editing anything.

## When To Use

- A save path calls a shared `m_*_merge` query but only a few columns truly change.
- The service reads a full DB row and re-binds many preserved values into `parms`.
- You want to replace one actionId for one use case with a dedicated `update`.
- The code lives in this repo's Java service plus SQL XML mapper flow.

## When Not To Use

- Broad cleanup across multiple queries or multiple save paths
- Non-Java or non-XML-mapper work
- Cases where the path still needs INSERT semantics
- Generic database refactors outside `ActionSet + Action`

## Hard Scope Limits

- Work on exactly one user-specified `actionId(queryId)`.
- Keep the existing shared `merge` query unchanged.
- Add exactly one new dedicated `update` query for the selected use case.
- Change only the single targeted call site to the new actionId.
- Keep the diff minimal. Do not widen into nearby candidates or unrelated cleanup.

## Workflow

1. Confirm the request identifies one target `actionId(queryId)` and one use case.
2. Locate:
   - the Java service call site
   - the `ActionSet.newAction(...)` usage
   - the shared SQL XML query
3. Trace the save path end to end:
   - where the row is read from DB
   - where each bound value comes from
   - where a value is recalculated, overwritten, or merely copied through
4. Classify fields into:
   - changed fields
   - identifier keys
   - preserved fields
   - timestamp or audit fields
5. Search tests broadly using:
   - service class name
   - use case name
   - existing actionId
   - related acceptance or integration coverage
6. Decide whether the target save path is covered strongly enough to refactor safely.
7. If coverage is weak or indirect, stop and ask the user before any code edit.
8. If coverage is sufficient:
   - add one dedicated `m_<entity>_<usecase>_update` query
   - include only proven changed fields in `SET`
   - use only row-identifying keys in `WHERE`
   - change only the targeted actionId call site
   - remove preserved-value rebinding that is no longer needed
   - preserve or improve timestamp semantics
9. Run the smallest verification set that gives confidence.

## Mandatory Rules

- Do not guess changed fields from names or proximity. Trace them.
- If a field is not proven to change, exclude it from the new `SET` or stop and ask.
- If the old SQL updates time using `NOW()`, the new path must not lose that behavior.
- Prefer an application-generated time parameter over DB `NOW()` in the new path, usually from `LocalDateTime.now()`.
- If the old SQL does not record change time, add change-time recording in the new dedicated update path when the right column is identifiable.
- If timestamp semantics or change-time columns are unclear, stop and ask.
- Do not satisfy the coverage gate by silently proceeding on weak tests. Stop and ask first.
- Do not rewrite the shared `merge` query to fit the new path.
- Add a source-preservation comment at the new SQL XML query that includes the original C# file and line range, not only the queryId. Example:
  `<!-- C# BO 원본: ActionManager.cs:4124-4126 m_delivery_merge (공유 upsert에서 분리) -->`
- Add a source-preservation comment at the Java call site where the new actionId is introduced, and keep the original file and line range. Example:
  `// C# BO 원본: ActionManager.cs:4124-4126 m_delivery_merge → m_delivery_partial_cancel_update로 분리`
- If an existing comment already has the original C# file and line range, keep that existing comment unchanged and add the new source-preservation comment on a separate line.
- Treat source comments as append-only for this workflow. Do not rewrite, replace, or compress an existing migration comment just to add the new origin note.
- Do not downgrade source comments from file+line references to only queryId or use-case prose.
- Do not delete existing C# BO migration comments that explain the original source path unless the user explicitly asks for comment cleanup.

## Stop Conditions

Stop and ask the user if any of the following is true:

- the request really spans more than one actionId
- the path may still require INSERT behavior
- changed fields cannot be proven safely
- the correct timestamp column cannot be identified safely
- test coverage is weak for the target save path

## Reporting

In the final response, include:

- the old and new actionId
- changed fields moved into the dedicated `update`
- `WHERE` keys used
- how timestamp handling changed
- what tests were used to justify the refactor
- the C# BO source path carried forward in code comments, including original file and line range
- any remaining risks or explicit user-approved exceptions
