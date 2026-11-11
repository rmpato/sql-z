# 0. Preparación

[← Volver al README](../../README.es.md) · [English](../00-setup.md)

Necesitás cuatro herramientas:

| Herramienta | Para qué | Versión |
|-------------|----------|---------|
| [Docker](https://docs.docker.com/get-docker/) + Compose | corre la base de datos Postgres | Compose v2 |
| [Go](https://go.dev/dl/) | corre los pasos 2 y 3 | 1.22 o más nueva |
| [Git](https://git-scm.com/downloads) | descarga este repo | cualquiera |
| `curl` | manda pedidos en el paso 3 | cualquiera |

Elegí tu sistema operativo abajo y después [revisá la instalación](#revisá-la-instalación).

## Ubuntu / Linux

```bash
sudo apt update
sudo apt install -y git curl docker.io docker-compose-v2
sudo snap install go --classic

# para que tu usuario pueda usar docker sin sudo
sudo usermod -aG docker $USER
```

Después **cerrá sesión y volvé a entrar**, así se aplica el cambio del grupo `docker`.

Ojo con esto:

- **No instales Go con `apt install golang-go`.** En Ubuntu 22.04 eso instala Go 1.18, que es demasiado viejo para la API. Usá snap (como arriba) o [go.dev](https://go.dev/dl/).
- **Escribí `docker compose` (con espacio), no `docker-compose` (con guion).** La versión con guion es la v1, vieja.
- **Si Docker no está corriendo**, arrancalo con `sudo systemctl enable --now docker`.

¿Querés la última versión de Docker? Seguí la [guía oficial de Docker para Ubuntu](https://docs.docker.com/engine/install/ubuntu/) en lugar de usar `docker.io`.

## macOS

Instalá [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/) y [Go](https://go.dev/dl/). Git y curl ya vienen instalados.

**Abrí Docker Desktop** y esperá a que diga que está corriendo antes de usar `docker`.

## Windows

Instalá [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/), [Go](https://go.dev/dl/) y [Git for Windows](https://git-scm.com/downloads/win).

- **Abrí Docker Desktop** y esperá a que diga que está corriendo.
- **Usá Git Bash como terminal** (viene con Git for Windows). Todos los comandos de estas guías funcionan ahí tal cual.

PowerShell y cmd no pueden ejecutar `./connect.sh`, y los ejemplos con `curl` se rompen. Si preferís PowerShell, abrí psql con `docker exec -it dbz-sql psql -U goku -d dragonball` y usá [Postman](https://www.postman.com/) en lugar de `curl`.

## Revisá la instalación

```bash
docker compose version        # v2.x o más nueva
go version                    # go1.22 o más nueva
docker run --rm hello-world   # muestra "Hello from Docker!" (sin sudo)
```

¿Funcionan los tres? Seguí. Si no, mirá [Problemas comunes](problemas.md).

## Bajá el código y levantá la base de datos

```bash
git clone https://github.com/rmpato/sql-z.git
cd sql-z
docker compose up -d --wait
```

`--wait` espera hasta que Postgres esté listo. La primera vez también crea las tablas y carga los datos.

## Opcional: un programa con interfaz gráfica

[Beekeeper Studio](https://www.beekeeperstudio.io/) es una app gratuita para ver tablas y ejecutar consultas. Los resultados aparecen en una grilla y podés tener consultas en distintas pestañas. Es una alternativa más amigable que la terminal de `psql`.

- Ubuntu: `sudo snap install beekeeper-studio`
- macOS / Windows: bajalo de su página

Creá una conexión **PostgreSQL** con estos datos (también sirven para DBeaver, TablePlus y otros programas):

| Host | Puerto | Base de datos | Usuario | Contraseña |
|------|--------|---------------|---------|------------|
| localhost | 5432 | dragonball | goku | kamehameha |

---

**Siguiente:** [1. SQL a mano →](01-sql.md)
