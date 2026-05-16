# Spring Framework Rules

Use this reference for Java/Spring planning, implementation, and review. These are structure and interface rules, so they take priority over local style preferences.

## Service and API contracts

- `@Service` classes should use verb-led use-case names such as `CreateOrder` or `CancelPayment`.
- Request types should end in `Request`.
- Response types should end in `Response`.
- Prefer immutable request/response types, ideally `record`.

## Time handling

- Do not call `LocalDateTime.now()` directly inside services.
- Pass current time through a request object or as the final method parameter.
- Do not use SQL `NOW()` for business timestamps; bind application-provided time values instead.
- Favor deterministic time flow so tests can control the clock.

## Package structure

- Prefer package-by-feature over package-by-layer.
- Keep related controller, use-case, repository interface, domain type, and enum in the same feature package when that matches the existing project direction.
- Default internal implementation classes to package-private.
- Expose `public` types only when another package genuinely needs them.

## Dependency direction

- High-level use cases should depend on interfaces, not concrete infrastructure classes.
- The client package should own the interface it needs.
- Infrastructure classes implement those interfaces.
- Domain code should remain independent from framework and infrastructure concerns where practical.

## Cross-package communication

- Prefer clear public interfaces or facades for package-to-package calls.
- Use events when looser coupling is the better fit.
- Avoid direct dependencies on another package's internal implementation classes.
- Avoid cyclic dependencies between feature packages.

## Review priorities

When reviewing or self-reviewing Java/Spring changes, check these first:

1. Noun-style `@Service` class names
2. Missing `Request` / `Response` naming on boundary types
3. Direct `LocalDateTime.now()` or SQL `NOW()` in application logic
4. New package-by-layer drift in code that should live under a feature package
5. Direct dependencies on `Jpa...`, `MySql...`, or other concrete infrastructure classes from high-level use cases
