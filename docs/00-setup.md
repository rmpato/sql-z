# 0. Setup

[← Back to README](../README.md)

You need four tools:

| Tool | Why | Version |
|------|-----|---------|
| [Docker](https://docs.docker.com/get-docker/) + Compose | runs the Postgres database | Compose v2 |
| [Go](https://go.dev/dl/) | runs steps 2 and 3 | 1.22 or newer |
| [Git](https://git-scm.com/downloads) | downloads this repo | any |
| `curl` | sends requests in step 3 | any |

Pick your system below, then [check your install](#check-your-install).

## Ubuntu / Linux

```bash
sudo apt update
sudo apt install -y git curl docker.io docker-compose-v2
sudo snap install go --classic

# let your user run docker without sudo
sudo usermod -aG docker $USER
```

Then **log out and back in**, so the `docker` group change takes effect.

Watch out for:

- **Don't install Go with `apt install golang-go`.** On Ubuntu 22.04 that's Go 1.18, too old for the API. Use snap (above) or [go.dev](https://go.dev/dl/).
- **Type `docker compose` (space), not `docker-compose` (hyphen).** The hyphen version is the old v1.
- **If Docker isn't running**, start it with `sudo systemctl enable --now docker`.

Prefer the latest Docker? Follow [Docker's official Ubuntu guide](https://docs.docker.com/engine/install/ubuntu/) instead of `docker.io`.

## macOS

Install [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/) and [Go](https://go.dev/dl/). Git and curl are already there.

**Open Docker Desktop** and wait until it says it's running before you use `docker`.

## Windows

Install [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/), [Go](https://go.dev/dl/) and [Git for Windows](https://git-scm.com/downloads/win).

- **Open Docker Desktop** and wait until it says it's running.
- **Use Git Bash as your terminal** (it comes with Git for Windows). Every command in these guides works there as written.

PowerShell and cmd won't run `./connect.sh`, and the `curl` examples break there. If you stick with PowerShell, open psql with `docker exec -it dbz-sql psql -U goku -d dragonball`, and use [Postman](https://www.postman.com/) instead of `curl`.

## Check your install

```bash
docker compose version     # v2.x or newer
go version                 # go1.22 or newer
docker run --rm hello-world   # prints "Hello from Docker!" (no sudo)
```

All three working? Continue. If not, see [Troubleshooting](troubleshooting.md).

## Get the code and start the database

```bash
git clone https://github.com/rmpato/sql-z.git
cd sql-z
docker compose up -d --wait
```

`--wait` returns once Postgres is ready. The first start also creates the tables and loads the data.

## Optional: a GUI client

[Beekeeper Studio](https://www.beekeeperstudio.io/) is a free desktop app for browsing tables and running queries. Results show up in a grid, and you can keep queries in tabs. It's a friendly alternative to the `psql` terminal.

- Ubuntu: `sudo snap install beekeeper-studio`
- macOS / Windows: download from the website

Create a **PostgreSQL** connection with these details (they work in DBeaver, TablePlus, and other clients too):

| Host | Port | Database | User | Password |
|------|------|----------|------|----------|
| localhost | 5432 | dragonball | goku | kamehameha |

---

**Next:** [1. SQL by hand →](01-sql.md)
