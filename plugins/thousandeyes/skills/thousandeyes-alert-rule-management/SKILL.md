---
name: thousandeyes-alert-rule-management
description: List, inspect, create, update, or delete ThousandEyes alert rules with MCP tools. Use when a user wants help managing alert rules for the currently documented write domains, Network & App Synthetics and Routing, and the session exposes `list_alert_rules`, `get_alert_rule`, `create_alert_rule`, `update_alert_rule`, or `delete_alert_rule`.
---
# ThousandEyes Alert Rule Management

Use this skill to manage ThousandEyes alert rules through the available MCP read and write tools. Align the user request to the official alert-rule docs and expression metadata, but only send fields that exist in the actual MCP tool schema.

## Use This Skill When

- A user wants to list existing ThousandEyes alert rules
- A user wants to inspect one ThousandEyes alert rule by ID
- A user wants to create a new ThousandEyes alert rule
- A user wants to update an existing alert rule
- A user wants to delete an existing alert rule
- A user needs help translating ThousandEyes alert-rule UI concepts into MCP tool arguments
- A user needs help writing or validating an alert `expression`

## Required Behavior

1. Inspect the alert-rule tool schema before using any of `list_alert_rules`, `get_alert_rule`, `create_alert_rule`, `update_alert_rule`, or `delete_alert_rule`.
2. Confirm the user intent first: `list`, `get`, `create`, `update`, or `delete`.
3. Treat `create_alert_rule`, `update_alert_rule`, and `delete_alert_rule` as external write actions. Get explicit user confirmation before calling them.
4. Treat `list_alert_rules` and `get_alert_rule` as read-only discovery tools. Use them without extra confirmation when they help identify the right rule or recover the current required fields for an update.
5. For `create` and `update`, gather the required fields before proceeding: `rule_name`, `expression`, `alert_type`, and `rounds_violating_out_of`.
6. For `get`, `update`, and `delete`, require `rule_id`.
7. Do not invent tool arguments from the UI docs. If a UI concept is not exposed by the tool schema, say that clearly and stop or ask for a supported alternative.
8. Validate `rounds_violating_required <= rounds_violating_out_of` before calling the tool.
9. If `rounds_violating_mode=auto`, prefer an explicit `sensitivity_level`.
10. Use the expression guidance in [reference.md](reference.md) when building or reviewing `expression`.
11. Summarize the exact payload you plan to send before execution, then summarize the result after execution.

## Inputs To Gather

- Operation: `list`, `get`, `create`, `update`, or `delete`
- Optional account scope: `aid`
- For `get`, `update`, and `delete`: `rule_id`
- For `create` and `update`: `rule_name`, `alert_type`, `expression`, `rounds_violating_out_of`
- Optional rule behavior: `rounds_violating_required`, `rounds_violating_mode`, `sensitivity_level`, `severity`, `notify_on_clear`, `is_default`
- Optional scope selectors supported by the tools: `test_ids`, `direction`, `alert_group_type`, `minimum_sources`, `minimum_sources_pct`, `endpoint_agent_ids`, `endpoint_label_ids`, `visited_sites_filter`, `include_covered_prefixes`
- Optional metadata: `description`, `notifications`

Load [reference.md](reference.md) for the docs-to-tool mapping and expression rules. Load [examples.md](examples.md) only when you need a response template or payload example.

## Workflow

### 1) Confirm the operation and available tools

1. Check that the relevant alert-rule tool exists in the session.
2. Confirm whether the user wants to list, inspect, create, update, or delete a rule.
3. If the user request mixes multiple operations, split them into separate confirmed actions.

### 2) Discover the target rule when needed

1. Use `list_alert_rules` when the user wants to browse rules, find a rule by name, or narrow down candidate rule IDs.
2. Use `get_alert_rule` when the user already has a `rule_id` or once `list_alert_rules` identified the likely rule.
3. Prefer `get_alert_rule` over `list_alert_rules` when you need the fullest current rule state before `update_alert_rule`.
4. If the session lacks the relevant read tools, say so and gather the missing identifiers or required fields from the user.

### 3) Normalize the desired rule

1. Identify the ThousandEyes product area and alert type the user is targeting.
2. Translate the user request into supported MCP fields only.
3. If the docs mention a selector that the tool does not expose, call out the gap instead of inventing a payload field.
4. If the user asks to update only one field but the current rule values for other required arguments are unknown, use `get_alert_rule` to recover them. If only the rule name is known, use `list_alert_rules` first to identify the right `rule_id`.

### 4) Build and validate the payload

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

### 5) Confirm before write

Before calling the tool, present a short execution summary that includes:

- the operation
- the target rule ID when applicable
- the core fields you will send
- any fields you intentionally omitted because the tool does not support them

Do not execute until the user confirms.

### 6) Execute the correct tool

- `list_alert_rules` for discovery and inventory views
- `get_alert_rule` for current-state inspection and update preparation
- `create_alert_rule` for new rules
- `update_alert_rule` for existing rules, always including `rule_id` plus the required core fields
- `delete_alert_rule` for removals, always including `rule_id`

### 7) Report the outcome

Always return:

- the operation performed
- `aid` if used
- the `rule_id` returned or targeted
- the main rule identity (`rule_name`, `alert_type`) when available
- for read operations, the key rule data the tool returned
- the final confirmed payload summary
- any unsupported doc/UI fields that were intentionally not sent

## Guardrails

- Never run `create_alert_rule`, `update_alert_rule`, or `delete_alert_rule` without explicit user confirmation.
- Prefer `get_alert_rule` before `update_alert_rule` when the user does not already know the required core fields.
- Never claim a UI feature is supported unless the MCP tool schema exposes it.
- Never fabricate a partial update payload for `update_alert_rule`; it still needs the required core fields.
- If the correct `rule_id` is uncertain, stop and ask.
- If the expression is ambiguous or unsupported for the chosen alert type, explain the problem and ask for a corrected condition.
- Keep notification examples minimal and avoid exposing sensitive recipient data unless the user explicitly provided it.

## Additional Resources

- [reference.md](reference.md)
- [examples.md](examples.md)
