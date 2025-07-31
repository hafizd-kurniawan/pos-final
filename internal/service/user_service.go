package service

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"pos-final/internal/repository"
	"strings"

	"golang.org/x/crypto/bcrypt"
)

type userService struct {
	userRepo repository.UserRepository
}

// NewUserService creates a new user service
func NewUserService(userRepo repository.UserRepository) UserService {
	return &userService{
		userRepo: userRepo,
	}
}

func (s *userService) CreateUser(ctx context.Context, user *domain.User, password string) error {
	// Validate required fields
	if err := s.validateUser(user); err != nil {
		return err
	}

	if password == "" {
		return fmt.Errorf("password is required")
	}

	if len(password) < 6 {
		return fmt.Errorf("password must be at least 6 characters")
	}

	// Check if username already exists
	existing, err := s.userRepo.GetByUsername(ctx, user.Username)
	if err != nil {
		return fmt.Errorf("failed to check existing username: %w", err)
	}
	if existing != nil {
		return fmt.Errorf("username already exists")
	}

	// Check if email already exists
	existing, err = s.userRepo.GetByEmail(ctx, user.Email)
	if err != nil {
		return fmt.Errorf("failed to check existing email: %w", err)
	}
	if existing != nil {
		return fmt.Errorf("email already exists")
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash password: %w", err)
	}
	user.PasswordHash = string(hashedPassword)

	// Create user
	if err := s.userRepo.Create(ctx, user); err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}

	return nil
}

func (s *userService) GetUserByID(ctx context.Context, id int) (*domain.User, error) {
	if id <= 0 {
		return nil, fmt.Errorf("invalid user ID")
	}

	user, err := s.userRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	if user == nil {
		return nil, fmt.Errorf("user not found")
	}

	return user, nil
}

func (s *userService) GetUserByUsername(ctx context.Context, username string) (*domain.User, error) {
	if username == "" {
		return nil, fmt.Errorf("username is required")
	}

	user, err := s.userRepo.GetByUsername(ctx, username)
	if err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	if user == nil {
		return nil, fmt.Errorf("user not found")
	}

	return user, nil
}

func (s *userService) ListUsers(ctx context.Context, page, limit int) ([]*domain.User, int, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	users, err := s.userRepo.List(ctx, offset, limit)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list users: %w", err)
	}

	total, err := s.userRepo.Count(ctx)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count users: %w", err)
	}

	return users, total, nil
}

func (s *userService) UpdateUser(ctx context.Context, user *domain.User) error {
	if user.ID <= 0 {
		return fmt.Errorf("invalid user ID")
	}

	// Validate required fields
	if err := s.validateUser(user); err != nil {
		return err
	}

	// Check if user exists
	existing, err := s.userRepo.GetByID(ctx, user.ID)
	if err != nil {
		return fmt.Errorf("failed to check existing user: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("user not found")
	}

	// Check if username is being updated and if it conflicts
	if existing.Username != user.Username {
		conflicting, err := s.userRepo.GetByUsername(ctx, user.Username)
		if err != nil {
			return fmt.Errorf("failed to check existing username: %w", err)
		}
		if conflicting != nil && conflicting.ID != user.ID {
			return fmt.Errorf("username already exists")
		}
	}

	// Check if email is being updated and if it conflicts
	if existing.Email != user.Email {
		conflicting, err := s.userRepo.GetByEmail(ctx, user.Email)
		if err != nil {
			return fmt.Errorf("failed to check existing email: %w", err)
		}
		if conflicting != nil && conflicting.ID != user.ID {
			return fmt.Errorf("email already exists")
		}
	}

	// Preserve password hash and creation date
	user.PasswordHash = existing.PasswordHash
	user.CreatedAt = existing.CreatedAt

	// Update user
	if err := s.userRepo.Update(ctx, user); err != nil {
		return fmt.Errorf("failed to update user: %w", err)
	}

	return nil
}

func (s *userService) DeleteUser(ctx context.Context, id int, deletedBy int) error {
	if id <= 0 {
		return fmt.Errorf("invalid user ID")
	}

	if deletedBy <= 0 {
		return fmt.Errorf("invalid deleted by user ID")
	}

	// Check if user exists
	existing, err := s.userRepo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to check existing user: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("user not found")
	}

	// TODO: Check if user has active sessions or is referenced by other entities

	// Soft delete user
	if err := s.userRepo.SoftDelete(ctx, id, deletedBy); err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	return nil
}

func (s *userService) GetUsersByRole(ctx context.Context, role domain.UserRole) ([]*domain.User, error) {
	if !isValidUserRole(role) {
		return nil, fmt.Errorf("invalid user role")
	}

	users, err := s.userRepo.GetByRole(ctx, role)
	if err != nil {
		return nil, fmt.Errorf("failed to get users by role: %w", err)
	}

	return users, nil
}

func (s *userService) ActivateUser(ctx context.Context, id int, isActive bool) error {
	if id <= 0 {
		return fmt.Errorf("invalid user ID")
	}

	// Check if user exists
	user, err := s.userRepo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to check existing user: %w", err)
	}
	if user == nil {
		return fmt.Errorf("user not found")
	}

	// Update active status
	user.IsActive = isActive
	if err := s.userRepo.Update(ctx, user); err != nil {
		return fmt.Errorf("failed to update user status: %w", err)
	}

	return nil
}

func (s *userService) ChangePassword(ctx context.Context, userID int, oldPassword, newPassword string) error {
	if userID <= 0 {
		return fmt.Errorf("invalid user ID")
	}

	if newPassword == "" {
		return fmt.Errorf("new password is required")
	}

	if len(newPassword) < 6 {
		return fmt.Errorf("new password must be at least 6 characters")
	}

	// Get user
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return fmt.Errorf("failed to get user: %w", err)
	}
	if user == nil {
		return fmt.Errorf("user not found")
	}

	// Verify old password if provided (for admin use, old password can be empty)
	if oldPassword != "" {
		err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(oldPassword))
		if err != nil {
			return fmt.Errorf("invalid old password")
		}
	}

	// Hash new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash new password: %w", err)
	}

	// Update password
	user.PasswordHash = string(hashedPassword)
	if err := s.userRepo.Update(ctx, user); err != nil {
		return fmt.Errorf("failed to update password: %w", err)
	}

	return nil
}

func (s *userService) validateUser(user *domain.User) error {
	if user == nil {
		return fmt.Errorf("user is required")
	}

	if strings.TrimSpace(user.Username) == "" {
		return fmt.Errorf("username is required")
	}

	if strings.TrimSpace(user.Email) == "" {
		return fmt.Errorf("email is required")
	}

	if strings.TrimSpace(user.FullName) == "" {
		return fmt.Errorf("full name is required")
	}

	if !isValidUserRole(user.Role) {
		return fmt.Errorf("invalid user role")
	}

	// Basic email validation
	if !strings.Contains(user.Email, "@") || !strings.Contains(user.Email, ".") {
		return fmt.Errorf("invalid email format")
	}

	// Username validation
	if len(user.Username) < 3 {
		return fmt.Errorf("username must be at least 3 characters")
	}

	return nil
}

func isValidUserRole(role domain.UserRole) bool {
	switch role {
	case domain.RoleAdmin, domain.RoleKasir, domain.RoleMekanik:
		return true
	default:
		return false
	}
}