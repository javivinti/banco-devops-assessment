#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KIND="$ROOT/.bin/kind"

echo "[1/3] Kill kubectl port-forward"
pkill -f "kubectl port-forward" || true

echo "[2/3] Delete kind cluster"
if [ -x "$KIND" ]; then
  "$KIND" delete cluster --name banco-devops || true
fi

echo "[3/3] Stop local docker containers (if any)"
docker ps -q | xargs -r docker stop

echo "DOWN ✅"
