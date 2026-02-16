# Default recipe (show available commands)
default:
    @just --list

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

# Start the coordinator (interactive bash shell)
start-coord:
  #!/usr/bin/env bash
  export LOCAL_UID=$(id -u)
  export LOCAL_GID=$(id -g)
  docker compose -p coord -f denv/docker-compose.coord.yml up -d
  docker compose -p coord -f denv/docker-compose.coord.yml exec opencode bash

# Stop the coordinator
stop-coord:
  docker compose -p coord -f denv/docker-compose.coord.yml down

# Start N autonomous worker agents (each in its own isolated stack)
start-agents N="1":
  #!/usr/bin/env bash
  export LOCAL_UID=$(id -u)
  export LOCAL_GID=$(id -g)
  for i in $(seq 1 {{N}}); do
    echo "[start-agents] starting worker-$i"
    docker compose -p "worker-$i" -f denv/docker-compose.worker.yml up -d
  done
  echo "[start-agents] started {{N}} worker(s)"

# Stop all worker agents
stop-agents N="1":
  #!/usr/bin/env bash
  for i in $(seq 1 {{N}}); do
    echo "[stop-agents] stopping worker-$i"
    docker compose -p "worker-$i" -f denv/docker-compose.worker.yml down
  done
  echo "[stop-agents] stopped {{N}} worker(s)"

# Show logs for a specific worker
worker-logs ID="1" FOLLOW="":
  #!/usr/bin/env bash
  FLAGS=""
  if [ -n "{{FOLLOW}}" ]; then FLAGS="-f"; fi
  docker compose -p "worker-{{ID}}" -f denv/docker-compose.worker.yml logs $FLAGS opencode

# Build the denv-opencode image
denv-build:
  docker build {{justfile_dir()}}/denv
