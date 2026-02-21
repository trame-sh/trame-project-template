# trame Project Template

> Claude Code on host, dev environment via MCP, isolated worktrees for parallel agents

All Claude Code processes run on the host machine. The Docker container is purely a dev environment (tools + services) accessed via an MCP server. Each worker gets its own compose stack and git worktree for full isolation.

```
Host Machine                         Docker Compose Stacks

┌─────────────────────┐              ┌─────────────────────┐
│ Coordinator          │──MCP───────▶│ project-coord       │
│ claude (interactive) │              │ devenv + postgres    │
└─────────────────────┘              └─────────────────────┘

┌─────────────────────┐              ┌─────────────────────┐
│ Worker 1             │──MCP───────▶│ project-worker-1    │
│ claude -p (headless) │              │ devenv + postgres    │
└─────────────────────┘              └─────────────────────┘
```

## Project Structure

```
.
├── denv/
│   ├── Dockerfile                # dev environment image (no agent CLI)
│   ├── entrypoint.sh             # UID/GID mapping entrypoint
│   ├── mcp-server.mjs            # MCP server exposing shell_exec
│   ├── mcp.sh                    # MCP launcher (auto-starts compose stack)
│   ├── docker-compose.base.yml   # shared service definitions
│   └── docker-compose.coord.yml  # coordinator stack
├── .mcp.json                     # Claude Code MCP config
├── CLAUDE.md                     # Claude Code instructions
└── AGENTS.md                     # agent guidance
```

## Prerequisites

- **Claude Code** on host ([installation guide](https://docs.anthropic.com/en/docs/claude-code/overview))
- **Docker** and **Docker Compose**
- **Optional: a trame account** — for coordinator/workers workflow. Sign up at [trame.sh](https://trame.sh)

## Quick Start

### 1. Build the Dev Environment Image

```bash
docker build denv/ -t $(basename "$PWD")-denv --no-cache
```

### 2. Start the Coordinator

Simply run `claude` from the project root. The MCP server auto-starts the compose stack:

```bash
claude
```

The `shell_exec` MCP tool runs commands in the dev container. File reads/writes happen directly on the host.

### 3. Stop the Dev Environment

```bash
docker compose -p "$(basename "$PWD")-coord" -f denv/docker-compose.coord.yml down
```

## Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. USE AT YOUR OWN RISK.

This template runs **autonomous AI agents** that can execute code, make API calls, create files, run shell commands, and consume resources (compute, network, storage, and third-party API credits) **for extended periods without human supervision**. By using this software, you acknowledge and agree that:

1. **You are solely responsible** for all costs, resource consumption, and consequences arising from running autonomous agents, including but not limited to API usage fees, cloud compute charges, and any actions the agents take on your behalf.
2. **You are solely responsible** for reviewing, testing, and validating any code or changes produced by autonomous agents before deploying them to any environment.
3. The authors and contributors of this project **shall not be held liable** for any direct, indirect, incidental, special, or consequential damages, including but not limited to financial loss, data loss, security vulnerabilities, or service disruptions resulting from the use of this software.
4. **No guarantee is made** regarding the correctness, safety, or fitness for any particular purpose of code generated or actions performed by autonomous agents.

You should set appropriate spending limits on all API providers and cloud services, monitor running agents regularly, and never run autonomous agents with credentials that have more permissions than strictly necessary.
