package handler

import (
	"net/http"
	"pos-final/internal/domain"
	"pos-final/internal/service"
	"strconv"

	"github.com/gin-gonic/gin"
)

type CustomerHandler struct {
	customerService service.CustomerService
}

// NewCustomerHandler creates a new customer handler
func NewCustomerHandler(customerService service.CustomerService) *CustomerHandler {
	return &CustomerHandler{
		customerService: customerService,
	}
}

type CreateCustomerRequest struct {
	Name      string  `json:"name" binding:"required"`
	KTPNumber *string `json:"ktp_number,omitempty"`
	Phone     *string `json:"phone,omitempty"`
	Email     *string `json:"email,omitempty"`
	Address   *string `json:"address,omitempty"`
}

type UpdateCustomerRequest struct {
	Name      string  `json:"name" binding:"required"`
	KTPNumber *string `json:"ktp_number,omitempty"`
	Phone     *string `json:"phone,omitempty"`
	Email     *string `json:"email,omitempty"`
	Address   *string `json:"address,omitempty"`
}

type CustomerResponse struct {
	ID           int     `json:"id"`
	CustomerCode string  `json:"customer_code"`
	Name         string  `json:"name"`
	KTPNumber    *string `json:"ktp_number,omitempty"`
	Phone        *string `json:"phone,omitempty"`
	Email        *string `json:"email,omitempty"`
	Address      *string `json:"address,omitempty"`
	CreatedAt    string  `json:"created_at"`
	UpdatedAt    string  `json:"updated_at"`
}

type ListCustomersResponse struct {
	Data       []CustomerResponse `json:"data"`
	Pagination PaginationResponse `json:"pagination"`
}

// CreateCustomer creates a new customer
func (h *CustomerHandler) CreateCustomer(c *gin.Context) {
	var req CreateCustomerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	customer := &domain.Customer{
		Name:      req.Name,
		KTPNumber: req.KTPNumber,
		Phone:     req.Phone,
		Email:     req.Email,
		Address:   req.Address,
	}

	if err := h.customerService.CreateCustomer(c.Request.Context(), customer); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create customer",
			"message": err.Error(),
		})
		return
	}

	response := CustomerResponse{
		ID:           customer.ID,
		CustomerCode: customer.CustomerCode,
		Name:         customer.Name,
		KTPNumber:    customer.KTPNumber,
		Phone:        customer.Phone,
		Email:        customer.Email,
		Address:      customer.Address,
		CreatedAt:    customer.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		UpdatedAt:    customer.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Customer created successfully",
		"data":    response,
	})
}

// GetCustomer gets a customer by ID
func (h *CustomerHandler) GetCustomer(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid customer ID",
			"message": "Customer ID must be a number",
		})
		return
	}

	customer, err := h.customerService.GetCustomerByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Customer not found",
			"message": err.Error(),
		})
		return
	}

	response := CustomerResponse{
		ID:           customer.ID,
		CustomerCode: customer.CustomerCode,
		Name:         customer.Name,
		KTPNumber:    customer.KTPNumber,
		Phone:        customer.Phone,
		Email:        customer.Email,
		Address:      customer.Address,
		CreatedAt:    customer.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		UpdatedAt:    customer.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Customer retrieved successfully",
		"data":    response,
	})
}

// ListCustomers lists customers with pagination
func (h *CustomerHandler) ListCustomers(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	search := c.Query("search")

	var customers []*domain.Customer
	var total int
	var err error

	if search != "" {
		customers, total, err = h.customerService.SearchCustomers(c.Request.Context(), search, page, limit)
	} else {
		customers, total, err = h.customerService.ListCustomers(c.Request.Context(), page, limit)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to list customers",
			"message": err.Error(),
		})
		return
	}

	// Convert to response format
	var customerResponses []CustomerResponse
	for _, customer := range customers {
		customerResponses = append(customerResponses, CustomerResponse{
			ID:           customer.ID,
			CustomerCode: customer.CustomerCode,
			Name:         customer.Name,
			KTPNumber:    customer.KTPNumber,
			Phone:        customer.Phone,
			Email:        customer.Email,
			Address:      customer.Address,
			CreatedAt:    customer.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			UpdatedAt:    customer.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
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

	response := ListCustomersResponse{
		Data:       customerResponses,
		Pagination: pagination,
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Customers retrieved successfully",
		"data":    response.Data,
		"pagination": response.Pagination,
	})
}

// UpdateCustomer updates a customer
func (h *CustomerHandler) UpdateCustomer(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid customer ID",
			"message": "Customer ID must be a number",
		})
		return
	}

	var req UpdateCustomerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	customer := &domain.Customer{
		Name:      req.Name,
		KTPNumber: req.KTPNumber,
		Phone:     req.Phone,
		Email:     req.Email,
		Address:   req.Address,
	}
	customer.ID = id

	if err := h.customerService.UpdateCustomer(c.Request.Context(), customer); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to update customer",
			"message": err.Error(),
		})
		return
	}

	response := CustomerResponse{
		ID:           customer.ID,
		CustomerCode: customer.CustomerCode,
		Name:         customer.Name,
		KTPNumber:    customer.KTPNumber,
		Phone:        customer.Phone,
		Email:        customer.Email,
		Address:      customer.Address,
		CreatedAt:    customer.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		UpdatedAt:    customer.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Customer updated successfully",
		"data":    response,
	})
}

// DeleteCustomer deletes a customer
func (h *CustomerHandler) DeleteCustomer(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid customer ID",
			"message": "Customer ID must be a number",
		})
		return
	}

	// Get user ID from JWT token
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "Unauthorized",
			"message": "User ID not found in token",
		})
		return
	}

	userIDInt, ok := userID.(int)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Invalid user ID",
			"message": "User ID is not a valid integer",
		})
		return
	}

	if err := h.customerService.DeleteCustomer(c.Request.Context(), id, userIDInt); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to delete customer",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Customer deleted successfully",
	})
}