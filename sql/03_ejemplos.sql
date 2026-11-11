-- ============================================================
-- Taller de SQL con Dragon Ball: lo esencial, paso a paso
--
-- Cómo usar este archivo:
--   * Abrí psql (./connect.sh) o una pestaña de consultas en Beekeeper Studio.
--   * Copiá UNA consulta por vez, ejecutala y mirá el resultado.
--   * Leé primero el comentario de arriba de cada consulta: te dice qué esperar.
--   * ¡Cambiá cosas! Un número, un nombre, una columna. Rompelo a propósito.
--
-- Algunas palabras que vas a ver todo el tiempo:
--   tabla          = una grilla tipo planilla (characters, planets, …)
--   fila           = un registro de la tabla (un personaje)
--   columna        = un dato que tiene cada fila (name, power_level, …)
--   clave primaria = una columna que identifica cada fila sin repetirse (id)
--   clave foránea  = una columna que apunta a la clave primaria de otra tabla
--                    (characters.planet_id → planets.id)
--   NULL           = "sin valor / desconocido". No es cero ni texto vacío.
--
-- A SQL no le importan mayúsculas o minúsculas en las palabras clave
-- (select = SELECT), pero escribirlas en MAYÚSCULAS hace más fácil leer
-- las consultas. Terminá cada consulta con ;
-- Las líneas que empiezan con -- son comentarios y se ignoran.
--
-- Las tablas y columnas tienen nombres en inglés (characters = personajes,
-- planets = planetas, races = razas, techniques = técnicas,
-- power_level = nivel de poder). Así es como se ven en proyectos reales.
-- ============================================================


-- ============================================================
-- PARTE 1: Leer datos (SELECT)
-- ============================================================

-- 1.1) Todo lo que hay en una tabla.
--      SELECT <columnas> FROM <tabla>;   * significa "todas las columnas"
SELECT * FROM characters;

-- 1.2) Solo las columnas que te interesan.
--      En código real, mejor nombrar las columnas en vez de usar *,
--      así traés exactamente lo que necesitás.
SELECT name, power_level FROM characters;

-- 1.3) Renombrar una columna en el resultado con AS (un "alias").
--      Solo cambia la etiqueta en la salida, no la tabla.
SELECT name AS luchador, power_level AS poder FROM characters;

-- 1.4) Valores únicos: DISTINCT saca las filas repetidas.
--      ¿De qué planetas vienen los personajes? (cada id una sola vez)
SELECT DISTINCT planet_id FROM characters;


-- ============================================================
-- PARTE 2: Filtrar filas (WHERE)
-- WHERE se queda solo con las filas donde la condición es verdadera.
-- ============================================================

-- 2.1) Comparaciones: =  <>  >  <  >=  <=   (<> significa "distinto")
SELECT name, power_level
FROM characters
WHERE power_level > 3000;

-- 2.2) Los textos van entre 'comillas simples'.
SELECT * FROM characters WHERE name = 'Goku';

-- 2.3) Combinar condiciones con AND / OR.
--      Fuertes Y de la Tierra (planet_id 1):
SELECT name, power_level, planet_id
FROM characters
WHERE power_level > 1000 AND planet_id = 1;

-- 2.4) IN: atajo para muchos OR.
--      Es lo mismo que: race_id = 2 OR race_id = 4
SELECT name, race_id
FROM characters
WHERE race_id IN (2, 4);

-- 2.5) BETWEEN: un rango, incluye los dos extremos.
SELECT name, power_level
FROM characters
WHERE power_level BETWEEN 1000 AND 5000;

-- 2.6) LIKE: buscar patrones en texto.
--      %  = cualquier cantidad de caracteres,  _ = exactamente uno
--      Nombres que empiezan con 'G':
SELECT name FROM characters WHERE name LIKE 'G%';
--      Tip: ILIKE (solo en Postgres) ignora mayúsculas y minúsculas:
SELECT name FROM characters WHERE name ILIKE '%an%';

-- 2.7) NULL es especial: NO podés usar = NULL.
--      Freezer (Frieza) no tiene raza. Esto no devuelve NADA (error clásico):
SELECT name FROM characters WHERE race_id = NULL;
--      La forma correcta es IS NULL / IS NOT NULL:
SELECT name FROM characters WHERE race_id IS NULL;


-- ============================================================
-- PARTE 3: Ordenar y limitar
-- ============================================================

-- 3.1) ORDER BY ordena el resultado. ASC (por defecto) = de menor a mayor,
--      DESC = de mayor a menor.
SELECT name, power_level
FROM characters
ORDER BY power_level DESC;

-- 3.2) LIMIT se queda solo con las primeras N filas. Junto con ORDER BY,
--      responde preguntas tipo "los N mejores". Los 3 más fuertes:
SELECT name, power_level
FROM characters
ORDER BY power_level DESC
LIMIT 3;


-- ============================================================
-- PARTE 4: Resumir (funciones de agregación + GROUP BY)
-- Las funciones de agregación juntan muchas filas en un solo valor.
-- ============================================================

-- 4.1) COUNT, SUM, AVG, MIN, MAX sobre toda la tabla.
SELECT
  COUNT(*)                 AS total_luchadores,
  MAX(power_level)         AS el_mas_fuerte,
  MIN(power_level)         AS el_mas_debil,
  ROUND(AVG(power_level))  AS poder_promedio
FROM characters;

-- 4.2) GROUP BY: una fila de resumen POR grupo.
--      ¿Cuántos personajes hay por planet_id?
--      Regla: cada columna del SELECT tiene que estar en el GROUP BY
--      o dentro de una función de agregación como COUNT().
SELECT planet_id, COUNT(*) AS luchadores
FROM characters
GROUP BY planet_id
ORDER BY luchadores DESC;

-- 4.3) HAVING filtra GRUPOS (después de agrupar).
--      WHERE filtra FILAS (antes de agrupar).
--      Planetas con más de 1 personaje:
SELECT planet_id, COUNT(*) AS luchadores
FROM characters
GROUP BY planet_id
HAVING COUNT(*) > 1;

-- 4.4) WHERE y HAVING juntos:
--      Contar solo a los que tienen más de 1000 de poder, y quedarse
--      con los planetas que tienen al menos 2 de esos.
SELECT planet_id, COUNT(*) AS luchadores_fuertes
FROM characters
WHERE power_level > 1000
GROUP BY planet_id
HAVING COUNT(*) >= 2;


-- ============================================================
-- PARTE 5: Combinar tablas (JOIN)
-- characters.planet_id guarda un número. JOIN busca la fila que
-- coincide en planets para poder mostrar el NOMBRE del planeta.
-- ============================================================

-- 5.1) INNER JOIN (o simplemente "JOIN"): filas que coinciden en los dos lados.
--      c y p son alias cortos para los nombres de las tablas.
--      ON dice cómo coinciden las filas: el planet_id del personaje = el id del planeta.
SELECT
  c.name AS personaje,
  c.power_level,
  p.name AS planeta
FROM characters c
JOIN planets p ON c.planet_id = p.id
ORDER BY c.power_level DESC;

-- 5.2) El problema del INNER JOIN: Freezer no tiene raza (NULL),
--      así que no tiene pareja en races y DESAPARECE. Contá las filas:
SELECT c.name AS personaje, r.name AS raza
FROM characters c
JOIN races r ON c.race_id = r.id;

-- 5.3) LEFT JOIN se queda con TODAS las filas de la tabla de la izquierda
--      (characters), aunque no tengan pareja. Lo que falta viene como NULL.
--      Freezer vuelve, con raza = NULL:
SELECT c.name AS personaje, r.name AS raza
FROM characters c
LEFT JOIN races r ON c.race_id = r.id;

-- 5.4) LEFT JOIN para encontrar cosas SIN pareja.
--      ¿Qué planetas no tienen personajes? ('Other World', el Otro Mundo)
SELECT p.name AS planeta_vacio
FROM planets p
LEFT JOIN characters c ON c.planet_id = p.id
WHERE c.id IS NULL;

-- 5.5) Unir más de dos tablas: técnica → personaje → planeta.
SELECT
  c.name AS personaje,
  t.name AS tecnica,
  p.name AS planeta_natal
FROM techniques t
JOIN characters c ON t.character_id = c.id
JOIN planets p    ON c.planet_id = p.id
ORDER BY c.name, t.name;

-- 5.6) JOIN + GROUP BY: poder promedio por NOMBRE de raza
--      (comparalo con 4.2, que solo tenía ids).
SELECT
  r.name AS raza,
  COUNT(c.id) AS luchadores,
  ROUND(AVG(c.power_level)) AS poder_promedio
FROM races r
JOIN characters c ON c.race_id = r.id
GROUP BY r.name
ORDER BY poder_promedio DESC;


-- ============================================================
-- PARTE 6: Una consulta adentro de otra (subconsulta)
-- ============================================================

-- 6.1) ¿Quién es más fuerte que el promedio?
--      La consulta de adentro se ejecuta primero y devuelve un número.
SELECT name, power_level
FROM characters
WHERE power_level > (SELECT AVG(power_level) FROM characters)
ORDER BY power_level DESC;


-- ============================================================
-- PARTE 7: Cambiar datos (INSERT, UPDATE, DELETE)
-- Estas consultas modifican la tabla de verdad. Para empezar de cero:
--   docker compose down -v && docker compose up -d --wait
-- ============================================================

-- 7.1) INSERT agrega una fila. Listá las columnas y después los valores
--      en el mismo orden. No ponemos el id: SERIAL lo genera solo.
--      RETURNING muestra la fila que Postgres acaba de crear (solo Postgres).
INSERT INTO characters (name, power_level, planet_id, race_id)
VALUES ('Yamcha', 400, 1, 2)
RETURNING *;

-- 7.2) Insertar varias filas de una.
INSERT INTO techniques (name, character_id) VALUES
  ('Kaioken',      1),
  ('Big Bang Attack', 2);

-- 7.3) UPDATE cambia filas que ya existen.
--      SET dice qué cambiar, WHERE dice CUÁLES filas.
UPDATE characters
SET power_level = 1200
WHERE name = 'Yamcha';

SELECT * FROM characters WHERE name = 'Yamcha';

-- 7.4) UPDATE puede usar el valor actual.
--      Todos los de la Tierra entrenan duro: +10% de poder.
UPDATE characters
SET power_level = power_level * 1.1
WHERE planet_id = 1;

-- 7.5) DELETE borra filas. Otra vez, WHERE dice cuáles.
DELETE FROM characters WHERE name = 'Yamcha';

-- ⚠️  UPDATE o DELETE SIN WHERE afecta TODAS las filas de la tabla.
--     "DELETE FROM characters;" vacía la tabla entera.
--     Costumbre: escribí el WHERE primero, o ejecutalo antes como SELECT
--     para ver qué filas vas a tocar.

-- 7.6) Las claves foráneas te cuidan. Goku (id 1) tiene técnicas que
--      apuntan a él, así que Postgres SE NIEGA a borrarlo. Leé el error:
DELETE FROM characters WHERE id = 1;
--      Lo mismo si insertás un personaje en un planeta que no existe:
INSERT INTO characters (name, power_level, planet_id) VALUES ('Fantasma', 1, 99);


-- ============================================================
-- PARTE 8: Transacciones (todo o nada)
-- BEGIN arranca una transacción. Los cambios solo se guardan con COMMIT.
-- ROLLBACK los descarta todos. Ideal para probar cosas riesgosas.
-- ============================================================

-- 8.1) Ejecutá estas líneas de a una:
BEGIN;
DELETE FROM techniques;               -- uy, borramos todo
SELECT COUNT(*) FROM techniques;      -- 0 … adentro de la transacción
ROLLBACK;                             -- ¡deshacer!
SELECT COUNT(*) FROM techniques;      -- volvió todo

-- 8.2) El uso real: pasos que tienen que salir bien juntos.
--      Para borrar a Goku primero hay que borrar sus técnicas (ver 7.6).
--      Si fallara el segundo paso, no querríamos que quede hecho el primero.
--      (Ejecutalo con ROLLBACK para que Goku sobreviva. Cambialo por COMMIT
--      para que quede.)
BEGIN;
DELETE FROM techniques WHERE character_id = 1;
DELETE FROM characters WHERE id = 1;
ROLLBACK;


-- ============================================================
-- PRÁCTICA: probá estos por tu cuenta (las respuestas están abajo)
-- ============================================================
-- P1) Los nombres de todos los Saiyajin (race_id 1), del más débil al más fuerte.
-- P2) ¿Cuántas técnicas tiene cada personaje? Mostrá el NOMBRE del
--     personaje. Incluí a los que tienen cero técnicas.
-- P3) El personaje más fuerte de cada planeta (nombre del planeta + poder máximo).
-- P4) Agregá a Bulma (Humana, Tierra, poder 12), después cambiale el poder
--     a 15, y después borrala.
-- P5) ¿Qué raza tiene el mayor poder total?




-- ============================================================
-- RESPUESTAS (una forma posible para cada una; suele haber varias)
-- ============================================================

-- P1
SELECT name FROM characters WHERE race_id = 1 ORDER BY power_level ASC;

-- P2
SELECT c.name, COUNT(t.id) AS tecnicas
FROM characters c
LEFT JOIN techniques t ON t.character_id = c.id
GROUP BY c.name
ORDER BY tecnicas DESC;

-- P3
SELECT p.name AS planeta, MAX(c.power_level) AS poder_maximo
FROM planets p
JOIN characters c ON c.planet_id = p.id
GROUP BY p.name;

-- P4
INSERT INTO characters (name, power_level, planet_id, race_id) VALUES ('Bulma', 12, 1, 2);
UPDATE characters SET power_level = 15 WHERE name = 'Bulma';
DELETE FROM characters WHERE name = 'Bulma';

-- P5
SELECT r.name, SUM(c.power_level) AS poder_total
FROM races r
JOIN characters c ON c.race_id = r.id
GROUP BY r.name
ORDER BY poder_total DESC
LIMIT 1;
