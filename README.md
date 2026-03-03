# trame Project Template

> Isolated development environments using git worktrees + docker compose for specs-driven agentic development

This repository contains:

```
.
├── denv/
│   ├── Dockerfile                # opencode in container
│   ├── entrypoint.sh             # entrypoint for Dockerfile
│   ├── docker-compose.base.yml   # shared service definitions
│   ├── docker-compose.coord.yml  # coordinator (interactive bash)
│   └── docker-compose.worker.yml # worker (autonomous agent loop)
├── .gitignore                    # ignoring worktrees/ folder
├── AGENTS.md                     # basic guidance for working in this environment
├── README.md                     # this file
├── justfile                      # our command runner
├── opencode.json                 # barebone opencode configuration with trame.sh mcp
└── prompt.md                     # a basic prompt.md used by our run-agent loop
```

## Prerequisites

Before using this template, ensure you have:

- **Git** 2.35 or higher (for worktree support)
- **Docker** and **Docker Compose**
- **just** - Command runner ([installation guide](https://github.com/casey/just#installation))
- **opencode CLI** - AI agent interface ([installation guide](https://opencode.ai/docs/installation))
- **trame account** - Sign up at [trame.sh](https://trame.sh)

## Quick Start

### 1. Use This Template

Click "Use this template" on GitHub or clone the repository:

```bash
git clone https://github.com/trame-sh/trame-project-template.git my-project
cd my-project
just denv-build # To build the agent image we are using here
```

Then edit `AGENTS.md`, `README.md`, and `prompt.md` to your liking.
You can start by specifying the name of the project you are creating.

### 2. Configure trame Authentication

Authenticate opencode CLI with trame:

```bash
opencode mcp auth trame
```

This will:

1. Open your browser for OAuth authentication
2. Connect your opencode CLI to trame platform
3. Store credentials in `~/.config/opencode`

**Note:** The `opencode.json` file in this template is already configured to connect to `https://trame.sh/mcp`.

### 3. Create Your First Project in trame

Create a project on [trame.sh](https://trame.sh) or via the opencode CLI:

```bash
echo "Create a new project called '<your-project>' with a description of what you're building" | opencode run
```

### 4. Start the Coordinator

Launch an interactive shell for hands-on development:

```bash
just start-coord
```

This starts a Docker stack (opencode container + postgres) and drops you into a bash shell.
From there you can run `opencode` and start working on specs, features and implementation plans.

To stop the coordinator:

```bash
just stop-coord
```

### 5. Start Autonomous Workers

Start a single worker in the foreground (Ctrl-C to stop and clean up):

```bash
just new-agent
```

Or spin up N workers in the background:

```bash
just start-agents 3
just worker-logs 2       # view logs for worker-2
just worker-logs 2 -f    # follow logs
just stop-agents          # stop all background workers
```

Each worker gets its own Docker stack (container + postgres). They auto-run the agent loop, claim plans from trame, create worktrees, and start implementing.

## Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. USE AT YOUR OWN RISK.

This template runs **autonomous AI agents** that can execute code, make API calls, create files, run shell commands, and consume resources (compute, network, storage, and third-party API credits) **for extended periods without human supervision**. By using this software, you acknowledge and agree that:

1. **You are solely responsible** for all costs, resource consumption, and consequences arising from running autonomous agents, including but not limited to API usage fees, cloud compute charges, and any actions the agents take on your behalf.
2. **You are solely responsible** for reviewing, testing, and validating any code or changes produced by autonomous agents before deploying them to any environment.
3. The authors and contributors of this project **shall not be held liable** for any direct, indirect, incidental, special, or consequential damages, including but not limited to financial loss, data loss, security vulnerabilities, or service disruptions resulting from the use of this software.
4. **No guarantee is made** regarding the correctness, safety, or fitness for any particular purpose of code generated or actions performed by autonomous agents.

You should set appropriate spending limits on all API providers and cloud services, monitor running agents regularly, and never run autonomous agents with credentials that have more permissions than strictly necessary.
