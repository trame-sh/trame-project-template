# Default recipe (show available commands)
default:
    @just --list

# Install all dependencies
install:
    pnpm install

# Run autonomous agent
run-agent:
  while :; do cat prompt.md | opencode -m anthropic/claude-sonnet-4-5 run; done

# Create a worktree for a feature branch, and start a development environment for it
start-env NAME:
  #!/usr/bin/env bash
  export LOCAL_UID=$(id -u)
  export LOCAL_GID=$(id -g)
  git worktree add -b {{NAME}} ./worktrees/{{NAME}}
  docker compose -p {{NAME}} -f denv/docker-compose.env.yml up -d

# Stop the development environment running in this worktree
stop-env:
  #!/usr/bin/env bash
  ENV=$(basename "$(git rev-parse --show-toplevel)")
  docker compose -p $ENV down

delete-env NAME:
  #!/usr/bin/env bash
  docker compose -p $ENV down
  git worktree remove ./worktrees/{{NAME}}

# Attach to the opencode container
attach:
  #!/usr/bin/env bash
  ENV=$(basename "$(git rev-parse --show-toplevel)")
  docker compose -p $ENV exec -w /workspace/worktrees/$ENV opencode bash
