# AGENTS

Agent guidance for working in this repository.

## Scope and intent

- This repo contains the ThousandEyes AI Agents Toolkit.
- The toolkit can include multiple integrations (for example Cursor plugin assets, MCP configuration, and future agent/tooling integrations).
- Make minimal, targeted edits that match the user request.
- Do not refactor unrelated files or reorganize directories unless requested.

## Repository structure guidance

- Keep integration boundaries clear (plugin files, docs, scripts, assets) and avoid cross-cutting changes unless requested.
- Prefer adding new integration-specific content in clearly named folders/files.
- Keep documentation aligned with the actual repository layout and supported integrations.

## Cursor plugin-specific guidance

- The Cursor plugin manifest is `.cursor-plugin/plugin.json` at repository root.
- The only **required** manifest field is `name` (lowercase, kebab-case, alphanumerics/hyphens/periods; must start and end with alphanumeric).
- Keep optional metadata accurate when editing: `description`, `version`, `author` (`name` required, `email` optional), `keywords`, `logo`, etc. See [Building plugins](https://cursor.com/docs/plugins/building).

### Supported components

Add only components that are needed:

- `rules/` — `.md`, `.mdc`, or `.markdown` files (YAML frontmatter required, e.g. `description`, `alwaysApply`, `globs`)
- `skills/<skill-name>/SKILL.md` (YAML frontmatter required: `name`, `description`)
- `agents/*.md` (YAML frontmatter required: `name`, `description`)
- `commands/` — `.md`, `.mdc`, `.markdown`, or `.txt` (frontmatter recommended: `name`, `description`)
- `hooks/hooks.json` and `scripts/*` for hook automation
- `.mcp.json` at plugin root for MCP server definitions (or use manifest `mcpServers` for custom path/inline config)
- `assets/logo.svg` or another manifest-referenced logo (prefer committing the logo and using a relative path)

If the manifest specifies paths for a component type (e.g. `"rules": "./my-rules/"`), that **replaces** folder-based discovery for that type; default folders are not also scanned.

### Validation and pitfalls checklist (when editing plugin assets)

Before finishing plugin work, verify all of the following:

1. `.cursor-plugin/plugin.json` exists at repository root and is valid JSON.
2. Plugin `name` is lowercase kebab-case; optional metadata (`description`, `author`, `version`, etc.) is accurate.
3. All manifest paths are **relative** (no `..`, no absolute paths) and resolve correctly (e.g. `logo`, `hooks`, MCP config).
4. Required frontmatter fields (`name`, `description` where applicable) are present in rule/skill/agent/command files.
5. Logo and other assets referenced by the manifest are committed and use correct relative paths.
6. Docs and examples match the current file layout and filenames.

## Safety and quality expectations

- Never hardcode secrets or tokens in manifests, docs, scripts, or examples.
- Prefer environment variable placeholders for credentials
- Preserve user changes in unrelated files; do not revert work you did not make.

