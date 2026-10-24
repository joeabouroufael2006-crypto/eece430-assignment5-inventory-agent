#!/usr/bin/env bash
# Local Docker build option; recommended fallback is GitHub Actions if pip/network fails on Mac.
set -euo pipefail
cd "$(dirname "$0")"
IMAGE="eece430-assignment5-inventory-agent:local"
CONTAINER="eece430-assignment5-inventory"
VOLUME="eece430-assignment5-db"
command -v docker >/dev/null || { echo "Install Docker Desktop first." >&2; exit 1; }
docker info >/dev/null 2>&1 || { echo "Open Docker Desktop before continuing." >&2; exit 1; }
[[ -f .env ]] || { echo "Missing .env; run bash finish_assignment5_mac.sh to set up the private key." >&2; exit 1; }

echo "Building image locally; full pip logs are saved to docker-build-last.log."
if ! docker build --progress=plain -t "$IMAGE" . 2>&1 | tee docker-build-last.log; then
    echo >&2
    echo "Local image build failed. See docker-build-last.log for the actual pip error." >&2
    echo "The assignment can still be built on GitHub Actions: bash finish_assignment5_mac.sh" >&2
    echo "If you see 'Name or service not known', 'Temporary failure in name resolution'," >&2
    echo "or 'Read timed out', your Docker/PyPI network access is the issue." >&2
    exit 1
fi
docker volume create "$VOLUME" >/dev/null
docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
docker run -d --name "$CONTAINER" -p 127.0.0.1:8000:8000 \
   --env-file .env -v "$VOLUME:/data" "$IMAGE" >/dev/null
echo "Waiting for database migration..."
sleep 4
docker logs "$CONTAINER"
[[ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER")" == "true" ]] || exit 1
echo "Application: http://127.0.0.1:8000/"
