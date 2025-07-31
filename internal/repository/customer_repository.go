package repository

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"strings"

	"github.com/jmoiron/sqlx"
)

type customerRepository struct {
	db *sqlx.DB
}

// NewCustomerRepository creates a new customer repository
func NewCustomerRepository(db *sqlx.DB) CustomerRepository {
	return &customerRepository{db: db}
}

func (r *customerRepository) Create(ctx context.Context, customer *domain.Customer) error {
	query := `
		INSERT INTO customers (customer_code, name, ktp_number, phone, email, address)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at, updated_at
	`
	
	err := r.db.QueryRowContext(ctx, query,
		customer.CustomerCode, customer.Name, customer.KTPNumber,
		customer.Phone, customer.Email, customer.Address,
	).Scan(&customer.ID, &customer.CreatedAt, &customer.UpdatedAt)
	
	if err != nil {
		return fmt.Errorf("failed to create customer: %w", err)
	}
	
	return nil
}

func (r *customerRepository) GetByID(ctx context.Context, id int) (*domain.Customer, error) {
	var customer domain.Customer
	query := `
		SELECT id, customer_code, name, ktp_number, phone, email, address,
			   deleted_at, deleted_by, created_at, updated_at
		FROM customers
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &customer, query, id)
	if err != nil {
		if IsNoRowsError(err) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get customer by ID: %w", err)
	}
	
	return &customer, nil
}

func (r *customerRepository) GetByCustomerCode(ctx context.Context, customerCode string) (*domain.Customer, error) {
	var customer domain.Customer
	query := `
		SELECT id, customer_code, name, ktp_number, phone, email, address,
			   deleted_at, deleted_by, created_at, updated_at
		FROM customers
		WHERE customer_code = $1 AND deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &customer, query, customerCode)
	if err != nil {
		if IsNoRowsError(err) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get customer by customer code: %w", err)
	}
	
	return &customer, nil
}

func (r *customerRepository) List(ctx context.Context, offset, limit int) ([]*domain.Customer, error) {
	var customers []*domain.Customer
	query := `
		SELECT id, customer_code, name, ktp_number, phone, email, address,
			   deleted_at, deleted_by, created_at, updated_at
		FROM customers
		WHERE deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $1 OFFSET $2
	`
	
	err := r.db.SelectContext(ctx, &customers, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list customers: %w", err)
	}
	
	return customers, nil
}

func (r *customerRepository) Update(ctx context.Context, customer *domain.Customer) error {
	query := `
		UPDATE customers
		SET name = $2, ktp_number = $3, phone = $4, email = $5, address = $6,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
		RETURNING updated_at
	`
	
	err := r.db.QueryRowContext(ctx, query,
		customer.ID, customer.Name, customer.KTPNumber,
		customer.Phone, customer.Email, customer.Address,
	).Scan(&customer.UpdatedAt)
	
	if err != nil {
		return fmt.Errorf("failed to update customer: %w", err)
	}
	
	return nil
}

func (r *customerRepository) SoftDelete(ctx context.Context, id int, deletedBy int) error {
	query := `
		UPDATE customers
		SET deleted_at = CURRENT_TIMESTAMP, deleted_by = $2
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	result, err := r.db.ExecContext(ctx, query, id, deletedBy)
	if err != nil {
		return fmt.Errorf("failed to delete customer: %w", err)
	}
	
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	
	if rowsAffected == 0 {
		return fmt.Errorf("customer not found or already deleted")
	}
	
	return nil
}

func (r *customerRepository) Count(ctx context.Context) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM customers WHERE deleted_at IS NULL`
	
	err := r.db.GetContext(ctx, &count, query)
	if err != nil {
		return 0, fmt.Errorf("failed to count customers: %w", err)
	}
	
	return count, nil
}

func (r *customerRepository) Search(ctx context.Context, query string, offset, limit int) ([]*domain.Customer, error) {
	var customers []*domain.Customer
	searchQuery := `
		SELECT id, customer_code, name, ktp_number, phone, email, address,
			   deleted_at, deleted_by, created_at, updated_at
		FROM customers
		WHERE deleted_at IS NULL
		AND (
			name ILIKE $1 OR
			customer_code ILIKE $1 OR
			phone ILIKE $1 OR
			email ILIKE $1 OR
			ktp_number ILIKE $1
		)
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`
	
	searchTerm := "%" + strings.ToLower(query) + "%"
	err := r.db.SelectContext(ctx, &customers, searchQuery, searchTerm, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to search customers: %w", err)
	}
	
	return customers, nil
}

func (r *customerRepository) GenerateCustomerCode(ctx context.Context) (string, error) {
	var lastNumber int
	query := `
		SELECT COALESCE(MAX(CAST(SUBSTRING(customer_code FROM 4) AS INTEGER)), 0)
		FROM customers
		WHERE customer_code LIKE 'CR-%'
		AND deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &lastNumber, query)
	if err != nil {
		return "", fmt.Errorf("failed to generate customer code: %w", err)
	}
	
	return fmt.Sprintf("CR-%04d", lastNumber+1), nil
}