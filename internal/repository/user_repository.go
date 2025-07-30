package repository

import (
	"context"
	"fmt"
	"pos-final/internal/domain"

	"github.com/jmoiron/sqlx"
)

type userRepository struct {
	db *sqlx.DB
}

// NewUserRepository creates a new user repository
func NewUserRepository(db *sqlx.DB) UserRepository {
	return &userRepository{db: db}
}

func (r *userRepository) Create(ctx context.Context, user *domain.User) error {
	query := `
		INSERT INTO users (username, email, password_hash, full_name, phone, role, is_active)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at
	`
	
	err := r.db.QueryRowContext(ctx, query,
		user.Username, user.Email, user.PasswordHash, user.FullName,
		user.Phone, user.Role, user.IsActive,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)
	
	if err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}
	
	return nil
}

func (r *userRepository) GetByID(ctx context.Context, id int) (*domain.User, error) {
	var user domain.User
	query := `
		SELECT id, username, email, password_hash, full_name, phone, role, is_active,
			   deleted_at, deleted_by, created_at, updated_at
		FROM users
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &user, query, id)
	if err != nil {
		if IsNoRowsError(err) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get user by ID: %w", err)
	}
	
	return &user, nil
}

func (r *userRepository) GetByUsername(ctx context.Context, username string) (*domain.User, error) {
	var user domain.User
	query := `
		SELECT id, username, email, password_hash, full_name, phone, role, is_active,
			   deleted_at, deleted_by, created_at, updated_at
		FROM users
		WHERE username = $1 AND deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &user, query, username)
	if err != nil {
		if IsNoRowsError(err) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get user by username: %w", err)
	}
	
	return &user, nil
}

func (r *userRepository) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
	var user domain.User
	query := `
		SELECT id, username, email, password_hash, full_name, phone, role, is_active,
			   deleted_at, deleted_by, created_at, updated_at
		FROM users
		WHERE email = $1 AND deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &user, query, email)
	if err != nil {
		if IsNoRowsError(err) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get user by email: %w", err)
	}
	
	return &user, nil
}

func (r *userRepository) List(ctx context.Context, offset, limit int) ([]*domain.User, error) {
	var users []*domain.User
	query := `
		SELECT id, username, email, password_hash, full_name, phone, role, is_active,
			   deleted_at, deleted_by, created_at, updated_at
		FROM users
		WHERE deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $1 OFFSET $2
	`
	
	err := r.db.SelectContext(ctx, &users, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list users: %w", err)
	}
	
	return users, nil
}

func (r *userRepository) Update(ctx context.Context, user *domain.User) error {
	query := `
		UPDATE users
		SET username = $2, email = $3, full_name = $4, phone = $5, role = $6, is_active = $7,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
		RETURNING updated_at
	`
	
	err := r.db.QueryRowContext(ctx, query,
		user.ID, user.Username, user.Email, user.FullName,
		user.Phone, user.Role, user.IsActive,
	).Scan(&user.UpdatedAt)
	
	if err != nil {
		return fmt.Errorf("failed to update user: %w", err)
	}
	
	return nil
}

func (r *userRepository) SoftDelete(ctx context.Context, id int, deletedBy int) error {
	query := `
		UPDATE users
		SET deleted_at = CURRENT_TIMESTAMP, deleted_by = $2
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	result, err := r.db.ExecContext(ctx, query, id, deletedBy)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}
	
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	
	if rowsAffected == 0 {
		return fmt.Errorf("user not found or already deleted")
	}
	
	return nil
}

func (r *userRepository) Count(ctx context.Context) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM users WHERE deleted_at IS NULL`
	
	err := r.db.GetContext(ctx, &count, query)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}
	
	return count, nil
}

func (r *userRepository) GetByRole(ctx context.Context, role domain.UserRole) ([]*domain.User, error) {
	var users []*domain.User
	query := `
		SELECT id, username, email, password_hash, full_name, phone, role, is_active,
			   deleted_at, deleted_by, created_at, updated_at
		FROM users
		WHERE role = $1 AND deleted_at IS NULL AND is_active = true
		ORDER BY created_at DESC
	`
	
	err := r.db.SelectContext(ctx, &users, query, role)
	if err != nil {
		return nil, fmt.Errorf("failed to get users by role: %w", err)
	}
	
	return users, nil
}