package handler

import (
	"net/http"
	"pos-final/internal/service"
	"time"

	"github.com/gin-gonic/gin"
)

type ReportHandler struct {
	reportService service.ReportService
}

func NewReportHandler(reportService service.ReportService) *ReportHandler {
	return &ReportHandler{
		reportService: reportService,
	}
}

// GetSalesReport godoc
// @Summary Get sales report
// @Description Get detailed sales report for a date range
// @Tags reports
// @Accept json
// @Produce json
// @Param start_date query string true "Start date (YYYY-MM-DD)"
// @Param end_date query string true "End date (YYYY-MM-DD)"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/reports/sales [get]
func (h *ReportHandler) GetSalesReport(c *gin.Context) {
	startDateStr := c.Query("start_date")
	endDateStr := c.Query("end_date")

	if startDateStr == "" || endDateStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "start_date and end_date parameters are required (YYYY-MM-DD format)",
		})
		return
	}

	startDate, err := time.Parse("2006-01-02", startDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid start_date format. Use YYYY-MM-DD",
		})
		return
	}

	endDate, err := time.Parse("2006-01-02", endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid end_date format. Use YYYY-MM-DD",
		})
		return
	}

	// Adjust end date to include the full day
	endDate = endDate.Add(24 * time.Hour).Add(-time.Second)

	report, err := h.reportService.GetSalesReport(c.Request.Context(), startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate sales report: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": report,
	})
}

// GetPurchaseReport godoc
// @Summary Get purchase report
// @Description Get detailed purchase report for a date range
// @Tags reports
// @Accept json
// @Produce json
// @Param start_date query string true "Start date (YYYY-MM-DD)"
// @Param end_date query string true "End date (YYYY-MM-DD)"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/reports/purchases [get]
func (h *ReportHandler) GetPurchaseReport(c *gin.Context) {
	startDateStr := c.Query("start_date")
	endDateStr := c.Query("end_date")

	if startDateStr == "" || endDateStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "start_date and end_date parameters are required (YYYY-MM-DD format)",
		})
		return
	}

	startDate, err := time.Parse("2006-01-02", startDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid start_date format. Use YYYY-MM-DD",
		})
		return
	}

	endDate, err := time.Parse("2006-01-02", endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid end_date format. Use YYYY-MM-DD",
		})
		return
	}

	// Adjust end date to include the full day
	endDate = endDate.Add(24 * time.Hour).Add(-time.Second)

	report, err := h.reportService.GetPurchaseReport(c.Request.Context(), startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate purchase report: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": report,
	})
}

// GetInventoryReport godoc
// @Summary Get inventory report
// @Description Get current inventory status report
// @Tags reports
// @Accept json
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/reports/inventory [get]
func (h *ReportHandler) GetInventoryReport(c *gin.Context) {
	report, err := h.reportService.GetInventoryReport(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate inventory report: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": report,
	})
}

// GetProfitLossReport godoc
// @Summary Get profit & loss report
// @Description Get profit and loss analysis for a date range
// @Tags reports
// @Accept json
// @Produce json
// @Param start_date query string true "Start date (YYYY-MM-DD)"
// @Param end_date query string true "End date (YYYY-MM-DD)"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/reports/profit-loss [get]
func (h *ReportHandler) GetProfitLossReport(c *gin.Context) {
	startDateStr := c.Query("start_date")
	endDateStr := c.Query("end_date")

	if startDateStr == "" || endDateStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "start_date and end_date parameters are required (YYYY-MM-DD format)",
		})
		return
	}

	startDate, err := time.Parse("2006-01-02", startDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid start_date format. Use YYYY-MM-DD",
		})
		return
	}

	endDate, err := time.Parse("2006-01-02", endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid end_date format. Use YYYY-MM-DD",
		})
		return
	}

	// Adjust end date to include the full day
	endDate = endDate.Add(24 * time.Hour).Add(-time.Second)

	report, err := h.reportService.GetProfitLossReport(c.Request.Context(), startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate profit & loss report: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": report,
	})
}

// GetVehicleReport godoc
// @Summary Get vehicle report
// @Description Get detailed vehicle inventory and status report
// @Tags reports
// @Accept json
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/reports/vehicles [get]
func (h *ReportHandler) GetVehicleReport(c *gin.Context) {
	report, err := h.reportService.GetVehicleReport(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate vehicle report: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": report,
	})
}

// GetWorkOrderReport godoc
// @Summary Get work order report
// @Description Get work order performance and metrics report
// @Tags reports
// @Accept json
// @Produce json
// @Param start_date query string true "Start date (YYYY-MM-DD)"
// @Param end_date query string true "End date (YYYY-MM-DD)"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/reports/work-orders [get]
func (h *ReportHandler) GetWorkOrderReport(c *gin.Context) {
	startDateStr := c.Query("start_date")
	endDateStr := c.Query("end_date")

	if startDateStr == "" || endDateStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "start_date and end_date parameters are required (YYYY-MM-DD format)",
		})
		return
	}

	startDate, err := time.Parse("2006-01-02", startDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid start_date format. Use YYYY-MM-DD",
		})
		return
	}

	endDate, err := time.Parse("2006-01-02", endDateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid end_date format. Use YYYY-MM-DD",
		})
		return
	}

	// Adjust end date to include the full day
	endDate = endDate.Add(24 * time.Hour).Add(-time.Second)

	report, err := h.reportService.GetWorkOrderReport(c.Request.Context(), startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate work order report: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": report,
	})
}

// GetDailyReport godoc
// @Summary Get daily report
// @Description Get comprehensive daily business report
// @Tags reports
// @Accept json
// @Produce json
// @Param date query string true "Date (YYYY-MM-DD)"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/reports/daily [get]
func (h *ReportHandler) GetDailyReport(c *gin.Context) {
	dateStr := c.Query("date")

	if dateStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "date parameter is required (YYYY-MM-DD format)",
		})
		return
	}

	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid date format. Use YYYY-MM-DD",
		})
		return
	}

	report, err := h.reportService.GetDailyReport(c.Request.Context(), date)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate daily report: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": report,
	})
}

// GetBusinessOverview godoc
// @Summary Get business overview
// @Description Get comprehensive business metrics and KPIs
// @Tags reports
// @Accept json
// @Produce json
// @Param period query string false "Period: week, month, quarter, year" default(month)
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/v1/reports/overview [get]
func (h *ReportHandler) GetBusinessOverview(c *gin.Context) {
	period := c.DefaultQuery("period", "month")

	var startDate, endDate time.Time
	now := time.Now()

	switch period {
	case "week":
		startDate = now.AddDate(0, 0, -7)
		endDate = now
	case "month":
		startDate = now.AddDate(0, -1, 0)
		endDate = now
	case "quarter":
		startDate = now.AddDate(0, -3, 0)
		endDate = now
	case "year":
		startDate = now.AddDate(-1, 0, 0)
		endDate = now
	default:
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid period. Use: week, month, quarter, or year",
		})
		return
	}

	// Get various reports
	salesReport, err := h.reportService.GetSalesReport(c.Request.Context(), startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get sales data: " + err.Error(),
		})
		return
	}

	purchaseReport, err := h.reportService.GetPurchaseReport(c.Request.Context(), startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get purchase data: " + err.Error(),
		})
		return
	}

	inventoryReport, err := h.reportService.GetInventoryReport(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get inventory data: " + err.Error(),
		})
		return
	}

	vehicleReport, err := h.reportService.GetVehicleReport(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get vehicle data: " + err.Error(),
		})
		return
	}

	profitLossReport, err := h.reportService.GetProfitLossReport(c.Request.Context(), startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get profit & loss data: " + err.Error(),
		})
		return
	}

	// Combine into overview
	overview := map[string]interface{}{
		"period": map[string]interface{}{
			"type":       period,
			"start_date": startDate.Format("2006-01-02"),
			"end_date":   endDate.Format("2006-01-02"),
		},
		"sales":       salesReport,
		"purchases":   purchaseReport,
		"inventory":   inventoryReport,
		"vehicles":    vehicleReport,
		"profit_loss": profitLossReport,
		"kpis": map[string]interface{}{
			"revenue_growth":     0, // TODO: Calculate compared to previous period
			"profit_margin":      profitLossReport["profit"].(map[string]interface{})["profit_margin"],
			"inventory_turnover": 0, // TODO: Calculate inventory turnover
			"customer_acquisition": 0, // TODO: Calculate new customers
		},
	}

	c.JSON(http.StatusOK, gin.H{
		"data": overview,
	})
}