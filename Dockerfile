# Dockerized version of the student's Assignment 3 Inventory Agent.
FROM python:3.13-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=60 \
    INVENTORY_DB_PATH=/data/db.sqlite3

WORKDIR /app

# Install separately from app code, so a normal code change uses the dependency cache.
# --prefer-binary avoids unnecessary compilation on Apple Silicon.
COPY requirements.txt /app/requirements.txt
RUN python -m pip install --no-cache-dir --prefer-binary --retries 8 --timeout 60 -r /app/requirements.txt

COPY . /app
RUN mkdir -p /data && chmod +x /app/docker/entrypoint.sh

EXPOSE 8000
VOLUME ["/data"]
ENTRYPOINT ["/app/docker/entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
