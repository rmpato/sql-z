# 4. Próximos pasos

[← Volver al README](../../README.es.md) · [English](../04-next-steps.md)

Ya usaste SQL a mano, desde código y detrás de una API. Ahora fijalo cambiando el código vos mismo, y después andá más allá de lo que cubre este taller.

## Desafíos: cambiá el código

Más o menos del más fácil al más difícil. Cada uno es un buen tema para charlar en una entrevista. Reiniciá la API después de cada cambio (`Ctrl+C` y después `go run .`).

### 1. Mostrá el nombre del planeta

`GET /characters/{id}` devuelve `"planet_id": 1`. Hacé que también devuelva `"planet": "Earth"`.

*Pista:* el JOIN de la lección 5.1, un campo nuevo `Planet string` en el struct y un argumento más en `Scan`.

### 2. Agregá `GET /planets`

Listá todos los planetas con su cantidad de personajes.

*Pista:* escribí primero el SQL en psql: un LEFT JOIN más GROUP BY (comparalo con el ejercicio P2). "Other World" tiene que aparecer con 0. Después copiá `listCharacters` y adaptalo.

### 3. Buscá por nombre

Hacé que `GET /characters?name=go` devuelva los personajes cuyo nombre contiene "go", sin importar mayúsculas.

*Pista:* `ILIKE` de la lección 2.6. Los comodines `%` van en el **valor** (`"%" + name + "%"`), nunca en el texto del SQL.

### 4. Endpoints de técnicas

Agregá `GET /characters/{id}/techniques` y `POST /characters/{id}/techniques`.

*Pista:* el id viene de la ruta y el nombre de la técnica del cuerpo. ¿Qué tendría que pasar si el personaje no existe? (La lección 7.6 tiene una pista.)

### 5. Agregá `PATCH /characters/{id}` (más difícil)

PUT reemplaza todos los campos. PATCH cambia solo lo que mandás, así que `{"power_level": 9999}` solo tendría que funcionar.

*Pista:* usá campos puntero (como `RaceID *int`) para diferenciar "no lo mandaron" (`nil`) de "lo mandaron en 0". Después, o hacés un SELECT de la fila actual y le mezclás los valores nuevos, o armás la parte del `SET` solo con los campos que llegaron.

## Para aprender después

Estos temas aparecen mucho en entrevistas para puestos junior. Probá cada uno con esta base de datos.

| Tema | En una línea | Probá esto |
|------|--------------|------------|
| **Índices** | Permiten encontrar filas sin recorrer toda la tabla: lecturas más rápidas, escrituras un poco más lentas | `CREATE INDEX ON characters (name);` y después `EXPLAIN SELECT * FROM characters WHERE name = 'Goku';` |
| **Restricciones** | Reglas que la base de datos hace cumplir por vos | Agregá `CHECK (power_level >= 0)`. Buscá qué es `ON DELETE CASCADE`: ¿por qué *no* lo querrías? |
| **Normalización** | Guardar cada dato una sola vez | ¿Por qué `planets` es su propia tabla y no una columna `planet_name`? Pensá en errores de tipeo y en renombrar |
| **Más JOINs** | `RIGHT`, `FULL OUTER` y self joins (una tabla unida consigo misma) | Dibujá el diagrama de Venn de cada uno, una pregunta clásica de entrevista |
| **Funciones de ventana** | Cálculos entre filas sin juntarlas en una | `RANK() OVER (PARTITION BY planet_id ORDER BY power_level DESC)` |
| **Diseñá una tabla** | Escribí tu propio `CREATE TABLE` | Agregá una tabla `battles` (quién peleó con quién, quién ganó), cargale filas y consultala |
