# ThousandEyes Debug Reference

## MCP Tool Checklist

Read descriptor JSON before calling tools. Primary ThousandEyes tools for this skill:

- `list_network_app_synthetics_tests`
- `get_network_app_synthetics_test`
- `get_network_app_synthetics_metrics`
- `get_service_map` (HTTP only)
- `get_full_path_visualization` / `get_path_visualization_results` (network-path context)

Observability correlation:

- Inventory every observability MCP available in the current session before choosing a backend.
- Prefer backend-native trace lookup first, then fall back to logs, events, metrics, incidents, or service topology.
- Do not assume Splunk or Datadog are the only backends. Treat them as examples, not requirements.

Examples in the current workspace may include:

- Datadog MCP: `search_datadog_spans`, `get_datadog_trace`, `search_datadog_logs`, `get_datadog_metric`, `search_datadog_events`, `search_datadog_services`
- Splunk MCP: `splunk_get_indexes`, `splunk_run_query`

## Investigation Order

1. Resolve the exact test and fetch full config.
2. Pull recent metrics for the requested time window.
3. Branch on test type:
   - `http-server`: inspect `distributedTracing`, then try `get_service_map`
   - other test types: stay metric-first and use path data only if relevant
4. Enumerate all observability backends available in the session.
5. Correlate the trace in every backend that can query traces, logs, events, metrics, incidents, or topology.
6. Only then produce root cause and remediation guidance.

## Metric Quick Map By Test Type

- `http-server`:
  - Availability: `WEB_AVAILABILITY`
  - Errors: `WEB_TOTAL_ERROR_COUNT`, `WEB_HTTP_ERROR_COUNT`, `WEB_DNS_ERROR_COUNT`, `WEB_CONNECT_ERROR_COUNT`, `WEB_SSL_ERROR_COUNT`
- `agent-to-server` / network:
  - Health: `NET_LOSS`, `NET_LATENCY`, `NET_JITTER`
- `dns-server`:
  - Health: `DNS_SERVER_AVAILABILITY`, `DNS_SERVER_TIME`
- `dns-trace`:
  - Health: `DNS_TRACE_AVAILABILITY`, `DNS_TRACE_QUERY_TIME`
- `page-load`:
  - Health: `WEB_PAGE_LOAD_COMPLETION_RATE`, `WEB_PAGE_ERROR_COUNT`, `WEB_PAGE_LOAD`
- `web-transactions`:
  - Health: `WEB_TRANSACTION_COMPLETION`, `WEB_TRANSACTION_ERROR`, `WEB_TRANSACTION_TIME`
- `api`:
  - Health: `API_REQUEST_COMPLETION`, `API_REQUEST_ASSERT_ERROR_COUNT`, `API_REQUEST_OTHER_ERROR_COUNT`, `API_TRANSACTION_TIME`
- `bgp`:
  - Health: `BGP_REACHABILITY`, `BGP_PATH_CHANGES`

## HTTP Distributed Tracing Decision Rules

1. If `distributedTracing=false`: report as observability gap and continue with non-trace evidence.
2. If `distributedTracing=true`:
   - call `get_service_map`
   - if map exists, identify failing service and dominant error
   - if map missing, continue with trace-ID fallback
3. If `get_service_map` shows healthy downstream services but the test still fails, do not force a backend root cause. Consider test-side errors such as DNS, connect, SSL, or assertion failures.

## Trace ID Extraction Notes

When available, parse W3C `traceparent`:

- Format: `00-<trace_id>-<parent_span_id>-<flags>`
- `trace_id` length: 32 lowercase hex chars

Regex:

```txt
^00-([0-9a-f]{32})-[0-9a-f]{16}-[0-9a-f]{2}$
```

## Generic Backend Correlation Playbook

For every observability backend exposed through MCP:

1. Read the backend tool schema first.
2. Identify which of these capabilities exist:
   - direct trace lookup
   - raw log search
   - metric query
   - event or incident search
   - service topology or dependency lookup
3. Query in this order:
   - trace ID exact match
   - trace ID in logs or span-like records
   - target, service, hostname, URL, or request context scoped to the ThousandEyes failing window
   - service-level error and latency telemetry for the same window
4. Capture one status per backend:
   - `hit`: trace or directly supporting telemetry found
   - `miss`: backend checked but no relevant trace or telemetry found
   - `blocked`: backend present but available MCP tools cannot query the needed data
5. For every backend, record:
   - tool(s) used
   - whether trace lookup was possible
   - whether trace lookup succeeded
   - which telemetry types were checked
   - which service, dependency, or error signal was found
6. Correlate findings back to:
   - ThousandEyes test identity
   - failing window
   - trace ID when available
   - implicated service, dependency, or infrastructure component

## Splunk Correlation Playbook

1. Discover indexes:

```spl
| metadata type=sources index=*
```

2. Broad trace search:

```spl
search index=* ("<trace_id>" OR trace_id="<trace_id>" OR traceId="<trace_id>")
| head 200
```

3. Service/error rollup:

```spl
search index=* ("<trace_id>" OR trace_id="<trace_id>" OR traceId="<trace_id>")
| stats count values(error) values(status) by service trace_id traceId
| sort - count
```

4. Time-bounding:
   - Keep `earliest_time` and `latest_time` aligned with ThousandEyes failing window.

5. Favor searches that preserve service name, error message, HTTP status, and span identifiers. The goal is a defensible evidence chain, not just a trace hit.

## Datadog Correlation Playbook

1. Trace-first lookup:

```txt
search_datadog_spans query='trace_id:<trace_id>'
```

2. If the trace is found, expand it:

```txt
get_datadog_trace trace_id='<trace_id>'
```

3. Pull correlated logs in the same window:

```txt
search_datadog_logs query='("<trace_id>" OR @trace_id:<trace_id> OR trace_id:<trace_id>)'
```

4. If a failing service is identified, confirm surrounding telemetry:
   - `search_datadog_events` for deploys/incidents in the same window
   - `get_datadog_metric` for service latency/error metrics
   - `search_datadog_services` if service ownership or naming needs clarification

5. Preserve service name, resource name, span status, error message, HTTP status, and timing deltas. Prefer exact trace hits over fuzzy text matches.

## Backend Sweep Pattern

1. Enumerate every observability MCP available in the session.
2. Apply the generic backend correlation playbook to each backend.
3. Search by `trace_id` first when supported.
4. Pull related telemetry for the same ThousandEyes failing window even when direct trace search is unavailable.
5. Record one of:
   - `hit`: trace found or directly supporting telemetry collected
   - `miss`: backend checked but no relevant trace or telemetry found
   - `blocked`: backend exists but current tools cannot query this data
6. Correlate service names, dependency signals, and error signatures back to the failing ThousandEyes test.
7. Do not stop after the first `hit`; complete the sweep across all available backends.

## Fix Confirmation Policy

Before code edits, always confirm:

- root cause confidence is sufficient
- target repository/service is available
- user explicitly approved implementing the fix now
