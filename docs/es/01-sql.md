# 1. SQL a mano

[← Volver al README](../../README.es.md) · [English](../01-sql.md)

**Objetivo:** hablar directamente con la base de datos y aprender el SQL esencial que se espera que sepa alguien junior.

## Abrí psql

```bash
./connect.sh
```

Esto levanta la base de datos si hace falta y te deja adentro de `psql`, el cliente de línea de comandos de Postgres. Vas a ver algo así: `dragonball=#`.

> O usá [Beekeeper Studio](00-preparacion.md#opcional-un-programa-con-interfaz-gráfica). Todo este paso funciona igual ahí.

## Mirá qué hay

```sql
\dt                       -- lista las tablas
\d characters             -- muestra las columnas de una tabla
SELECT * FROM planets;    -- muestra los datos
```

Los comandos que empiezan con `\` son atajos de psql, no SQL. Terminá cada consulta SQL con `;`.

| Comando de psql | Qué hace |
|-----------------|----------|
| `\dt` | lista las tablas |
| `\d nombre` | describe una tabla |
| `\q` | sale de psql |

## La lección

Abrí [`sql/03_ejemplos.sql`](../../sql/03_ejemplos.sql) en un editor al lado de psql. Recorrelo **de arriba a abajo, una consulta por vez**:

1. Leé el comentario de arriba de la consulta. Te dice qué esperar.
2. Copiá y pegá la consulta y ejecutala.
3. Cambiá algo (un número, una columna, un nombre) y ejecutala de nuevo.

| Parte | Tema | Vas a aprender |
|-------|------|----------------|
| 1 | Leer | `SELECT`, columnas, `AS`, `DISTINCT` |
| 2 | Filtrar | `WHERE`, `AND`/`OR`, `IN`, `BETWEEN`, `LIKE`, `IS NULL` |
| 3 | Ordenar | `ORDER BY`, `LIMIT` |
| 4 | Resumir | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING` |
| 5 | Unir tablas | `JOIN`, `LEFT JOIN` |
| 6 | Subconsultas | una consulta adentro de otra |
| 7 | Cambiar datos | `INSERT`, `UPDATE`, `DELETE`, claves foráneas |
| 8 | Transacciones | `BEGIN`, `COMMIT`, `ROLLBACK` |

El archivo termina con **ejercicios de práctica**, con las respuestas abajo de todo. Intentalos antes de espiar.

> **Tené el machete abierto.** [`docs/es/cheatsheet.html`](cheatsheet.html) tiene todos estos temas en una sola página, con ejemplos para copiar. Abrilo en el navegador: `xdg-open docs/es/cheatsheet.html` (Linux), `open docs/es/cheatsheet.html` (macOS) o `start docs/es/cheatsheet.html` (Windows). También está online: [rmpato.github.io/sql-z/docs/es/cheatsheet.html](https://rmpato.github.io/sql-z/docs/es/cheatsheet.html).

## Bueno saber

- **Algunas consultas fallan a propósito** para mostrar errores comunes. El comentario de arriba lo avisa.
- **La parte 7 cambia los datos de verdad.** Para empezar de cero: `docker compose down -v && docker compose up -d --wait`.
- **En Beekeeper**, pegá el archivo entero en una pestaña, poné el cursor sobre una consulta y ejecutá solo esa.

---

**Siguiente:** [2. SQL desde código →](02-go-demo.md)
