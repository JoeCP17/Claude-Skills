# Narrow Upsert Pattern

Use this reference when executing the `narrow-upsert-to-update` workflow.

## Pattern

Keep the shared upsert-like `merge` query for existing callers. Add one dedicated `update` query for one use case, then swap exactly one targeted Java actionId call site to the new query.

This is not "shrink the shared merge." It is "split one narrow path away from the shared merge."

## Why This Skill Exists

The target smell is:

1. read a row from DB
2. copy many DB values back into `parms`
3. overwrite a few values
4. call a large shared `m_*_merge`

The goal is to reduce no-op rewrites. You must prove which DB-read values actually change and store only those values in the new dedicated `update`.

## Field Classification

Classify every field you encounter into exactly one group.

### Changed Field

A value that is recalculated, overwritten from request input, or otherwise changed in the target save path.

Only these fields belong in the new `SET` clause.

### Identifier Key

A value used only to identify the row to update.

Only these fields belong in the new `WHERE` clause.

### Preserved Field

A DB-read value that is re-bound only to satisfy the shared merge query.

These fields must be removed from the narrow dedicated `update` path.

### Timestamp or Audit Field

A field that records who changed the row and when it changed.

Treat these separately from business fields. Preserve or improve their semantics.

## Trace Rule

Do not classify fields by reading the final `parms.put(...)` block alone.

Trace each value through the whole save path:

- where it was loaded
- where it was transformed
- where it was overridden
- whether it stays unchanged all the way to write time

If you cannot prove whether a value changes, stop and ask instead of guessing.

## Timestamp Rules

- If the old shared SQL updates time using `NOW()`, the new dedicated `update` must not lose that behavior.
- Prefer generating the current time in Java and binding it as a parameter instead of using DB `NOW()` in the new path.
- Usually this means creating a current-time value in the service with `LocalDateTime.now()` and passing it into SQL.
- If the old SQL does not record a change timestamp, the new dedicated `update` must add one when the correct column is identifiable.
- If multiple timestamp columns are plausible and the correct one is unclear, stop and ask.

## Naming

Prefer:

- `m_<entity>_<usecase>_update`

Examples:

- `m_delivery_partial_cancel_update`
- `m_delivery_fee_recalculate_update`

The name should expose the narrow use case, not a generic action.

## Review Checklist

- Does this path truly not need INSERT semantics?
- Is the shared `merge` query still untouched?
- Does the new `SET` contain only proven changed fields?
- Does the new `WHERE` contain only row-identifying keys?
- Were preserved-value rebindings removed from the narrow path?
- Was timestamp handling preserved or improved?
- Did the new SQL query keep a comment that names the original C# file and line range, not just the query id?
- Did the Java action swap keep a comment that points back to the original C# file and line range?
- Did the diff stay limited to one new query, one actionId swap, and minimum required cleanup?

## Common Mistakes

- Editing the shared `merge` query itself
- Still binding most of the original row into the dedicated `update`
- Adding unrelated cleanup because the surrounding code looks messy
- Omitting change-time updates
- Replacing more than the single requested actionId
- Proceeding despite weak save-path coverage
- Deleting C# BO migration comments during the refactor so the origin of the split is lost
- Rewriting a source comment and accidentally dropping the original C# line numbers
- Replacing an existing migration comment instead of adding a separate origin-preservation comment below it

## Comment Preservation

When splitting one narrow path away from a shared legacy merge, preserve the migration trail in both places:

- SQL XML example:
  `<!-- C# BO 원본: ActionManager.cs:4124-4126 m_delivery_merge (공유 upsert에서 분리) -->`
- Java call site example:
  `// C# BO 원본: ActionManager.cs:4124-4126 m_delivery_merge → m_delivery_partial_cancel_update로 분리`

If an existing migration comment is already present, keep it unchanged and add the new source comment as an additional line. Do not rewrite the existing comment to "improve" it.

Carry this origin forward in the final report as part of the refactor result, including the original file and line range.

## Project Example

Current shared query example:

- mapper: `src/main/resources/sql/mall.admin.sell.xml`
- query id: `m_delivery_merge`

Observed timestamp semantics in that query:

- duplicate-key update sets `MOD_USER_NO = :SS_USER_NO`
- duplicate-key update sets `MOD_DT = now()`

For a narrow refactor that splits a use case away from `m_delivery_merge`, the dedicated `update` path must preserve those semantics or improve them by passing application-generated current time into SQL.

## Validation Example

Branch example for dry-run validation:

- service: `src/main/java/com/ktown4u/thomas/order/legacyadmin/delivery/PartialCancelService.java`
- current actionId: `m_delivery_merge`
- likely dedicated query name: `m_delivery_partial_cancel_update`

Expected gate behavior:

- detect the DB-read plus re-bind pattern
- inspect related tests, including `PartialCancelDeliveryAcceptanceTest`
- notice that direct save-path or actionId characterization coverage is still weak
- stop and ask before doing the refactor
