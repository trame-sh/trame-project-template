# Default recipe (show available commands)
default:
    @just --list

# Install all dependencies
install:
    pnpm install

# Run autonomous agent
run-agent:
  #!/usr/bin/env bash
  SIGNALS_DIR="${AGENT_SIGNALS_DIR:-/tmp/agent-signals}"
  mkdir -p "$SIGNALS_DIR"
  while :; do
    cat prompt.md | opencode -m anthropic/claude-sonnet-4-5 run || {
      echo "[run-agent] opencode exited with code $? — aborting"
      exit 1
    }
    if [ -f "$SIGNALS_DIR/no-plan" ]; then
      rm -f "$SIGNALS_DIR/no-plan"
      echo "[run-agent] no plans available — sleeping 5 minutes"
      sleep 300
    fi
  done

# Create a worktree for a feature branch, and start a development environment for it
start-env NAME="main":
  #!/usr/bin/env bash
  export LOCAL_UID=$(id -u)
  export LOCAL_GID=$(id -g)
  if [[ {{NAME}} != "main" ]]; then
    git worktree add --relative-paths -b {{NAME}} ./worktrees/{{NAME}}
  fi
  docker compose -p {{NAME}} -f docker-compose.env.yml up -d

# Stop the development environment running in this worktree
stop-env:
  #!/usr/bin/env bash
  ENV=$(git rev-parse --abbrev-ref HEAD)
  docker compose -p $ENV down

delete-env NAME:
  #!/usr/bin/env bash
  docker compose -p {{NAME}} down
  git worktree remove ./worktrees/{{NAME}}

# Attach to the opencode container
attach:
  #!/usr/bin/env bash
  ENV=$(git rev-parse --abbrev-ref HEAD)
  docker compose -p $ENV attach opencode
