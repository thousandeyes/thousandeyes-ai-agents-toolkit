# ThousandEyes Synthetic Monitoring Reference

## Product Language Alignment

Use ThousandEyes product language consistently:

- **Synthetic monitoring** is the umbrella workflow.
- **Synthetic tests** are the concrete dynamic or scheduled tests used in that workflow.
- **Network and Application Synthetics** covers network, DNS, API, HTTP server, and other non-browser synthetic checks.
- **Browser Synthetics** covers page-load and transaction-style browser tests.
- **Application monitoring through templates** is the preferred workflow when the user wants to monitor an application rather than configure every test individually.

## Primary MCP Tools

Read the tool schema before calling unfamiliar tools. The current skill is centered on these synthetic-test tools:

- `list_network_app_synthetics_tests`
- `get_network_app_synthetics_test`
- `create_synthetic_test`
- `update_synthetic_test`
- `delete_synthetic_test`
- `list_cloud_enterprise_agents`
- `get_templates`
- `deploy_template`

Instant-test tools:

- `run_agent_to_server_instant_test`
- `run_agent_to_agent_instant_test`
- `run_http_server_instant_test`
- `run_page_load_instant_test`
- `run_dns_server_instant_test`
- `run_dns_trace_instant_test`
- `run_api_instant_test`
- `run_web_transaction_instant_test`

## Product Family to Test-Type Mapping

Use the narrowest valid test type for the target, but explain it in product language first.

| Test Type | Best For | Required Fields |
| --- | --- | --- |
| `agent-to-server` | Network and Application Synthetics for reachability, path, and latency | `test_name`, `server`, `agent_ids`; often `protocol` |
| `agent-to-agent` | Network and Application Synthetics for inter-site connectivity; currently create/get/delete only | `test_name`, `agent_ids`, `target_agent_id`; often `protocol`, `port` |
| `http-server` | Network and Application Synthetics for URL availability and response timing | `test_name`, `url`, `agent_ids` |
| `page-load` | Browser Synthetics for page performance and waterfalls | `test_name`, `url`, `agent_ids` |
| `dns-server` | Network and Application Synthetics for DNS response time and availability | `test_name`, `domain`, `dns_servers`, `agent_ids` |
| `dns-trace` | Network and Application Synthetics for DNS delegation-chain validation | `test_name`, `domain`, `agent_ids` |
| `dnssec` | Network and Application Synthetics for DNSSEC validation | `test_name`, `domain`, `agent_ids` |
| `api` | Network and Application Synthetics for multi-step API workflows | `test_name`, `url`, `requests_config`, `agent_ids` |
| `web-transactions` | Browser Synthetics for scripted browser journeys | `test_name`, `url`, `transaction_script`, `agent_ids` |
| `ftp-server` | Network and Application Synthetics for FTP service checks | `test_name`, `url`, `agent_ids` |
| `sip-server` | Network and Application Synthetics for SIP infrastructure checks | `test_name`, `target_sip_credentials`, `agent_ids` |
| `voice` | Network and Application Synthetics for voice-quality workflows | `test_name`, `target_sip_credentials`, `agent_ids` |
| `bgp` | Network and Application Synthetics for route monitoring by prefix | `test_name`, `prefix` |

## Update and Delete Rules

`update_synthetic_test` and `delete_synthetic_test` both require:

- `test_id`
- `test_type`

Additional update rules:

- Include only the fields you intend to change, but do not guess unknown values.
- If the exact current test is unclear, inspect it first with `get_network_app_synthetics_test`.
- Keep `test_type` aligned with the existing test. Do not use update as a type conversion.
- `agent-to-agent` is not currently supported by `update_synthetic_test`. If the user needs to change one, explain the limitation and recommend delete-and-recreate after inspection and confirmation.

Delete rules:

- Deletion is permanent.
- If the user knows only a test name, first resolve the exact `test_id` and `test_type` with `list_network_app_synthetics_tests`.

## Dynamic Validation Guide

Use instant tests when the user wants an immediate dynamic check before committing to scheduled synthetic monitoring:

| User Need | Instant Tool |
| --- | --- |
| Quick URL availability check | `run_http_server_instant_test` |
| Quick browser page experience check | `run_page_load_instant_test` |
| Quick DNS answer check | `run_dns_server_instant_test` |
| Quick DNS chain check | `run_dns_trace_instant_test` |
| Quick network path check to a server | `run_agent_to_server_instant_test` |
| Quick enterprise-to-enterprise network check | `run_agent_to_agent_instant_test` |
| Quick API workflow validation | `run_api_instant_test` |
| Quick scripted browser journey validation | `run_web_transaction_instant_test` |

If the user wants to keep the monitoring after validation, recommend converting the successful instant-test design into a scheduled synthetic test with the matching type.

## Agent Selection Guidance

- Use `list_cloud_enterprise_agents` to discover valid `agent_ids`.
- For external customer-view monitoring, prefer multiple cloud agents across relevant geographies.
- For internal service monitoring, prefer enterprise agents close to the real users or infrastructure.
- `agent-to-agent` tests require enterprise agents, not cloud agents.
- `bgp` tests do not require `agent_ids`.

## Template Deployment Guidance

Use `get_templates` when the user wants to monitor an application through preconfigured synthetic tests, especially for products such as Microsoft 365, Salesforce, Slack, Zoom, Okta, or ServiceNow.

Deployment workflow:

1. Find the template with `get_templates`.
2. Read the required user inputs from the template response.
3. Build `user_input_values` using only the required inputs and user-confirmed values.
4. Confirm the deployment summary before calling `deploy_template`.

Prefer templates when they replace a complex multi-test manual setup and align better with the "Monitor Application" workflow in the product.

## Browser Synthetics Transaction Creation

Use `web-transactions` when the user needs a browser-based scripted journey rather than a single page render or a pure API sequence.

Creation workflow:

1. Start with the journey, not the selectors:
   - identify the start URL
   - list the critical user actions in order
   - define the success condition for the journey
2. Prefer Browser Synthetics only when a browser is required:
   - login flows
   - search flows
   - checkout or multistep navigation
   - workflows that depend on DOM state, rendering, or client-side JavaScript
3. If the workflow is only API calls and does not need a browser, use an `api` test instead.
4. Draft the script with the BrowserBot async pattern and explicit waits.
5. Validate the journey with `run_web_transaction_instant_test` before creating or updating scheduled monitoring when the user wants proof first.

Official example repository:

- Root repo: [thousandeyes/transaction-scripting-examples](https://github.com/thousandeyes/transaction-scripting-examples)
- Browser journey examples: [applications/](https://github.com/thousandeyes/transaction-scripting-examples/tree/master/applications)
- Reusable interaction helpers: [examples/](https://github.com/thousandeyes/transaction-scripting-examples/tree/master/examples)
- API-oriented script examples in the same repo: [API-transaction-scripts/](https://github.com/thousandeyes/transaction-scripting-examples/tree/master/API-transaction-scripts)

Use the repo as follows:

1. Check `applications/` first for a workflow similar to the user journey.
2. Check `examples/` for helper patterns such as targeted clicks, mouse movement, or other interaction workarounds.
3. Reuse structure and waiting patterns from the examples, but keep the final script minimal and specific to the user journey.

Additional docs:

- Transaction tests overview: [Transaction Tests](https://docs.thousandeyes.com/product-documentation/browser-synthetics/transaction-tests)
- Scripting API reference: [Transaction Scripting Reference](https://docs.thousandeyes.com/product-documentation/browser-synthetics/transaction-tests/transaction-scripting-reference)
- Execution model and async pattern: [Transactions – Executing Custom JavaScript Code](https://docs.thousandeyes.com/product-documentation/browser-synthetics/transaction-tests/development-guide/transactions-executing-custom-javascript-code)
- Getting started overview: [Getting Started with Transactions](https://docs.thousandeyes.com/product-documentation/getting-started/getting-started-with-transactions)

Transaction authoring rules:

- Always wrap browser actions in an async function and call it explicitly.
- Import `driver` from `thousandeyes`.
- Import `By`, `Key`, `until`, or other helpers from `selenium-webdriver` only when needed.
- Prefer `driver.wait(...)` with clear element or state conditions over fixed sleeps.
- Use `driver.executeScript(...)` when interaction must happen inside the page context.
- Keep selectors stable; prefer IDs and durable attributes over brittle DOM paths.
- Add `console.log(...)` markers only when they materially help debug a fragile flow.

## Web Transaction Script Rules

`web-transactions` scripts run in the ThousandEyes BrowserBot context. Enforce these minimum rules:

- Wrap all awaited browser actions inside an async function.
- Import `driver` from `thousandeyes`.
- Import selectors and waits from `selenium-webdriver`.
- Pass both `url` and `transaction_script`.
- Prefer explicit waits over fixed sleeps.

Minimal valid structure:

```javascript
import { driver } from 'thousandeyes';
import { By, until } from 'selenium-webdriver';

runScript();

async function runScript() {
  await driver.get('https://example.com');
  await driver.wait(until.titleContains('Example'), 10000);
}
```

Do not use top-level `await`.

## API Test Creation

Use `api` tests when the user wants to validate API behavior through one or more HTTP calls without a browser-rendered journey.

Creation workflow:

1. Confirm the base URL and the exact sequence of API calls.
2. Create a short ordered step list before writing `requests_config`:
   - step name
   - HTTP method
   - full request URL
   - required headers
   - request body when applicable
3. Keep request names stable and descriptive, for example `Authenticate`, `Get Health`, or `Create Order`.
4. Include only the headers and payload fields needed for the workflow.
5. Prefer `run_api_instant_test` when the user wants to validate the sequence before saving a scheduled test.
6. Use `create_synthetic_test` with `test_type: "api"` when the workflow is ready for scheduled monitoring.

API test guidance from the docs:

- Overview: [API Tests](https://docs.thousandeyes.com/product-documentation/api-test)
- Getting started and prerequisites: [Getting Started with API Tests](https://docs.thousandeyes.com/product-documentation/api-test/create-api-test)

API test rules:

- `url` should be the base target for the test.
- `requests_config` should be a small ordered list of requests, each with:
  - `name`
  - `url`
  - `method`
  - optional `headers`
  - optional `body`
- Prefer full URLs in each request entry unless the session tooling clearly supports a safer derived pattern.
- Keep bodies as explicit JSON strings when a POST, PUT, or PATCH step needs payload data.
- Do not overfit the payload to UI-only Step Builder features that are not present in the MCP schema.
- If the user needs browser behavior, cookies driven by rendered pages, or DOM interaction, switch to Browser Synthetics instead of forcing an API test.

Minimal API example shape:

```json
[
  {
    "name": "Get Health",
    "url": "https://api.example.com/health",
    "method": "get"
  },
  {
    "name": "Create Session",
    "url": "https://api.example.com/session",
    "method": "post",
    "headers": [
      { "key": "content-type", "value": "application/json" }
    ],
    "body": "{\"username\":\"demo\",\"password\":\"secret\"}"
  }
]
```

## Recommended Creation Pattern

For a new synthetic monitoring workflow:

1. Resolve the target type and agent scope.
2. If the user wants validation first, run the matching instant test.
3. If the user wants to monitor an application and a suitable template exists, prefer template deployment over many standalone tests.
4. Otherwise summarize the planned scheduled-test payload.
5. After confirmation, call `create_synthetic_test`.
6. Return the new test identity and recommended follow-up actions, such as alerting or wider agent coverage.
