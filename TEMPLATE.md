# Template Adaptation Guide

This file is for AI agents adapting this template to a specific project.
Read this before modifying any files.

## Architecture

The `denv/` directory provides a Docker-based development environment with two modes:

- **Coordinator** (interactive): A human developer runs an agent CLI inside a container
  with companion services. Uses `docker-compose.coord.yml`.
- **Worker** (autonomous): A headless agent loop that claims plans from trame and
  implements them. Uses `docker-compose.worker.yml`.

Both extend `docker-compose.base.yml` which defines shared services.

The agent loop (`just run-agent` in the justfile) repeatedly pipes `prompt.md` into the
agent CLI. Between iterations it checks for signal files (e.g., `no-plan`) written by
the agent to decide whether to sleep before retrying. This loop mechanism is
CLI-agnostic — only the invocation command changes.

## File-by-file guide

### denv/Dockerfile

Base image providing the agent CLI and project toolchain.
Sections are marked with inline comments:

- `[REQUIRED]` — layers that must stay regardless of project (system deps, git, just, entrypoint)
- `[OPTIONAL: <tool>]` — language/tool-specific layers; add or remove based on project needs
- `[AGENT-CLI]` — the agent CLI install block; replace when using a different CLI

**Required layers (do not remove):**
- System essentials: curl, wget, ca-certificates, build-essential, gosu
- Git >= 2.48 (built from source for `--relative-paths` worktree support)
- `just` command runner
- Entrypoint script + WORKDIR/VOLUME setup

**Optional layers (add/remove based on project):**
- Node.js + pnpm — the template base image is `node:25-trixie-slim`; drop or swap if not needed
- Rust toolchain — remove if project doesn't use Rust
- Python + pip — already included as system dep; add venv/poetry if needed
- Go toolchain — add if project uses Go
- Any other language runtime the project needs

**Important:** The base image (`node:25-trixie-slim`) provides a `node` user that
`entrypoint.sh` remaps to the host UID/GID. If you switch to a different base image,
ensure it has a non-root user or create one, and update `entrypoint.sh` accordingly
(the username `node` is referenced there and in compose volumes using `/home/node`).

### denv/entrypoint.sh

Maps container UID/GID to host user via gosu. **Do not modify** unless you change the
base image or have specific user-mapping requirements. Works with any agent CLI.

### denv/docker-compose.base.yml

Shared service definitions extended by coord and worker compose files.
Sections are marked with inline comments:

- `[ADAPT]` — values that should change per project
- `[KEEP]` — structural elements that should stay

**`opencode` service (rename if using a different CLI):**
- `image`: Points to the built Docker image. Set via `DENV_IMAGE` env var.
- `environment`: Add project-specific env vars here (DATABASE_URL, API keys, etc.)
- `volumes`:
  - `../:/workspace` — mounts the project root. **Keep this.**
  - Agent CLI config directories — adapt paths for your agent CLI:
    - opencode: `~/.config/opencode`, `~/.local/share/opencode`, `~/.local/state/opencode`
    - Claude Code: `~/.claude`
    - Other: check your CLI's config/data/state locations
  - `agent_signals:/tmp/agent-signals` — inter-agent signaling. **Keep this.**
- `depends_on`: List companion services the project needs.

**Companion services:**
The template includes PostgreSQL. Modify based on project needs — see
"Companion service examples" section below.

### denv/docker-compose.coord.yml

Extends base for interactive use. Adds `stdin_open: true` and `tty: true`.
**Rarely needs modification.** Just ensure it extends the correct base service names.

### denv/docker-compose.worker.yml

Extends base for autonomous agent loops.
- `command`: Set to the agent loop command. Default: `["just", "run-agent"]`
- `restart`: `on-failure:3` for resilience

**Modify `command` if using a different agent CLI or loop mechanism.**

### justfile

Command runner with recipes for managing coord/worker stacks.

**Key recipes (keep all of these):**
- `denv-build` — builds the Docker image
- `start-coord` / `stop-coord` — coordinator lifecycle
- `new-agent` — single foreground worker
- `start-agents N` / `stop-agents` — background worker management
- `worker-logs` — view worker output
- `run-agent` — the inner agent loop (called inside the container)

**Adapt:**
- The `run-agent` recipe: change the CLI invocation if not using opencode.
  The signal file mechanism (`no-plan` → sleep 5 min) is part of the trame workflow
  and should stay regardless of CLI choice. Only the `cat prompt.md | opencode ... run`
  line needs to change.
- Add project-specific recipes (test, build, migrate, lint, etc.)

### opencode.json

opencode-specific configuration. Contains:
- `plugin`: References to `.opencode/plugins/` (see below)
- `mcp.trame`: The trame MCP server connection

For other agent CLIs, replace this file with the equivalent config and set up the
trame MCP connection per their docs (see "Agent CLI alternatives" below).

### .opencode/plugins/

opencode plugins that provide two tools used by the trame workflow:

- **`setup-worktree.ts`** → `setup_worktree` tool: Creates or reuses a git worktree
  under `worktrees/<branch>` for isolated work. Returns the worktree path. All file
  edits, test runs, and commits should happen inside this path.

- **`agent-signal.ts`** → `agent_signal` tool: Writes a signal file (e.g., `no-plan`)
  to `$AGENT_SIGNALS_DIR`. The `run-agent` justfile loop checks for these files
  between iterations to decide whether to sleep.

**When using a different CLI:** These tools need equivalents. Some CLIs (like Claude Code
running via trame) get `setup_worktree` and `agent_signal` as MCP tools from the trame
server directly. For others, you'll need to implement equivalent functionality — the
plugin source code serves as a reference for the expected behavior.

### AGENTS.md

System-level instructions injected into agent context. Update with:
- Project name and description
- Key architectural decisions
- Testing and commit conventions
- Links to important files/docs

### prompt.md

The prompt fed to the agent on each loop iteration (worker mode).

**Trame workflow parts (keep these):**
- Study project specs via trame
- Claim an implementation plan if none is claimed
- Call `agent_signal` with `no-plan` if no plans are available
- Call `setup_worktree` before starting work
- Update plan status on trame when done

**Project-specific parts (adapt these):**
- Testing strategy (property-based, unit, integration)
- Commit conventions
- Any project-specific workflow steps

## Agent CLI alternatives

### opencode (default)

- **Install:** curl binary from GitHub releases
- **Config:** `opencode.json` with `mcp` and `plugin` sections
- **Auth:** `opencode mcp auth trame`
- **Agent loop:** `cat prompt.md | opencode -m "$MODEL" run`
- **Plugins:** `.opencode/plugins/` provides `setup_worktree` and `agent_signal` tools

### Claude Code

- **Install:** `npm install -g @anthropic-ai/claude-code`
- **Config:** `.claude/settings.json` or `claude mcp add --transport http trame https://trame.sh/mcp`
- **Auth:** Automatic OAuth on first MCP call
- **Agent loop:** `cat prompt.md | claude --dangerously-skip-permissions`
- **Plugins:** `setup_worktree` and `agent_signal` are provided by the trame MCP server
  when running via Claude Code — no local plugins needed

### Generic / Other

- Install the CLI per its docs
- Configure MCP connection to `https://trame.sh/mcp`
- Adapt the `run-agent` justfile recipe with the correct invocation
- Implement `setup_worktree` and `agent_signal` tool equivalents if not provided
  by the trame MCP server for your CLI

## Companion service examples

### PostgreSQL (included in template)
```yaml
postgres:
  image: postgres:15-alpine
  environment:
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: testpass
    POSTGRES_DB: myproject
  volumes:
    - postgres_data:/var/lib/postgresql/data
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres"]
    interval: 5s
    timeout: 5s
    retries: 5
```

### Redis
```yaml
redis:
  image: redis:7-alpine
  volumes:
    - redis_data:/data
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 5s
    timeout: 5s
    retries: 5
```

### MongoDB
```yaml
mongo:
  image: mongo:7
  environment:
    MONGO_INITDB_ROOT_USERNAME: root
    MONGO_INITDB_ROOT_PASSWORD: testpass
  volumes:
    - mongo_data:/data/db
  healthcheck:
    test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
    interval: 5s
    timeout: 5s
    retries: 5
```

### MySQL
```yaml
mysql:
  image: mysql:8
  environment:
    MYSQL_ROOT_PASSWORD: testpass
    MYSQL_DATABASE: myproject
  volumes:
    - mysql_data:/var/lib/mysql
  healthcheck:
    test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
    interval: 5s
    timeout: 5s
    retries: 5
```

Each companion service should have:
- A healthcheck (so `depends_on` with `condition: service_healthy` works)
- A named volume for data persistence
- Environment variables for credentials
