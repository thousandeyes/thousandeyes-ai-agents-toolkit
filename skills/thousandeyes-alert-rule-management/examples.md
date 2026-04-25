# ThousandEyes Alert Rule Management Examples

## Example 1: List existing alert rules

User intent:

```text
Show me the alert rules in account 123456 so I can find the API latency rule.
```

Possible tool call shape:

```json
{
  "aid": "123456"
}
```

Expected response pattern:

```text
Use list_alert_rules to return the available rule IDs and names, then ask which rule the user wants to inspect or modify if the target is still ambiguous.
```

## Example 2: Create a new HTTP alert rule

User intent:

```text
Create an alert rule for my API test that fires when response time is above 500 ms for 2 out of 5 rounds and notify api-alerts@example.com.
```

Execution summary before confirmation:

```text
Planned tool: create_alert_rule
rule_name: API latency alert
alert_type: http-server
expression: ((responseTime >= 500 ms))
rounds_violating_required: 2
rounds_violating_out_of: 5
notifications:
  email:
    recipients:
      - api-alerts@example.com
```

Possible tool call shape:

```json
{
  "rule_name": "API latency alert",
  "expression": "((responseTime >= 500 ms))",
  "alert_type": "http-server",
  "rounds_violating_out_of": 5,
  "rounds_violating_required": 2,
  "notifications": {
    "email": {
      "recipients": ["api-alerts@example.com"]
    }
  }
}
```

## Example 3: Inspect a rule and prepare an update

User intent:

```text
Update rule 127094 so it only applies to the Finance label, keeps the same core rule settings, and triggers for the app.example.com visited site.
```

Expected handling:

```text
Call get_alert_rule first to recover the current rule_name, expression, alert_type, and rounds_violating_out_of. Then summarize the planned update and wait for confirmation before calling update_alert_rule.
```

Possible read call shape:

```json
{
  "rule_id": "127094"
}
```

Possible tool call shape after the required values are known:

```json
{
  "rule_id": "127094",
  "rule_name": "Finance browser error alert",
  "expression": "<<existing expression>>",
  "alert_type": "endpoint-browser-sessions-application",
  "rounds_violating_out_of": 3,
  "alert_group_type": "browser-session",
  "endpoint_label_ids": ["finance-label-id"],
  "visited_sites_filter": ["app.example.com"]
}
```

## Example 4: Delete an alert rule

User intent:

```text
Delete alert rule 127094 from account 123456.
```

Execution summary before confirmation:

```text
Planned tool: delete_alert_rule
rule_id: 127094
aid: 123456
```

Possible tool call shape:

```json
{
  "rule_id": "127094",
  "aid": "123456"
}
```

## Example 5: Handle an unsupported UI-only selector

User intent:

```text
Create a traffic insights alert for a specific geolocation scope type.
```

Expected response pattern:

```text
The ThousandEyes docs describe that scope type in the UI, but the current alert-rule MCP write tool does not expose a dedicated field for that selector. I can help build the supported parts of the rule, but I should not invent a payload field for the missing scope selector.
```
