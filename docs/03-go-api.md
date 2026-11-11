# 3. SQL behind an API

[← Back to README](../README.md)

**Goal:** follow a value from an HTTP request, into a SQL query, into the table. This is what most backend code does all day.

## Run it

```bash
cd go-api
go run .
```

The API is now listening on `http://localhost:8080`. Leave this terminal open: it prints every request and the SQL it runs.

## How requests become queries

Each endpoint gets its input from a different part of the request:

| Request | Input comes from | SQL it runs |
|---------|------------------|-------------|
| `GET /characters?min_power=3000` | query string | `SELECT … WHERE power_level >= $1` |
| `GET /characters/{id}` | URL path | `SELECT … WHERE id = $1` |
| `POST /characters` | JSON body | `INSERT … VALUES ($1, $2, $3, $4)` |
| `PUT /characters/{id}` | URL path + JSON body | `UPDATE … SET … WHERE id = $5` |
| `DELETE /characters/{id}` | URL path | `DELETE … WHERE id = $1` (in a transaction) |

## Set up three windows

| Window | Use it to |
|--------|-----------|
| 1. API terminal | watch the request, the SQL, and the values in `$1, $2, …` |
| 2. Second terminal | send requests with `curl` |
| 3. psql or Beekeeper | check what actually changed in the table |

For each request below: send it, read the log, then `SELECT` to confirm.

## Try each method

**GET: read**

```bash
curl localhost:8080/characters
curl "localhost:8080/characters?min_power=3000"
curl localhost:8080/characters/1
```

**POST: create.** The JSON body becomes the INSERT values. Note the `id` in the response.

```bash
curl -X POST localhost:8080/characters \
  -d '{"name":"Bulma","power_level":12,"planet_id":1,"race_id":2}'
```

**PUT: update.** The id comes from the URL and the new values from the body. Send every field.

```bash
curl -X PUT localhost:8080/characters/4 \
  -d '{"name":"Krillin","power_level":1770,"planet_id":1,"race_id":2}'
```

**DELETE: remove.** Deletes the character's techniques too, in one transaction.

```bash
curl -i -X DELETE localhost:8080/characters/4
```

The server log for the POST looks like this:

```
→ POST /characters
  SQL: INSERT INTO characters (name, power_level, planet_id, race_id) VALUES ($1, $2, $3, $4) RETURNING id
       $1=Bulma $2=12 $3=1 $4=2
```

## Try breaking it

| Try | You get | Why |
|-----|---------|-----|
| `curl localhost:8080/characters/999` | `404 not found` | the query ran but matched no rows |
| POST with `"planet_id": 99` | `400` | the foreign key rejects it (lesson 7.6) |
| `curl localhost:8080/characters/abc` | `400` | the API checks input before running any SQL |

Also compare the DELETE code in [`go-api/main.go`](../go-api/main.go) with lesson **8.2**. It's the same transaction, written in Go.

Stop the server with `Ctrl+C`.

> Both Go programs connect to `localhost:5432` by default. Set the `DATABASE_URL` environment variable to use a different database.

---

**Next:** [4. Next steps →](04-next-steps.md)
