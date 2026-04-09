# TraceID to ThousandEyes Reference

## MCP Tool Checklist

Read descriptor JSON before calling tools.

Primary ThousandEyes tools for this skill:

- `list_network_app_synthetics_tests`
- `get_network_app_synthetics_test`
- `get_network_app_synthetics_metrics`
- `get_path_visualization_results`
- `get_full_path_visualization`

Observability Platform expectations:

- Prefer exact trace lookup by `traceId`
- If direct trace lookup is unavailable, prefer exact span or log search by `traceId`
- Record one outcome per backend: `hit`, `miss`, or `blocked`

## Trace Attribute Extraction Rules

Search every trace hit for these attribute names:

- `tracestate`
- `w3c.tracestate`

Inspect all levels that the backend exposes:

- trace-level attributes
- resource attributes
- span attributes
- event attributes when the backend includes span events inline

If the backend also exposes ThousandEyes OpenTelemetry attributes such as `thousandeyes.account.id` or `thousandeyes.test.id`, use them to validate the decoded result. Do not use them as a substitute for the `te=` value when you still need agent or exact execution-time context.

## W3C Tracestate Parsing Rules

Treat the attribute as a comma-separated W3C vendor-state list:

```txt
vendor-a=foo,te=app.stg.thousandeyes.com/network-app-synthetics/views/?__a%3D102374&testId%3D562934&agentId%3D2334&teRegion%3D0&startTime%3D1775723400,vendor-b=bar
```

Parsing order:

1. Split on top-level commas into vendor entries.
2. Select the entry whose key is `te`.
3. Remove the `te=` prefix.
4. URL-decode the value once before reading query parameters.
5. If the decoded value has no scheme, prepend `https://` temporarily so standard URL parsing can read the query string.

## ThousandEyes Payload Example

Raw `te` value:

```txt
te=app.stg.thousandeyes.com/network-app-synthetics/views/?__a%3D102374&testId%3D562934&agentId%3D2334&teRegion%3D0&startTime%3D1775723400
```

Decoded ThousandEyes value:

```txt
app.stg.thousandeyes.com/network-app-synthetics/views/?__a=102374&testId=562934&agentId=2334&teRegion=0&startTime=1775723400
```

Recovered fields:

- `__a` -> `accountId=102374`
- `testId` -> `testId=562934`
- `agentId` -> `agentId=2334`
- `startTime` -> `executionTime=1775723400` (use this as the round selector for the exact test execution)

Treat `startTime` as Unix epoch seconds unless the backend clearly documents a different unit.

## ThousandEyes Query Strategy

1. Scope the ThousandEyes query to `accountId` when the available tool supports account selection.
2. Resolve the test with `get_network_app_synthetics_test` or `list_network_app_synthetics_tests`.
3. Query metrics around `executionTime` with the narrowest practical window.
4. If path data is relevant, fetch `get_path_visualization_results` or `get_full_path_visualization` for the same test, agent, and execution time.
5. If the test is HTTP and service context matters, use `get_service_map` for the same time window as supporting context.

## Exact Result Selection Rules

When the ThousandEyes MCP does not expose a literal `roundId`:

1. Prefer results from the recovered `agentId`.
2. Select the result or bucket with the smallest time delta from `executionTime`.
3. State the chosen selection rule in the final answer if the match is approximate.
4. If the backend only returns aggregated metrics, say that the exact round was not directly exposed and summarize the closest available window instead.

## Failure Modes

- No Observability Platform returns the trace.
- A backend returns the trace, but no `tracestate` or `w3c.tracestate` attribute exists.
- `tracestate` exists, but no `te=` vendor entry is present.
- The `te` value decodes, but one of `__a`, `testId`, `agentId`, or `startTime` is missing.
- ThousandEyes returns the test definition, but not an exact round or path result for the recovered execution time.
- Multiple Observability Platforms disagree on the recovered ThousandEyes identifiers.

In all of these cases, report the precise gap instead of inferring missing identifiers.
