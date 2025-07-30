package handler

import (
	"net/http"
	"pos-final/internal/domain"
	"pos-final/internal/service"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type PurchaseHandler struct {
	purchaseService service.PurchaseService
}

// NewPurchaseHandler creates a new purchase handler
func NewPurchaseHandler(purchaseService service.PurchaseService) *PurchaseHandler {
	return &PurchaseHandler{
		purchaseService: purchaseService,
	}
}

type CreatePurchaseRequest struct {
	TransactionType   string   `json:"transaction_type" binding:"required,oneof=customer supplier"`
	CustomerID        *int     `json:"customer_id"`
	SupplierID        *int     `json:"supplier_id"`
	VehicleID         int      `json:"vehicle_id" binding:"required"`
	PurchasePrice     float64  `json:"purchase_price" binding:"required,min=0"`
	NegotiatedPrice   *float64 `json:"negotiated_price"`
	PaymentMethod     string   `json:"payment_method" binding:"required,oneof=cash transfer"`
	Notes             *string  `json:"notes"`
	TransactionDate   *string  `json:"transaction_date"`
}

func (h *PurchaseHandler) CreatePurchaseInvoice(c *gin.Context) {
	var req CreatePurchaseRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	// Validate transaction type and corresponding ID
	transactionType := domain.TransactionType(req.TransactionType)
	if transactionType == domain.TransactionTypeCustomer && req.CustomerID == nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "customer_id is required for customer transactions",
		})
		return
	}
	if transactionType == domain.TransactionTypeSupplier && req.SupplierID == nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "supplier_id is required for supplier transactions",
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
	invoice := &domain.PurchaseInvoice{
		TransactionType: transactionType,
		CustomerID:      req.CustomerID,
		SupplierID:      req.SupplierID,
		VehicleID:       req.VehicleID,
		PurchasePrice:   req.PurchasePrice,
		NegotiatedPrice: req.NegotiatedPrice,
		PaymentMethod:   domain.PaymentMethod(req.PaymentMethod),
		Notes:           req.Notes,
		CreatedBy:       userID.(int),
		TransactionDate: transactionDate,
	}

	if err := h.purchaseService.CreatePurchaseInvoice(c.Request.Context(), invoice); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create purchase invoice",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Purchase invoice created successfully",
		"data":    invoice,
	})
}

func (h *PurchaseHandler) GetPurchaseInvoice(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid invoice ID"})
		return
	}

	invoice, err := h.purchaseService.GetPurchaseInvoiceByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Purchase invoice not found",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Purchase invoice retrieved successfully",
		"data":    invoice,
	})
}

func (h *PurchaseHandler) ListPurchaseInvoices(c *gin.Context) {
	// Parse query parameters
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	invoices, total, err := h.purchaseService.ListPurchaseInvoices(c.Request.Context(), page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to retrieve purchase invoices",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Purchase invoices retrieved successfully",
		"data":    invoices,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
		},
	})
}

func (h *PurchaseHandler) GetDailyPurchaseReport(c *gin.Context) {
	// Parse date parameter
	dateStr := c.DefaultQuery("date", time.Now().Format("2006-01-02"))
	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid date format, use YYYY-MM-DD",
		})
		return
	}

	totalAmount, count, err := h.purchaseService.GetDailyPurchaseReport(c.Request.Context(), date)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to get daily purchase report",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Daily purchase report retrieved successfully",
		"data": gin.H{
			"date":         date.Format("2006-01-02"),
			"total_amount": totalAmount,
			"total_count":  count,
		},
	})
}