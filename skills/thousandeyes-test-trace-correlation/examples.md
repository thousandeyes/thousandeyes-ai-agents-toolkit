# Output Templates

## Diagnosis Only

```markdown
## ThousandEyes Test Diagnosis

- Test: <name> (`<testId>`, `<type>`) target `<target>`
- Scope: window `<window>` aid `<aid or default>`
- Latest signal: availability `<value>`; dominant error `<metric/error>`; failing window `<time or bucket>`
- HTTP tracing: distributedTracing `<true|false>`
- Service map: `<available|unavailable>`; failing service(s): `<list or n/a>`
- Trace correlation: traceId `<id or unavailable>`
- Observability Platform coverage:
  - `<observability-platform-1>`: `<hit|miss|blocked>`; trace lookup `<yes/no>`; telemetry `<trace/logs/metrics/events/incidents/topology>`
  - `<observability-platform-2>`: `<hit|miss|blocked>`; trace lookup `<yes/no>`; telemetry `<trace/logs/metrics/events/incidents/topology>`

### Root cause
<clear statement with evidence>

### Recommended remediation
1. <action 1>
2. <action 2>
```

## Diagnosis Plus Confirmed Fix

```markdown
## ThousandEyes Test Diagnosis + Fix

- Test: <name> (`<testId>`, `<type>`)
- Root cause: <statement>
- Observability Platform coverage: `<all Observability Platform summaries>`

### Implemented change
- Files: `<path1>`, `<path2>`
- Behavior change: <what now succeeds>

### Validation
- Checks run: `<lint/test/command>`
- Result: `<pass/fail>`
- Post-fix verification plan: <how to confirm in ThousandEyes>
```

## Service Map Unavailable, Trace-Only Correlation

```markdown
## ThousandEyes Test Diagnosis (Trace Fallback)

- Test: <name> (`<testId>`, `http-server`)
- distributedTracing: `true`
- `get_service_map`: unavailable (`<reason if known>`)
- Recovered traceId: `<trace_id>`
- Correlation window: `<earliest>` to `<latest>`

### Observability Platform Coverage
- `<observability-platform-1>`: `<hit|miss|blocked>`; trace lookup `<yes/no>`; service(s) `<list or n/a>`; error `<message/code or n/a>`
- `<observability-platform-2>`: `<hit|miss|blocked>`; trace lookup `<yes/no>`; service(s) `<list or n/a>`; error `<message/code or n/a>`

### Root cause
<statement linked to trace evidence>

### Next actions
1. <fix action>
2. <verification action>
```
