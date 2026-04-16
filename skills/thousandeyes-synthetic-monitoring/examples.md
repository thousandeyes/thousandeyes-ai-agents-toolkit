# ThousandEyes Synthetic Monitoring Examples

## Example 1: List tests by name

User intent:

```text
Show me the synthetic tests we already have for wikipedia.
```

Possible tool call shape:

```json
{
  "name": "wikipedia"
}
```

Expected response pattern:

```text
Use list_network_app_synthetics_tests to return matching tests with their test IDs, types, and targets so the user can choose the right one for inspection or cleanup.
```

## Example 2: Create a scheduled HTTP server test

User intent:

```text
Set up synthetic monitoring for https://api.example.com/health from three US cloud agents every 5 minutes.
```

Execution summary before confirmation:

```text
Planned tool: create_synthetic_test
test_name: API health check
test_type: http-server
url: https://api.example.com/health
agent_ids:
  - <agent-1>
  - <agent-2>
  - <agent-3>
interval: 300
enabled: true
```

Possible tool call shape:

```json
{
  "test_name": "API health check",
  "test_type": "http-server",
  "url": "https://api.example.com/health",
  "agent_ids": ["<agent-1>", "<agent-2>", "<agent-3>"],
  "interval": 300,
  "enabled": true
}
```

## Example 3: Run a Browser Synthetics validation first

User intent:

```text
Check our homepage from Europe right now before we set up scheduled Browser Synthetics monitoring.
```

Execution summary before run:

```text
Planned tool: run_page_load_instant_test
url: https://www.example.com
agent_ids:
  - <europe-agent-1>
  - <europe-agent-2>
test_name: Quick homepage validation
```

Possible tool call shape:

```json
{
  "url": "https://www.example.com",
  "agent_ids": ["<europe-agent-1>", "<europe-agent-2>"],
  "test_name": "Quick homepage validation"
}
```

## Example 4: Update an existing test interval

User intent:

```text
Change test 612983 to run every 10 minutes instead of every minute.
```

Execution summary before confirmation:

```text
Planned tool: update_synthetic_test
test_id: 612983
test_type: http-server
interval: 600
```

Possible tool call shape:

```json
{
  "test_id": "612983",
  "test_type": "http-server",
  "interval": 600
}
```

## Example 5: Delete a scheduled test safely

User intent:

```text
Delete the old Slack monitoring test with ID 733201.
```

Execution summary before confirmation:

```text
Planned tool: delete_synthetic_test
test_id: 733201
test_type: page-load
```

Possible tool call shape:

```json
{
  "test_id": "733201",
  "test_type": "page-load"
}
```

## Example 6: Deploy an application monitoring template

User intent:

```text
Set up synthetic monitoring for Salesforce tenant acme from our standard cloud agents.
```

Expected handling:

```text
Use get_templates(name="Salesforce") to find the right application template, collect its required user inputs, summarize the deployment plan, and wait for confirmation before calling deploy_template.
```
