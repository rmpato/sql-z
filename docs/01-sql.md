# 1. SQL by hand

[← Back to README](../README.md)

**Goal:** talk to the database directly and learn the essential SQL a junior developer is expected to know.

## Open psql

```bash
./connect.sh
```

This starts the database if needed and drops you into `psql`, Postgres's command-line client. You'll see a prompt like `dragonball=#`.

> Or use [Beekeeper Studio](00-setup.md#optional-a-gui-client). Everything in this step works the same there.

## Look around

```sql
\dt                       -- list tables
\d characters             -- show a table's columns
SELECT * FROM planets;    -- see the data
```

Commands starting with `\` are psql shortcuts, not SQL. End every SQL query with `;`.

| psql command | What it does |
|--------------|--------------|
| `\dt` | list tables |
| `\d name` | describe a table |
| `\q` | quit |

## The lesson

Open [`sql/03_examples.sql`](../sql/03_examples.sql) in an editor next to psql. Work through it **top to bottom, one query at a time**:

1. Read the comment above the query. It says what to expect.
2. Copy and paste the query and run it.
3. Change something (a number, a column, a name) and run it again.

| Part | Topic | You'll learn |
|------|-------|--------------|
| 1 | Reading | `SELECT`, columns, `AS`, `DISTINCT` |
| 2 | Filtering | `WHERE`, `AND`/`OR`, `IN`, `BETWEEN`, `LIKE`, `IS NULL` |
| 3 | Sorting | `ORDER BY`, `LIMIT` |
| 4 | Summarizing | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING` |
| 5 | Joining tables | `JOIN`, `LEFT JOIN` |
| 6 | Subqueries | a query inside a query |
| 7 | Changing data | `INSERT`, `UPDATE`, `DELETE`, foreign keys |
| 8 | Transactions | `BEGIN`, `COMMIT`, `ROLLBACK` |

The file ends with **practice exercises**, with answers at the bottom. Try them before peeking.

> **Keep the cheatsheet open.** [`docs/cheatsheet.html`](cheatsheet.html) has every topic above as short recipes with expected results. Open it in your browser: `xdg-open docs/cheatsheet.html` (Linux), `open docs/cheatsheet.html` (macOS) or `start docs/cheatsheet.html` (Windows).

## Good to know

- **Some queries fail on purpose** to show common mistakes. The comment above them says so.
- **Part 7 changes data for real.** To start over: `docker compose down -v && docker compose up -d --wait`.
- **In Beekeeper**, paste the whole file into one tab, put your cursor on a query, and run just that one.

---

**Next:** [2. SQL from code →](02-go-demo.md)
