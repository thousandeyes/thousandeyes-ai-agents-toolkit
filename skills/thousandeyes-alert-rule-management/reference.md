# ThousandEyes Alert Rule Management Reference

## Primary Docs

- Alert rule configuration guide: https://docs.thousandeyes.com/product-documentation/alerts/creating-and-editing-alert-rules
- Alert rule expression metadata: https://developer.cisco.com/docs/thousandeyes/alert-rule-metadata/
- Expression table anchor: https://developer.cisco.com/docs/thousandeyes/alert-rule-metadata/#expressions

## Supported MCP Tools

The current skill is centered on these alert-rule MCP tools:

- `list_alert_rules`
- `get_alert_rule`
- `create_alert_rule`
- `update_alert_rule`
- `delete_alert_rule`

Read the tool schema before calling them. Do not assume the docs UI fields map one-to-one to MCP arguments.

## Read Tool Arguments

### `list_alert_rules`

- optional `aid`

### `get_alert_rule`

- `rule_id`
- optional `aid`

## Required MCP Arguments

### `create_alert_rule`

- `rule_name`
- `expression`
- `alert_type`
- `rounds_violating_out_of`

### `update_alert_rule`

- `rule_id`
- `rule_name`
- `expression`
- `alert_type`
- `rounds_violating_out_of`

### `delete_alert_rule`

- `rule_id`

### Optional arguments exposed today

- `aid`
- `description`
- `direction`
- `notify_on_clear`
- `is_default`
- `alert_group_type`
- `minimum_sources`
- `minimum_sources_pct`
- `rounds_violating_required`
- `rounds_violating_mode`
- `include_covered_prefixes`
- `sensitivity_level`
- `severity`
- `endpoint_agent_ids`
- `endpoint_label_ids`
- `visited_sites_filter`
- `notifications`
- `test_ids`

## Docs-To-Tool Mapping

Use this mapping when translating the ThousandEyes docs into MCP arguments:

- Existing rules inventory -> `list_alert_rules`
- Existing rule details by ID -> `get_alert_rule`
- Rule Name -> `rule_name`
- Alert Type -> `alert_type`
- Tests -> `test_ids`
- Direction -> `direction`
- Severity -> `severity`
- Description -> `description`
- Notifications -> `notifications`
- "X of Y times" global condition -> `rounds_violating_required` and `rounds_violating_out_of`
- Adaptive or automatic-style global condition -> `rounds_violating_mode=auto` plus `sensitivity_level`
- Default rule toggle -> `is_default`
- Notify on clear -> `notify_on_clear`
- Browser-session agent scope -> `endpoint_agent_ids` or `endpoint_label_ids`
- Browser-session visited sites -> `visited_sites_filter`
- BGP covered prefixes -> `include_covered_prefixes`

## Product Scope Notes

The ThousandEyes alert docs span product areas such as:

- Network & App Synthetics
- Endpoint Experience
- Routing
- Devices
- Internet Insights
- WAN Insights
- Cloud Insights
- Traffic Insights
- Event Detection
- Connected Devices

The current MCP tool schema supports common fields used across many of those products, but not every product-specific selector from the UI is exposed as a dedicated argument.

Examples of doc concepts that may not be directly expressible with the current write-tool schema:

- "all agents except" or "specific monitors" selector modes
- device or interface selectors
- catalog provider selectors
- cloud provider or cloud scope-type selectors
- traffic-insights scope selectors
- connected-devices-specific workflow details

When the user asks for one of those, say the current MCP write tool does not expose a direct field for it. Do not invent payload keys.

## Expression Rules

Follow the Cisco expression metadata when building or reviewing `expression`.

Key rules:

- Use metric names that are valid for the chosen `alert_type`.
- Include units where the metadata expects them, such as `ms`, `%`, `kbps`, `Mbps`, or `B`.
- Quote string values, for example `((errorType != "None"))`.
- Regex matches use slash-delimited patterns.
- You can combine multiple metrics with `&&` or `||`.
- When combining three or more metrics, keep to a single operator family rather than mixing `&&` and `||`.

Examples:

- HTTP availability-style error: `((probDetail != ""))`
- Network latency threshold: `((avgLatency >= 500 ms))`
- HTTP response code: `((responseCode >= 400))`
- Auto mode example: `((Auto(connectTime >= High sensitivity)) && (Auto(responseTime >= High sensitivity)))`

## Condition Validation Rules

- `rounds_violating_required` must not be greater than `rounds_violating_out_of`
- `rounds_violating_mode` valid values: `any`, `exact`, `auto`
- `sensitivity_level` valid values: `high`, `medium`, `low`
- `severity` valid values: `info`, `minor`, `major`, `critical`, `unknown`
- `direction` valid values: `to-target`, `from-target`, `bidirectional`

## Notifications Shape

`notifications` is an object. Common supported top-level keys include:

- `email`
- `thirdParty`
- `webhook`
- `customWebhook`

Keep examples small. If the user does not specify a notification method, omit the field.

## Update Strategy

`update_alert_rule` is not a patch-style call with only `rule_id` plus one changed field. It still requires:

- `rule_id`
- `rule_name`
- `expression`
- `alert_type`
- `rounds_violating_out_of`

If the user only knows the one field they want to change:

1. Use `get_alert_rule` to recover the current rule values when `rule_id` is known.
2. If only the rule name is known, use `list_alert_rules` first to identify the right `rule_id`, then call `get_alert_rule`.
3. If no read path exists, ask for the missing required values.
4. Do not guess.

## Read Strategy

Use the read tools to avoid risky write guesses:

1. `list_alert_rules` to discover candidate rules and IDs.
2. `get_alert_rule` to confirm the exact rule and recover the current required core fields.
3. Only move on to `update_alert_rule` once the required write fields are known and confirmed.

## Delete Strategy

Before `delete_alert_rule`, confirm:

- the exact `rule_id`
- the correct account scope if `aid` is relevant
- that the user wants deletion now
