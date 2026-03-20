# Datadog Query Reference

## Timestamp Conversion

Always use Python with KST (UTC+9). Timestamps must be in **milliseconds**.

```python
from datetime import datetime, timezone, timedelta
kst = timezone(timedelta(hours=9))
dt = datetime(YYYY, M, D, H, m, s, tzinfo=kst)
ms = int(dt.timestamp() * 1000)
```

## Required ToolSearch (run before any data query)

Load these 6 tools in parallel:
- `select:mcp__datadog-mcp__search_datadog_logs`
- `select:mcp__datadog-mcp__search_datadog_incidents`
- `select:mcp__datadog-mcp__search_datadog_monitors`
- `select:mcp__datadog-mcp__search_datadog_events`
- `select:mcp__datadog-mcp__get_datadog_metric`
- `select:mcp__datadog-mcp__analyze_datadog_logs`

## Query Templates

### Error Logs (Pattern Mode)
```
query: "service:<svc> env:<env> status:error"
use_log_patterns: true
max_tokens: 8000
```

### Error Logs (Raw, noise-excluded)
```
query: "service:<svc> env:<env> status:error -\"dd.trace\" -\"JAVA_TOOL_OPTIONS\" -\"OpenJDK\" -\"Appender named\" -\"Picked up\""
use_log_patterns: false
extra_fields: ["http*", "error*", "exception*"]
max_tokens: 10000
```

### Incidents
```
query: "title:*<svc>*"
from/to: ISO8601 with KST offset
```

### Monitors
```
query: "<svc>"
```

### Events
```
query: "<svc>"
from/to: unix milliseconds
```

### p99 Latency
```
queries: ["p99:trace.servlet.request{service:<svc>,env:<env>} by {resource_name}"]
max_tokens: 15000
```

### TPS (Total)
```
queries: ["sum:trace.servlet.request.hits{service:<svc>,env:<env>}.as_count()"]
```

### TPS (Per Endpoint)
```
queries: ["sum:trace.servlet.request.hits{service:<svc>,env:<env>} by {resource_name}.as_count()"]
```

## Calculation Formulas

```
avg_tps = total_requests / ((to_ms - from_ms) / 1000)
daily_avg = total_requests * 86400 / ((to_ms - from_ms) / 1000)
peak_tps = max_bin_hits / bin_interval_seconds
```

## p99 Result Parsing

When metric results are saved to file:
```python
import json
with open('<file_path>', 'r') as f:
    data = json.loads(f.read())
text = data[0]['text']
json_data = json.loads(text[text.find('[{'):])
sorted_data = sorted(json_data, key=lambda x: x.get('overall_stats',{}).get('avg',0), reverse=True)
for item in sorted_data:
    scope = item['scope'].replace('resource_name:', '')
    avg = item['overall_stats']['avg']
    mx = item['overall_stats']['max']
    print(f'{scope}: p99_avg={avg*1000:.1f}ms  p99_max={mx*1000:.1f}ms')
```

## Deep Link URL Format

Use **facet queries** (not full-text) because special characters break the Datadog UI:

**Correct:**
```
https://app.datadoghq.com/logs?query=service:<svc>+env:<env>+status:error+@error.message:*keyword*&from_ts=<ms>&to_ts=<ms>&live=false
```

**Incorrect (breaks in UI):**
```
service:thomas status:error "ResultSet.HasResultError()"   ← parentheses break it
service:thomas status:error HasResultError                  ← full-text matching unreliable
```

Always use `@error.message:*keyword*` or `@error.kind:FullyQualifiedClassName`.
