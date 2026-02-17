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
  docker compose -p coord -f denv/docker-compose.coord.yml exec --user node opencode bash

# Stop the coordinator
stop-coord:
  docker compose -p coord -f denv/docker-compose.coord.yml down

# Start a single worker agent in the foreground (Ctrl-C to stop)
new-agent:
  #!/usr/bin/env bash
  export LOCAL_UID=$(id -u)
  export LOCAL_GID=$(id -g)
  last=$(docker compose ls --format json | grep -o '"worker-[0-9]*"' | tr -d '"' | sed 's/worker-//' | sort -n | tail -1)
  id=$((${last:-0} + 1))
  project="worker-$id"
  echo "[new-agent] starting $project (Ctrl-C to stop)"
  trap "echo '[new-agent] stopping $project'; docker compose -p $project -f denv/docker-compose.worker.yml down" EXIT
  docker compose -p "$project" -f denv/docker-compose.worker.yml up --build

# Start N autonomous worker agents in the background
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
stop-agents:
  #!/usr/bin/env bash
  workers=$(docker compose ls --format json | grep -o '"worker-[0-9]*"' | tr -d '"')
  if [ -z "$workers" ]; then
    echo "[stop-agents] no workers running"
    exit 0
  fi
  for project in $workers; do
    echo "[stop-agents] stopping $project"
    docker compose -p "$project" -f denv/docker-compose.worker.yml down
  done
  echo "[stop-agents] all workers stopped"

# Show logs for a specific worker
worker-logs ID="1" FOLLOW="":
  #!/usr/bin/env bash
  FLAGS=""
  if [ -n "{{FOLLOW}}" ]; then FLAGS="-f"; fi
  docker compose -p "worker-{{ID}}" -f denv/docker-compose.worker.yml logs $FLAGS opencode

# Build the denv-opencode image
denv-build:
  docker build {{justfile_dir()}}/denv -t denv-opencode --no-cache
