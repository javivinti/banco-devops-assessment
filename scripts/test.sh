#!/usr/bin/env bash
set -euo pipefail

HOST="http://localhost:8000"
JWT="$(curl -s ${HOST}/token)"

curl -s -X POST \
-H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" \
-H "X-JWT-KWY: ${JWT}" \
-H "Content-Type: application/json" \
-d '{ "message":"This is a test", "to":"Javier Carpio", "from":"Rita Asturia", "timeToLifeSec":45 }' \
"${HOST}/DevOps"

echo ""
