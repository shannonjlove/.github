#!/bin/bash
# Remote VPS Command Executor
# Usage: ./vps-execute.sh "your command here"

VPS_HOST="${VPS_HOST:-72.61.74.250}"
VPS_PORT="${VPS_PORT:-8812}"
API_KEY="${REMOTE_EXECUTOR_KEY:-}"

if [ -z "$API_KEY" ]; then
    echo "❌ Error: REMOTE_EXECUTOR_KEY not set"
    echo "Set it: export REMOTE_EXECUTOR_KEY='your-key-here'"
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: $0 'command'"
    exit 1
fi

COMMAND="$1"
SHELL_MODE="${2:-false}"

# Execute via HTTP API
curl -s -X POST \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"command\": \"$COMMAND\", \"shell\": $SHELL_MODE}" \
    "http://$VPS_HOST:$VPS_PORT/execute" | jq .

