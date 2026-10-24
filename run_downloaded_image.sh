#!/usr/bin/env bash
# Load the image exported from GitHub when direct GHCR access is unavailable.
set -euo pipefail
cd "$(dirname "$0")"

ARCHIVE="${1:-inventory-agent-arm64.tar.gz}"
ENV_FILE="${2:-.env}"
IMAGE='ghcr.io/joeabouroufael2006-crypto/eece430-assignment5-inventory-agent:latest'
CONTAINER='eece430-assignment5-from-github'

[[ -f "$ARCHIVE" ]] || { echo "Image archive not found: $ARCHIVE" >&2; exit 1; }
[[ -f "$ENV_FILE" ]] || { echo 'Pass your private .env file as the second argument.' >&2; exit 1; }
docker info >/dev/null
docker load --input "$ARCHIVE"

if docker container inspect "$CONTAINER" >/dev/null 2>&1; then
    docker start "$CONTAINER" >/dev/null
    echo 'The existing homework container is running.'
    echo 'Its application address is http://127.0.0.1:8000/'
    exit 0
fi

docker run -d --name "$CONTAINER" \
    -p 127.0.0.1:8000:8000 \
    --env-file "$ENV_FILE" \
    --mount type=volume,source=eece430-assignment5-db,target=/data \
    "$IMAGE"
echo 'Application started. Open http://127.0.0.1:8000/'
