# Troubleshooting

[← Back to README](../README.md) · [Español](es/problemas.md)

Find the error you see, then apply the fix.

## Docker

| Error | Fix |
|-------|-----|
| `Cannot connect to the Docker daemon` | Docker isn't running. **Mac/Windows:** open Docker Desktop. **Linux:** `sudo systemctl enable --now docker` |
| `docker: command not found` | Docker isn't installed. See [Setup](00-setup.md) |
| `permission denied while trying to connect to the Docker daemon socket` (Linux) | `sudo usermod -aG docker $USER`, then log out and back in |
| `'compose' is not a docker command` or `unknown flag: --wait` | Compose v2 is missing. **Ubuntu:** `sudo apt install docker-compose-v2`. Use `docker compose`, not `docker-compose` |
| `port is already allocated` / `address already in use` (5432) | Another Postgres is running. **Ubuntu:** `sudo systemctl stop postgresql`. Or [change the port](#use-a-different-port) |
| `container name "/dbz-sql" is already in use` | An old copy is still running: `docker rm -f dbz-sql` |

### Use a different port

In `docker-compose.yml`, change `"5432:5432"` to `"5433:5432"`. Then use port 5433 in your GUI client, and run the Go programs with:

```bash
export DATABASE_URL="postgres://goku:kamehameha@localhost:5433/dragonball?sslmode=disable"
```

## Go

| Error | Fix |
|-------|-----|
| errors mentioning `go 1.22`, or `GET /characters/{id}` returns 404 | Go is too old (`go version` must show 1.22+). **Ubuntu:** `sudo apt remove golang-go && sudo snap install go --classic` |
| `can't reach the database` | Start it first: `docker compose up -d --wait` |

## Windows

| Error | Fix |
|-------|-----|
| `./connect.sh` doesn't run, or `curl` complains about JSON | Use Git Bash. See [Setup → Windows](00-setup.md#windows) |
| `the input device is not a TTY` (Git Bash) | Add `winpty` in front: `winpty docker exec -it dbz-sql psql -U goku -d dragonball` |

## Something else

Reset everything to a clean state:

```bash
docker compose down -v && docker compose up -d --wait
```
