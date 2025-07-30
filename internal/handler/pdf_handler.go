package handler

import (
	"net/http"
	"pos-final/internal/service"
	"strconv"

	"github.com/gin-gonic/gin"
)

type PDFHandler struct {
	pdfService PDFService
}

type PDFService interface {
	GenerateSalesInvoicePDF(ctx *gin.Context, invoiceID int) ([]byte, error)
	GeneratePurchaseInvoicePDF(ctx *gin.Context, invoiceID int) ([]byte, error)
	GenerateWorkOrderPDF(ctx *gin.Context, workOrderID int) ([]byte, error)
	GenerateReportPDF(ctx *gin.Context, reportType string, data interface{}) ([]byte, error)
}

func NewPDFHandler(pdfService service.InvoiceService) *PDFHandler {
	return &PDFHandler{
		pdfService: &pdfServiceAdapter{invoiceService: pdfService},
	}
}

// Adapter to adapt service.InvoiceService to PDFService
type pdfServiceAdapter struct {
	invoiceService service.InvoiceService
}

func (a *pdfServiceAdapter) GenerateSalesInvoicePDF(ctx *gin.Context, invoiceID int) ([]byte, error) {
	return a.invoiceService.GenerateSalesInvoicePDF(ctx.Request.Context(), invoiceID)
}

func (a *pdfServiceAdapter) GeneratePurchaseInvoicePDF(ctx *gin.Context, invoiceID int) ([]byte, error) {
	return a.invoiceService.GeneratePurchaseInvoicePDF(ctx.Request.Context(), invoiceID)
}

func (a *pdfServiceAdapter) GenerateWorkOrderPDF(ctx *gin.Context, workOrderID int) ([]byte, error) {
	return a.invoiceService.GenerateWorkOrderPDF(ctx.Request.Context(), workOrderID)
}

func (a *pdfServiceAdapter) GenerateReportPDF(ctx *gin.Context, reportType string, data interface{}) ([]byte, error) {
	return a.invoiceService.GenerateReportPDF(ctx.Request.Context(), reportType, data)
}

// GenerateSalesInvoicePDF generates a PDF for sales invoice
func (h *PDFHandler) GenerateSalesInvoicePDF(c *gin.Context) {
	idParam := c.Param("id")
	invoiceID, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid invoice ID",
		})
		return
	}

	pdfBytes, err := h.pdfService.GenerateSalesInvoicePDF(c, invoiceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate PDF: " + err.Error(),
		})
		return
	}

	c.Header("Content-Type", "application/pdf")
	c.Header("Content-Disposition", "attachment; filename=sales_invoice_"+idParam+".pdf")
	c.Header("Content-Length", strconv.Itoa(len(pdfBytes)))
	
	c.Data(http.StatusOK, "application/pdf", pdfBytes)
}

// GeneratePurchaseInvoicePDF generates a PDF for purchase invoice
func (h *PDFHandler) GeneratePurchaseInvoicePDF(c *gin.Context) {
	idParam := c.Param("id")
	invoiceID, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid invoice ID",
		})
		return
	}

	pdfBytes, err := h.pdfService.GeneratePurchaseInvoicePDF(c, invoiceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate PDF: " + err.Error(),
		})
		return
	}

	c.Header("Content-Type", "application/pdf")
	c.Header("Content-Disposition", "attachment; filename=purchase_invoice_"+idParam+".pdf")
	c.Header("Content-Length", strconv.Itoa(len(pdfBytes)))
	
	c.Data(http.StatusOK, "application/pdf", pdfBytes)
}

// GenerateWorkOrderPDF generates a PDF for work order
func (h *PDFHandler) GenerateWorkOrderPDF(c *gin.Context) {
	idParam := c.Param("id")
	workOrderID, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid work order ID",
		})
		return
	}

	pdfBytes, err := h.pdfService.GenerateWorkOrderPDF(c, workOrderID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate PDF: " + err.Error(),
		})
		return
	}

	c.Header("Content-Type", "application/pdf")
	c.Header("Content-Disposition", "attachment; filename=work_order_"+idParam+".pdf")
	c.Header("Content-Length", strconv.Itoa(len(pdfBytes)))
	
	c.Data(http.StatusOK, "application/pdf", pdfBytes)
}

// GenerateReportPDF generates a PDF for various reports
func (h *PDFHandler) GenerateReportPDF(c *gin.Context) {
	reportType := c.Query("type")
	if reportType == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Report type is required",
		})
		return
	}

	// For now, we'll generate a simple report based on the type
	var data interface{}
	switch reportType {
	case "daily_sales":
		date := c.Query("date")
		if date == "" {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Date parameter is required for daily sales report",
			})
			return
		}
		data = map[string]interface{}{
			"date":         date,
			"total_sales":  0, // This would be calculated from actual data
			"total_amount": 0,
			"total_profit": 0,
		}
	case "daily_purchases":
		date := c.Query("date")
		if date == "" {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Date parameter is required for daily purchases report",
			})
			return
		}
		data = map[string]interface{}{
			"date":            date,
			"total_purchases": 0, // This would be calculated from actual data
			"total_amount":    0,
		}
	default:
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Unsupported report type",
		})
		return
	}

	pdfBytes, err := h.pdfService.GenerateReportPDF(c, reportType, data)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate PDF: " + err.Error(),
		})
		return
	}

	c.Header("Content-Type", "application/pdf")
	c.Header("Content-Disposition", "attachment; filename="+reportType+"_report.pdf")
	c.Header("Content-Length", strconv.Itoa(len(pdfBytes)))
	
	c.Data(http.StatusOK, "application/pdf", pdfBytes)
}