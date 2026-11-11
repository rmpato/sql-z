// go-demo: the same SQL you typed in psql (step 1), now run from code.
//
// Compare side by side with sql/03_examples.sql:
//   insertTrunks   ↔ 7.1 (INSERT … RETURNING)
//   listCharacters ↔ 5.1 (JOIN characters + planets)
//
// What's different when SQL lives in code:
//   1. You connect with a URL instead of opening psql.
//   2. Values go in as $1, $2, … placeholders, never pasted into the text.
//   3. Results come back row by row and you copy each column into a
//      Go variable with Scan, instead of reading a printed table.
package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq" // Postgres driver: registers itself as "postgres"
)

func main() {
	// Same database that psql and Beekeeper talk to.
	// Format: postgres://user:password@host:port/database
	connStr := envOr("DATABASE_URL", "postgres://goku:kamehameha@localhost:5432/dragonball?sslmode=disable")

	// sql.Open doesn't connect yet. Ping actually reaches the database.
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatal("can't reach the database (is docker compose up?): ", err)
	}
	fmt.Println("connected to dragonball ✓")

	insertTrunks(db)
	listCharacters(db)
}

// In psql (example 7.1) you'd type the values straight into the query:
//
//	INSERT INTO characters (name, power_level, planet_id, race_id)
//	VALUES ('Trunks', 5000, 1, 1) RETURNING id;
//
// In code, the query has $1..$4 and the values are passed separately.
// The database fills them in safely. Gluing user input into the SQL
// string ("VALUES ('" + name + "', …") is how SQL injection happens.
func insertTrunks(db *sql.DB) {
	const q = `
		INSERT INTO characters (name, power_level, planet_id, race_id)
		VALUES ($1, $2, $3, $4)
		RETURNING id
	`

	// QueryRow: we expect exactly one row back (the new id).
	// Scan copies that row's column into our Go variable.
	var id int
	err := db.QueryRow(q, "Trunks", 5000, 1, 1).Scan(&id)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("\ninserted Trunks with id=%d\n", id)
}

// Same JOIN as example 5.1. In psql the result is printed for you;
// here we loop over the rows and decide what to do with each one.
func listCharacters(db *sql.DB) {
	rows, err := db.Query(`
		SELECT c.name, c.power_level, p.name AS planet
		FROM characters c
		JOIN planets p ON c.planet_id = p.id
		ORDER BY c.power_level DESC
	`)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close() // always release the connection when done

	fmt.Println()
	fmt.Printf("%-12s %8s  %s\n", "NAME", "POWER", "PLANET")
	fmt.Println("--------------------------------")

	for rows.Next() { // move to the next row; false when there are none left
		var name, planet string
		var power int
		// Scan's arguments follow the SELECT's column order.
		if err := rows.Scan(&name, &power, &planet); err != nil {
			log.Fatal(err)
		}
		fmt.Printf("%-12s %8d  %s\n", name, power, planet)
	}
	if err := rows.Err(); err != nil { // errors that happened mid-loop
		log.Fatal(err)
	}
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
