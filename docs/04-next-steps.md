# 4. Next steps

[← Back to README](../README.md)

You've used SQL by hand, from code, and behind an API. Now make it stick by changing the code yourself, then go beyond what this workshop covers.

## Challenges: change the code

Roughly easiest first. Each one is a good thing to talk about in an interview. Restart the API after each change (`Ctrl+C`, then `go run .`).

### 1. Show the planet name

`GET /characters/{id}` returns `"planet_id": 1`. Make it also return `"planet": "Earth"`.

*Hint:* the JOIN from lesson 5.1, a new `Planet string` field on the struct, and one more argument to `Scan`.

### 2. Add `GET /planets`

List every planet with its number of characters.

*Hint:* write the SQL in psql first: a LEFT JOIN plus GROUP BY (compare with practice exercise P2). "Other World" should show up with 0. Then copy `listCharacters` and adapt it.

### 3. Search by name

Make `GET /characters?name=go` return characters whose name contains "go", ignoring case.

*Hint:* `ILIKE` from lesson 2.6. Put the `%` wildcards in the **value** (`"%" + name + "%"`), never in the SQL text.

### 4. Techniques endpoints

Add `GET /characters/{id}/techniques` and `POST /characters/{id}/techniques`.

*Hint:* the id comes from the path and the technique name from the body. What should happen if the character doesn't exist? (Lesson 7.6 has a clue.)

### 5. Add `PATCH /characters/{id}` (harder)

PUT replaces every field. PATCH changes only what you send, so `{"power_level": 9999}` alone should work.

*Hint:* use pointer fields (like `RaceID *int`) to tell "not sent" (`nil`) apart from "sent as 0". Then either SELECT the current row and merge in the new values, or build the `SET` part from only the fields that were sent.

## Learn next

These topics come up a lot in junior interviews. Try each one on this database.

| Topic | In one line | Try this |
|-------|-------------|----------|
| **Indexes** | Let the database find rows without scanning the whole table: faster reads, slightly slower writes | `CREATE INDEX ON characters (name);` then `EXPLAIN SELECT * FROM characters WHERE name = 'Goku';` |
| **Constraints** | Rules the database enforces for you | Add `CHECK (power_level >= 0)`. Look up `ON DELETE CASCADE`: why might you *not* want it? |
| **Normalization** | Store each fact once | Why is `planets` its own table instead of a `planet_name` column? Think typos and renames |
| **More JOINs** | `RIGHT`, `FULL OUTER`, and self joins | Draw the Venn diagram for each, a classic interview question |
| **Window functions** | Calculations across rows without collapsing them | `RANK() OVER (PARTITION BY planet_id ORDER BY power_level DESC)` |
| **Design a table** | Write your own `CREATE TABLE` | Add a `battles` table (who fought whom, who won), insert rows, and query it |
