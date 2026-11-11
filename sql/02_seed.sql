-- ============================================================
-- Seed data (INSERT)
-- ============================================================

INSERT INTO planets (name, gravity) VALUES
  ('Earth',       1.00),
  ('Namek',       1.00),
  ('Vegeta',     10.00),
  ('Other World', 1.00);

INSERT INTO races (name) VALUES
  ('Saiyan'),
  ('Human'),
  ('Namekian'),
  ('Android');

-- planet_id / race_id match the insert order above (1=Earth, 1=Saiyan, …)
-- Frieza has no race on purpose — useful for showing LEFT JOIN later
INSERT INTO characters (name, power_level, planet_id, race_id) VALUES
  ('Goku',       9001, 1, 1),
  ('Vegeta',     8500, 3, 1),
  ('Gohan',      4200, 1, 1),
  ('Krillin',     750, 1, 2),
  ('Piccolo',    3500, 2, 3),
  ('Tien',        800, 1, 2),
  ('Android 18', 2800, 1, 4),
  ('Frieza',     5300, 2, NULL);

INSERT INTO techniques (name, character_id) VALUES
  ('Kamehameha',           1),
  ('Spirit Bomb',          1),
  ('Instant Transmission', 1),
  ('Galick Gun',           2),
  ('Final Flash',          2),
  ('Masenko',              3),
  ('Destructo Disc',       4),
  ('Special Beam Cannon',  5),
  ('Tri-Beam',             6),
  ('Energy Blast',         7),
  ('Death Beam',           8);
