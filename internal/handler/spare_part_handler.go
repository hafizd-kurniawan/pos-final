package handler

import (
	"net/http"
	"pos-final/internal/domain"
	"pos-final/internal/service"
	"strconv"

	"github.com/gin-gonic/gin"
)

type SparePartHandler struct {
	sparePartService service.SparePartService
}

// NewSparePartHandler creates a new spare part handler
func NewSparePartHandler(sparePartService service.SparePartService) *SparePartHandler {
	return &SparePartHandler{
		sparePartService: sparePartService,
	}
}

type CreateSparePartRequest struct {
	Barcode       *string `json:"barcode,omitempty"`
	Name          string  `json:"name" binding:"required"`
	Brand         *string `json:"brand,omitempty"`
	Category      *string `json:"category,omitempty"`
	Description   *string `json:"description,omitempty"`
	CostPrice     float64 `json:"cost_price" binding:"required"`
	SellingPrice  float64 `json:"selling_price" binding:"required"`
	StockQuantity int     `json:"stock_quantity"`
	MinStockLevel int     `json:"min_stock_level"`
	Unit          string  `json:"unit,omitempty"`
}

type UpdateSparePartRequest struct {
	Barcode       *string `json:"barcode,omitempty"`
	Name          string  `json:"name" binding:"required"`
	Brand         *string `json:"brand,omitempty"`
	Category      *string `json:"category,omitempty"`
	Description   *string `json:"description,omitempty"`
	CostPrice     float64 `json:"cost_price" binding:"required"`
	SellingPrice  float64 `json:"selling_price" binding:"required"`
	StockQuantity int     `json:"stock_quantity"`
	MinStockLevel int     `json:"min_stock_level"`
	Unit          string  `json:"unit,omitempty"`
}

type AdjustStockRequest struct {
	Adjustment int    `json:"adjustment" binding:"required"`
	Notes      string `json:"notes,omitempty"`
}

type SparePartResponse struct {
	ID            int     `json:"id"`
	PartCode      string  `json:"part_code"`
	Barcode       *string `json:"barcode,omitempty"`
	Name          string  `json:"name"`
	Brand         *string `json:"brand,omitempty"`
	Category      *string `json:"category,omitempty"`
	Description   *string `json:"description,omitempty"`
	CostPrice     float64 `json:"cost_price"`
	SellingPrice  float64 `json:"selling_price"`
	StockQuantity int     `json:"stock_quantity"`
	MinStockLevel int     `json:"min_stock_level"`
	Unit          string  `json:"unit,omitempty"`
	IsLowStock    bool    `json:"is_low_stock"`
	CreatedAt     string  `json:"created_at"`
	UpdatedAt     string  `json:"updated_at"`
}

type ListSparePartsResponse struct {
	Data       []SparePartResponse `json:"data"`
	Pagination PaginationResponse  `json:"pagination"`
}

// CreateSparePart creates a new spare part
func (h *SparePartHandler) CreateSparePart(c *gin.Context) {
	var req CreateSparePartRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	sparePart := &domain.SparePart{
		Barcode:       req.Barcode,
		Name:          req.Name,
		Brand:         req.Brand,
		Category:      req.Category,
		Description:   req.Description,
		CostPrice:     req.CostPrice,
		SellingPrice:  req.SellingPrice,
		StockQuantity: req.StockQuantity,
		MinStockLevel: req.MinStockLevel,
		Unit:          req.Unit,
	}

	if err := h.sparePartService.CreateSparePart(c.Request.Context(), sparePart); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create spare part",
			"message": err.Error(),
		})
		return
	}

	response := h.toSparePartResponse(sparePart)

	c.JSON(http.StatusCreated, gin.H{
		"message": "Spare part created successfully",
		"data":    response,
	})
}

// GetSparePart gets a spare part by ID
func (h *SparePartHandler) GetSparePart(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid spare part ID",
			"message": "Spare part ID must be a number",
		})
		return
	}

	sparePart, err := h.sparePartService.GetSparePartByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Spare part not found",
			"message": err.Error(),
		})
		return
	}

	response := h.toSparePartResponse(sparePart)

	c.JSON(http.StatusOK, gin.H{
		"message": "Spare part retrieved successfully",
		"data":    response,
	})
}

// GetSparePartByCode gets a spare part by part code
func (h *SparePartHandler) GetSparePartByCode(c *gin.Context) {
	partCode := c.Param("code")
	if partCode == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid part code",
			"message": "Part code is required",
		})
		return
	}

	sparePart, err := h.sparePartService.GetSparePartByCode(c.Request.Context(), partCode)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Spare part not found",
			"message": err.Error(),
		})
		return
	}

	response := h.toSparePartResponse(sparePart)

	c.JSON(http.StatusOK, gin.H{
		"message": "Spare part retrieved successfully",
		"data":    response,
	})
}

// GetSparePartByBarcode gets a spare part by barcode
func (h *SparePartHandler) GetSparePartByBarcode(c *gin.Context) {
	barcode := c.Param("barcode")
	if barcode == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid barcode",
			"message": "Barcode is required",
		})
		return
	}

	sparePart, err := h.sparePartService.GetSparePartByBarcode(c.Request.Context(), barcode)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Spare part not found",
			"message": err.Error(),
		})
		return
	}

	response := h.toSparePartResponse(sparePart)

	c.JSON(http.StatusOK, gin.H{
		"message": "Spare part retrieved successfully",
		"data":    response,
	})
}

// ListSpareParts lists spare parts with pagination and filtering
func (h *SparePartHandler) ListSpareParts(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	search := c.Query("search")
	lowStock := c.Query("low_stock")

	var spareParts []*domain.SparePart
	var total int
	var err error

	if lowStock == "true" {
		spareParts, total, err = h.sparePartService.ListLowStockParts(c.Request.Context(), page, limit)
	} else if search != "" {
		spareParts, total, err = h.sparePartService.SearchSpareParts(c.Request.Context(), search, page, limit)
	} else {
		spareParts, total, err = h.sparePartService.ListSpareParts(c.Request.Context(), page, limit)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to list spare parts",
			"message": err.Error(),
		})
		return
	}

	// Convert to response format
	var sparePartResponses []SparePartResponse
	for _, sparePart := range spareParts {
		sparePartResponses = append(sparePartResponses, h.toSparePartResponse(sparePart))
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

	response := ListSparePartsResponse{
		Data:       sparePartResponses,
		Pagination: pagination,
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Spare parts retrieved successfully",
		"data":       response.Data,
		"pagination": response.Pagination,
	})
}

// CheckLowStock returns all spare parts with low stock
func (h *SparePartHandler) CheckLowStock(c *gin.Context) {
	spareParts, err := h.sparePartService.CheckLowStock(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to check low stock",
			"message": err.Error(),
		})
		return
	}

	// Convert to response format
	var sparePartResponses []SparePartResponse
	for _, sparePart := range spareParts {
		sparePartResponses = append(sparePartResponses, h.toSparePartResponse(sparePart))
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Low stock parts retrieved successfully",
		"data":    sparePartResponses,
		"count":   len(sparePartResponses),
	})
}

// UpdateSparePart updates a spare part
func (h *SparePartHandler) UpdateSparePart(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid spare part ID",
			"message": "Spare part ID must be a number",
		})
		return
	}

	var req UpdateSparePartRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	sparePart := &domain.SparePart{
		Barcode:       req.Barcode,
		Name:          req.Name,
		Brand:         req.Brand,
		Category:      req.Category,
		Description:   req.Description,
		CostPrice:     req.CostPrice,
		SellingPrice:  req.SellingPrice,
		StockQuantity: req.StockQuantity,
		MinStockLevel: req.MinStockLevel,
		Unit:          req.Unit,
	}
	sparePart.ID = id

	if err := h.sparePartService.UpdateSparePart(c.Request.Context(), sparePart); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to update spare part",
			"message": err.Error(),
		})
		return
	}

	response := h.toSparePartResponse(sparePart)

	c.JSON(http.StatusOK, gin.H{
		"message": "Spare part updated successfully",
		"data":    response,
	})
}

// AdjustStock adjusts spare part stock
func (h *SparePartHandler) AdjustStock(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid spare part ID",
			"message": "Spare part ID must be a number",
		})
		return
	}

	var req AdjustStockRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
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

	if err := h.sparePartService.AdjustStock(c.Request.Context(), id, req.Adjustment, req.Notes, userIDInt); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to adjust stock",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Stock adjusted successfully",
	})
}

// DeleteSparePart deletes a spare part
func (h *SparePartHandler) DeleteSparePart(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid spare part ID",
			"message": "Spare part ID must be a number",
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

	if err := h.sparePartService.DeleteSparePart(c.Request.Context(), id, userIDInt); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to delete spare part",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Spare part deleted successfully",
	})
}

// toSparePartResponse converts domain.SparePart to SparePartResponse
func (h *SparePartHandler) toSparePartResponse(sparePart *domain.SparePart) SparePartResponse {
	isLowStock := sparePart.StockQuantity <= sparePart.MinStockLevel

	return SparePartResponse{
		ID:            sparePart.ID,
		PartCode:      sparePart.PartCode,
		Barcode:       sparePart.Barcode,
		Name:          sparePart.Name,
		Brand:         sparePart.Brand,
		Category:      sparePart.Category,
		Description:   sparePart.Description,
		CostPrice:     sparePart.CostPrice,
		SellingPrice:  sparePart.SellingPrice,
		StockQuantity: sparePart.StockQuantity,
		MinStockLevel: sparePart.MinStockLevel,
		Unit:          sparePart.Unit,
		IsLowStock:    isLowStock,
		CreatedAt:     sparePart.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		UpdatedAt:     sparePart.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}