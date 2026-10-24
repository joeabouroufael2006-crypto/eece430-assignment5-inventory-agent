# EECE430 Assignment 5 — AI Inventory Agent in Docker

This version is based on **your uploaded `EECE430_Assignment3_Final(1).zip`**.
Your original inventory CRUD tools, price editing, VAT calculation, Gemini agent,
chat UI, and sample Chocolate bar migration are preserved.

## Professor's requirements
1. Create a Docker image for the AI Agent application.
2. Push the application into a new GitHub repository.
3. Invite `am38@aub.edu.lb` as a collaborator.
4. Run the Docker image downloaded from GitHub.

## How to finish on your Mac (recommended cloud build)

Docker Desktop must be open and running. You have already installed `gh` and
signed into GitHub in Assignment 4. Download this ZIP to your Mac Desktop,
unzip it, and run:

```bash
cd ~/Desktop
unzip -o EECE430_Assignment5_FINAL_FIXED.zip
cd EECE430_Assignment5_FINAL
bash finish_assignment5_mac.sh
```

The script:
- Reuses your existing **private** `~/Desktop/EECE430_Assignment5_Corrected/.env`
  if you still have it; otherwise it asks for the Gemini key silently.
- Creates and uploads the source to a new **public** repo named
  `eece430-assignment5-inventory-agent`.
- Sends an invite to `Ali-Moukallid` (verify this is the GitHub account corresponding
  to your instructor's email `am38@aub.edu.lb`).
- Lets **GitHub Actions** build and publish the Docker image in GitHub Container Registry.
  This avoids the PyPI pip-install failure on your Mac during `docker build`.
- Pulls the published image to your Mac and runs it on port 8000.
- Runs the Django tests for price updates and VAT without using Gemini API credits.
- Writes `SUBMIT_THIS_LINK.txt` and `DOCKER_RUN_PROOF.txt` **only when verified**.

After completion, visit http://127.0.0.1:8000/ and ask:

> What is the cost of 3 chocolate bars after adding 10% VAT?

With a new inventory, the sample item has price 2.50 and the answer is 8.25.
A quote does not reduce stock. If you retained data from earlier runs, amounts
may differ because the inventory database is persistent.

### If the cloud Docker image is not public

In GitHub open your profile > **Packages** > the package > **Package settings** >
**Change visibility** > **Public**. Then run:

```bash
cd ~/Desktop/EECE430_Assignment5_FINAL
bash run_from_github.sh
```

### If Docker cannot download the image

Your earlier error `lookup registry-1.docker.io: no such host` was a DNS/network
problem. Switching Wi-Fi to a hotspot or correcting Docker Desktop networking may
be required. GitHub Actions can still create the image even if your Mac cannot.

### Optional local build (not required if GitHub Actions succeeds)

```bash
bash start_mac.sh
```

This command writes the full build log to `docker-build-last.log`. If `pip`
fails, inspect that log to distinguish DNS/timeouts from true Python dependency
conflicts. The earlier `exit code: 1` by itself does not identify the cause.

## Technical details
- Base image: Python 3.13 slim (Debian Bookworm).
- Django 6.1.2, google-genai 2.23.0, python-dotenv 1.x.
- Database persists in named Docker volume `eece430-assignment5-db`.
- The image contains **no Gemini API key**; the private `.env` is passed at runtime.
- GitHub Actions builds multiarchitecture Linux images (AMD64 and ARM64).
- GitHub repository contains the original `chat/`, `config/`, templates,
  migration files and screenshot, plus Docker and automation files.
- Designed for a local coursework demo, not for public deployment.

## What has and has not been verified here

Project source syntax, shell scripts, ZIP contents and VAT arithmetic were checked.
Docker and pip package installation could not be performed in the authoring
environment, which has no container engine or working PyPI network access.
Do not claim a successful GitHub build or local Docker run until the setup script
completes on your Mac.
