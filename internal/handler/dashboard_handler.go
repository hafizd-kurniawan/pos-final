package handler

import (
	"net/http"
	"pos-final/internal/domain"
	"pos-final/internal/service"
	"time"

	"github.com/gin-gonic/gin"
)

type DashboardHandler struct {
	customerService  service.CustomerService
	vehicleService   service.VehicleService
	sparePartService service.SparePartService
	salesService     service.SalesService
	purchaseService  service.PurchaseService
	workOrderService service.WorkOrderService
}

// NewDashboardHandler creates a new dashboard handler
func NewDashboardHandler(
	customerService service.CustomerService,
	vehicleService service.VehicleService,
	sparePartService service.SparePartService,
	salesService service.SalesService,
	purchaseService service.PurchaseService,
	workOrderService service.WorkOrderService,
) *DashboardHandler {
	return &DashboardHandler{
		customerService:  customerService,
		vehicleService:   vehicleService,
		sparePartService: sparePartService,
		salesService:     salesService,
		purchaseService:  purchaseService,
		workOrderService: workOrderService,
	}
}

type DashboardStats struct {
	TotalCustomers        int                     `json:"total_customers"`
	TotalVehicles         int                     `json:"total_vehicles"`
	VehiclesByStatus      map[string]int          `json:"vehicles_by_status"`
	TotalSpareParts       int                     `json:"total_spare_parts"`
	LowStockPartsCount    int                     `json:"low_stock_parts_count"`
	TodaySalesAmount      float64                 `json:"today_sales_amount"`
	TodaySalesCount       int                     `json:"today_sales_count"`
	TodayPurchaseAmount   float64                 `json:"today_purchase_amount"`
	TodayPurchaseCount    int                     `json:"today_purchase_count"`
	TodayProfit           float64                 `json:"today_profit"`
	PendingWorkOrders     int                     `json:"pending_work_orders"`
	InProgressWorkOrders  int                     `json:"in_progress_work_orders"`
	RecentActivities      []DashboardActivity     `json:"recent_activities"`
}

type DashboardActivity struct {
	Type        string    `json:"type"`
	Description string    `json:"description"`
	Time        time.Time `json:"time"`
	UserName    string    `json:"user_name,omitempty"`
}

// GetDashboardStats returns dashboard statistics
func (h *DashboardHandler) GetDashboardStats(c *gin.Context) {
	ctx := c.Request.Context()
	today := time.Now().Truncate(24 * time.Hour)

	stats := DashboardStats{
		VehiclesByStatus: make(map[string]int),
		RecentActivities: make([]DashboardActivity, 0),
	}

	// Get total customers
	if _, total, err := h.customerService.ListCustomers(ctx, 1, 1); err == nil {
		stats.TotalCustomers = total
	}

	// Get total vehicles and vehicle status counts
	if _, total, err := h.vehicleService.ListVehicles(ctx, 1, 1); err == nil {
		stats.TotalVehicles = total
	}

	// Get vehicles by status
	statuses := []domain.VehicleStatus{
		domain.VehicleStatusAvailable,
		domain.VehicleStatusInRepair,
		domain.VehicleStatusSold,
	}
	
	for _, status := range statuses {
		if vehicles, _, err := h.vehicleService.ListVehiclesByStatus(ctx, status, 1, 100); err == nil {
			stats.VehiclesByStatus[string(status)] = len(vehicles)
		}
	}

	// Get total spare parts and low stock count
	if _, total, err := h.sparePartService.ListSpareParts(ctx, 1, 1); err == nil {
		stats.TotalSpareParts = total
	}

	if lowStockParts, err := h.sparePartService.CheckLowStock(ctx); err == nil {
		stats.LowStockPartsCount = len(lowStockParts)
	}

	// Get today's sales stats
	if amount, profit, count, err := h.salesService.GetDailySalesReport(ctx, today); err == nil {
		stats.TodaySalesAmount = amount
		stats.TodaySalesCount = count
		stats.TodayProfit = profit
	}

	// Get today's purchase stats
	if amount, count, err := h.purchaseService.GetDailyPurchaseReport(ctx, today); err == nil {
		stats.TodayPurchaseAmount = amount
		stats.TodayPurchaseCount = count
	}

	// Get work order counts by status
	if workOrders, _, err := h.workOrderService.ListWorkOrdersByStatus(ctx, domain.WorkOrderStatusPending, 1, 100); err == nil {
		stats.PendingWorkOrders = len(workOrders)
	}

	if workOrders, _, err := h.workOrderService.ListWorkOrdersByStatus(ctx, domain.WorkOrderStatusInProgress, 1, 100); err == nil {
		stats.InProgressWorkOrders = len(workOrders)
	}

	// TODO: Implement recent activities from audit log or activity table
	// For now, return empty activities

	c.JSON(http.StatusOK, gin.H{
		"message": "Dashboard stats retrieved successfully",
		"data":    stats,
	})
}

// GetKasirDashboard returns dashboard for kasir role
func (h *DashboardHandler) GetKasirDashboard(c *gin.Context) {
	ctx := c.Request.Context()
	today := time.Now().Truncate(24 * time.Hour)

	// Kasir-specific dashboard with focus on sales and customers
	stats := map[string]interface{}{
		"today_sales":     make(map[string]interface{}),
		"today_purchase":  make(map[string]interface{}),
		"customers":       make(map[string]interface{}),
		"vehicles":        make(map[string]interface{}),
		"recent_sales":    make([]interface{}, 0),
	}

	// Get today's sales
	if amount, profit, count, err := h.salesService.GetDailySalesReport(ctx, today); err == nil {
		stats["today_sales"] = map[string]interface{}{
			"total_amount": amount,
			"total_count":  count,
			"profit":       profit,
		}
	}

	// Get today's purchases
	if amount, count, err := h.purchaseService.GetDailyPurchaseReport(ctx, today); err == nil {
		stats["today_purchase"] = map[string]interface{}{
			"total_amount": amount,
			"total_count":  count,
		}
	}

	// Get customer stats
	if _, total, err := h.customerService.ListCustomers(ctx, 1, 1); err == nil {
		stats["customers"] = map[string]interface{}{
			"total_count": total,
		}
	}

	// Get available vehicles
	if vehicles, _, err := h.vehicleService.ListVehiclesByStatus(ctx, domain.VehicleStatusAvailable, 1, 100); err == nil {
		stats["vehicles"] = map[string]interface{}{
			"available_count": len(vehicles),
		}
	}

	// Get recent sales (last 5)
	if salesInvoices, _, err := h.salesService.ListSalesInvoices(ctx, 1, 5); err == nil {
		recentSales := make([]map[string]interface{}, 0)
		for _, sale := range salesInvoices {
			customerName := ""
			if sale.Customer != nil {
				customerName = sale.Customer.Name
			}
			recentSales = append(recentSales, map[string]interface{}{
				"invoice_number": sale.InvoiceNumber,
				"final_price":    sale.FinalPrice,
				"customer_name":  customerName,
				"created_at":     sale.CreatedAt,
			})
		}
		stats["recent_sales"] = recentSales
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Kasir dashboard retrieved successfully",
		"data":    stats,
	})
}

// GetMekanikDashboard returns dashboard for mechanic role
func (h *DashboardHandler) GetMekanikDashboard(c *gin.Context) {
	ctx := c.Request.Context()

	// Get mechanic ID from JWT token
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

	// Mechanic-specific dashboard with focus on work orders
	stats := map[string]interface{}{
		"my_work_orders":  make(map[string]interface{}),
		"spare_parts":     make(map[string]interface{}),
		"recent_work":     make([]interface{}, 0),
	}

	// Get mechanic's work orders
	if workOrders, _, err := h.workOrderService.ListWorkOrdersByMechanic(ctx, userIDInt, 1, 100); err == nil {
		pending := 0
		inProgress := 0
		completed := 0

		for _, wo := range workOrders {
			switch wo.Status {
			case domain.WorkOrderStatusPending:
				pending++
			case domain.WorkOrderStatusInProgress:
				inProgress++
			case domain.WorkOrderStatusCompleted:
				completed++
			}
		}

		stats["my_work_orders"] = map[string]interface{}{
			"total":       len(workOrders),
			"pending":     pending,
			"in_progress": inProgress,
			"completed":   completed,
		}

		// Get recent work orders (last 5)
		if len(workOrders) > 0 {
			recentWork := make([]map[string]interface{}, 0)
			limit := 5
			if len(workOrders) < limit {
				limit = len(workOrders)
			}
			
			for i := 0; i < limit; i++ {
				wo := workOrders[i]
				vehicleCode := ""
				if wo.Vehicle != nil {
					vehicleCode = wo.Vehicle.VehicleCode
				}
				recentWork = append(recentWork, map[string]interface{}{
					"wo_number":    wo.WONumber,
					"vehicle_code": vehicleCode,
					"status":       wo.Status,
					"progress":     wo.ProgressPercentage,
					"created_at":   wo.CreatedAt,
				})
			}
			stats["recent_work"] = recentWork
		}
	}

	// Get low stock spare parts (important for mechanics)
	if lowStockParts, err := h.sparePartService.CheckLowStock(ctx); err == nil {
		stats["spare_parts"] = map[string]interface{}{
			"low_stock_count": len(lowStockParts),
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Mechanic dashboard retrieved successfully",
		"data":    stats,
	})
}