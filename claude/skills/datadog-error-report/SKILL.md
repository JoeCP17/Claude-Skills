---
name: datadog-error-report
description: "Generate a comprehensive error status report for a service instance using Datadog MCP. Use this skill whenever the user asks about error reports, error status, service health, latency analysis, API performance, incident checks — including Korean phrases like 서비스 현황, 에러 리포트, 장애 현황, latency 분석, API 성능, or even casual requests like 'thomas 어제 에러 좀 봐줘' or 'check alice errors last week'. If the user mentions a service name and wants to know what went wrong, this is the right skill."
---

# Datadog Error Report

Collect error logs, incidents, monitors, events, and API performance metrics from Datadog MCP, classify noise from real errors, and produce a structured report.

## Input

The user provides:
- **Service name** — maps to Datadog `service` tag (e.g., Thomas, Alice)
- **Time range** — start/end in KST (end defaults to now)
- **Environment** — prod/dev/stage (defaults to prod)

## Execution

### 1. Parse parameters

Convert timestamps to **milliseconds** using Python with KST (UTC+9) — seconds will silently produce wrong results. See `references/datadog-queries.md` for the conversion snippet.

### 2. Load Datadog MCP tools

Run 6 ToolSearch calls in parallel **before** any data queries — the tools aren't available until loaded. See `references/datadog-queries.md` for the exact tool names.

### 3. Collect data in parallel (6 queries)

Launch all simultaneously — running them sequentially takes 6x longer for no benefit:

| # | Data | Purpose |
|---|------|---------|
| 1 | Error logs (pattern mode) | See the big picture of all errors |
| 2 | Incidents | Active/resolved incidents for the service |
| 3 | Monitors | Alert/warn/OK status |
| 4 | Events | Deploys, scaling, incidents |
| 5 | p99 latency by endpoint | Find slow APIs |
| 6 | TPS / request volume | Understand traffic patterns |

See `references/datadog-queries.md` for exact query templates.

### 4. Classify error logs (A/B/C)

This is the most important step — without it, infra noise buries real application errors.

| Category | What it is | Action |
|----------|-----------|--------|
| **A — Infra noise** | JVM/agent artifacts misclassified as errors | Report separately, don't count as app errors |
| **B — Deploy-related** | Transient errors during rolling updates | Correlate with deploy events, report separately |
| **C — Application errors** | Everything else | Core of the report — analyze in detail |

See `references/noise-patterns.md` for the full pattern list and exclusion filters.

### 5. Fetch raw logs for Category C

Re-query with noise exclusion filters to get actionable detail on real application errors.

### 6. Generate report

Use the template in `references/report-template.md`. The report covers:
1. Error summary with A/B/C classification
2. Category C detail with frequency, time distribution, and causal chain analysis
3. Incidents, monitors, events
4. API performance (TPS, p99, slow APIs)
5. Prioritized recommendations

### 7. Deep links

When the user wants to drill into specific errors, construct Datadog URLs using **facet queries** (`@error.message:*keyword*`), not full-text search — special characters break the UI. See `references/datadog-queries.md` for the URL format.
