import { Plugin } from "@opencode-ai/plugin";
import { tool } from "@opencode-ai/plugin/tool";

export default (async (ctx) => {
  const signalsDir = process.env.AGENT_SIGNALS_DIR || "/tmp/agent-signals";

  return {
    tool: {
      agent_signal: tool({
        description:
          "Signal the agent loop about a condition. " +
          "Use this when there are no implementation plans available to claim on trame. " +
          "The loop will sleep before retrying.",
        args: {
          signal: tool.schema
            .enum(["no-plan"])
            .describe("The signal to send. Use 'no-plan' when no implementation plans are available to claim."),
        },
        async execute(args) {
          await ctx.$`mkdir -p ${signalsDir}`;
          await ctx.$`touch ${signalsDir}/${args.signal}`;

          return JSON.stringify({
            status: "signaled",
            signal: args.signal,
            message: `Signal '${args.signal}' sent. The agent loop will handle this accordingly.`,
          });
        },
      }),
    },
  };
}) satisfies Plugin;
