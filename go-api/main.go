// A tiny REST API over the characters table.
//
// The point: follow a value from the HTTP request, into a SQL query,
// and into the database. Every handler logs the SQL it runs and the
// values it plugs in, so you can watch it happen in the terminal.
//
//   Request                       Where the input comes from    SQL
//   GET    /characters            query string (?min_power=)    SELECT … WHERE power_level >= $1
//   GET    /characters/{id}       URL path                      SELECT … WHERE id = $1
//   POST   /characters            JSON body                     INSERT … VALUES ($1, $2, $3, $4)
//   PUT    /characters/{id}       URL path + JSON body          UPDATE … SET … WHERE id = $5
//   DELETE /characters/{id}       URL path                      DELETE … WHERE id = $1 (in a transaction)
package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/lib/pq"
)

// Character is one row of the characters table.
// The json tags decide the field names in requests and responses.
type Character struct {
	ID         int    `json:"id"`
	Name       string `json:"name"`
	PowerLevel int    `json:"power_level"`
	PlanetID   int    `json:"planet_id"`
	RaceID     *int   `json:"race_id"` // pointer so NULL ↔ null works (Frieza has no race)
}

func main() {
	connStr := envOr("DATABASE_URL", "postgres://goku:kamehameha@localhost:5432/dragonball?sslmode=disable")

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()
	if err := db.Ping(); err != nil {
		log.Fatal("can't reach the database (is docker compose up?): ", err)
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /characters", func(w http.ResponseWriter, r *http.Request) { listCharacters(w, r, db) })
	mux.HandleFunc("GET /characters/{id}", func(w http.ResponseWriter, r *http.Request) { getCharacter(w, r, db) })
	mux.HandleFunc("POST /characters", func(w http.ResponseWriter, r *http.Request) { createCharacter(w, r, db) })
	mux.HandleFunc("PUT /characters/{id}", func(w http.ResponseWriter, r *http.Request) { updateCharacter(w, r, db) })
	mux.HandleFunc("DELETE /characters/{id}", func(w http.ResponseWriter, r *http.Request) { deleteCharacter(w, r, db) })

	addr := ":8080"
	fmt.Println("API listening on http://localhost" + addr)
	fmt.Println("  GET    /characters            (optional ?min_power=N)")
	fmt.Println("  GET    /characters/{id}")
	fmt.Println("  POST   /characters")
	fmt.Println("  PUT    /characters/{id}")
	fmt.Println("  DELETE /characters/{id}")
	fmt.Println()
	log.Fatal(http.ListenAndServe(addr, logRequests(mux)))
}

// ---------------------------------------------------------------
// GET /characters?min_power=3000
// Input: optional query string value → $1
// ---------------------------------------------------------------
func listCharacters(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	minPower := 0
	if v := r.URL.Query().Get("min_power"); v != "" {
		n, err := strconv.Atoi(v)
		if err != nil {
			http.Error(w, "min_power must be a number", http.StatusBadRequest)
			return
		}
		minPower = n
	}

	// Heads-up: with no ?min_power, $1 is 0, so this still filters.
	// Rows where power_level is NULL are hidden, because NULL >= 0 is
	// not true (see 2.7 in sql/03_examples.sql). The seed data has no
	// NULL power levels, but one inserted by hand in psql won't show up
	// here. To include them: WHERE power_level >= $1 OR power_level IS NULL
	const q = `
		SELECT id, name, power_level, planet_id, race_id
		FROM characters
		WHERE power_level >= $1
		ORDER BY id`
	logSQL(q, minPower)

	rows, err := db.Query(q, minPower)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	out := []Character{} // empty list encodes as [] instead of null
	for rows.Next() {
		var c Character
		if err := rows.Scan(&c.ID, &c.Name, &c.PowerLevel, &c.PlanetID, &c.RaceID); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		out = append(out, c)
	}
	if err := rows.Err(); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJSON(w, http.StatusOK, out)
}

// ---------------------------------------------------------------
// GET /characters/{id}
// Input: id from the URL path → $1
// ---------------------------------------------------------------
func getCharacter(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	id, ok := pathID(w, r)
	if !ok {
		return
	}

	const q = `
		SELECT id, name, power_level, planet_id, race_id
		FROM characters
		WHERE id = $1`
	logSQL(q, id)

	var c Character
	err := db.QueryRow(q, id).Scan(&c.ID, &c.Name, &c.PowerLevel, &c.PlanetID, &c.RaceID)
	if errors.Is(err, sql.ErrNoRows) {
		http.Error(w, "not found", http.StatusNotFound)
		return
	}
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	writeJSON(w, http.StatusOK, c)
}

// ---------------------------------------------------------------
// POST /characters   body: {"name":"Bulma","power_level":12,"planet_id":1,"race_id":2}
// Input: JSON body → struct → $1..$4
// ---------------------------------------------------------------
func createCharacter(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	in, ok := readCharacter(w, r)
	if !ok {
		return
	}

	const q = `
		INSERT INTO characters (name, power_level, planet_id, race_id)
		VALUES ($1, $2, $3, $4)
		RETURNING id`
	logSQL(q, in.Name, in.PowerLevel, in.PlanetID, in.RaceID)

	err := db.QueryRow(q, in.Name, in.PowerLevel, in.PlanetID, in.RaceID).Scan(&in.ID)
	if err != nil {
		writeDBError(w, err)
		return
	}

	writeJSON(w, http.StatusCreated, in)
}

// ---------------------------------------------------------------
// PUT /characters/{id}   body: same shape as POST
// Input: id from the URL path → $5, JSON body → $1..$4
// PUT replaces the whole row, so every field is sent.
// ---------------------------------------------------------------
func updateCharacter(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	id, ok := pathID(w, r)
	if !ok {
		return
	}
	in, ok := readCharacter(w, r)
	if !ok {
		return
	}

	const q = `
		UPDATE characters
		SET name = $1, power_level = $2, planet_id = $3, race_id = $4
		WHERE id = $5`
	logSQL(q, in.Name, in.PowerLevel, in.PlanetID, in.RaceID, id)

	res, err := db.Exec(q, in.Name, in.PowerLevel, in.PlanetID, in.RaceID, id)
	if err != nil {
		writeDBError(w, err)
		return
	}
	// No row had that id → nothing was updated.
	if n, _ := res.RowsAffected(); n == 0 {
		http.Error(w, "not found", http.StatusNotFound)
		return
	}

	in.ID = id
	writeJSON(w, http.StatusOK, in)
}

// ---------------------------------------------------------------
// DELETE /characters/{id}
// Input: id from the URL path → $1
// techniques point at characters (foreign key), so they must go
// first. Both deletes run in ONE transaction: all or nothing.
// ---------------------------------------------------------------
func deleteCharacter(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	id, ok := pathID(w, r)
	if !ok {
		return
	}

	tx, err := db.Begin()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	// If we return before Commit, undo everything. After Commit it's a no-op.
	defer tx.Rollback()

	const q1 = `DELETE FROM techniques WHERE character_id = $1`
	logSQL(q1, id)
	if _, err := tx.Exec(q1, id); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	const q2 = `DELETE FROM characters WHERE id = $1`
	logSQL(q2, id)
	res, err := tx.Exec(q2, id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if n, _ := res.RowsAffected(); n == 0 {
		http.Error(w, "not found", http.StatusNotFound) // deferred Rollback runs
		return
	}

	if err := tx.Commit(); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ---------------------------------------------------------------
// helpers
// ---------------------------------------------------------------

// pathID reads {id} from the URL and makes sure it's a number.
func pathID(w http.ResponseWriter, r *http.Request) (int, bool) {
	id, err := strconv.Atoi(r.PathValue("id"))
	if err != nil {
		http.Error(w, "id must be a number", http.StatusBadRequest)
		return 0, false
	}
	return id, true
}

// readCharacter decodes the JSON body and checks required fields.
func readCharacter(w http.ResponseWriter, r *http.Request) (Character, bool) {
	var in Character
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		http.Error(w, "bad JSON: "+err.Error(), http.StatusBadRequest)
		return in, false
	}
	if in.Name == "" {
		http.Error(w, "name is required", http.StatusBadRequest)
		return in, false
	}
	return in, true
}

// writeDBError turns database errors the client caused into 400s.
// 23503 is Postgres's code for "foreign key violation", e.g.
// planet_id 99 when there is no planet 99.
func writeDBError(w http.ResponseWriter, err error) {
	var pqErr *pq.Error
	if errors.As(err, &pqErr) && pqErr.Code == "23503" {
		http.Error(w, "planet_id or race_id does not exist", http.StatusBadRequest)
		return
	}
	http.Error(w, err.Error(), http.StatusInternalServerError)
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

// logSQL prints the query and the values that replace $1, $2, …
func logSQL(q string, args ...any) {
	vals := make([]string, len(args))
	for i, a := range args {
		if p, ok := a.(*int); ok { // show *int as its value (or NULL)
			if p == nil {
				a = "NULL"
			} else {
				a = *p
			}
		}
		vals[i] = fmt.Sprintf("$%d=%v", i+1, a)
	}
	log.Printf("  SQL: %s\n       %s", strings.Join(strings.Fields(q), " "), strings.Join(vals, " "))
}

// logRequests prints each incoming request before it's handled.
func logRequests(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("→ %s %s", r.Method, r.URL.RequestURI())
		next.ServeHTTP(w, r)
	})
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
