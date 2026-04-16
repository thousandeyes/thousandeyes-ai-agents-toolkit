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
| `agent-to-agent` | Network and Application Synthetics for inter-site connectivity | `test_name`, `agent_ids`, `target_agent_id`; often `protocol`, `port` |
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

## Recommended Creation Pattern

For a new synthetic monitoring workflow:

1. Resolve the target type and agent scope.
2. If the user wants validation first, run the matching instant test.
3. If the user wants to monitor an application and a suitable template exists, prefer template deployment over many standalone tests.
4. Otherwise summarize the planned scheduled-test payload.
5. After confirmation, call `create_synthetic_test`.
6. Return the new test identity and recommended follow-up actions, such as alerting or wider agent coverage.
