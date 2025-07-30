package handler

import (
	"net/http"
	"pos-final/internal/domain"
	"pos-final/internal/service"

	"github.com/gin-gonic/gin"
)

// AuthHandler handles authentication-related HTTP requests
type AuthHandler struct {
	authService service.AuthService
}

// NewAuthHandler creates a new auth handler
func NewAuthHandler(authService service.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
	}
}

// LoginRequest represents the login request payload
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// RegisterRequest represents the register request payload
type RegisterRequest struct {
	Username string          `json:"username" binding:"required"`
	Email    string          `json:"email" binding:"required,email"`
	Password string          `json:"password" binding:"required,min=6"`
	FullName string          `json:"full_name" binding:"required"`
	Phone    string          `json:"phone"`
	Role     domain.UserRole `json:"role" binding:"required"`
}

// ChangePasswordRequest represents the change password request payload
type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

// LoginResponse represents the login response
type LoginResponse struct {
	User  *domain.User `json:"user"`
	Token string       `json:"token"`
}

// Login handles user login
func (h *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid request data",
			"details": err.Error(),
		})
		return
	}

	user, token, err := h.authService.Login(c.Request.Context(), req.Username, req.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Login successful",
		"data": LoginResponse{
			User:  user,
			Token: token,
		},
	})
}

// Register handles user registration
func (h *AuthHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid request data",
			"details": err.Error(),
		})
		return
	}

	user := &domain.User{
		Username: req.Username,
		Email:    req.Email,
		FullName: req.FullName,
		Phone:    &req.Phone,
		Role:     req.Role,
	}

	err := h.authService.Register(c.Request.Context(), user, req.Password)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	// Remove password hash from response
	user.PasswordHash = ""

	c.JSON(http.StatusCreated, gin.H{
		"message": "User registered successfully",
		"data":    user,
	})
}

// RefreshToken handles token refresh
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "User ID not found in context",
		})
		return
	}

	userIDInt, ok := userID.(int)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Invalid user ID",
		})
		return
	}

	token, err := h.authService.RefreshToken(c.Request.Context(), userIDInt)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Token refreshed successfully",
		"data": gin.H{
			"token": token,
		},
	})
}

// ChangePassword handles password change
func (h *AuthHandler) ChangePassword(c *gin.Context) {
	var req ChangePasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid request data",
			"details": err.Error(),
		})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "User ID not found in context",
		})
		return
	}

	userIDInt, ok := userID.(int)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Invalid user ID",
		})
		return
	}

	err := h.authService.ChangePassword(c.Request.Context(), userIDInt, req.OldPassword, req.NewPassword)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Password changed successfully",
	})
}

// GetProfile returns the current user's profile
func (h *AuthHandler) GetProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "User ID not found in context",
		})
		return
	}

	username, exists := c.Get("username")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Username not found in context",
		})
		return
	}

	role, exists := c.Get("role")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Role not found in context",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Profile retrieved successfully",
		"data": gin.H{
			"user_id":  userID,
			"username": username,
			"role":     role,
		},
	})
}