-- ============================================================
-- Dragon Ball SQL workshop: the essentials, step by step
--
-- How to use this file:
--   * Open psql (./connect.sh) or a Beekeeper Studio query tab.
--   * Copy ONE query at a time, run it, look at the result.
--   * Read the comment above each query first: it says what to expect.
--   * Change things! Swap a number, a name, a column. Break it on purpose.
--
-- A few words you'll see everywhere:
--   table        = a spreadsheet-like grid (characters, planets, …)
--   row          = one record in a table (one character)
--   column       = one field every row has (name, power_level, …)
--   primary key  = a column that uniquely identifies each row (id)
--   foreign key  = a column that points at another table's primary key
--                  (characters.planet_id → planets.id)
--   NULL         = "no value / unknown". Not zero, not empty text.
--
-- SQL keywords are not case-sensitive (select = SELECT), but writing
-- them in CAPS makes queries easier to read. End each query with ;
-- Lines starting with -- are comments and are ignored.
-- ============================================================


-- ============================================================
-- PART 1: Reading data (SELECT)
-- ============================================================

-- 1.1) Everything from a table.
--      SELECT <columns> FROM <table>;   * means "all columns"
SELECT * FROM characters;

-- 1.2) Only the columns you care about.
--      In real code, prefer naming columns over * so you get
--      exactly what you need.
SELECT name, power_level FROM characters;

-- 1.3) Rename a column in the result with AS (an "alias").
--      Only changes the label in the output, not the table.
SELECT name AS fighter, power_level AS power FROM characters;

-- 1.4) Unique values only: DISTINCT removes duplicate rows.
--      Which planets do our characters come from? (each id once)
SELECT DISTINCT planet_id FROM characters;


-- ============================================================
-- PART 2: Filtering rows (WHERE)
-- WHERE keeps only the rows where the condition is true.
-- ============================================================

-- 2.1) Comparison: =  <>  >  <  >=  <=   (<> means "not equal")
SELECT name, power_level
FROM characters
WHERE power_level > 3000;

-- 2.2) Text values go in 'single quotes'.
SELECT * FROM characters WHERE name = 'Goku';

-- 2.3) Combine conditions with AND / OR.
--      Strong AND from Earth (planet_id 1):
SELECT name, power_level, planet_id
FROM characters
WHERE power_level > 1000 AND planet_id = 1;

-- 2.4) IN: shorthand for many ORs.
--      Same as: race_id = 2 OR race_id = 4
SELECT name, race_id
FROM characters
WHERE race_id IN (2, 4);

-- 2.5) BETWEEN: a range, both ends included.
SELECT name, power_level
FROM characters
WHERE power_level BETWEEN 1000 AND 5000;

-- 2.6) LIKE: pattern matching on text.
--      %  = any number of characters,  _ = exactly one character
--      Names starting with 'G':
SELECT name FROM characters WHERE name LIKE 'G%';
--      Tip: ILIKE (Postgres-only) ignores upper/lower case:
SELECT name FROM characters WHERE name ILIKE '%an%';

-- 2.7) NULL is special: you can NOT use = NULL.
--      Frieza has no race. This returns NOTHING (a classic mistake):
SELECT name FROM characters WHERE race_id = NULL;
--      The right way is IS NULL / IS NOT NULL:
SELECT name FROM characters WHERE race_id IS NULL;


-- ============================================================
-- PART 3: Sorting and limiting
-- ============================================================

-- 3.1) ORDER BY sorts the result. ASC (default) = smallest first,
--      DESC = biggest first.
SELECT name, power_level
FROM characters
ORDER BY power_level DESC;

-- 3.2) LIMIT keeps only the first N rows. Combined with ORDER BY,
--      it answers "top N" questions. Top 3 strongest:
SELECT name, power_level
FROM characters
ORDER BY power_level DESC
LIMIT 3;


-- ============================================================
-- PART 4: Summarizing (aggregate functions + GROUP BY)
-- Aggregates squash many rows into one value.
-- ============================================================

-- 4.1) COUNT, SUM, AVG, MIN, MAX over the whole table.
SELECT
  COUNT(*)                 AS total_fighters,
  MAX(power_level)         AS strongest,
  MIN(power_level)         AS weakest,
  ROUND(AVG(power_level))  AS average_power
FROM characters;

-- 4.2) GROUP BY: one summary row PER group.
--      How many characters per planet_id?
--      Rule: every column in SELECT must either be in GROUP BY
--      or be inside an aggregate like COUNT().
SELECT planet_id, COUNT(*) AS fighters
FROM characters
GROUP BY planet_id
ORDER BY fighters DESC;

-- 4.3) HAVING filters GROUPS (after grouping).
--      WHERE filters ROWS (before grouping).
--      Planets with more than 1 character:
SELECT planet_id, COUNT(*) AS fighters
FROM characters
GROUP BY planet_id
HAVING COUNT(*) > 1;

-- 4.4) WHERE and HAVING together:
--      Only count fighters above 1000 power, then keep planets
--      with at least 2 of them.
SELECT planet_id, COUNT(*) AS strong_fighters
FROM characters
WHERE power_level > 1000
GROUP BY planet_id
HAVING COUNT(*) >= 2;


-- ============================================================
-- PART 5: Combining tables (JOIN)
-- characters.planet_id holds a number. JOIN looks up the matching
-- row in planets so we can show the planet NAME instead.
-- ============================================================

-- 5.1) INNER JOIN (just "JOIN"): rows that match on both sides.
--      c and p are short aliases for the table names.
--      ON says how rows match: character's planet_id = planet's id.
SELECT
  c.name AS character,
  c.power_level,
  p.name AS planet
FROM characters c
JOIN planets p ON c.planet_id = p.id
ORDER BY c.power_level DESC;

-- 5.2) The problem with INNER JOIN: Frieza has no race (NULL),
--      so he has no match in races and DISAPPEARS. Count the rows:
SELECT c.name AS character, r.name AS race
FROM characters c
JOIN races r ON c.race_id = r.id;

-- 5.3) LEFT JOIN keeps EVERY row from the left table (characters),
--      even without a match. Missing values come back as NULL.
--      Frieza is back, with race = NULL:
SELECT c.name AS character, r.name AS race
FROM characters c
LEFT JOIN races r ON c.race_id = r.id;

-- 5.4) LEFT JOIN to find things with NO match.
--      Which planets have no characters? ('Other World')
SELECT p.name AS empty_planet
FROM planets p
LEFT JOIN characters c ON c.planet_id = p.id
WHERE c.id IS NULL;

-- 5.5) Joining more than two tables: technique → character → planet.
SELECT
  c.name AS character,
  t.name AS technique,
  p.name AS home_planet
FROM techniques t
JOIN characters c ON t.character_id = c.id
JOIN planets p    ON c.planet_id = p.id
ORDER BY c.name, t.name;

-- 5.6) JOIN + GROUP BY: average power per race NAME
--      (compare with 4.2, which only had ids).
SELECT
  r.name AS race,
  COUNT(c.id) AS fighters,
  ROUND(AVG(c.power_level)) AS avg_power
FROM races r
JOIN characters c ON c.race_id = r.id
GROUP BY r.name
ORDER BY avg_power DESC;


-- ============================================================
-- PART 6: A query inside a query (subquery)
-- ============================================================

-- 6.1) Who is stronger than the average?
--      The inner query runs first and returns one number.
SELECT name, power_level
FROM characters
WHERE power_level > (SELECT AVG(power_level) FROM characters)
ORDER BY power_level DESC;


-- ============================================================
-- PART 7: Changing data (INSERT, UPDATE, DELETE)
-- These modify the table for real. To start over at any time:
--   docker compose down -v && docker compose up -d --wait
-- ============================================================

-- 7.1) INSERT adds a row. List the columns, then the values in the
--      same order. We don't give an id: SERIAL generates it.
--      RETURNING shows the row Postgres just created (Postgres-only).
INSERT INTO characters (name, power_level, planet_id, race_id)
VALUES ('Yamcha', 400, 1, 2)
RETURNING *;

-- 7.2) Insert several rows at once.
INSERT INTO techniques (name, character_id) VALUES
  ('Kaioken',      1),
  ('Big Bang Attack', 2);

-- 7.3) UPDATE changes existing rows.
--      SET says what to change, WHERE says WHICH rows.
UPDATE characters
SET power_level = 1200
WHERE name = 'Yamcha';

SELECT * FROM characters WHERE name = 'Yamcha';

-- 7.4) UPDATE can use the current value.
--      Everyone from Earth trains hard: +10% power.
UPDATE characters
SET power_level = power_level * 1.1
WHERE planet_id = 1;

-- 7.5) DELETE removes rows. Again, WHERE says which ones.
DELETE FROM characters WHERE name = 'Yamcha';

-- ⚠️  UPDATE or DELETE WITHOUT a WHERE hits EVERY row in the table.
--     "DELETE FROM characters;" empties the whole table.
--     Habit: write the WHERE first, or run it as a SELECT first
--     to see which rows would be affected.

-- 7.6) Foreign keys protect you. Goku (id 1) has techniques that
--      point at him, so Postgres REFUSES to delete him. Read the error:
DELETE FROM characters WHERE id = 1;
--      Same with inserting a character on a planet that doesn't exist:
INSERT INTO characters (name, power_level, planet_id) VALUES ('Ghost', 1, 99);


-- ============================================================
-- PART 8: Transactions (all-or-nothing)
-- BEGIN starts a transaction. Changes are only kept on COMMIT.
-- ROLLBACK throws them all away. Great for trying risky things.
-- ============================================================

-- 8.1) Run these lines one by one:
BEGIN;
DELETE FROM techniques;               -- oops, deleted everything
SELECT COUNT(*) FROM techniques;      -- 0 … inside the transaction
ROLLBACK;                             -- undo!
SELECT COUNT(*) FROM techniques;      -- all back

-- 8.2) The real use: steps that must succeed together.
--      To delete Goku we must delete his techniques first (see 7.6).
--      If the second step failed, we wouldn't want the first one kept.
--      (Run with ROLLBACK so Goku survives. Swap for COMMIT to keep it.)
BEGIN;
DELETE FROM techniques WHERE character_id = 1;
DELETE FROM characters WHERE id = 1;
ROLLBACK;


-- ============================================================
-- PRACTICE: try these on your own (answers at the bottom)
-- ============================================================
-- P1) Names of all Saiyans (race_id 1), weakest first.
-- P2) How many techniques does each character have? Show the
--     character's NAME. Include characters with zero techniques.
-- P3) The strongest character on each planet (planet name + max power).
-- P4) Add Bulma (Human, Earth, power 12), then change her power to 15,
--     then delete her.
-- P5) Which race has the highest total power?




-- ============================================================
-- ANSWERS (one possible way each; there are often several)
-- ============================================================

-- P1
SELECT name FROM characters WHERE race_id = 1 ORDER BY power_level ASC;

-- P2
SELECT c.name, COUNT(t.id) AS techniques
FROM characters c
LEFT JOIN techniques t ON t.character_id = c.id
GROUP BY c.name
ORDER BY techniques DESC;

-- P3
SELECT p.name AS planet, MAX(c.power_level) AS max_power
FROM planets p
JOIN characters c ON c.planet_id = p.id
GROUP BY p.name;

-- P4
INSERT INTO characters (name, power_level, planet_id, race_id) VALUES ('Bulma', 12, 1, 2);
UPDATE characters SET power_level = 15 WHERE name = 'Bulma';
DELETE FROM characters WHERE name = 'Bulma';

-- P5
SELECT r.name, SUM(c.power_level) AS total_power
FROM races r
JOIN characters c ON c.race_id = r.id
GROUP BY r.name
ORDER BY total_power DESC
LIMIT 1;
