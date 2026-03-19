---
name: thousandeyes-test-debug
description: Investigate failing ThousandEyes synthetic tests with MCP tools. Use when a user wants ThousandEyes test triage, service-map or trace-ID correlation, distributed-tracing checks, backend-agnostic observability correlation, or evidence-backed root-cause analysis with optional code fixes.
---
# ThousandEyes Test Debug

Use this skill to diagnose a failing ThousandEyes synthetic test end-to-end. Prefer evidence from ThousandEyes first, then correlate into observability backends. Only edit code after explicit user approval.

## Use This Skill When

- A ThousandEyes synthetic test is failing or flaky
- The user wants service-map analysis or trace-based correlation
- The user wants root-cause analysis tied to any observability backend available through MCP
- The user wants a fix proposal after diagnosis, or approves implementing the fix

## Required Behavior

1. Read MCP tool descriptor JSON before using any MCP tool.
2. Start from the test definition before interpreting metrics.
3. Pull recent failure signals before forming a hypothesis.
4. For `http-server` tests, always inspect `distributedTracing`.
5. If distributed tracing is enabled, call `get_service_map` before jumping to backend correlation.
6. If service-map data is missing or partial, continue with trace-ID fallback.
7. Enumerate all observability backends available in the session before backend correlation. Do this even if Splunk or Datadog are present.
8. Once a valid `traceId` is available, query every available observability backend that supports trace or telemetry correlation for that trace.
9. For each observability backend, also check telemetry tied to the ThousandEyes failing window. Do this even when direct trace lookup is available, because the extra telemetry helps explain the problem more completely.
10. Do not stop after the first backend hit. Record positive hits, empty results, and backend/tool limitations.
11. Tie backend findings back to both the ThousandEyes test and the recovered trace ID whenever possible.
12. Ask for explicit approval before making code changes.

## Inputs To Gather

- Test reference: `testId` or exact/partial test name
- Optional account scope: `aid`
- Investigation window: `window` or `start_date` / `end_date` (default `24h`)
- Whether the user wants diagnosis only or diagnosis plus code fix

Load [reference.md](reference.md) for metric names, trace rules, and generic backend-correlation guidance. Load [examples.md](examples.md) only when formatting the final output.

## Workflow

### 1) Access the test

1. Resolve test by name/id with `list_network_app_synthetics_tests`.
2. If multiple candidates match, ask the user to choose one.
3. Load full configuration with `get_network_app_synthetics_test`.
4. Record `testId`, `type`, `target`, `enabled`, agent list, and key options that affect diagnosis.

### 2) Get latest result and identify failure signal

1. Pull metric time series with `get_network_app_synthetics_metrics`.
2. Choose availability and error metrics based on test type from [reference.md](reference.md).
3. Filter by this test (`filter_dimension=TEST`, `filter_values=[testId]`).
4. Summarize the latest non-null buckets, failure timing, and dominant error class.
5. If there is no recent failure in the requested window, say so explicitly and stop unless the user wants historical analysis.

### 3) HTTP-specific tracing checks

1. If test type is `http-server`, inspect test config for `distributedTracing`.
2. If disabled, report this as a major observability gap and include enablement guidance.
3. If enabled, call `get_service_map` with the same test and failing time window.
4. Extract failing services, error spans, latency anomalies, and likely failure cause from the map output.
5. If the map identifies the failing service clearly, use that as the primary hypothesis.

### 4) Service map fallback and trace-ID path

If `get_service_map` is unavailable or incomplete:

1. Attempt to recover `traceId` from service-map output if present.
2. If not present, attempt extraction from `traceparent` data available in test/request context.
3. Validate the trace ID format before using it.
4. Continue diagnosis using cross-backend correlation by trace ID.

### 5) Correlate trace in observability backends

1. Check available MCP servers and read their schemas first.
2. Build a backend inventory for the current session. Include every observability backend exposed through MCP that can help with traces, logs, events, metrics, incidents, or service topology.
3. For each backend, determine the strongest available lookup path in this order:
   - exact trace lookup by `traceId`
   - exact or near-exact telemetry lookup scoped to the ThousandEyes failing window and implicated target or service
   - service-level telemetry lookup that can confirm or refute the ThousandEyes failure signal
4. If a backend supports direct trace lookup, run that first.
5. If a backend does not support direct trace lookup, query telemetry that could still correlate to the ThousandEyes failure window:
   - logs containing the trace ID, request ID, target, or failing service
   - events, incidents, or alerts in the same window
   - metrics that confirm latency, availability, or error spikes
   - service topology or dependency data that supports the failure hypothesis
6. Time-bound all backend queries to the failing ThousandEyes window, expanding slightly only when needed to recover trace or adjacent telemetry.
7. Do not conclude correlation until every reachable observability backend has been checked or ruled out due to missing tools or missing data.
8. Build an evidence chain: failing TE test -> failure window -> trace ID if available -> backend coverage -> failing service or dependency -> concrete error or confirming telemetry.
9. If multiple backends disagree, call that out explicitly and rank the most reliable evidence.

### 6) Root cause and remediation

1. Provide a concise root-cause statement backed by evidence.
2. State confidence as `high`, `medium`, or `low`.
3. If evidence is weak or split across multiple hypotheses, ask for one precise next data point.
4. If code is accessible, propose a fix plan.
5. Ask for explicit user confirmation before making edits.
6. After confirmation, implement the fix, validate it, and summarize impact.

## Output Contract

Always return:

- Test identity and scope used
- Latest failing signal and failing window
- HTTP tracing state (`distributedTracing` enabled/disabled)
- Service-map findings or trace-ID fallback findings
- Observability backend coverage: every backend checked, trace hit/miss status when applicable, and telemetry gathered for the ThousandEyes failing window
- Root cause statement with confidence level
- Next actions (and fix status, if code changes were confirmed)

Use the templates in [examples.md](examples.md) when the user wants a structured report.

## Guardrails

- Do not run destructive write actions in external systems without user confirmation.
- Do not leak credentials, tokens, or sensitive config values.
- If evidence is insufficient, state uncertainty and request one precise next data point.
- Do not claim a root cause from a single weak signal when ThousandEyes and backend evidence disagree.
- If multiple observability backends were available but not checked, the investigation is incomplete.
- If a trace ID exists but only one backend was checked, the investigation is incomplete unless no other observability backends were available in the session.

## Additional Resources

- [reference.md](reference.md)
- [examples.md](examples.md)
