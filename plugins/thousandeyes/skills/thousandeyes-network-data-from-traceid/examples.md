# Output Templates

## TraceID Resolved to ThousandEyes Data

```markdown
## ThousandEyes Network Data from TraceID

- Trace ID: `<traceId>`
- Observability Platform coverage:
  - `<platform-1>`: `<hit|miss|blocked>`; lookup `<trace|span-search|log-search>`; tracestate `<found|not found>`
  - `<platform-2>`: `<hit|miss|blocked>`; lookup `<trace|span-search|log-search>`; tracestate `<found|not found>`
- Tracestate attribute: `<tracestate|w3c.tracestate>`
- Raw tracestate: `<raw value>`
- Decoded ThousandEyes payload: `<decoded value>`

### ThousandEyes Result
- Account: `<accountId>`
- Test: `<test name>` (`<testId>`, `<type>`)
- Result window: `<time window or exact round>`
- Agent: `<agentId>`
- Metrics: `<key metrics or error signal>`
- Path data: `<summary or n/a>`
- Service-map context: `<summary or n/a>`

### Notes
- Match rule: `<exact match or nearest-round rule>`
- Next step: `<optional follow-up>`
```

## Trace Found but ThousandEyes Linkage Missing

```markdown
## ThousandEyes Network Data from TraceID

- Trace ID: `<traceId>`
- Observability Platform coverage:
  - `<platform-1>`: `hit`; tracestate `not found`
  - `<platform-2>`: `miss`
- ThousandEyes linkage: unavailable

### Blocking Issue
`tracestate` or `w3c.tracestate` did not contain a usable `te=` value, so the ThousandEyes account, test, agent, and execution identifiers could not be recovered.

### Next step
1. Check whether another Observability Platform stores richer span attributes for this trace.
2. Ask for a trace export or raw span payload that includes W3C tracestate.
```
