import {
  existsSync,
  readdirSync,
  readFileSync,
  realpathSync,
  statSync,
} from "node:fs";
import { basename, dirname, join, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type ServerConfig = Parameters<ExtensionAPI["registerMcpServer"]>[1];

function findWorkspace(cwd: string): string | undefined {
  const workingDir = realpathSync(cwd);
  const gitFile = join(workingDir, ".git");

  // Check only Pi's working directory. Never search parent directories.
  if (!existsSync(gitFile) || !statSync(gitFile).isFile()) return;

  const firstLine = readFileSync(gitFile, "utf8").split(/\r?\n/, 1)[0];
  const match = /^gitdir:\s+(.+)$/.exec(firstLine);
  if (!match) throw new Error(`Invalid Git pointer: ${gitFile}`);

  // Relative gitdir paths are relative to the directory containing .git.
  const gitDir = realpathSync(resolve(workingDir, match[1].trim()));
  const commonFile = join(gitDir, "commondir");

  // Follow Git's explicit metadata, not an ancestor-directory search.
  // At the workspace root, .git already points directly to .bare.
  const commonDir = existsSync(commonFile)
    ? realpathSync(resolve(gitDir, readFileSync(commonFile, "utf8").trim()))
    : gitDir;

  if (basename(commonDir) !== ".bare") return;
  return dirname(commonDir);
}

export default function (pi: ExtensionAPI) {
  const registered = new Set<string>();
  let generation = 0;

  function clearServers() {
    generation++;
    for (const name of registered) pi.unregisterMcpServer(name);
    registered.clear();
  }

  pi.on("session_start", async (_event, ctx) => {
    clearServers();
    const currentGeneration = generation;
    if (!ctx.isProjectTrusted()) return;

    try {
      const workspace = findWorkspace(ctx.cwd);
      if (!workspace) return;

      const configPath = join(workspace, ".pi", "mcp.json");
      if (!existsSync(configPath)) return;

      // Avoid duplicating a file that native Pi loads at the current cwd.
      const localPath = join(ctx.cwd, ".pi", "mcp.json");
      if (
        existsSync(localPath) &&
        realpathSync(localPath) === realpathSync(configPath)
      ) {
        return;
      }

      const config: { mcpServers?: Record<string, ServerConfig> } =
        JSON.parse(readFileSync(configPath, "utf8"));
      const servers = Object.entries(config.mcpServers ?? {});
      if (servers.length === 0) return;

      if (!ctx.hasUI) {
        ctx.ui.notify(
          `Skipped ${configPath}: interactive approval required.`,
          "warning",
        );
        return;
      }

      const approved = await ctx.ui.confirm(
        "Load shared workspace MCP servers?",
        `${configPath}\n\n` +
          `Servers: ${servers.map(([name]) => name).join(", ")}\n\n` +
          "This configuration can execute commands and connect to services.",
      );

      // Don't register servers if the session ended during confirmation.
      if (!approved || generation !== currentGeneration) return;

      for (const [name, server] of servers) {
        pi.registerMcpServer(name, server);
        registered.add(name);
      }
    } catch (error) {
      if (generation !== currentGeneration) return;
      clearServers();
      ctx.ui.notify(`Workspace MCP loading failed: ${error}`, "error");
    }
  });

  // Skills are discovered independently of MCP configuration and approval.
  pi.on("resources_discover", async (_event, ctx) => {
    const currentGeneration = generation;
    if (!ctx.isProjectTrusted()) return;

    try {
      const workspace = findWorkspace(ctx.cwd);
      if (!workspace) return;

      const skillsPath = join(workspace, ".pi", "skills");
      if (!existsSync(skillsPath) || !statSync(skillsPath).isDirectory()) return;
      if (readdirSync(skillsPath).length === 0) return;

      // Native Pi already discovers skills from the current directory.
      const localPath = join(ctx.cwd, ".pi", "skills");
      if (
        existsSync(localPath) &&
        realpathSync(localPath) === realpathSync(skillsPath)
      ) {
        return;
      }

      if (!ctx.hasUI) {
        ctx.ui.notify(
          `Skipped ${skillsPath}: interactive approval required.`,
          "warning",
        );
        return;
      }

      const approved = await ctx.ui.confirm(
        "Load shared workspace skills?",
        `${skillsPath}\n\n` +
          "Skills add instructions for the model and may include scripts. " +
          "Only load skills you trust.",
      );

      if (!approved || generation !== currentGeneration) return;

      // Let Pi scan SKILL.md files and register the normal skill commands.
      return { skillPaths: [skillsPath] };
    } catch (error) {
      if (generation !== currentGeneration) return;
      ctx.ui.notify(`Workspace skills loading failed: ${error}`, "error");
    }
  });

  pi.on("session_shutdown", clearServers);
}
