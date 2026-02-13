# trame Project Template

> Isolated development environments using git worktrees + docker compose for specs-driver agentic development

This template provides a streamlined setup for developing projects with [trame.sh](https://trame.sh). It leverages git worktrees to create isolated development environments where AI agents can work autonomously on features while fetching specifications from trame.sh via the Model Context Protocol (MCP).

## Overview

```
/
- dev/
-- Dockerfile # opencode in container
-- docker-compose.env.yml # simple isolated development stack
- opencode.json # barebone opencode configuration with trame.sh mcp
- justfile # our command runner
- .gitignore # ignoring worktrees/ folder, where we create our isolated environments
- prompt.md # a basic prompt.md used by our run-agent loop
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

Using the opencode CLI with trame MCP tools:

```bash
echo "Create a new project called 'my-project' for building a task management API" | opencode run
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

The agent will:

1. Fetch project specs from trame
2. Request or use an assigned implementation plan
3. Write tests first (TDD approach)
4. Implement the feature
5. Update `plan.md` with progress
6. Commit changes when tests pass

### 6. Attach to the Development Container (Optional)

If you need to interact with the containerized environment:

```bash
just attach
```

This attaches to the opencode container's terminal.

### 7. Stop the Environment

When done with the feature:

```bash
cd worktrees/feature-auth
just stop-env
```

This stops and removes the Docker containers for this worktree. The worktree directory and your code remain intact.

### 8. Clean Up the Worktree (After Merging)

After merging your feature branch:

```bash
cd ../../  # Back to main repo
git worktree remove worktrees/feature-auth
git branch -d feature-auth
```

## Configuration Files

### `opencode.json`

Configures the opencode CLI to connect to trame's MCP server:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "trame": {
      "type": "remote",
      "url": "https://trame.sh/mcp",
      "enabled": true
    }
  }
}
```

- **type**: `"remote"` — connects to a remote MCP server
- **url**: trame's MCP endpoint
- **enabled**: `true` — activates the trame integration

This configuration allows the opencode CLI (and autonomous agents) to fetch project specifications, features, and implementation plans from trame.

### `docker-compose.env.yml`

Defines the Docker environment for each worktree:

**Services:**

1. **opencode** - Development container with mounted workspace
   - Uses `opencode-env` image (must be built separately)
   - Mounts current directory as `/workspace`
   - Mounts opencode config for authentication persistence
   - Sets user permissions via `LOCAL_UID` and `LOCAL_GID`

2. **postgres** - PostgreSQL 15 database
   - Database: `trame_test`
   - User: `postgres` / Password: `testpass`
   - Healthcheck ensures database is ready before use
   - Data persisted in named volume `postgres_test_data`

**Environment Variables:**

- `DATABASE_URL` — Connection string for PostgreSQL (used by your application)
- `LOCAL_UID` / `LOCAL_GID` — Your user/group ID (prevents permission issues)

### `AGENTS.md`

Single-line instruction for AI agents:

```markdown
- specs of project, features and implementation plans are available on trame mcp tool
```

This tells agents where to fetch project specifications. You can expand this file with project-specific instructions.

### `prompt.md`

Defines the autonomous agent workflow:

```markdown
study project specs
if you don't have an implementation plan assigned on trame, request one
study your assigned implementation plan and select the most important task to work on

IMPORTANT:

- author property based tests or unit tests (which ever is best)
- after making changes to the files, run the tests
- when tests pass, update the plan.md, then commit your changes
```

This is used by `just run-agent` to create an infinite development loop where the agent:

1. Studies specs from trame
2. Gets or requests an implementation plan
3. Writes tests first (TDD)
4. Implements code
5. Updates `plan.md`
6. Commits when tests pass
7. Repeats

## Usage

### Managing Multiple Features

You can create as many worktree environments as you need:

```bash
just start-env feature-oauth      # Creates ./worktrees/feature-oauth/
just start-env feature-api        # Creates ./worktrees/feature-api/
just start-env feature-ui         # Creates ./worktrees/feature-ui/
```

Each environment:

- Has its own git branch
- Runs independent Docker containers
- Has isolated PostgreSQL database
- Can run autonomous agents independently

### Working with Autonomous Agents

#### Running the Agent Loop

```bash
cd worktrees/your-feature
just run-agent
```

This runs an infinite loop that repeatedly executes `prompt.md` using the Claude Sonnet 4.5 model through opencode.

**The agent will:**

- Fetch project specs from trame via MCP
- Read or request an implementation plan
- Implement tasks from the plan
- Write tests before code (TDD)
- Commit progress automatically

**To stop the agent:** Press `Ctrl+C`

#### Customizing Agent Behavior

Edit `prompt.md` to change the agent workflow:

```markdown
study project specs

# Add custom instructions
- follow our coding style guide at docs/STYLE.md
- always add JSDoc comments to functions
- use functional programming patterns

# Standard workflow
if you don't have an implementation plan assigned on trame, request one
study your assigned implementation plan and select the most important task to work on

IMPORTANT:
- author property based tests or unit tests (which ever is best)
- after making changes to the files, run the tests
- when tests pass, update the plan.md, then commit your changes
```

### Working with Implementation Plans

The agent creates and updates a `plan.md` file in each worktree to track progress.

**Example `plan.md` structure:**

```markdown
# Implementation Plan: User Authentication

## Status: In Progress

## Tasks

- [x] Set up database schema for users table
- [x] Implement password hashing with bcrypt
- [ ] Create login endpoint with JWT
- [ ] Add refresh token mechanism
- [ ] Write integration tests for auth flow

## Notes

- Using bcrypt with cost factor 12
- JWT expires in 15 minutes, refresh token in 7 days
```

The agent updates this file as it completes tasks.

### Manual Development (Without Agents)

You can also use the worktree environments for manual development:

```bash
cd worktrees/feature-api

# Install dependencies (if Node.js project)
just install

# Make changes to code
# Run tests
# Commit manually

git add .
git commit -m "Add user authentication endpoint"
```

### Database Access

Each worktree has its own PostgreSQL instance accessible at:

```
Host: postgres
Port: 5432
Database: trame_test
User: postgres
Password: testpass
```

**Connection string (from within opencode container):**

```
postgresql://postgres:testpass@postgres:5432/trame_test
```

This is automatically set in the `DATABASE_URL` environment variable.

### Available Commands

Run `just` (or `just --list`) to see all available commands:

```bash
just                # Show available commands
just install        # Install dependencies (pnpm install)
just run-agent      # Run autonomous agent loop
just start-env NAME # Create worktree + start Docker environment
just stop-env       # Stop current worktree's Docker environment
just attach         # Attach to opencode container terminal
```

## Workflow Examples

### Example 1: Feature Development with AI Agent

```bash
# 1. Create environment
just start-env feature-notifications
cd worktrees/feature-notifications

# 2. Start autonomous agent
just run-agent

# Agent will:
# - Fetch specs from trame
# - Request implementation plan
# - Write tests
# - Implement feature
# - Commit progress

# 3. Monitor progress
# Watch git log to see commits
git log --oneline

# 4. Review implementation
# Check plan.md for status
cat plan.md

# 5. Stop agent when done (Ctrl+C)

# 6. Push to remote
git push origin feature-notifications

# 7. Create PR and merge

# 8. Clean up
cd ../..
just stop-env
git worktree remove worktrees/feature-notifications
git branch -d feature-notifications
```

### Example 2: Manual Development in Parallel

```bash
# Terminal 1: Work on feature A
just start-env feature-api-endpoints
cd worktrees/feature-api-endpoints
# Edit code, run tests manually

# Terminal 2: Work on feature B
just start-env feature-database-migrations
cd worktrees/feature-database-migrations
# Edit migrations, test

# Terminal 3: Run agent on feature C
just start-env feature-auth-refactor
cd worktrees/feature-auth-refactor
just run-agent
# Agent works autonomously

# Each feature has isolated:
# - Git branch
# - Docker containers
# - PostgreSQL database
# - Dependencies
```

### Example 3: Debugging in Container

```bash
just start-env debug-issue-123
cd worktrees/debug-issue-123

# Attach to container to run commands interactively
just attach

# Inside container:
# Run tests with verbose output
pnpm test --verbose

# Debug database
psql postgresql://postgres:testpass@postgres:5432/trame_test

# Exit container (Ctrl+D)

# Continue debugging locally
```

## Troubleshooting

### Docker Containers Won't Start

**Symptom:** `just start-env` fails with Docker errors

**Solutions:**

1. **Check Docker is running:**

   ```bash
   docker ps
   ```

2. **Build the opencode-env image first:**

   ```bash
   docker build -t opencode-env .
   ```

   (You may need to create a Dockerfile if not present)

3. **Check port conflicts:**
   Ensure PostgreSQL port 5432 isn't already in use:

   ```bash
   lsof -i :5432
   ```

4. **Check Docker Compose version:**

   ```bash
   docker compose version  # Should be v2.0+
   ```

### Permission Issues in Container

**Symptom:** Files created by container are owned by root

**Solution:** Ensure `LOCAL_UID` and `LOCAL_GID` are set:

```bash
export LOCAL_UID=$(id -u)
export LOCAL_GID=$(id -g)
just start-env your-feature
```

The `justfile` should set these automatically, but you can export them manually if needed.

### trame MCP Connection Fails

**Symptom:** Agent can't fetch specs from trame

**Solutions:**

1. **Check authentication:**

   ```bash
   opencode auth status
   ```

2. **Re-authenticate:**

   ```bash
   opencode auth login
   ```

3. **Verify opencode.json:**
   Check that `url` points to `https://trame.sh/mcp` and `enabled` is `true`

4. **Test MCP connection:**

   ```bash
   echo "List my trame projects" | opencode run
   ```

### Worktree Already Exists

**Symptom:** `just start-env` fails because worktree already exists

**Solution:**

```bash
# List existing worktrees
git worktree list

# Remove the conflicting worktree
git worktree remove worktrees/feature-name

# Try again
just start-env feature-name
```

### Database Connection Refused

**Symptom:** Application can't connect to PostgreSQL

**Solutions:**

1. **Wait for healthcheck:**
   PostgreSQL takes a few seconds to start. Check status:

   ```bash
   docker compose ps
   ```

2. **Check from inside container:**

   ```bash
   just attach
   psql postgresql://postgres:testpass@postgres:5432/trame_test
   ```

3. **Restart services:**

   ```bash
   just stop-env
   just start-env your-feature
   ```

### Agent Keeps Failing

**Symptom:** `just run-agent` loop repeatedly fails

**Solutions:**

1. **Check prompt.md syntax:**
   Ensure it's valid markdown with clear instructions

2. **Review agent logs:**
   The agent output shows what it's trying to do

3. **Run agent manually (single iteration):**

   ```bash
   cat prompt.md | opencode -m anthropic/claude-sonnet-4-5 run
   ```

4. **Check trame plan assignment:**
   Ensure you have an implementation plan assigned in trame

## Advanced Usage

### Custom Docker Services

Add additional services to `docker-compose.env.yml`:

```yaml
services:
  opencode:
    # ... existing config

  postgres:
    # ... existing config

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  mailhog:
    image: mailhog/mailhog
    ports:
      - "8025:8025"  # Web UI
      - "1025:1025"  # SMTP
```

### Custom Environment Variables

Edit `docker-compose.env.yml` to add environment variables:

```yaml
services:
  opencode:
    environment:
      - LOCAL_UID=$LOCAL_UID
      - LOCAL_GID=$LOCAL_GID
      - DATABASE_URL=postgresql://postgres:testpass@postgres:5432/trame_test
      - REDIS_URL=redis://redis:6379
      - SMTP_HOST=mailhog
      - SMTP_PORT=1025
```

### Different AI Models

Change the model in `justfile`:

```makefile
# Use a different model
run-agent:
  while :; do cat prompt.md | opencode -m anthropic/claude-opus-4 run; done
```

Available models:

- `anthropic/claude-sonnet-4-5` (default, balanced)
- `anthropic/claude-opus-4` (most capable, slower)
- `openai/gpt-4` (OpenAI alternative)

## Best Practices

1. **One Feature Per Worktree**
   - Keep worktrees focused on single features or bug fixes
   - Easier to review and merge

2. **Stop Environments When Not in Use**
   - Saves system resources
   - Run `just stop-env` when done

3. **Clean Up Merged Worktrees**
   - Remove worktrees after merging to remote
   - Keeps repository clean

4. **Commit Frequently**
   - Let agents commit small changes
   - Easier to review and rollback

5. **Review Agent Changes**
   - Always review what the agent committed
   - Test manually before pushing

6. **Use Descriptive Worktree Names**
   - `feature-oauth` instead of `feat1`
   - `fix-login-bug` instead of `bugfix`

7. **Keep prompt.md Updated**
   - Adjust agent instructions as project evolves
   - Add project-specific constraints

## Contributing

This is a template repository. Feel free to fork and customize for your needs.

If you find issues or have improvements, please:

1. Open an issue on GitHub
2. Submit a pull request
3. Share your customizations with the community

## License

MIT License - see [LICENSE](LICENSE) file for details

## Resources

- **trame Platform**: [trame.sh](https://trame.sh)
- **trame Documentation**: [trame.sh/docs](https://trame.sh/docs)
- **OpenCode CLI**: [opencode.ai](https://opencode.ai)
- **Just Command Runner**: [github.com/casey/just](https://github.com/casey/just)
- **Git Worktrees**: [git-scm.com/docs/git-worktree](https://git-scm.com/docs/git-worktree)

## Support

- **Documentation**: Visit [trame.sh/docs](https://trame.sh/docs)
- **Issues**: Open an issue on this repository
- **Community**: Join discussions in trame community channels

---

**Happy building with trame!** 🚀
