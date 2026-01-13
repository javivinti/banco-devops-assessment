#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$ROOT/.bin"
KUBECTL="$BIN/kubectl"
KIND="$BIN/kind"

CLUSTER="banco-devops"
IMAGE="banco-app:latest"
HOST_PORT="8000"

mkdir -p "$BIN"

# ---- bootstrap local  ----
if [ ! -x "$KUBECTL" ]; then
  echo "[bootstrap] downloading kubectl..."
  KVER="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
  curl -L -o "$KUBECTL" "https://dl.k8s.io/release/${KVER}/bin/linux/amd64/kubectl"
  chmod +x "$KUBECTL"
fi

if [ ! -x "$KIND" ]; then
  echo "[bootstrap] downloading kind..."
  curl -L -o "$KIND" "https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64"
  chmod +x "$KIND"
fi

echo "[1/5] create kind cluster (if needed)"
if ! "$KIND" get clusters | grep -q "^${CLUSTER}$"; then
  "$KIND" create cluster --name "$CLUSTER"
else
  echo "  - cluster exists: $CLUSTER"
fi

echo "[2/5] build docker image"
docker build -t "$IMAGE" "$ROOT"

echo "[3/5] load image into kind"
"$KIND" load docker-image "$IMAGE" --name "$CLUSTER"

echo "[4/5] apply kubernetes manifests"
"$KUBECTL" apply -f "$ROOT/k8s/"

echo "[5/5] wait & port-forward to localhost:${HOST_PORT}"
"$KUBECTL" rollout status deploy/app --timeout=120s || true
"$KUBECTL" rollout status deploy/nginx --timeout=120s || true

pkill -f "kubectl port-forward svc/nginx ${HOST_PORT}:80" >/dev/null 2>&1 || true
nohup "$KUBECTL" port-forward svc/nginx "${HOST_PORT}:80" >/tmp/pichincha_pf.log 2>&1 &

echo ""
echo "READY ✅"
echo "HOST=http://localhost:${HOST_PORT}"
echo "JWT=\$(curl -s http://localhost:${HOST_PORT}/token)"
