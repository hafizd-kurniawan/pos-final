package service

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"pos-final/internal/middleware"
	"pos-final/internal/repository"
	"time"

	"golang.org/x/crypto/bcrypt"
)

type authService struct {
	userRepo      repository.UserRepository
	jwtSecret     string
	jwtExpiry     time.Duration
}

// NewAuthService creates a new authentication service
func NewAuthService(userRepo repository.UserRepository, jwtSecret string, jwtExpiry time.Duration) AuthService {
	return &authService{
		userRepo:  userRepo,
		jwtSecret: jwtSecret,
		jwtExpiry: jwtExpiry,
	}
}

func (s *authService) Login(ctx context.Context, username, password string) (*domain.User, string, error) {
	// Get user by username
	user, err := s.userRepo.GetByUsername(ctx, username)
	if err != nil {
		return nil, "", fmt.Errorf("failed to get user: %w", err)
	}
	
	if user == nil {
		return nil, "", fmt.Errorf("invalid credentials")
	}
	
	// Check if user is active
	if !user.IsActive {
		return nil, "", fmt.Errorf("user account is inactive")
	}
	
	// Verify password
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
	if err != nil {
		return nil, "", fmt.Errorf("invalid credentials")
	}
	
	// Generate JWT token
	token, err := middleware.GenerateJWT(user, s.jwtSecret, s.jwtExpiry)
	if err != nil {
		return nil, "", fmt.Errorf("failed to generate token: %w", err)
	}
	
	// Remove password hash from response
	user.PasswordHash = ""
	
	return user, token, nil
}

func (s *authService) Register(ctx context.Context, user *domain.User, password string) error {
	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash password: %w", err)
	}
	
	user.PasswordHash = string(hashedPassword)
	user.IsActive = true
	
	// Create user
	err = s.userRepo.Create(ctx, user)
	if err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}
	
	return nil
}

func (s *authService) ValidateToken(token string) (*domain.User, error) {
	claims, err := middleware.ParseJWT(token, s.jwtSecret)
	if err != nil {
		return nil, fmt.Errorf("invalid token: %w", err)
	}
	
	// Create user from claims
	user := &domain.User{
		BaseModel: domain.BaseModel{ID: claims.UserID},
		Username:  claims.Username,
		Role:      claims.Role,
	}
	
	return user, nil
}

func (s *authService) RefreshToken(ctx context.Context, userID int) (string, error) {
	// Get user by ID
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return "", fmt.Errorf("failed to get user: %w", err)
	}
	
	if user == nil {
		return "", fmt.Errorf("user not found")
	}
	
	if !user.IsActive {
		return "", fmt.Errorf("user account is inactive")
	}
	
	// Generate new JWT token
	token, err := middleware.GenerateJWT(user, s.jwtSecret, s.jwtExpiry)
	if err != nil {
		return "", fmt.Errorf("failed to generate token: %w", err)
	}
	
	return token, nil
}

func (s *authService) ChangePassword(ctx context.Context, userID int, oldPassword, newPassword string) error {
	// Get user by ID
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return fmt.Errorf("failed to get user: %w", err)
	}
	
	if user == nil {
		return fmt.Errorf("user not found")
	}
	
	// Verify old password
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(oldPassword))
	if err != nil {
		return fmt.Errorf("invalid old password")
	}
	
	// Hash new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash new password: %w", err)
	}
	
	user.PasswordHash = string(hashedPassword)
	
	// Update user
	err = s.userRepo.Update(ctx, user)
	if err != nil {
		return fmt.Errorf("failed to update user password: %w", err)
	}
	
	return nil
}

func (s *authService) ResetPassword(ctx context.Context, email string) error {
	// Get user by email
	user, err := s.userRepo.GetByEmail(ctx, email)
	if err != nil {
		return fmt.Errorf("failed to get user: %w", err)
	}
	
	if user == nil {
		return fmt.Errorf("user not found")
	}
	
	// TODO: Implement password reset logic
	// For now, this is a placeholder
	// In a real implementation, you would:
	// 1. Generate a reset token
	// 2. Store it in database with expiry
	// 3. Send email with reset link
	
	return fmt.Errorf("password reset not implemented yet")
}