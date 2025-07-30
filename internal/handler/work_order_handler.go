package handler

import (
	"net/http"
	"pos-final/internal/domain"
	"pos-final/internal/service"
	"strconv"

	"github.com/gin-gonic/gin"
)

type WorkOrderHandler struct {
	workOrderService service.WorkOrderService
}

// NewWorkOrderHandler creates a new work order handler
func NewWorkOrderHandler(workOrderService service.WorkOrderService) *WorkOrderHandler {
	return &WorkOrderHandler{
		workOrderService: workOrderService,
	}
}

type CreateWorkOrderRequest struct {
	VehicleID          int     `json:"vehicle_id" binding:"required"`
	Description        string  `json:"description" binding:"required"`
	AssignedMechanicID int     `json:"assigned_mechanic_id" binding:"required"`
	LaborCost          float64 `json:"labor_cost" binding:"min=0"`
	Notes              *string `json:"notes"`
}

type UpdateProgressRequest struct {
	Progress int `json:"progress" binding:"required,min=0,max=100"`
}

type AssignMechanicRequest struct {
	MechanicID int `json:"mechanic_id" binding:"required"`
}

type UsePartRequest struct {
	SparePartID int `json:"spare_part_id" binding:"required"`
	Quantity    int `json:"quantity" binding:"required,min=1"`
}

func (h *WorkOrderHandler) CreateWorkOrder(c *gin.Context) {
	var req CreateWorkOrderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	// Get user from context
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found in context"})
		return
	}

	// Create work order
	workOrder := &domain.WorkOrder{
		VehicleID:          req.VehicleID,
		Description:        req.Description,
		AssignedMechanicID: req.AssignedMechanicID,
		Status:             domain.WorkOrderStatusPending,
		ProgressPercentage: 0,
		TotalPartsCost:     0,
		LaborCost:          req.LaborCost,
		Notes:              req.Notes,
		CreatedBy:          userID.(int),
	}

	if err := h.workOrderService.CreateWorkOrder(c.Request.Context(), workOrder); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create work order",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Work order created successfully",
		"data":    workOrder,
	})
}

func (h *WorkOrderHandler) GetWorkOrder(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid work order ID"})
		return
	}

	workOrder, err := h.workOrderService.GetWorkOrderByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Work order not found",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Work order retrieved successfully",
		"data":    workOrder,
	})
}

func (h *WorkOrderHandler) ListWorkOrders(c *gin.Context) {
	// Parse query parameters
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	status := c.Query("status")

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	var workOrders []*domain.WorkOrder
	var total int
	var err error

	if status != "" {
		workOrderStatus := domain.WorkOrderStatus(status)
		workOrders, total, err = h.workOrderService.ListWorkOrdersByStatus(c.Request.Context(), workOrderStatus, page, limit)
	} else {
		workOrders, total, err = h.workOrderService.ListWorkOrders(c.Request.Context(), page, limit)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to retrieve work orders",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Work orders retrieved successfully",
		"data":    workOrders,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
		},
	})
}

func (h *WorkOrderHandler) ListMyWorkOrders(c *gin.Context) {
	// Get user from context
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found in context"})
		return
	}

	// Parse query parameters
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	workOrders, total, err := h.workOrderService.ListWorkOrdersByMechanic(c.Request.Context(), userID.(int), page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to retrieve work orders",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Work orders retrieved successfully",
		"data":    workOrders,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
		},
	})
}

func (h *WorkOrderHandler) StartWorkOrder(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid work order ID"})
		return
	}

	if err := h.workOrderService.StartWorkOrder(c.Request.Context(), id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to start work order",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Work order started successfully",
	})
}

func (h *WorkOrderHandler) CompleteWorkOrder(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid work order ID"})
		return
	}

	if err := h.workOrderService.CompleteWorkOrder(c.Request.Context(), id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to complete work order",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Work order completed successfully",
	})
}

func (h *WorkOrderHandler) UpdateProgress(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid work order ID"})
		return
	}

	var req UpdateProgressRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	if err := h.workOrderService.UpdateWorkOrderProgress(c.Request.Context(), id, req.Progress); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to update work order progress",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Work order progress updated successfully",
	})
}

func (h *WorkOrderHandler) AssignMechanic(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid work order ID"})
		return
	}

	var req AssignMechanicRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	if err := h.workOrderService.AssignMechanic(c.Request.Context(), id, req.MechanicID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to assign mechanic",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Mechanic assigned successfully",
	})
}

func (h *WorkOrderHandler) UsePart(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid work order ID"})
		return
	}

	var req UsePartRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	// Get user from context
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found in context"})
		return
	}

	if err := h.workOrderService.UsePartInWorkOrder(c.Request.Context(), id, req.SparePartID, req.Quantity, userID.(int)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to use part in work order",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Part used successfully",
	})
}