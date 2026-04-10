---
name: thousandeyes-network-data-from-traceid
description: Obtain ThousandEyes Network & App Synthetics data given a trace ID. Use when a user has a `traceId`, ThousandEyes MCP is available, and one or more Observability Platform integrations or equivalent tooling paths are available to query every relevant Observability Platform for the trace, extract `tracestate` or `w3c.tracestate`, decode the embedded ThousandEyes permalink, recover the ThousandEyes account/test/agent/execution identifiers, and fetch the matching ThousandEyes network data.
---
# Obtain ThousandEyes Network Data from TraceID

Use this skill to pivot from an existing distributed trace into the matching ThousandEyes test result. Treat ThousandEyes as the system of record for the recovered test data, and use Observability Platforms to discover the ThousandEyes context from the trace.

## Required Behavior

1. Use the client's built-in tool discovery for available ThousandEyes and Observability Platform tools. Inspect schemas or argument details before calling unfamiliar tools when that information is available.
2. Verify that ThousandEyes MCP is available and that at least one Observability Platform integration or equivalent tooling path is available before starting.
3. Build an inventory of every Observability Platform integration or equivalent tooling path available in the current session.
4. Query every available Observability Platform by exact `traceId`. Do not stop after the first hit.
5. For every matching trace, inspect trace-level, resource-level, and span-level attributes for `tracestate` and `w3c.tracestate`.
6. If an Observability Platform lacks direct trace lookup but can search spans or logs by exact `traceId`, use that fallback and record it as fallback correlation.
7. Parse the `tracestate` value as a W3C vendor-state list and extract the `te=` member.
8. URL-decode the ThousandEyes value before reading query parameters.
9. Recover `accountId` from `__a`, `testId` from `testId`, `agentId` from `agentId`, and `executionTime` from `startTime`. Treat `executionTime` as the round selector for the exact ThousandEyes test execution.
10. Use the recovered identifiers to query ThousandEyes test details and the exact result window, preferring the same agent and the closest execution time.
11. If ThousandEyes tools expose time-based round selection instead of a literal `roundId`, use `startTime` to select the matching round or result. Do not invent a `roundId`.
12. Return both the observability evidence chain and the recovered ThousandEyes data.

## Inputs To Gather

- Required: `traceId`
- Optional: expected service name, Observability Platform preference, or investigation window
- Optional: whether the user wants raw data only or diagnosis too

Load [reference.md](reference.md) for parsing rules, identifier extraction, and ThousandEyes query strategy. Load [examples.md](examples.md) only when the user wants a structured report.

## Workflow

### 1) Inventory Observability Platforms

1. Check available ThousandEyes and Observability Platform tools, integrations, and any equivalent tooling surfaced by the current client. Inspect schemas or argument contracts when they are available.
2. Identify every Observability Platform that can query traces, spans, logs, or telemetry by exact `traceId`.
3. Mark each Observability Platform as `trace`, `span-search`, `log-search`, or `blocked`.

### 2) Query the trace across every Observability Platform

1. Use exact trace lookup first on each Observability Platform.
2. If exact trace lookup is unavailable, use exact `traceId` search in spans or logs scoped to a reasonable window.
3. Capture one result per Observability Platform: `hit`, `miss`, or `blocked`.
4. Preserve the raw attribute payload that contains the ThousandEyes linkage.

### 3) Recover ThousandEyes identifiers from tracestate

1. Search every trace hit for `tracestate` and `w3c.tracestate`.
2. Prefer the first value that contains a `te=` member.
3. Extract only the `te` vendor entry if other vendors are present.
4. Decode the ThousandEyes payload and parse the query parameters.
5. Recover `accountId`, `testId`, `agentId`, and `executionTime`.
6. If multiple Observability Platforms produce ThousandEyes identifiers, compare them. Treat matching values as confirmation and call out disagreements explicitly.

### 4) Query ThousandEyes

1. Use the recovered `accountId` when the ThousandEyes MCP tool supports account scoping.
2. Load the test definition with `get_network_app_synthetics_test`, or resolve it first with `list_network_app_synthetics_tests` if required by the tool.
3. Pull metrics near `executionTime` with `get_network_app_synthetics_metrics`.
4. If the test exposes network path data, retrieve exact-round path context with `get_path_visualization_results` or `get_full_path_visualization`, scoped to the recovered `agentId` and execution time when possible.
5. If the test is HTTP and service-map context helps explain the result, optionally use `get_service_map` for the same test and time window.
6. When multiple nearby rounds exist, choose the one with the same `agentId` and the smallest time delta from `executionTime`.

### 5) Return the result

Always include:

- the input `traceId`
- Observability Platform coverage and `hit`/`miss`/`blocked` status for every platform checked
- the raw `tracestate` attribute name used (`tracestate` or `w3c.tracestate`)
- the decoded ThousandEyes permalink payload
- recovered `accountId`, `testId`, `agentId`, and `executionTime`
- the ThousandEyes test identity and the exact result window used
- the retrieved ThousandEyes network data or the precise reason it could not be retrieved

Use the templates in [examples.md](examples.md) when the user wants a structured report.

## Guardrails

- Do not skip other Observability Platforms after the first successful trace lookup.
- If `tracestate` or `w3c.tracestate` is absent after inspecting the full trace payload, stop and say that no usable ThousandEyes trace linkage was found.
- If the ThousandEyes payload is still undecoded after extraction (for example it still contains `%3D`), stop and say that it must be URL-decoded before query parsing.
- Do not invent missing ThousandEyes identifiers. If `testId`, `agentId`, or `startTime` is absent after decoding, stop and say what is missing.
- Do not claim an exact ThousandEyes round unless the time and agent match are explicit or the selection rule is stated.
- Do not run destructive write actions in external systems without user confirmation.

## Additional Resources

- [reference.md](reference.md)
- [examples.md](examples.md)
