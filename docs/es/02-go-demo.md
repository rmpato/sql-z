# 2. SQL desde código

[← Volver al README](../../README.es.md) · [English](../02-go-demo.md)

**Objetivo:** ver el SQL que escribiste en el paso 1 ejecutándose adentro de un programa, y qué cambia cuando pasa eso.

## Ejecutalo

Con la base de datos levantada:

```bash
cd go-demo
go run .
```

Vas a ver:

```
connected to dragonball ✓

inserted Trunks with id=9

NAME            POWER  PLANET
--------------------------------
Goku             9001  Earth
Vegeta           8500  Vegeta
...
```

## Comparalo con el paso 1

Abrí [`go-demo/main.go`](../../go-demo/main.go) al lado de [`sql/03_ejemplos.sql`](../../sql/03_ejemplos.sql). El programa ejecuta dos consultas que ya conocés:

| Función | Misma consulta que | Qué cambia en el código |
|---------|--------------------|-------------------------|
| `insertTrunks` | 7.1 (`INSERT … RETURNING`) | Los valores se pasan como `$1, $2, …` en lugar de escribirlos dentro de la consulta |
| `listCharacters` | 5.1 (`JOIN`) | No hay tabla impresa: recorrés las filas y copiás cada columna a una variable con `Scan` |

## Las tres ideas para llevarte

1. **Conectarse.** El código se conecta con una URL: `postgres://usuario:contraseña@host:puerto/base`.
2. **Placeholders.** Nunca pegues valores dentro del texto del SQL (`"... VALUES ('" + name + "')"`). Pasalos aparte como `$1, $2`. Así se evita la **inyección SQL**, uno de los errores de seguridad más comunes.
3. **Leer filas.** `rows.Next()` pasa a la siguiente fila, y `rows.Scan(...)` copia sus columnas a variables, en el mismo orden que el `SELECT`.

## Revisalo en la base de datos

Cada vez que lo ejecutás agrega otro Trunks. Fijate en psql:

```sql
SELECT * FROM characters WHERE name = 'Trunks';
```

El programa y psql comparten la misma base de datos. Esa es la idea.

> Los comentarios del código están en inglés, como es habitual en programación.

---

**Siguiente:** [3. SQL detrás de una API →](03-go-api.md)
