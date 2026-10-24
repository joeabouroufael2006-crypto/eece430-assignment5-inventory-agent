# EECE430 Assignment 5 - AI Inventory Agent in Docker

A Dockerized version of the original Django Inventory Agent from Assignment 3.
It keeps the inventory tools, price updates, VAT calculation, Gemini chat,
HTML interface and sample Chocolate bar migration.

## Verified results - 24 October 2026

- The dedicated public repository contains the source and Docker configuration.
- GitHub Actions built and published images for Linux AMD64 and ARM64.
- The instructor invitation to **Ali-Moukallid** (am38@aub.edu.lb) is pending acceptance.
- The GitHub-published ARM64 image runs in Docker Desktop on the Mac.
- The homepage returns HTTP 200 and all 3 Django tests pass.
- Live Gemini chat returned **8.25** for 3 chocolate bars with 10% VAT:
  subtotal 7.50 plus VAT 0.75. The sample stock remains 10 units.
- The image does not contain a `.env` file or Gemini API key.

Successful original image build:
https://github.com/joeabouroufael2006-crypto/eece430-assignment5-inventory-agent/actions/runs/40077926645

Export of that published image:
https://github.com/joeabouroufael2006-crypto/eece430-assignment5-inventory-agent/actions/runs/40078359503

## Standard Docker build and run

Docker Desktop must be running. Clone this repository and create a private `.env`
using `.env.example`; enter your own Gemini API key there.

```bash
docker build -t inventory-agent .
docker run -d --name inventory-agent \
  -p 127.0.0.1:8000:8000 --env-file .env \
  --mount type=volume,source=eece430-assignment5-db,target=/data \
  inventory-agent
```

Open http://127.0.0.1:8000/.

## Run the image from GitHub

The image is hosted at:

```text
ghcr.io/joeabouroufael2006-crypto/eece430-assignment5-inventory-agent:latest
```

With access to the registry, use `bash run_from_github.sh`. If the package is
private, your GitHub account needs package read access and Docker must be signed
in. The existing publishing workflow uses its own temporary GitHub token.

### Downloadable image for registry connection failures

On this Mac, a direct pull failed because DNS could not resolve `ghcr.io`.
The **Download published Docker image** workflow pulls the published image on
GitHub's runner and exports it as a downloadable archive. This route was verified
on the Mac with the actual published image.

1. Open the successful export run linked above and download its
   `inventory-agent-arm64` artifact while it is retained.
2. Unzip the artifact. It contains `inventory-agent-arm64.tar.gz`,
   `SHA256SUMS`, and `image-details.txt`.
3. Check the archive and load it:

```bash
shasum -a 256 -c SHA256SUMS
bash run_downloaded_image.sh \
  /path/to/inventory-agent-arm64.tar.gz /path/to/private/.env
```

The export targets Apple Silicon (ARM64). An Intel machine should use the AMD64
image from the registry or build the Dockerfile locally. GitHub artifacts expire
after 30 days; rerun the export workflow for another downloadable copy.

## Verify and restart

```bash
docker exec eece430-assignment5-from-github python manage.py check
docker exec eece430-assignment5-from-github python manage.py test chat --noinput
docker start eece430-assignment5-from-github
```

Ask: `What is the cost of 3 chocolate bars after adding 10% VAT?`
A fresh sample inventory returns 8.25. A quote does not reduce stock. Persistent
inventory changes can alter later quotes.

The database is saved in the named Docker volume `eece430-assignment5-db`.
Stopping a container preserves it. Keep `.env` private; pass it at runtime.
This project uses Django's development server for the local coursework demo.

## Technology

Python 3.13, Django 6.1.2, google-genai 2.23.0, python-dotenv 1.x and SQLite.
The entrypoint applies migrations before starting the app on port 8000.
