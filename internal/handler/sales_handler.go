package handler

import (
	"log"
	"net/http"
	"pos-final/internal/domain"
	"pos-final/internal/service"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type SalesHandler struct {
	salesService service.SalesService
}

// NewSalesHandler creates a new sales handler
func NewSalesHandler(salesService service.SalesService) *SalesHandler {
	return &SalesHandler{
		salesService: salesService,
	}
}

type CreateSalesRequest struct {
	CustomerID         int     `json:"customer_id" binding:"required"`
	VehicleID          int     `json:"vehicle_id" binding:"required"`
	SellingPrice       float64 `json:"selling_price" binding:"required,min=0"`
	DiscountPercentage float64 `json:"discount_percentage" binding:"min=0,max=100"`
	PaymentMethod      string  `json:"payment_method" binding:"required,oneof=cash transfer"`
	Notes              *string `json:"notes"`
	TransactionDate    *string `json:"transaction_date"`
}

func (h *SalesHandler) CreateSalesInvoice(c *gin.Context) {
	var req CreateSalesRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	// Get user from context (set by JWT middleware)
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found in context"})
		return
	}

	// Parse transaction date
	var transactionDate time.Time
	if req.TransactionDate != nil {
		var err error
		transactionDate, err = time.Parse("2006-01-02", *req.TransactionDate)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Invalid transaction date format, use YYYY-MM-DD",
			})
			return
		}
	} else {
		transactionDate = time.Now()
	}

	// Create invoice
	invoice := &domain.SalesInvoice{
		CustomerID:         req.CustomerID,
		VehicleID:          req.VehicleID,
		SellingPrice:       req.SellingPrice,
		DiscountPercentage: req.DiscountPercentage,
		PaymentMethod:      domain.PaymentMethod(req.PaymentMethod),
		Notes:              req.Notes,
		CreatedBy:          userID.(int),
		TransactionDate:    transactionDate,
	}

	if err := h.salesService.CreateSalesInvoice(c.Request.Context(), invoice); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create sales invoice",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Sales invoice created successfully",
		"data":    invoice,
	})
}

func (h *SalesHandler) GetSalesInvoice(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid invoice ID"})
		return
	}

	invoice, err := h.salesService.GetSalesInvoiceByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Sales invoice not found",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Sales invoice retrieved successfully",
		"data":    invoice,
	})
}

func (h *SalesHandler) ListSalesInvoices(c *gin.Context) {
	log.Printf("=== Sales Handler: ListSalesInvoices Request ===")
	log.Printf("Request Method: %s", c.Request.Method)
	log.Printf("Request URL: %s", c.Request.URL.String())
	log.Printf("Request Headers: %v", c.Request.Header)
	log.Printf("Client IP: %s", c.ClientIP())
	log.Printf("User Agent: %s", c.Request.UserAgent())
	
	// Parse query parameters
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	customerIDStr := c.Query("customer_id")

	log.Printf("Query Parameters:")
	log.Printf("  page: %d (raw: %s)", page, c.DefaultQuery("page", "1"))
	log.Printf("  limit: %d (raw: %s)", limit, c.DefaultQuery("limit", "10"))
	log.Printf("  customer_id: %s", customerIDStr)

	if page < 1 {
		log.Printf("Invalid page number %d, setting to 1", page)
		page = 1
	}
	if limit < 1 || limit > 100 {
		log.Printf("Invalid limit %d, setting to 10", limit)
		limit = 10
	}

	log.Printf("Final parameters: page=%d, limit=%d", page, limit)

	// Check user context
	userID, exists := c.Get("user_id")
	if !exists {
		log.Printf("ERROR: User ID not found in context")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found in context"})
		return
	}
	
	userRole, _ := c.Get("role")
	log.Printf("Request made by User ID: %v, Role: %v", userID, userRole)

	var invoices []*domain.SalesInvoice
	var total int
	var err error

	log.Printf("Calling sales service...")

	if customerIDStr != "" {
		customerID, err := strconv.Atoi(customerIDStr)
		if err != nil {
			log.Printf("ERROR: Invalid customer ID format: %s, error: %v", customerIDStr, err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid customer ID"})
			return
		}
		log.Printf("Fetching sales invoices for customer ID: %d", customerID)
		invoices, total, err = h.salesService.ListSalesInvoicesByCustomer(c.Request.Context(), customerID, page, limit)
	} else {
		log.Printf("Fetching all sales invoices")
		invoices, total, err = h.salesService.ListSalesInvoices(c.Request.Context(), page, limit)
	}

	if err != nil {
		log.Printf("ERROR: Sales service error: %v", err)
		log.Printf("ERROR: Error type: %T", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to retrieve sales invoices",
			"details": err.Error(),
		})
		return
	}

	log.Printf("Sales service response:")
	log.Printf("  Invoices count: %d", len(invoices))
	log.Printf("  Total count: %d", total)
	
	if len(invoices) > 0 {
		log.Printf("  First invoice ID: %d, Number: %s", invoices[0].ID, invoices[0].InvoiceNumber)
		log.Printf("  Last invoice ID: %d, Number: %s", invoices[len(invoices)-1].ID, invoices[len(invoices)-1].InvoiceNumber)
	}

	responseData := gin.H{
		"message": "Sales invoices retrieved successfully",
		"data":    invoices,
		"pagination": gin.H{
			"page":        page,
			"limit":       limit,
			"total":       total,
			"total_pages": (total + limit - 1) / limit,
			"has_next":    (page * limit) < total,
			"has_prev":    page > 1,
		},
	}

	log.Printf("Sending successful response with %d invoices", len(invoices))
	c.JSON(http.StatusOK, responseData)
	log.Printf("=== End Sales Handler: ListSalesInvoices ===")
}

func (h *SalesHandler) GetDailySalesReport(c *gin.Context) {
	// Parse date parameter
	dateStr := c.DefaultQuery("date", time.Now().Format("2006-01-02"))
	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid date format, use YYYY-MM-DD",
		})
		return
	}

	totalAmount, totalProfit, count, err := h.salesService.GetDailySalesReport(c.Request.Context(), date)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to get daily sales report",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Daily sales report retrieved successfully",
		"data": gin.H{
			"date":         date.Format("2006-01-02"),
			"total_amount": totalAmount,
			"total_profit": totalProfit,
			"total_count":  count,
		},
	})
}

func (h *SalesHandler) UpdateSalesInvoice(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid invoice ID"})
		return
	}

	// Get existing invoice
	invoice, err := h.salesService.GetSalesInvoiceByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Sales invoice not found",
			"details": err.Error(),
		})
		return
	}

	var req CreateSalesRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	// Update invoice fields
	invoice.CustomerID = req.CustomerID
	invoice.SellingPrice = req.SellingPrice
	invoice.DiscountPercentage = req.DiscountPercentage
	invoice.PaymentMethod = domain.PaymentMethod(req.PaymentMethod)
	invoice.Notes = req.Notes

	if req.TransactionDate != nil {
		transactionDate, err := time.Parse("2006-01-02", *req.TransactionDate)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Invalid transaction date format, use YYYY-MM-DD",
			})
			return
		}
		invoice.TransactionDate = transactionDate
	}

	if err := h.salesService.UpdateSalesInvoice(c.Request.Context(), invoice); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to update sales invoice",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Sales invoice updated successfully",
		"data":    invoice,
	})
}

func (h *SalesHandler) DeleteSalesInvoice(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid invoice ID"})
		return
	}

	// Get user from context
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found in context"})
		return
	}

	if err := h.salesService.DeleteSalesInvoice(c.Request.Context(), id, userID.(int)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to delete sales invoice",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Sales invoice deleted successfully",
	})
}