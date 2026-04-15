---
name: thousandeyes-synthetic-test-management
description: List, inspect, create, update, delete, or validate ThousandEyes synthetic tests with MCP tools. Use when a user wants to manage Network & App Synthetics tests, run instant checks before creating a scheduled test, deploy template-based SaaS monitoring, or clean up existing tests.
---
# ThousandEyes Synthetic Test Management

Use this skill to manage ThousandEyes synthetic tests through the available MCP tools. Start with discovery, map the requested outcome to the correct test type, validate required arguments before any write, and confirm destructive or persistent changes with the user.

## Use This Skill When

- A user wants to list or inspect existing ThousandEyes synthetic tests
- A user wants to create a new scheduled synthetic test
- A user wants to update an existing synthetic test
- A user wants to delete one or more synthetic tests
- A user wants to run an instant synthetic check before creating a scheduled test
- A user wants to deploy a ThousandEyes monitoring template for a SaaS application
- A user needs help choosing the right ThousandEyes synthetic test type for a target

## Required Behavior

1. Inspect the relevant ThousandEyes tool schema before using unfamiliar synthetic-test tools.
2. Confirm the user intent first: `list`, `get`, `create`, `update`, `delete`, `instant-test`, or `deploy-template`.
3. Treat `create_synthetic_test`, `update_synthetic_test`, `delete_synthetic_test`, and `deploy_template` as external write actions. Get explicit user confirmation before calling them.
4. Treat instant-test tools as execution actions. Confirm before running them unless the user explicitly asked to run the check now.
5. Use read-only discovery tools without extra confirmation when they help identify the right test, test type, agent set, or template.
6. For `update` and `delete`, require both `test_id` and `test_type`.
7. Do not invent tool arguments that are not exposed by the MCP tool schema.
8. When the user gives only a test name, use discovery tools to recover the exact `test_id` and `test_type` before any write.
9. Recommend the narrowest valid test type for the target instead of defaulting everything to HTTP.
10. Summarize the exact payload or execution plan before running any write or instant action, then summarize the result after execution.

## Inputs To Gather

- Operation: `list`, `get`, `create`, `update`, `delete`, `instant-test`, or `deploy-template`
- Optional account scope: `aid`
- Target details: URL, server, domain, prefix, or target agent depending on test type
- Agent scope: source `agent_ids`, agent type preference, or template agent-selection inputs
- For `get`, `update`, and `delete`: `test_id` and `test_type`
- For `create`: `test_name`, `test_type`, and the required type-specific fields
- For `update`: the fields to change plus the current required test identifiers
- For `deploy-template`: template identity plus all required `user_input_values`

Load [reference.md](reference.md) for test-type mapping, supported write tools, and validation rules. Load [examples.md](examples.md) only when you need response or payload examples.

## Workflow

### 1) Confirm the operation and available tools

1. Check which synthetic-test tools are available in the session.
2. Confirm whether the user wants to browse, inspect, create, update, delete, run an instant test, or deploy a template.
3. If the request mixes multiple operations, split them into separate confirmed actions.

### 2) Discover the target test, agent set, or template

1. Use `list_network_app_synthetics_tests` when the user wants to browse tests or only knows a partial test name or target.
2. Use `get_network_app_synthetics_test` when `test_id` and `test_type` are already known.
3. Use `list_cloud_enterprise_agents` when agent IDs are needed for synthetic monitoring.
4. Use `get_templates` when the user wants SaaS monitoring or only knows the application name.
5. If the exact scheduled test type is unknown, map the target to a recommended type using [reference.md](reference.md) before proposing creation.

### 3) Normalize the requested monitoring action

1. Match the target to the correct test family:
   - `http-server` for URL availability and response timing
   - `page-load` for browser-rendered pages and component timing
   - `dns-server` or `dns-trace` for DNS validation
   - `agent-to-server` for network path and reachability
   - `agent-to-agent` for inter-site connectivity between enterprise agents
   - `api` for multi-step API request workflows
   - `web-transactions` for scripted browser journeys
   - `bgp` when the user is monitoring route reachability for a prefix
2. If a SaaS template already covers the target use case, prefer `deploy_template` over building a large manual test set from scratch.
3. If the user wants validation before a persistent change, prefer the matching instant-test tool first.

### 4) Build and validate the plan

1. Start with the required fields for the selected operation.
2. Add only supported optional fields that the user actually requested.
3. Validate the target-specific requirements:
   - `url` for `http-server`, `page-load`, `api`, and `web-transactions`
   - `server` for `agent-to-server`
   - `domain` for `dns-server`, `dns-trace`, and `dnssec`
   - `prefix` for `bgp`
   - `target_agent_id` for `agent-to-agent`
   - `transaction_script` for `web-transactions`
4. Validate agent requirements:
   - `agent_ids` are required for all scheduled synthetic tests except `bgp`
   - `agent-to-agent` requires enterprise agents on both ends
   - external customer-view tests should usually use multiple cloud agents
5. For `web-transactions`, require an async-function style script and both `url` and `transaction_script`.
6. For `update`, do not guess the current test configuration. If required update fields are unclear, inspect the current test first.

### 5) Confirm before execution

Before running any write or instant action, present a short execution summary that includes:

- the operation
- the test or template identity
- the `test_type` when applicable
- the core required fields you will send
- the agent scope or template inputs
- any unsupported or omitted fields that you intentionally are not sending

Do not execute until the user confirms, unless the user explicitly asked to run the instant test immediately.

### 6) Execute the correct tool

- `list_network_app_synthetics_tests` for discovery
- `get_network_app_synthetics_test` for current-state inspection
- `create_synthetic_test` for new scheduled tests
- `update_synthetic_test` for changes to existing scheduled tests
- `delete_synthetic_test` for removals
- the matching `run_*_instant_test` tool for immediate validation
- `get_templates` and `deploy_template` for template-based SaaS monitoring

### 7) Report the outcome

Always return:

- the operation performed
- `aid` if used
- the test or template identity involved
- `test_id` and `test_type` when applicable
- the final confirmed payload or execution summary
- the key result fields returned by the tool
- the recommended next step, especially when an instant test should lead to a scheduled test or alerting follow-up

## Guardrails

- Never run `create_synthetic_test`, `update_synthetic_test`, `delete_synthetic_test`, or `deploy_template` without explicit user confirmation.
- Never delete a test unless both the exact `test_id` and `test_type` are known.
- Never fabricate type-specific fields such as `url`, `server`, `domain`, `prefix`, or `target_agent_id`.
- If the user asks for a partial update but the current test details are unclear, inspect the test first instead of guessing.
- If multiple tests match a name or target, stop and ask the user to choose.
- Keep sample transaction scripts minimal and point to [reference.md](reference.md) for the required async structure.

## Additional Resources

- [reference.md](reference.md)
- [examples.md](examples.md)
