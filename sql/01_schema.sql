-- ============================================================
-- Dragon Ball SQL workshop — schema (CREATE TABLE)
-- ============================================================

CREATE TABLE planets (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  gravity     NUMERIC(4, 2)  -- Earth = 1.00
);

CREATE TABLE races (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE
);

CREATE TABLE characters (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  power_level INTEGER,
  planet_id   INTEGER REFERENCES planets(id),
  race_id     INTEGER REFERENCES races(id)
);

CREATE TABLE techniques (
  id            SERIAL PRIMARY KEY,
  name          TEXT NOT NULL,
  character_id  INTEGER REFERENCES characters(id)
);
