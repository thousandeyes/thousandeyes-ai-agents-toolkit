# ThousandEyes AI Agents Toolkit

This repository contains the ThousandEyes AI Agents Toolkit: a growing collection of integrations that connect ThousandEyes with LLM-powered developer tools and AI agents.

## Available Skills

| Skill | Description |
| --- | --- |
| [thousandeyes-network-data-from-traceid](skills/thousandeyes-network-data-from-traceid/SKILL.md) | Recover ThousandEyes Network & App Synthetics data from a trace ID. Use when a user has a `traceId` and both ThousandEyes MCP plus one or more Observability Platform MCP integrations are available, and Codex needs to query every available Observability Platform for the trace, extract `tracestate` or `w3c.tracestate`, decode the embedded ThousandEyes permalink, recover the ThousandEyes account/test/agent/execution identifiers, and fetch the matching ThousandEyes network data. |
| [thousandeyes-test-trace-correlation](skills/thousandeyes-test-trace-correlation/SKILL.md) | Investigate failing ThousandEyes synthetic tests with MCP tools. Use when a user wants ThousandEyes test triage, service-map or trace-ID correlation, distributed-tracing checks, correlation across Observability Platforms, or evidence-backed root-cause analysis with optional code fixes. |

## Skill sync workflow

The repository-level `skills/` directory is the source of truth for shared skills. Cursor and Claude Code discover those skills directly from the repo root, while the Codex plugin ships mirrored copies under `plugins/thousandeyes/skills/`.

- Sync all Codex skill copies after editing or adding shared skills: `bash scripts/sync_codex_skill.sh sync`
- Verify all mirrored Codex skill copies are still aligned: `bash scripts/sync_codex_skill.sh check`
- Scope the command to specific skills when needed: `bash scripts/sync_codex_skill.sh sync <skill-name>`
- Enable the repo hook so commits are blocked when the copies drift: `git config core.hooksPath .githooks`

## Getting Started

### ThousandEyes Codex Plugin

This repository now includes a local Codex marketplace plugin for ThousandEyes at `plugins/thousandeyes`, with a matching marketplace definition at `.agents/plugins/marketplace.json`.

#### Install in Codex

1. Open Codex and add the local marketplace rooted at this repository's `.agents/plugins/marketplace.json`.
2. Find **ThousandEyes** in that marketplace and install it.
3. Complete authentication when prompted.
4. Start a new chat and use ThousandEyes tools through the plugin-provided MCP integration.

### ThousandEyes Cursor Plugin

As an alternative to configuring the ThousandEyes MCP Server directly in Cursor, you can install the ThousandEyes Cursor plugin.

#### Install via Cursor Settings

1. Open Cursor and go to **Settings** > **Plugins**.
2. Search for **ThousandEyes**.
3. Click **Add to Cursor** and choose the scope:
   - **Project** scope: install only for the current workspace.
   - **User** scope: install for all your Cursor projects.
4. Go to **Settings** > **Tools & MCP**, scroll to the ThousandEyes plugin, click **Connect** and complete the authentication.
5. Start a new chat and use ThousandEyes tools through the plugin-provided MCP integration.

#### Install via Cursor Chat

1. Open a Cursor chat.
2. Run `/add-plugin thousandeyes`.
3. Confirm the install prompt and scope (project or user).
4. Go to **Settings** > **Tools & MCP**, scroll to the ThousandEyes plugin, click **Connect** and complete the authentication.
5. Start a new chat and use ThousandEyes tools through the plugin-provided MCP integration.

For more details on plugin installation and management, see: https://cursor.com/docs/plugins

### ThousandEyes Claude Code Plugin

As an alternative to configuring the ThousandEyes MCP Server directly in Claude Code, you can install the ThousandEyes Claude Code plugin. The plugin exposes the shared repo skills in `skills/` alongside the MCP integration.

#### Install via Claude Code CLI

1. Run `claude plugin install thousandeyes` and choose the scope:
   - `--scope user` (default): install for all your Claude Code projects.
   - `--scope project`: install only for the current workspace (shared via version control).
   - `--scope local`: install for the current project only (gitignored).
2. Start a new session and use ThousandEyes tools through the plugin-provided MCP integration.

#### Install via Claude Code TUI

1. Open Claude Code.
2. Type `/plugin` and search for **ThousandEyes**.
3. Follow the prompts to install and choose the scope.
4. Start a new session and use ThousandEyes tools through the plugin-provided MCP integration.

#### Using shared skills in Claude Code

- Shared plugin skills live under `skills/` at the repository root.
- Claude Code namespaces plugin skills by plugin name, so `skills/thousandeyes-test-trace-correlation/SKILL.md` is available as `/thousandeyes:thousandeyes-test-trace-correlation`.
- After adding a new shared skill, reinstall or reload the plugin if Claude Code does not pick it up immediately.

For more details on Claude Code plugins, see: https://code.claude.com/docs/en/plugins-reference

## Support

For bug reports, feature requests, or questions about this toolkit, please contact [ThousandEyes Support](https://docs.thousandeyes.com/product-documentation/getting-started/getting-support-from-thousandeyes#contacting-support).

## ThousandEyes MCP Server documentation

For setup guidance, prerequisites, and available MCP tools, see: https://docs.thousandeyes.com/product-documentation/integration-guides/thousandeyes-mcp-server
