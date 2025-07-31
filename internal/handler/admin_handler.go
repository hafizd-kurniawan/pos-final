package handler

import (
	"net/http"
	"pos-final/internal/domain"
	"pos-final/internal/service"
	"strconv"

	"github.com/gin-gonic/gin"
)

type AdminHandler struct {
	userService service.UserService
}

// NewAdminHandler creates a new admin handler
func NewAdminHandler(userService service.UserService) *AdminHandler {
	return &AdminHandler{
		userService: userService,
	}
}

type CreateUserRequest struct {
	Username string          `json:"username" binding:"required"`
	Email    string          `json:"email" binding:"required,email"`
	Password string          `json:"password" binding:"required,min=6"`
	Role     domain.UserRole `json:"role" binding:"required,oneof=admin kasir mekanik"`
	FullName string          `json:"full_name" binding:"required"`
	Phone    *string         `json:"phone,omitempty"`
	IsActive bool            `json:"is_active"`
}

type UpdateUserRequest struct {
	Username string          `json:"username" binding:"required"`
	Email    string          `json:"email" binding:"required,email"`
	Role     domain.UserRole `json:"role" binding:"required,oneof=admin kasir mekanik"`
	FullName string          `json:"full_name" binding:"required"`
	Phone    *string         `json:"phone,omitempty"`
	IsActive bool            `json:"is_active"`
}

type ChangeUserPasswordRequest struct {
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

type UserResponse struct {
	ID        int             `json:"id"`
	Username  string          `json:"username"`
	Email     string          `json:"email"`
	Role      domain.UserRole `json:"role"`
	FullName  string          `json:"full_name"`
	Phone     *string         `json:"phone,omitempty"`
	IsActive  bool            `json:"is_active"`
	CreatedAt string          `json:"created_at"`
	UpdatedAt string          `json:"updated_at"`
}

type ListUsersResponse struct {
	Data       []UserResponse     `json:"data"`
	Pagination PaginationResponse `json:"pagination"`
}

// CreateUser creates a new user (admin only)
func (h *AdminHandler) CreateUser(c *gin.Context) {
	var req CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	user := &domain.User{
		Username: req.Username,
		Email:    req.Email,
		Role:     req.Role,
		FullName: req.FullName,
		Phone:    req.Phone,
		IsActive: req.IsActive,
	}

	if err := h.userService.CreateUser(c.Request.Context(), user, req.Password); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create user",
			"message": err.Error(),
		})
		return
	}

	response := h.toUserResponse(user)

	c.JSON(http.StatusCreated, gin.H{
		"message": "User created successfully",
		"data":    response,
	})
}

// GetUser gets a user by ID (admin only)
func (h *AdminHandler) GetUser(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid user ID",
			"message": "User ID must be a number",
		})
		return
	}

	user, err := h.userService.GetUserByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "User not found",
			"message": err.Error(),
		})
		return
	}

	response := h.toUserResponse(user)

	c.JSON(http.StatusOK, gin.H{
		"message": "User retrieved successfully",
		"data":    response,
	})
}

// ListUsers lists users with pagination (admin only)
func (h *AdminHandler) ListUsers(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	role := c.Query("role")

	var users []*domain.User
	var total int
	var err error

	if role != "" {
		userRole := domain.UserRole(role)
		users, err = h.userService.GetUsersByRole(c.Request.Context(), userRole)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   "Failed to list users by role",
				"message": err.Error(),
			})
			return
		}
		total = len(users)
	} else {
		users, total, err = h.userService.ListUsers(c.Request.Context(), page, limit)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   "Failed to list users",
				"message": err.Error(),
			})
			return
		}
	}

	// Convert to response format
	var userResponses []UserResponse
	for _, user := range users {
		userResponses = append(userResponses, h.toUserResponse(user))
	}

	// Calculate pagination
	totalPages := (total + limit - 1) / limit
	pagination := PaginationResponse{
		Page:       page,
		Limit:      limit,
		Total:      total,
		TotalPages: totalPages,
		HasNext:    page < totalPages,
		HasPrev:    page > 1,
	}

	response := ListUsersResponse{
		Data:       userResponses,
		Pagination: pagination,
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Users retrieved successfully",
		"data":       response.Data,
		"pagination": response.Pagination,
	})
}

// UpdateUser updates a user (admin only)
func (h *AdminHandler) UpdateUser(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid user ID",
			"message": "User ID must be a number",
		})
		return
	}

	var req UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	user := &domain.User{
		Username: req.Username,
		Email:    req.Email,
		Role:     req.Role,
		FullName: req.FullName,
		Phone:    req.Phone,
		IsActive: req.IsActive,
	}
	user.ID = id

	if err := h.userService.UpdateUser(c.Request.Context(), user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to update user",
			"message": err.Error(),
		})
		return
	}

	response := h.toUserResponse(user)

	c.JSON(http.StatusOK, gin.H{
		"message": "User updated successfully",
		"data":    response,
	})
}

// ChangeUserPassword changes a user's password (admin only)
func (h *AdminHandler) ChangeUserPassword(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid user ID",
			"message": "User ID must be a number",
		})
		return
	}

	var req ChangeUserPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	// For admin changing user password, we use empty old password
	if err := h.userService.ChangePassword(c.Request.Context(), id, "", req.NewPassword); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to change user password",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User password changed successfully",
	})
}

// ActivateUser activates or deactivates a user (admin only)
func (h *AdminHandler) ActivateUser(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid user ID",
			"message": "User ID must be a number",
		})
		return
	}

	var req struct {
		IsActive bool `json:"is_active"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	if err := h.userService.ActivateUser(c.Request.Context(), id, req.IsActive); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to update user status",
			"message": err.Error(),
		})
		return
	}

	status := "deactivated"
	if req.IsActive {
		status = "activated"
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User " + status + " successfully",
	})
}

// DeleteUser deletes a user (admin only)
func (h *AdminHandler) DeleteUser(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid user ID",
			"message": "User ID must be a number",
		})
		return
	}

	// Get current user ID from JWT token
	currentUserID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "Unauthorized",
			"message": "User ID not found in token",
		})
		return
	}

	currentUserIDInt, ok := currentUserID.(int)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Invalid user ID",
			"message": "User ID is not a valid integer",
		})
		return
	}

	// Prevent admin from deleting themselves
	if id == currentUserIDInt {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Cannot delete your own account",
			"message": "Use another admin account to delete this user",
		})
		return
	}

	if err := h.userService.DeleteUser(c.Request.Context(), id, currentUserIDInt); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to delete user",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User deleted successfully",
	})
}

// toUserResponse converts domain.User to UserResponse
func (h *AdminHandler) toUserResponse(user *domain.User) UserResponse {
	return UserResponse{
		ID:        user.ID,
		Username:  user.Username,
		Email:     user.Email,
		Role:      user.Role,
		FullName:  user.FullName,
		Phone:     user.Phone,
		IsActive:  user.IsActive,
		CreatedAt: user.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		UpdatedAt: user.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}