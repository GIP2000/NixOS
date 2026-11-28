---
name: workspace-resources
description: >-
  Manage repository-local Pi skills and MCP servers. Use when asked to add,
  install, update, or remove a skill for the local repo, or add, remove, modify,
  enable, or disable an MCP server for a project or workspace. Follow the current
  directory's .git pointer to a .bare workspace and use its shared .pi/skills
  folder and .pi/mcp.json file.
---

# Local repository skills and MCP servers

Use this workflow for repository-local Pi resources. In a Git worktree managed
by the workspace extension, "local repo" means the shared repository workspace
by default, not just the current branch's checkout.

An explicit user request for a different scope or destination takes precedence.

## Resolve the destination before writing

Use the Pi session's working directory as the starting directory. If the user
explicitly names a different repository directory, use that directory instead
and explain that the extension discovers resources from the directory where Pi
starts.

**Only inspect `.git` directly in that directory. Never search parent
directories for `.git` or `.bare`. Do not use Git's automatic upward repository
discovery to bypass this rule.**

1. Resolve the starting directory to its real filesystem path.
2. Check whether `<directory>/.git` is a file.
3. Read its first line, which must have the form `gitdir: <path>`.
   Resolve a relative path against the directory containing the `.git` file,
   then resolve symlinks. This is the Git metadata directory.
4. If `<git-directory>/commondir` exists, read it and resolve its path relative
   to the Git metadata directory, including symlinks. This gives the common
   repository directory. Without `commondir`, use the Git metadata directory
   itself.
5. If the resulting directory is named `.bare`, its parent is the shared
   workspace root. Use these destinations:

   | Resource | Destination |
   |---|---|
   | Skill | `<workspace-root>/.pi/skills/<skill-name>/SKILL.md` |
   | MCP server definitions | `<workspace-root>/.pi/mcp.json` |

Following explicit Git metadata is allowed; scanning ancestor directories for
matching folder names is not. A worktree can live outside the shared workspace
and still point to the same `.bare` repository.

For example:

```text
project/
├── .git                         # gitdir: ./.bare
├── .bare/
│   └── worktrees/
│       └── feature/
│           └── commondir        # ../..
├── .pi/
│   ├── mcp.json                 # shared MCP definitions
│   └── skills/
│       └── review-changes/
│           └── SKILL.md         # shared skill
└── feature/
    └── .git                     # gitdir: /.../project/.bare/worktrees/feature
```

Starting in `project/feature/` or `project/` selects the same shared `.pi/`
directory. Starting in `project/feature/src/` without its own `.git` file does
not trigger workspace discovery.

### Other layouts and explicit scopes

- If the current directory contains a normal `.git` **directory**, there is no
  shared workspace lookup. Use that directory's own `.pi/skills/` and
  `.pi/mcp.json` for local repository resources.
- If `.git` is missing, its pointer is invalid, its target cannot be read, or
  the common directory is not named `.bare`, explain the mismatch and ask for
  the intended repository root or destination. Do not guess, search upward, or
  create a `.bare` directory.
- If the user explicitly requests worktree-only resources, use that worktree's
  own `.pi/` directory instead of the shared workspace directory.
- Do not put shared resources inside `.bare/`, in global configuration, or in
  the current worktree's `.pi/` by default.
- Never edit Git's `.git`, `commondir`, or other repository metadata.

## Common editing rules

State the resolved destination and whether it is shared across worktrees.
Follow applicable repository instructions and inspect existing content before
editing. Preserve unrelated resources and settings. If a requested resource
name or scope is ambiguous, clarify it before changing or removing anything.

This skill is globally installed through Nix. Its loaded `/nix/store/` copy is
read-only and is not a destination for repository resources. Do not change Nix
configuration or global resources unless separately requested.

## Add, update, or remove a skill

1. Inspect existing skills to avoid accidental name collisions.
2. Create `<skill-name>/SKILL.md` with YAML frontmatter:

   ```markdown
   ---
   name: review-changes
   description: Review repository changes for correctness and missing tests. Use when reviewing a diff or preparing a change for commit.
   ---

   # Review changes

   Add the repository-specific workflow here.
   ```

3. Use a lowercase name with letters, numbers, and hyphens, at most 64 characters,
   without leading, trailing, or consecutive hyphens. Match the directory name.
4. Write a description of at most 1024 characters that says what the skill does
   and when to use it. Put the workflow in the Markdown body.
5. Keep supporting scripts, references, and assets inside the skill directory
   and reference them relative to that directory, not the agent's cwd.
6. For an update, read the existing skill and change only the requested content.
   For removal, inspect and remove only the requested skill and its dedicated
   supporting files; do not remove the entire skills directory.
7. Check frontmatter, the required description, and referenced files. Use Pi's
   skill parser if readily available, but do not run bundled scripts merely to
   validate the skill.

## Add, modify, or remove an MCP server

Work on the resolved `.pi/mcp.json`. Read it first; do not replace an existing
file with a new minimal document or discard unrelated server entries. If its
JSON is malformed, diagnose it rather than silently resetting the file.

The server definitions live under `mcpServers`:

```json
{
  "mcpServers": {
    "example": {
      "url": "https://example.com/mcp"
    }
  }
}
```

- **Add:** obtain the actual server command or URL and required configuration.
  Create the file if absent, otherwise add only the requested named entry.
  Do not silently overwrite a different server with the same name.
- **Modify:** edit only the requested entry and fields. Preserve transport,
  environment, headers, OAuth, exposure, and other fields unless the requested
  change requires altering them.
- **Enable or disable:** change `enabled` on the full server definition; keep
  its command or URL and other fields intact.
- **Remove:** delete only the requested `mcpServers.<name>` entry. Preserve
  other servers and top-level settings. An empty `mcpServers` object is fine.
  Removing a definition does not authorize deleting OAuth credentials, signing
  out, uninstalling software, or editing other configuration files.

### MCP configuration details

- Shared servers are registered by the extension and need complete definitions:
  stdio uses `command` with an `args` array; HTTP uses `url`. A bare override
  such as `{ "enabled": false }` is not a complete extension registration.
- `command` is one executable, not a shell command string. Relative `cwd`
  resolves against the Pi session directory, not the shared configuration file.
  Set an appropriate explicit `cwd` when a server depends on a fixed directory.
- Server names may contain letters, digits, underscores, and hyphens. Names
  differing only by `-` versus `_` collide.
- Prefer supported environment-variable references in `env`, `headers`, or
  `oauth.clientSecret` over literal secrets. Do not invent credentials, print
  existing secrets, or copy saved OAuth tokens into the shared file.
- Preserve required OAuth client settings when copying or updating a server.
  Saved sign-ins remain in `~/.pi/agent/mcp-auth.json`; they are associated
  with server name and URL, so do not rename either casually.
- Global and current-directory file definitions take precedence over shared
  extension registrations with the same name, even when disabled. Warn about
  such conflicts; do not alter those other files without authorization.
  Removing a shared entry may leave a same-named global server available.
- The extension registers entries under `mcpServers`; it does not apply
  unrelated top-level options such as `autoEnableCodemode`.
- `pi mcp add/remove -l` targets the command's current directory. Do not run
  it in a worktree and expect it to update the shared workspace file. Prefer
  editing the explicitly resolved file.
- Validate JSON and the changed definition without exposing secrets. Report
  configuration validation separately from an actual successful connection.

## Reload and verify

Report the absolute paths changed and whether the changes affect all worktrees
pointing to this repository.

Tell the user to run `/reload` in a Pi session started in the worktree root and
approve loading shared resources when prompted. Skills and MCP servers have
separate approvals and work independently of each other.

- Skills can be invoked with `/skill:<skill-name>`.
- Inspect MCP connections and configuration sources with `/mcp` inside Pi.
  Shell-level `pi mcp list` does not load extensions, so running it from a
  worktree does not verify these shared registrations.
- For extension-registered MCP servers, changes made in the `/mcp` UI to
  enabled state or exposure are session-only. Edit the shared JSON file for
  persistent changes.
- At the workspace root, native Pi already loads the local `.pi/` resources.
  A deeper directory without its own `.git` file does not discover shared
  resources through this extension.

Adding or changing workspace skills or MCP definitions does not require a Nix
rebuild or another Nix entry: the extension already loads these locations.
