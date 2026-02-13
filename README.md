# trame Project Template

> Isolated development environments using git worktrees + docker compose for specs-driven agentic development

This repository contains:

```
.
├── denv/
│   ├── Dockerfile              # opencode in container
│   ├── entrypoint.sh           # entrypoint for Dockerfile
│   └── docker-compose.env.yml  # simple isolated development stack
├── .gitignore                  # ignoring worktrees/ folder
├── AGENTS.md                   # basic guidance for working in this environment
├── README.md                   # this file
├── justfile                    # our command runner
├── opencode.json               # barebone opencode configuration with trame.sh mcp
└── prompt.md                   # a basic prompt.md used by our run-agent loop
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
```

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

### 4. Create Your First Worktree Environment

Create an isolated environment for a feature:

```bash
just start-env feature-auth
```

This command:

1. Creates a new git branch called `feature-auth`
2. Creates a worktree at `./worktrees/feature-auth/`
3. Launches Docker containers (opencode, postgres) for this feature
4. Sets up proper user permissions (uses your UID/GID)

### 5. Work in the Worktree

Navigate to the worktree:

```bash
cd worktrees/feature-auth
just attach
```

You can now:

- Run the autonomous agent: `just run-agent`
- Manually work on code
- Install dependencies: `just install`
- Run tests, build, etc.

### 6. Stop the Environment

From the worktree directory:

```bash
just stop-env
```

This stops and removes the Docker containers. The worktree directory and your code remain intact.

### 7. Clean Up the Worktree

```bash
just delete-env feature-auth
```
