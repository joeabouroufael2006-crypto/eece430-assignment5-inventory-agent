#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
REPO='eece430-assignment5-inventory-agent'
CONTAINER='eece430-assignment5-from-github'
VOLUME='eece430-assignment5-db'
command -v docker >/dev/null || { echo 'Install Docker Desktop.' >&2; exit 1; }
docker info >/dev/null 2>&1 || { echo 'Start Docker Desktop.' >&2; exit 1; }
[[ -f .env ]] || { echo 'Missing private .env; run bash finish_assignment5_mac.sh' >&2; exit 1; }
OWNER="${GITHUB_USERNAME:-}"
if [[ -z "$OWNER" ]]; then
    command -v gh >/dev/null || { echo 'Install gh or set GITHUB_USERNAME.' >&2; exit 1; }
    OWNER="$(gh api user --jq .login)"
fi
OWNER="$(printf '%s' "$OWNER" | tr '[:upper:]' '[:lower:]')"
IMAGE="ghcr.io/$OWNER/$REPO:latest"
echo "Pulling the Docker image built on GitHub: $IMAGE"
if ! docker pull "$IMAGE"; then
    echo 'Could not pull image from GHCR. Confirm the Actions workflow is green,' >&2
    echo 'then make the package Public in GitHub profile > Packages > Package settings.' >&2
    echo 'If DNS/connectivity fails, check Docker Desktop networking.' >&2
    exit 1
fi
docker rm -f eece430-assignment5-inventory >/dev/null 2>&1 || true
docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
docker volume create "$VOLUME" >/dev/null
docker run -d --name "$CONTAINER" -p 127.0.0.1:8000:8000 --env-file .env \
     -v "$VOLUME:/data" "$IMAGE" >/dev/null
sleep 4
docker logs "$CONTAINER"
[[ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER")" == "true" ]] || exit 1
echo "Application running from GitHub-hosted image at http://127.0.0.1:8000/"
