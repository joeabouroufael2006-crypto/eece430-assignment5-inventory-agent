#!/usr/bin/env bash
# Primary route: publish to GitHub first, let its runner build dependencies,
# then download/run the published image on the Mac. This avoids host pip failures.
set -euo pipefail
cd "$(dirname "$0")"
REPO='eece430-assignment5-inventory-agent'
echo 'EECE430 Assignment 5 - Finish using GitHub Actions (cloud build)'

command -v gh >/dev/null || { echo 'Install GitHub CLI: brew install gh' >&2; exit 1; }
if ! gh auth status >/dev/null 2>&1; then
    gh auth login --web --git-protocol https
fi
command -v docker >/dev/null || { echo 'Install Docker Desktop first.' >&2; exit 1; }
if ! docker info >/dev/null 2>&1; then
    echo 'Open Docker Desktop and finish its setup first.' >&2
    exit 1
fi

# Preserve private key from the earlier project if possible; do NOT print it.
if [[ ! -f .env && -f "$HOME/Desktop/EECE430_Assignment5_Corrected/.env" ]]; then
    cp "$HOME/Desktop/EECE430_Assignment5_Corrected/.env" .env
    echo 'Reused your local private .env file from the earlier Assignment 5 folder.'
fi
if [[ ! -f .env ]]; then
    umask 077
    cp .env.example .env
fi
key="$(sed -n 's/^GEMINI_API_KEY=//p' .env | head -n 1)"
if [[ -z "$key" || "$key" == PASTE_* || "$key" == your_actual_key_here ]]; then
    printf 'Enter your Gemini API key (hidden): '
    IFS= read -r -s key
    printf '\n'
    [[ -n "$key" ]] || { echo 'A private Gemini key is required for live chat.' >&2; exit 1; }
    umask 077
    secret="$(openssl rand -hex 32)"
    printf 'GEMINI_API_KEY=%s\nDJANGO_SECRET_KEY=%s\n' "$key" "$secret" > .env
fi
unset key
chmod 600 .env

echo 'STEP 1 - Publishing project to a new public GitHub repository...'
bash publish_github.sh
OWNER="$(gh api user --jq .login)"
LINK="https://github.com/$OWNER/$REPO"
echo 'STEP 2 - Waiting for GitHub Actions to build and publish a Docker image...'
run_id=''
for _ in $(seq 1 24); do
    run_id="$(gh run list --repo "$OWNER/$REPO" --workflow docker-image.yml --branch main --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || true)"
    [[ -n "$run_id" ]] && break
    sleep 5
done
if [[ -z "$run_id" ]]; then
    echo "Code is uploaded, but the Actions run is not visible yet. Check $LINK/actions" >&2
    exit 1
fi
if ! gh run watch "$run_id" --repo "$OWNER/$REPO" --exit-status; then
    echo "Cloud image build failed. Open $LINK/actions and check its logs." >&2
    echo 'If you prefer a local build, try: bash start_mac.sh' >&2
    exit 1
fi
echo 'STEP 3 - Downloading and running the image from GitHub...'
if ! bash run_from_github.sh; then
    echo 'Repository and cloud image were published, but local pull/run is pending.' >&2
    echo 'Check GitHub package visibility and Docker DNS, then run: bash run_from_github.sh' >&2
    exit 1
fi
echo 'STEP 4 - Running original Inventory Agent pricing/VAT tests...'
docker exec eece430-assignment5-from-github python manage.py test chat --noinput
echo 'STEP 5 - Writing a simple submission file...'
printf 'EECE430 Assignment 5\nJoe Abou Roufael\n\nPublic GitHub repository: %s\nDocker image: ghcr.io/%s/%s:latest\n\nProfessor collaborator invitation: see repository Settings > Collaborators.\n' \
    "$LINK" "$(printf '%s' "$OWNER" | tr '[:upper:]' '[:lower:]')" "$REPO" > SUBMIT_THIS_LINK.txt
printf 'Application launched from Docker image hosted on GitHub.\nImage: ghcr.io/%s/%s:latest\n' \
   "$(printf '%s' "$OWNER" | tr '[:upper:]' '[:lower:]')" "$REPO" > DOCKER_RUN_PROOF.txt
docker ps --filter name=eece430-assignment5-from-github --format '{{.Names}} {{.Image}} {{.Status}}' >> DOCKER_RUN_PROOF.txt
echo "DONE: $LINK"
echo 'Open http://127.0.0.1:8000/ and try: cost of 3 chocolate bars with 10% VAT'
echo 'Submit SUBMIT_THIS_LINK.txt if Moodle requires an upload.'
