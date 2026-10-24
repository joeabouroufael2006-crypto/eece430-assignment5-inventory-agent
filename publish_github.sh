#!/usr/bin/env bash
# Upload only public source files; .env is excluded by .gitignore.
set -euo pipefail
cd "$(dirname "$0")"
REPO='eece430-assignment5-inventory-agent'
PROFESSOR='Ali-Moukallid'
command -v gh >/dev/null || { echo 'Run: brew install gh' >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo 'Run: gh auth login --web --git-protocol https' >&2; exit 1; }
OWNER="$(gh api user --jq .login)"
gh auth setup-git

[[ -d .git ]] || git init -b main
git add .
# Fail if the secret has accidentally been included.
if git ls-files --cached --name-only | grep -Eq '(^|/)(\.env|\.venv)(/|$)'; then
    echo 'ERROR: a local secret or environment was staged; stop before pushing.' >&2
    exit 1
fi
if ! git diff --cached --quiet; then
    git -c user.name="$OWNER" -c user.email="$OWNER@users.noreply.github.com" \
        commit -m 'Dockerize Assignment 3 Inventory Agent for EECE430 Assignment 5'
fi
git branch -M main
if ! gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
    gh repo create "$OWNER/$REPO" --public --source=. --remote=origin
fi
if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "https://github.com/$OWNER/$REPO.git"
else
    git remote add origin "https://github.com/$OWNER/$REPO.git"
fi
git push -u origin main
echo "Published source: https://github.com/$OWNER/$REPO"
if gh api --method PUT "/repos/$OWNER/$REPO/collaborators/$PROFESSOR" -f permission=push >/dev/null; then
    echo 'Professor collaborator invitation requested; confirm under Settings > Collaborators.'
else
    echo 'Please invite am38@aub.edu.lb via Settings > Collaborators.' >&2
fi
