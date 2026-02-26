# AGENTS

Agent guidance for working in this repository.

## Scope and intent

- This repo contains the official ThousandEyes Cursor plugin.
- Make minimal, targeted edits that match the user request.
- Do not refactor unrelated files or reorganize directories unless requested.

## Single-plugin repository

- This repository is for one plugin only.
- The canonical manifest is `.cursor-plugin/plugin.json` at repository root.
- Keep `name`, `displayName`, `description`, `author`, and `version` accurate when editing plugin metadata.

## Supported plugin components

Add only components that are needed:

- `rules/` with `.mdc` files (YAML frontmatter required)
- `skills/<skill-name>/SKILL.md` (YAML frontmatter required)
- `agents/*.md` (YAML frontmatter required)
- `commands/*.(md|mdc|markdown|txt)` (frontmatter recommended)
- `hooks/hooks.json` and `scripts/*` for hook automation
- `mcp.json` for MCP server definitions
- `assets/logo.svg` or another manifest-referenced logo asset

## Validation and pitfalls checklist

Before finishing plugin work, verify all of the following:

1. `.cursor-plugin/plugin.json` exists at repository root and is valid JSON.
2. Plugin `name` is lowercase kebab-case and metadata (`displayName`, `description`, `author`, `version`) is accurate.
3. Manifest-referenced paths (for example `logo`, hooks, and MCP config files) resolve correctly.
4. Required frontmatter fields (`name`, `description`) are present in rule/skill/agent/command files where required.
5. Logo/image assets referenced by manifests are committed and use correct relative paths.
6. Docs and examples match the current file layout and filenames.

## Safety and quality expectations

- Never hardcode secrets or tokens in manifests, docs, scripts, or examples.
- Prefer environment variable placeholders for credentials (for example `${THOUSANDEYES_AUTHORIZATION}`).
- Preserve user changes in unrelated files; do not revert work you did not make.

