# Error Log Noise Patterns

## Category A: Infra/Agent Noise

These are JVM or Datadog agent artifacts misclassified as errors. Exclude them from the application error count.

| Pattern | Why it's noise |
|---------|---------------|
| `dd.trace` + `INFO` | Datadog agent internal log misrouted to error level |
| `JAVA_TOOL_OPTIONS` | JVM startup env var echo, not an error |
| `Picked up JAVA_TOOL_OPTIONS` | Same as above |
| `OpenJDK 64-Bit Server VM warning` | JVM performance warning, informational |
| `logback` / `Appender named [CONSOLE]` | Logging framework config message |
| `DebuggerAgent` | Datadog debugger agent lifecycle message |
| `StatusLogger` | Log4j2 internal status, not application error |
| `DDAgentStatsDConnection` | StatsD connection lifecycle |
| `ProfileUploader` | Datadog profiler upload status |
| `SymDB Report` | Datadog symbol database sync |

## Category B: Deploy-Related Errors

Transient errors caused by rolling updates. Correlate with deploy events.

| Pattern | How to identify |
|---------|----------------|
| HTTP 503 during deploy | Cross-reference with deploy events in same time window |
| Readiness probe failures | Overlap with pod restart timestamps |
| Connection refused / reset | Brief spike during container replacement |

## Category C: Application Errors

Everything not in A or B. These are the core of the report.

## Noise Exclusion Filter

Use this query suffix to exclude Category A noise from raw log queries:
```
-"dd.trace" -"JAVA_TOOL_OPTIONS" -"OpenJDK" -"Appender named" -"Picked up"
```
