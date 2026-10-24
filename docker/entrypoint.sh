#!/bin/sh
set -eu

# Apply the original Assignment 3 migrations (including its sample Chocolate bar).
python manage.py migrate --noinput
exec "$@"
