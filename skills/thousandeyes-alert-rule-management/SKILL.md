---
name: thousandeyes-alert-rule-management
description: Create, update, or delete ThousandEyes alert rules with MCP tools. Use when a user wants to manage alert rules across ThousandEyes product areas such as Network & App Synthetics, Endpoint Experience, Routing, Connected Devices, Cloud Insights, or Traffic Insights, and the session exposes `create_alert_rule`, `update_alert_rule`, or `delete_alert_rule`.
---
# ThousandEyes Alert Rule Management

Use this skill to manage ThousandEyes alert rules through the write-capable MCP tools. Align the user request to the official alert-rule docs and expression metadata, but only send fields that exist in the actual MCP tool schema.

## Use This Skill When

- A user wants to create a new ThousandEyes alert rule
- A user wants to update an existing alert rule
- A user wants to delete an existing alert rule
- A user needs help translating ThousandEyes alert-rule UI concepts into MCP tool arguments
- A user needs help writing or validating an alert `expression`

## Required Behavior

1. Inspect the alert-rule tool schema before using `create_alert_rule`, `update_alert_rule`, or `delete_alert_rule`.
2. Confirm the user intent first: `create`, `update`, or `delete`.
3. Treat all three alert-rule tools as external write actions. Get explicit user confirmation before calling them.
4. For `create` and `update`, gather the required fields before proceeding: `rule_name`, `expression`, `alert_type`, and `rounds_violating_out_of`.
5. For `update` and `delete`, require `rule_id`.
6. Do not invent tool arguments from the UI docs. If a UI concept is not exposed by the tool schema, say that clearly and stop or ask for a supported alternative.
7. Validate `rounds_violating_required <= rounds_violating_out_of` before calling the tool.
8. If `rounds_violating_mode=auto`, prefer an explicit `sensitivity_level`.
9. Use the expression guidance in [reference.md](reference.md) when building or reviewing `expression`.
10. Summarize the exact payload you plan to send before execution, then summarize the result after execution.

## Inputs To Gather

- Operation: `create`, `update`, or `delete`
- Optional account scope: `aid`
- For `update` and `delete`: `rule_id`
- For `create` and `update`: `rule_name`, `alert_type`, `expression`, `rounds_violating_out_of`
- Optional rule behavior: `rounds_violating_required`, `rounds_violating_mode`, `sensitivity_level`, `severity`, `notify_on_clear`, `is_default`
- Optional scope selectors supported by the tools: `test_ids`, `direction`, `alert_group_type`, `minimum_sources`, `minimum_sources_pct`, `endpoint_agent_ids`, `endpoint_label_ids`, `visited_sites_filter`, `include_covered_prefixes`
- Optional metadata: `description`, `notifications`

Load [reference.md](reference.md) for the docs-to-tool mapping and expression rules. Load [examples.md](examples.md) only when you need a response template or payload example.

## Workflow

### 1) Confirm the operation and available tools

1. Check that the relevant alert-rule tool exists in the session.
2. Confirm whether the user wants to create, update, or delete a rule.
3. If the user request mixes multiple operations, split them into separate confirmed actions.

### 2) Normalize the desired rule

1. Identify the ThousandEyes product area and alert type the user is targeting.
2. Translate the user request into supported MCP fields only.
3. If the docs mention a selector that the tool does not expose, call out the gap instead of inventing a payload field.
4. If the user asks to update only one field but the current rule values for other required arguments are unknown, use any available read tool to recover them. If no read path exists, ask the user for the missing required values before calling `update_alert_rule`.

### 3) Build and validate the payload

1. Start with the required fields.
2. Add only supported optional fields that the user actually requested.
3. Validate the `expression` syntax as far as the docs and schema allow:
   - use supported metric names for the selected alert type
   - include units where required
   - quote string values
   - do not mix `&&` and `||` in the same expression when combining three or more metrics
4. Validate condition settings:
   - `rounds_violating_required` cannot exceed `rounds_violating_out_of`
   - `sensitivity_level` only makes sense with `rounds_violating_mode=auto`
   - `direction` is only valid for applicable network-style alert types
   - `endpoint_agent_ids`, `endpoint_label_ids`, and `visited_sites_filter` are only valid for browser-session style endpoint rules
   - `include_covered_prefixes` is only valid for BGP-style rules

### 4) Confirm before write

Before calling the tool, present a short execution summary that includes:

- the operation
- the target rule ID when applicable
- the core fields you will send
- any fields you intentionally omitted because the tool does not support them

Do not execute until the user confirms.

### 5) Execute the correct tool

- `create_alert_rule` for new rules
- `update_alert_rule` for existing rules, always including `rule_id` plus the required core fields
- `delete_alert_rule` for removals, always including `rule_id`

### 6) Report the outcome

Always return:

- the operation performed
- `aid` if used
- the `rule_id` returned or targeted
- the main rule identity (`rule_name`, `alert_type`) when available
- the final confirmed payload summary
- any unsupported doc/UI fields that were intentionally not sent

## Guardrails

- Never run `create_alert_rule`, `update_alert_rule`, or `delete_alert_rule` without explicit user confirmation.
- Never claim a UI feature is supported unless the MCP tool schema exposes it.
- Never fabricate a partial update payload for `update_alert_rule`; it still needs the required core fields.
- If the correct `rule_id` is uncertain, stop and ask.
- If the expression is ambiguous or unsupported for the chosen alert type, explain the problem and ask for a corrected condition.
- Keep notification examples minimal and avoid exposing sensitive recipient data unless the user explicitly provided it.

## Additional Resources

- [reference.md](reference.md)
- [examples.md](examples.md)
