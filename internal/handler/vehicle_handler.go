package handler

import (
	"net/http"
	"pos-final/internal/domain"
	"pos-final/internal/service"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type VehicleHandler struct {
	vehicleService service.VehicleService
}

// NewVehicleHandler creates a new vehicle handler
func NewVehicleHandler(vehicleService service.VehicleService) *VehicleHandler {
	return &VehicleHandler{
		vehicleService: vehicleService,
	}
}

type CreateVehicleRequest struct {
	CategoryID      int                     `json:"category_id" binding:"required"`
	Brand           string                  `json:"brand" binding:"required"`
	Model           string                  `json:"model" binding:"required"`
	Year            int                     `json:"year" binding:"required"`
	ChassisNumber   *string                 `json:"chassis_number,omitempty"`
	EngineNumber    *string                 `json:"engine_number,omitempty"`
	PlateNumber     *string                 `json:"plate_number,omitempty"`
	Color           *string                 `json:"color,omitempty"`
	FuelType        *string                 `json:"fuel_type,omitempty"`
	Transmission    *string                 `json:"transmission,omitempty"`
	PurchasePrice   *float64                `json:"purchase_price,omitempty"`
	RepairCost      float64                 `json:"repair_cost"`
	SellingPrice    *float64                `json:"selling_price,omitempty"`
	Status          domain.VehicleStatus    `json:"status,omitempty"`
	ConditionNotes  *string                 `json:"condition_notes,omitempty"`
	PurchasedDate   *time.Time              `json:"purchased_date,omitempty"`
}

type UpdateVehicleRequest struct {
	CategoryID      int                     `json:"category_id" binding:"required"`
	Brand           string                  `json:"brand" binding:"required"`
	Model           string                  `json:"model" binding:"required"`
	Year            int                     `json:"year" binding:"required"`
	ChassisNumber   *string                 `json:"chassis_number,omitempty"`
	EngineNumber    *string                 `json:"engine_number,omitempty"`
	PlateNumber     *string                 `json:"plate_number,omitempty"`
	Color           *string                 `json:"color,omitempty"`
	FuelType        *string                 `json:"fuel_type,omitempty"`
	Transmission    *string                 `json:"transmission,omitempty"`
	PurchasePrice   *float64                `json:"purchase_price,omitempty"`
	RepairCost      float64                 `json:"repair_cost"`
	SellingPrice    *float64                `json:"selling_price,omitempty"`
	ConditionNotes  *string                 `json:"condition_notes,omitempty"`
}

type UpdateVehicleStatusRequest struct {
	Status domain.VehicleStatus `json:"status" binding:"required"`
}

type VehicleResponse struct {
	ID              int                     `json:"id"`
	VehicleCode     string                  `json:"vehicle_code"`
	CategoryID      int                     `json:"category_id"`
	Category        *CategoryResponse       `json:"category,omitempty"`
	Brand           string                  `json:"brand"`
	Model           string                  `json:"model"`
	Year            int                     `json:"year"`
	ChassisNumber   *string                 `json:"chassis_number,omitempty"`
	EngineNumber    *string                 `json:"engine_number,omitempty"`
	PlateNumber     *string                 `json:"plate_number,omitempty"`
	Color           *string                 `json:"color,omitempty"`
	FuelType        *string                 `json:"fuel_type,omitempty"`
	Transmission    *string                 `json:"transmission,omitempty"`
	PurchasePrice   *float64                `json:"purchase_price,omitempty"`
	RepairCost      float64                 `json:"repair_cost"`
	HPP             *float64                `json:"hpp,omitempty"`
	SellingPrice    *float64                `json:"selling_price,omitempty"`
	Status          domain.VehicleStatus    `json:"status"`
	ConditionNotes  *string                 `json:"condition_notes,omitempty"`
	PrimaryPhoto    *string                 `json:"primary_photo,omitempty"`
	PurchasedDate   *time.Time              `json:"purchased_date,omitempty"`
	SoldDate        *time.Time              `json:"sold_date,omitempty"`
	CreatedAt       string                  `json:"created_at"`
	UpdatedAt       string                  `json:"updated_at"`
}

type CategoryResponse struct {
	ID          int     `json:"id"`
	Name        string  `json:"name"`
	Description *string `json:"description,omitempty"`
}

type ListVehiclesResponse struct {
	Data       []VehicleResponse  `json:"data"`
	Pagination PaginationResponse `json:"pagination"`
}

// CreateVehicle creates a new vehicle
func (h *VehicleHandler) CreateVehicle(c *gin.Context) {
	var req CreateVehicleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	vehicle := &domain.Vehicle{
		CategoryID:      req.CategoryID,
		Brand:           req.Brand,
		Model:           req.Model,
		Year:            req.Year,
		ChassisNumber:   req.ChassisNumber,
		EngineNumber:    req.EngineNumber,
		PlateNumber:     req.PlateNumber,
		Color:           req.Color,
		FuelType:        req.FuelType,
		Transmission:    req.Transmission,
		PurchasePrice:   req.PurchasePrice,
		RepairCost:      req.RepairCost,
		SellingPrice:    req.SellingPrice,
		Status:          req.Status,
		ConditionNotes:  req.ConditionNotes,
		PurchasedDate:   req.PurchasedDate,
	}

	if err := h.vehicleService.CreateVehicle(c.Request.Context(), vehicle); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create vehicle",
			"message": err.Error(),
		})
		return
	}

	response := h.toVehicleResponse(vehicle)

	c.JSON(http.StatusCreated, gin.H{
		"message": "Vehicle created successfully",
		"data":    response,
	})
}

// GetVehicle gets a vehicle by ID
func (h *VehicleHandler) GetVehicle(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid vehicle ID",
			"message": "Vehicle ID must be a number",
		})
		return
	}

	vehicle, err := h.vehicleService.GetVehicleByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Vehicle not found",
			"message": err.Error(),
		})
		return
	}

	response := h.toVehicleResponse(vehicle)

	c.JSON(http.StatusOK, gin.H{
		"message": "Vehicle retrieved successfully",
		"data":    response,
	})
}

// ListVehicles lists vehicles with pagination and filtering
func (h *VehicleHandler) ListVehicles(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	search := c.Query("search")
	status := c.Query("status")
	categoryIDStr := c.Query("category_id")

	var vehicles []*domain.Vehicle
	var total int
	var err error

	if search != "" {
		vehicles, total, err = h.vehicleService.SearchVehicles(c.Request.Context(), search, page, limit)
	} else if status != "" {
		vehicleStatus := domain.VehicleStatus(status)
		vehicles, total, err = h.vehicleService.ListVehiclesByStatus(c.Request.Context(), vehicleStatus, page, limit)
	} else if categoryIDStr != "" {
		categoryID, parseErr := strconv.Atoi(categoryIDStr)
		if parseErr != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error":   "Invalid category ID",
				"message": "Category ID must be a number",
			})
			return
		}
		vehicles, total, err = h.vehicleService.ListVehiclesByCategory(c.Request.Context(), categoryID, page, limit)
	} else {
		vehicles, total, err = h.vehicleService.ListVehicles(c.Request.Context(), page, limit)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to list vehicles",
			"message": err.Error(),
		})
		return
	}

	// Convert to response format
	var vehicleResponses []VehicleResponse
	for _, vehicle := range vehicles {
		vehicleResponses = append(vehicleResponses, h.toVehicleResponse(vehicle))
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

	response := ListVehiclesResponse{
		Data:       vehicleResponses,
		Pagination: pagination,
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Vehicles retrieved successfully",
		"data":       response.Data,
		"pagination": response.Pagination,
	})
}

// UpdateVehicle updates a vehicle
func (h *VehicleHandler) UpdateVehicle(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid vehicle ID",
			"message": "Vehicle ID must be a number",
		})
		return
	}

	var req UpdateVehicleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	vehicle := &domain.Vehicle{
		CategoryID:     req.CategoryID,
		Brand:          req.Brand,
		Model:          req.Model,
		Year:           req.Year,
		ChassisNumber:  req.ChassisNumber,
		EngineNumber:   req.EngineNumber,
		PlateNumber:    req.PlateNumber,
		Color:          req.Color,
		FuelType:       req.FuelType,
		Transmission:   req.Transmission,
		PurchasePrice:  req.PurchasePrice,
		RepairCost:     req.RepairCost,
		SellingPrice:   req.SellingPrice,
		ConditionNotes: req.ConditionNotes,
	}
	vehicle.ID = id

	if err := h.vehicleService.UpdateVehicle(c.Request.Context(), vehicle); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to update vehicle",
			"message": err.Error(),
		})
		return
	}

	response := h.toVehicleResponse(vehicle)

	c.JSON(http.StatusOK, gin.H{
		"message": "Vehicle updated successfully",
		"data":    response,
	})
}

// UpdateVehicleStatus updates vehicle status
func (h *VehicleHandler) UpdateVehicleStatus(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid vehicle ID",
			"message": "Vehicle ID must be a number",
		})
		return
	}

	var req UpdateVehicleStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	if err := h.vehicleService.UpdateVehicleStatus(c.Request.Context(), id, req.Status); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to update vehicle status",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Vehicle status updated successfully",
	})
}

// DeleteVehicle deletes a vehicle
func (h *VehicleHandler) DeleteVehicle(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid vehicle ID",
			"message": "Vehicle ID must be a number",
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

	if err := h.vehicleService.DeleteVehicle(c.Request.Context(), id, userIDInt); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to delete vehicle",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Vehicle deleted successfully",
	})
}

// toVehicleResponse converts domain.Vehicle to VehicleResponse
func (h *VehicleHandler) toVehicleResponse(vehicle *domain.Vehicle) VehicleResponse {
	response := VehicleResponse{
		ID:             vehicle.ID,
		VehicleCode:    vehicle.VehicleCode,
		CategoryID:     vehicle.CategoryID,
		Brand:          vehicle.Brand,
		Model:          vehicle.Model,
		Year:           vehicle.Year,
		ChassisNumber:  vehicle.ChassisNumber,
		EngineNumber:   vehicle.EngineNumber,
		PlateNumber:    vehicle.PlateNumber,
		Color:          vehicle.Color,
		FuelType:       vehicle.FuelType,
		Transmission:   vehicle.Transmission,
		PurchasePrice:  vehicle.PurchasePrice,
		RepairCost:     vehicle.RepairCost,
		HPP:            vehicle.HPP,
		SellingPrice:   vehicle.SellingPrice,
		Status:         vehicle.Status,
		ConditionNotes: vehicle.ConditionNotes,
		PrimaryPhoto:   vehicle.PrimaryPhoto,
		PurchasedDate:  vehicle.PurchasedDate,
		SoldDate:       vehicle.SoldDate,
		CreatedAt:      vehicle.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		UpdatedAt:      vehicle.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}

	// Add category information if available
	if vehicle.Category != nil {
		response.Category = &CategoryResponse{
			ID:          vehicle.Category.ID,
			Name:        vehicle.Category.Name,
			Description: vehicle.Category.Description,
		}
	}

	return response
}