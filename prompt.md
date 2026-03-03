study project specs
if you don't have an implementation plan claimed on trame, claim one. if there are no plans available to claim, call the `agent_signal` tool with signal `no-plan` and stop.
study your claimed implementation plan and select the most important task to work on.


IMPORTANT:
- ALWAYS call the `setup_worktree` tool with a short kebab-case branch name derived from your claimed plan (e.g. `add-user-auth`) before starting to work on a task
- ALL work MUST happen inside the worktree path returned by the `setup_worktree` tool, not in the root workspace.
- author property-based tests or unit tests (whichever is best)
- after making changes, run the tests from inside the worktree
- when tests pass, commit your changes, then update your implementation plan on trame
- when you have finished all tasks in your implementation plan, set the plan status to completed on trame
