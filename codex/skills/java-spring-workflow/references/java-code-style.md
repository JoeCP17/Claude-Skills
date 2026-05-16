# Java Code Style

Use this reference during Java implementation and Java/Spring review. These rules are implementation-time rules, not brainstorming rules.

## Naming

- Prefer record-style accessors: `status()` instead of `getStatus()`.
- Query methods return data without mutation and should read naturally:
  - simple lookup: `name()`
  - conditional lookup: `userById(...)`, `ordersFor(...)`, `latestPaymentBy(...)`
- Command methods mutate state and should start with verbs:
  - `create(...)`, `update(...)`, `cancel(...)`, `process(...)`

## Parameters and locals

- Add `final` to parameters and local variables unless the surrounding codebase clearly avoids it.
- Split method or constructor parameters across multiple lines when there are 3+ parameters or the line becomes long.
- Align each parameter vertically and place the closing `)` on its own aligned line.

## Exceptions and logging

- Prefer specific unchecked exceptions or `RuntimeException` over broad `Exception`.
- Use fail-fast behavior for core business rules, invalid state, and new well-tested flows.
- Use silent failure only for truly auxiliary behavior in legacy or low-confidence paths, and log it clearly.
- Keep log prefixes consistent within a feature, such as `payment history:`.
- Avoid duplicate logging for the same failure across multiple layers.

## Conditionals and null handling

- Use Yoda comparisons for nulls, constants, and sentinel values when following this style:
  - `null != value`
  - `EMPTY == this`
- Short guard clauses are acceptable on one line: `if (!ready) return EMPTY;`
- Prefer null-object or sentinel patterns like `EMPTY` over raw `null` when the type already supports that pattern.

## Collections and iteration

- Prefer stream pipelines over manual loops when the transformation is straightforward.
- Prefer immutable collection results when practical.
- Prefer collection interfaces in signatures and fields unless a concrete type is required.
- Prefer method references over trivial lambdas when readability improves.

## Class and DTO design

- Prefer `record` for immutable request/response and parameter objects when available.
- If `record` is not viable, keep DTOs immutable and use record-style fluent accessors instead of getters.
- Avoid `@Builder` unless the existing codebase already standardizes on it for the relevant type.
- Keep classes small and purpose-driven; do not add speculative helpers or unused methods.

## Review priorities

When reviewing, prioritize these violations:

1. Getter-style accessors where fluent accessors are expected
2. Missing `final` in touched code when the surrounding code follows the rule
3. `@Builder` on simple immutable DTOs
4. Inconsistent logging prefixes in the same feature
5. Manual loops and mutable collectors where a simple immutable stream pipeline would be clearer
