# trame Project Template

> Claude Code on host, dev environment via MCP, isolated worktrees for parallel agents

GitHub template for projects using [trame-tools](https://github.com/trame-sh/trame-tools) as their dev environment base image. All Claude Code processes run on the host machine. The Docker container is purely a dev environment (tools + services) accessed via an MCP server.

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
│   ├── Dockerfile                # FROM trame-tools + project layers
│   ├── mcp.sh                    # MCP launcher (auto-starts compose stack)
│   ├── docker-compose.base.yml   # shared service definitions
│   ├── docker-compose.coord.yml  # coordinator stack
│   ├── AGENTS.md                 # dev environment rules (from trame-tools)
│   └── update.sh                 # pulls latest mcp.sh + AGENTS.md from trame-tools
├── .mcp.json                     # Claude Code MCP config
├── CLAUDE.md                     # dev environment rules + project-specific instructions
└── AGENTS.md                     # references denv/AGENTS.md + project-specific agent instructions
```

## Prerequisites

- **Claude Code** on host ([installation guide](https://docs.anthropic.com/en/docs/claude-code/overview))
- **Docker** and **Docker Compose**
- **Optional: a trame account** — for coordinator/workers workflow. Sign up at [trame.sh](https://trame.sh)

## Quick Start

### 1. Use This Template

Click **"Use this template"** on GitHub, or clone and remove the `.git` directory:

```bash
git clone https://github.com/trame-sh/trame-project-template myproject
cd myproject
rm -rf .git && git init
```

### 2. Customize

- Edit `denv/Dockerfile` — uncomment optional layers (pnpm, Rust) or add your own
- Edit `denv/docker-compose.base.yml` — adjust services, DB names, credentials
- Edit `CLAUDE.md` — add project-specific instructions

### 3. Build the Dev Environment Image

```bash
docker build denv/ -t $(basename "$PWD")-denv
```

### 4. Start Claude Code

Simply run `claude` from the project root. The MCP server auto-starts the compose stack:

```bash
claude
```

The `shell_exec` MCP tool runs commands in the dev container. File reads/writes happen directly on the host.

### 5. Stop the Dev Environment

```bash
docker compose -p "$(basename "$PWD")-coord" -f denv/docker-compose.coord.yml down
```

## Updating trame-tools

Pull the latest host-side files (`mcp.sh`, `AGENTS.md`) from trame-tools:

```bash
denv/update.sh          # latest release
denv/update.sh v1.2.0   # specific version
```

To update the base Docker image, rebuild:

```bash
docker build denv/ -t $(basename "$PWD")-denv --pull
```
