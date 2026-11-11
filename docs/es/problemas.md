# Problemas comunes

[← Volver al README](../../README.es.md) · [English](../troubleshooting.md)

Buscá el error que te aparece y aplicá la solución. Los mensajes de error están en inglés porque así los vas a ver en la terminal.

## Docker

| Error | Solución |
|-------|----------|
| `Cannot connect to the Docker daemon` | Docker no está corriendo. **Mac/Windows:** abrí Docker Desktop. **Linux:** `sudo systemctl enable --now docker` |
| `docker: command not found` | Docker no está instalado. Mirá la [Preparación](00-preparacion.md) |
| `permission denied while trying to connect to the Docker daemon socket` (Linux) | `sudo usermod -aG docker $USER`, después cerrá sesión y volvé a entrar |
| `'compose' is not a docker command` o `unknown flag: --wait` | Falta Compose v2. **Ubuntu:** `sudo apt install docker-compose-v2`. Usá `docker compose`, no `docker-compose` |
| `port is already allocated` / `address already in use` (5432) | Ya hay otro Postgres corriendo. **Ubuntu:** `sudo systemctl stop postgresql`. O [cambiá el puerto](#usar-otro-puerto) |
| `container name "/dbz-sql" is already in use` | Quedó una copia vieja corriendo: `docker rm -f dbz-sql` |

### Usar otro puerto

En `docker-compose.yml`, cambiá `"5432:5432"` por `"5433:5432"`. Después usá el puerto 5433 en tu programa gráfico, y ejecutá los programas en Go con:

```bash
export DATABASE_URL="postgres://goku:kamehameha@localhost:5433/dragonball?sslmode=disable"
```

## Go

| Error | Solución |
|-------|----------|
| errores que mencionan `go 1.22`, o `GET /characters/{id}` devuelve 404 | Tu Go es muy viejo (`go version` tiene que decir 1.22 o más). **Ubuntu:** `sudo apt remove golang-go && sudo snap install go --classic` |
| `can't reach the database` | Levantá la base primero: `docker compose up -d --wait` |

## Windows

| Error | Solución |
|-------|----------|
| `./connect.sh` no se ejecuta, o `curl` se queja del JSON | Usá Git Bash. Mirá [Preparación → Windows](00-preparacion.md#windows) |
| `the input device is not a TTY` (Git Bash) | Agregá `winpty` adelante: `winpty docker exec -it dbz-sql psql -U goku -d dragonball` |

## Otra cosa

Volvé todo a un estado limpio:

```bash
docker compose down -v && docker compose up -d --wait
```
