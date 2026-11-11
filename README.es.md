# sql-z

[English](README.md) · **Español**

**Aprendé lo esencial de SQL con datos de Dragon Ball, y después mirá cómo lo usa el código de verdad.**
No hace falta saber nada de bases de datos.

## El recorrido

| # | Guía | Qué vas a hacer |
|---|------|-----------------|
| 0 | [Preparación](docs/es/00-preparacion.md) | Instalar Docker y Go, levantar la base de datos |
| 1 | [SQL a mano](docs/es/01-sql.md) | Leer, filtrar, ordenar, resumir, unir y cambiar datos en `psql` o Beekeeper |
| 2 | [SQL desde código](docs/es/02-go-demo.md) | Ejecutar las mismas consultas desde un programa en Go y comparar |
| 3 | [SQL detrás de una API](docs/es/03-go-api.md) | Seguir un valor desde un pedido HTTP (GET, POST, PUT, DELETE) hasta la tabla |
| 4 | [Próximos pasos](docs/es/04-proximos-pasos.md) | Desafíos de código y temas para aprender después |

¿Te trabaste? Mirá [Problemas comunes](docs/es/problemas.md).

## Machete

Tené abierto el **[machete de SQL](https://rmpato.github.io/sql-z/docs/es/cheatsheet.html)** mientras trabajás. Tiene todos los temas de la lección en una sola página, con ejemplos para copiar.

También está en el repo en `docs/es/cheatsheet.html`, así que funciona sin internet. Abrilo en el navegador:

```bash
xdg-open docs/es/cheatsheet.html   # Ubuntu / Linux
open docs/es/cheatsheet.html       # macOS
start docs/es/cheatsheet.html      # Windows (Git Bash)
```

## Arranque rápido

¿Ya tenés Docker y Go 1.22 o más nuevo? Entonces:

```bash
git clone https://github.com/rmpato/sql-z.git
cd sql-z
./connect.sh        # levanta la base de datos y abre psql
```

Si no, empezá por la [Preparación](docs/es/00-preparacion.md).

## La base de datos

Cuatro tablas, conectadas por ids:

```
planets ──┐
          ├── characters ── techniques
races   ──┘
```

| Tabla | Qué guarda | Apunta a |
|-------|------------|----------|
| `planets` (planetas) | Tierra, Namek, … | |
| `races` (razas) | Saiyajin, Humano, … | |
| `characters` (personajes) | Goku, Vegeta, … | un planeta y una raza |
| `techniques` (técnicas) | Kamehameha, … | un personaje |

Los nombres de tablas y columnas están en inglés, como en la mayoría de los proyectos reales. Se definen en [`sql/01_schema.sql`](sql/01_schema.sql) y se llenan con [`sql/02_seed.sql`](sql/02_seed.sql).

## Comandos

| Para | Comando |
|------|---------|
| Levantar la base de datos | `docker compose up -d --wait` |
| Abrir psql | `./connect.sh` |
| Apagarla (los datos quedan) | `docker compose down` |
| Volver a los datos iniciales | `docker compose down -v && docker compose up -d --wait` |

**Datos de conexión** (para programas con interfaz gráfica y para el código):

| Host | Puerto | Base de datos | Usuario | Contraseña |
|------|--------|---------------|---------|------------|
| localhost | 5432 | dragonball | goku | kamehameha |

## Qué hay en el repo

```
sql/
  01_schema.sql     definición de las tablas
  02_seed.sql       datos iniciales
  03_examples.sql   la lección de SQL en inglés
  03_ejemplos.sql   la lección de SQL en español (paso 1)
go-demo/            paso 2: un programa en Go que ejecuta SQL
go-api/             paso 3: una API REST que usa SQL
docs/es/            las guías y el machete en español
docs/               las guías y el machete en inglés
connect.sh          levanta la base de datos y abre psql
```

> El código de Go (`go-demo/` y `go-api/`) tiene los comentarios en inglés, como es habitual en programación. Las guías en español explican todo lo importante.
