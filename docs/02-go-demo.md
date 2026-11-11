# 2. SQL from code

[← Back to README](../README.md)

**Goal:** see the SQL you typed in step 1 running inside a program, and what changes when it does.

## Run it

With the database running:

```bash
cd go-demo
go run .
```

You'll see:

```
connected to dragonball ✓

inserted Trunks with id=9

NAME            POWER  PLANET
--------------------------------
Goku             9001  Earth
Vegeta           8500  Vegeta
...
```

## Compare with step 1

Open [`go-demo/main.go`](../go-demo/main.go) next to [`sql/03_examples.sql`](../sql/03_examples.sql). The program runs two queries you already know:

| Function | Same query as | What's different in code |
|----------|---------------|--------------------------|
| `insertTrunks` | 7.1 (`INSERT … RETURNING`) | Values are passed as `$1, $2, …` placeholders, not typed into the query |
| `listCharacters` | 5.1 (`JOIN`) | No printed table: you loop over rows and `Scan` each column into a variable |

## The three ideas to take away

1. **Connecting.** Code connects with a URL: `postgres://user:password@host:port/database`.
2. **Placeholders.** Never glue values into SQL text (`"... VALUES ('" + name + "')"`). Pass them separately as `$1, $2`. This is what prevents **SQL injection**, one of the most common security bugs.
3. **Reading rows.** `rows.Next()` moves to the next row, and `rows.Scan(...)` copies its columns into variables, in the same order as the `SELECT`.

## Check it in the database

Each run inserts another Trunks. Check in psql:

```sql
SELECT * FROM characters WHERE name = 'Trunks';
```

The program and psql share the same database. That's the point.

---

**Next:** [3. SQL behind an API →](03-go-api.md)
