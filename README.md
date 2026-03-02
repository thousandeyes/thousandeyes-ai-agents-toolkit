# ThousandEyes AI Agents Toolkit

This repository contains the ThousandEyes AI Agents Toolkit: a growing collection of integrations that connect ThousandEyes with LLM-powered developer tools and AI agents.

## What is included

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

As an alternative to configuring the ThousandEyes MCP Server directly in Claude Code, you can install the ThousandEyes Claude Code plugin.

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

For more details on Claude Code plugins, see: https://code.claude.com/docs/en/plugins-reference

## Support

For bug reports, feature requests, or questions about this toolkit, please contact [ThousandEyes Support](https://docs.thousandeyes.com/product-documentation/getting-started/getting-support-from-thousandeyes#contacting-support).

## ThousandEyes MCP Server documentation

For setup guidance, prerequisites, and available MCP tools, see: https://docs.thousandeyes.com/product-documentation/integration-guides/thousandeyes-mcp-server.
