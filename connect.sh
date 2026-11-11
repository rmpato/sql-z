#!/usr/bin/env bash
# Drop into psql against the Dragon Ball workshop DB (starts it if needed)
set -euo pipefail
cd "$(dirname "$0")"

# --wait blocks until the healthcheck passes, so psql never connects too early
docker compose up -d --wait

exec docker exec -it dbz-sql psql -U goku -d dragonball
