import { Plugin } from "@opencode-ai/plugin";
import { tool } from "@opencode-ai/plugin/tool";

export default (async (ctx) => {
  return {
    tool: {
      setup_worktree: tool({
        description:
          "Create (or reuse) a git worktree for a feature branch. " +
          "Returns the absolute path to the worktree directory. " +
          "All subsequent file edits, test runs, and commits should happen inside this path.",
        args: {
          branch: tool.schema
            .string()
            .describe(
              "Short kebab-case branch name derived from the implementation plan (e.g. add-user-auth)",
            ),
        },
        async execute(args, context) {
          const branch = args.branch.replace(/[^a-z0-9-]/g, "-");
          const worktreeRoot = context.worktree || context.directory;
          const worktreePath = `${worktreeRoot}/worktrees/${branch}`;

          // Check if the worktree already exists
          const check = await ctx.$`test -d ${worktreePath}`.nothrow();

          if (check.exitCode === 0) {
            return JSON.stringify({
              status: "reused",
              branch,
              path: worktreePath,
              message: `Worktree already exists at ${worktreePath}. Use this directory for all work.`,
            });
          }

          // Create the worktree
          const result =
            await ctx.$`git worktree add --relative-paths -b ${branch} ${worktreePath}`
              .cwd(worktreeRoot)
              .nothrow();

          if (result.exitCode !== 0) {
            const stderr = result.stderr.toString().trim();

            // Branch exists but no worktree — try without -b
            if (stderr.includes("already exists")) {
              const retry =
                await ctx.$`git worktree add --relative-paths ${worktreePath} ${branch}`
                  .cwd(worktreeRoot)
                  .nothrow();

              if (retry.exitCode !== 0) {
                return JSON.stringify({
                  status: "error",
                  branch,
                  message: retry.stderr.toString().trim(),
                });
              }

              return JSON.stringify({
                status: "created",
                branch,
                path: worktreePath,
                message: `Worktree created at ${worktreePath} using existing branch. Use this directory for all work.`,
              });
            }

            return JSON.stringify({
              status: "error",
              branch,
              message: stderr,
            });
          }

          return JSON.stringify({
            status: "created",
            branch,
            path: worktreePath,
            message: `Worktree created at ${worktreePath}. Use this directory for all work.`,
          });
        },
      }),
    },
  };
}) satisfies Plugin;
