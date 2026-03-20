# Report Template

Use this exact structure when generating the error report.

```markdown
# [Service Name] Error Status Report

- Period: YYYY.MM.DD HH:mm:ss ~ YYYY.MM.DD HH:mm:ss (KST)
- Environment: prod / dev / stage
- Generated: YYYY.MM.DD HH:mm:ss (KST)

---

## 1. Error Log Summary

| Item | Value |
|------|-------|
| Total error logs | N |
| Infra noise (Cat A) | N |
| Deploy-related (Cat B) | N |
| **Application errors (Cat C)** | **N** |

### 1-1. Application Error Detail

| Error Message | Count | Env | Time Range (KST) | Analysis |
|--------------|-------|-----|-------------------|----------|
| [message] | N | prod/dev | HH:mm~HH:mm | [analysis] |

### 1-2. Error Causal Chain Analysis
- Analyze cause-effect relationships among errors in the same time window
- Example: PG refund failure → NPE → inventory restore failure

---

## 2. Incidents

| Status | Count |
|--------|-------|
| Active | N |
| Resolved | N |

### Incident List
- [Title] - Status - Created

---

## 3. Monitors

| Status | Count |
|--------|-------|
| Alert | N |
| Warn | N |
| OK | N |

### Alerting Monitors
- [Name] - Status - Last Triggered

---

## 4. Events

| Item | Value |
|------|-------|
| Total events | N |

### Key Events (deploys, scaling, incidents)
- [Title] - Time (KST)

---

## 5. API Performance

### 5-1. TPS / Request Volume

| Item | Value |
|------|-------|
| Total requests | N |
| Daily average | N/day |
| Avg TPS | N |
| Peak TPS | N (time) |

### 5-2. Top 10 APIs by Volume

| # | Endpoint | Total | Daily Avg | Avg TPS | Share |
|---|----------|-------|-----------|---------|-------|
| 1 | [endpoint] | N | N | N | N% |

### 5-3. Slow APIs (p99 >= 800ms)

| # | Endpoint | p99 Avg | p99 Max | Total Requests | Avg TPS |
|---|----------|---------|---------|----------------|---------|
| 1 | [endpoint] | Nms | Nms | N | N |

### 5-4. Warning Zone (p99 500~800ms)
- APIs below 800ms that still warrant attention

---

## 6. Recommendations

| Priority | Item | Description |
|----------|------|-------------|
| HIGH | [item] | [detail] |
| MED | [item] | [detail] |
| LOW | [item] | [detail] |
```
