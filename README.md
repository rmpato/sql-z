# Dragon Ball SQL workshop

A small PostgreSQL playground for learning essential SQL, then seeing how real code uses it. No prior database experience needed.

The workshop has three steps, and each one builds on the last:

1. **SQL by hand (`psql` or Beekeeper).** Learn to read, filter, sort, summarize, join, and change data by typing queries straight into the database.
2. **The same SQL from code (`go-demo/`).** A Go program runs queries from step 1. Compare typing a query yourself with a program sending it.
3. **SQL behind an API (`go-api/`).** A web API where each request (GET, POST, PUT, DELETE) turns into a query. Follow a value from the HTTP request into the SQL and into the table.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with Docker Compose (Docker Desktop includes both)
- [Go](https://go.dev/dl/) 1.22 or newer (only needed for steps 2 and 3)

## Get the code

```bash
git clone https://github.com/rmpato/sql-z.git
cd sql-z
```

## Start the database

```bash
docker compose up -d --wait
```

`--wait` returns once Postgres is ready. On first start it also creates the tables and loads the seed data from `sql/`.

### Prefer a GUI? Try Beekeeper Studio

[Beekeeper Studio](https://www.beekeeperstudio.io/) is a free, friendly desktop app for browsing tables and running queries. It's a nice alternative to `psql` if you'd rather click around, see results in a grid, and keep a few queries in tabs. Create a new **PostgreSQL** connection with these details (they work in any other client too, such as DBeaver or TablePlus):

| Setting  | Value       |
|----------|-------------|
| Host     | localhost   |
| Port     | 5432        |
| Database | dragonball  |
| User     | goku        |
| Password | kamehameha  |

## Tables

```
planets ──┐
          ├── characters ── techniques
races   ──┘
```

- **planets**: Earth, Namek, …
- **races**: Saiyan, Human, …
- **characters**: fighters, each linked to a planet and a race
- **techniques**: moves, each linked to a character

The schema is in `sql/01_schema.sql` and the seed data is in `sql/02_seed.sql`.

## Step 1: SQL in psql

Open a `psql` shell. This also starts the database if it isn't running:

```bash
./connect.sh
```

(Or run it directly: `docker exec -it dbz-sql psql -U goku -d dragonball`.)

Look around:

```sql
-- list tables
\dt

-- describe a table
\d characters

-- peek at data
SELECT * FROM planets;
SELECT * FROM characters;
```

Then work through **`sql/03_examples.sql`** from top to bottom, one query at a time. Each query has a comment explaining what it does and what to expect. It's split into parts:

| Part | Topic | You'll learn |
|------|-------|--------------|
| 1 | Reading | `SELECT`, choosing columns, `AS`, `DISTINCT` |
| 2 | Filtering | `WHERE`, `AND`/`OR`, `IN`, `BETWEEN`, `LIKE`, `IS NULL` |
| 3 | Sorting | `ORDER BY`, `LIMIT` |
| 4 | Summarizing | `COUNT`/`SUM`/`AVG`/`MIN`/`MAX`, `GROUP BY`, `HAVING` |
| 5 | Combining tables | `JOIN`, `LEFT JOIN`, finding rows with no match |
| 6 | Subqueries | a query inside a query |
| 7 | Changing data | `INSERT`, `UPDATE`, `DELETE`, and how foreign keys protect you |
| 8 | Transactions | `BEGIN`, `COMMIT`, `ROLLBACK` |

It ends with practice exercises, with answers at the bottom. Some queries fail **on purpose** to show common mistakes, and the comment says so. Part 7 changes data; [reset](#stop--reset) any time to start fresh.

> **Tip:** the examples are also nice in [Beekeeper Studio](#prefer-a-gui-try-beekeeper-studio). Paste the whole file into a query tab, put the cursor on one query, and run just that one.

Handy `psql` shortcuts:

| Command    | What it does        |
|------------|---------------------|
| `\dt`      | list tables         |
| `\d t`     | describe table `t`  |
| `\q`       | quit                |
| `\i /path` | run a SQL file      |

## Step 2: Go demo

With the database running:

```bash
cd go-demo
go run .
```

It connects, inserts **Trunks**, and prints every character with their planet, strongest first.

Now open `go-demo/main.go` next to `sql/03_examples.sql`. The program runs two queries you already know:

| In code | Same as step 1 | What's different in code |
|---------|----------------|--------------------------|
| `insertTrunks` | 7.1 `INSERT … RETURNING` | Values go in as `$1, $2, …` placeholders instead of being typed into the query. That's what prevents SQL injection. |
| `listCharacters` | 5.1 `JOIN` | You don't get a printed table. You loop over rows and `Scan` each column into a Go variable. |

Each run inserts another Trunks. Check in psql with `SELECT * FROM characters WHERE name = 'Trunks';`.

## Step 3: Go API

```bash
cd go-api
go run .
```

The server listens on http://localhost:8080. Each endpoint takes input from a different part of the request and puts it into a query:

| Request | Input comes from | SQL it runs |
|---------|------------------|-------------|
| `GET /characters?min_power=3000` | query string | `SELECT … WHERE power_level >= $1` |
| `GET /characters/{id}` | URL path | `SELECT … WHERE id = $1` |
| `POST /characters` | JSON body | `INSERT … VALUES ($1, $2, $3, $4)` |
| `PUT /characters/{id}` | URL path + JSON body | `UPDATE … SET … WHERE id = $5` |
| `DELETE /characters/{id}` | URL path | `DELETE … WHERE id = $1` (in a transaction) |

Keep three windows side by side: the **server terminal**, a **second terminal** for `curl`, and **psql or Beekeeper**. For each call below:

1. Run the `curl`.
2. Watch the server terminal. It logs the request, the exact SQL, and the values that went into `$1, $2, …`.
3. Run a `SELECT` in psql or Beekeeper to check what actually changed in the table.

```bash
# GET: list everyone, or filter with a query-string value
curl localhost:8080/characters
curl "localhost:8080/characters?min_power=3000"

# GET: one character, id taken from the URL
curl localhost:8080/characters/1

# POST: create. The JSON body becomes the INSERT values. Note the returned id.
curl -X POST localhost:8080/characters \
  -d '{"name":"Bulma","power_level":12,"planet_id":1,"race_id":2}'

# PUT: update. id from the URL, new values from the body (send every field)
curl -X PUT localhost:8080/characters/4 \
  -d '{"name":"Krillin","power_level":1770,"planet_id":1,"race_id":2}'

# DELETE: remove one by id (their techniques are removed too, in one transaction)
curl -i -X DELETE localhost:8080/characters/4
```

Things to try:
- `curl localhost:8080/characters/999` returns `404 not found`. The query ran but matched no rows.
- POST with `"planet_id": 99` returns `400`. The database refuses because of the foreign key (see 7.6 in step 1), and the API turns that into a clear error.
- Compare `DELETE` with example 8.2 in step 1. It's the same transaction, written in Go.

Stop the server with `Ctrl+C`.

Both Go programs connect to `postgres://goku:kamehameha@localhost:5432/dragonball` by default. Set `DATABASE_URL` to point them somewhere else.

## Stop / reset

```bash
# stop (data is kept)
docker compose down

# wipe data and start fresh (re-runs the SQL init scripts)
docker compose down -v && docker compose up -d --wait
```

## Troubleshooting

- **`port is already allocated` / `address already in use` on 5432.** Another Postgres is running. Stop it, or change the port mapping in `docker-compose.yml` to `"5433:5432"` (also use 5433 in your GUI client and in `DATABASE_URL`).
- **`container name "/dbz-sql" is already in use`.** An old copy of this workshop is still running. Remove it with `docker rm -f dbz-sql`.
- **Go: `can't reach the database`.** Start the database first (`docker compose up -d --wait`).
