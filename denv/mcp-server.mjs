import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { spawn } from "node:child_process";

const server = new McpServer({
  name: "devenv",
  version: "1.0.0",
});

server.tool(
  "shell_exec",
  "Execute a shell command in the dev environment container",
  {
    command: z.string().describe("The shell command to execute"),
    workdir: z
      .string()
      .default("/workspace")
      .describe("Working directory (default: /workspace)"),
    timeout_ms: z
      .number()
      .default(120000)
      .describe("Timeout in milliseconds (default: 120000)"),
  },
  async ({ command, workdir, timeout_ms }) => {
    return new Promise((resolve) => {
      const proc = spawn("bash", ["-c", command], {
        cwd: workdir,
        stdio: ["ignore", "pipe", "pipe"],
      });

      let stdout = "";
      let stderr = "";
      let killed = false;

      const timer = setTimeout(() => {
        killed = true;
        proc.kill("SIGKILL");
      }, timeout_ms);

      proc.stdout.on("data", (chunk) => (stdout += chunk));
      proc.stderr.on("data", (chunk) => (stderr += chunk));

      proc.on("close", (exitCode) => {
        clearTimeout(timer);
        const result = {
          exitCode: killed ? -1 : exitCode,
          stdout,
          stderr,
          ...(killed && { error: `Timed out after ${timeout_ms}ms` }),
        };
        resolve({
          content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
        });
      });
    });
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
