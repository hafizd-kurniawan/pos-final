package repository

import (
	"database/sql"
	"fmt"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

// Database holds the database connection
type Database struct {
	DB *sqlx.DB
}

// NewDatabase creates a new database connection
func NewDatabase(databaseURL string) (*Database, error) {
	db, err := sqlx.Connect("postgres", databaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	// Configure connection pool
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(25)
	db.SetConnMaxLifetime(0)

	// Ping database to verify connection
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return &Database{DB: db}, nil
}

// Close closes the database connection
func (d *Database) Close() error {
	return d.DB.Close()
}

// BeginTx starts a new transaction
func (d *Database) BeginTx() (*sqlx.Tx, error) {
	return d.DB.Beginx()
}

// GetDB returns the database connection
func (d *Database) GetDB() *sqlx.DB {
	return d.DB
}

// IsNoRowsError checks if the error is a no rows error
func IsNoRowsError(err error) bool {
	return err == sql.ErrNoRows
}