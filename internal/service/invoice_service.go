package service

import (
	"bytes"
	"context"
	"fmt"
	"time"

	"github.com/jung-kurt/gofpdf"
)

type invoiceServiceImpl struct {
	salesService     SalesService
	purchaseService  PurchaseService
	workOrderService WorkOrderService
}

func NewInvoiceService(salesService SalesService, purchaseService PurchaseService, workOrderService WorkOrderService) InvoiceService {
	return &invoiceServiceImpl{
		salesService:     salesService,
		purchaseService:  purchaseService,
		workOrderService: workOrderService,
	}
}

func (s *invoiceServiceImpl) GenerateSalesInvoicePDF(ctx context.Context, invoiceID int) ([]byte, error) {
	// Get sales invoice data
	invoice, err := s.salesService.GetSalesInvoiceByID(ctx, invoiceID)
	if err != nil {
		return nil, fmt.Errorf("failed to get sales invoice: %w", err)
	}

	pdf := gofpdf.New("P", "mm", "A4", "")
	pdf.AddPage()

	// Set font
	pdf.SetFont("Arial", "B", 16)
	
	// Header
	pdf.Cell(190, 10, "SALES INVOICE")
	pdf.Ln(15)

	// Company info
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(50, 8, "POS Vehicle System")
	pdf.Ln(6)
	pdf.SetFont("Arial", "", 10)
	pdf.Cell(50, 6, "Vehicle Sales & Repair Center")
	pdf.Ln(15)

	// Invoice details
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(30, 8, "Invoice #:")
	pdf.SetFont("Arial", "", 12)
	pdf.Cell(60, 8, invoice.InvoiceNumber)
	pdf.Ln(8)

	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(30, 8, "Date:")
	pdf.SetFont("Arial", "", 12)
	pdf.Cell(60, 8, invoice.TransactionDate.Format("2006-01-02"))
	pdf.Ln(8)

	if invoice.Customer != nil {
		pdf.SetFont("Arial", "B", 12)
		pdf.Cell(30, 8, "Customer:")
		pdf.SetFont("Arial", "", 12)
		pdf.Cell(60, 8, invoice.Customer.Name)
		pdf.Ln(8)
	}

	// Pricing details
	pdf.Ln(10)
	pdf.SetFont("Arial", "B", 14)
	pdf.Cell(190, 10, "Pricing")
	pdf.Ln(10)

	pdf.SetFont("Arial", "B", 11)
	pdf.Cell(70, 8, "Selling Price:")
	pdf.SetFont("Arial", "", 11)
	pdf.Cell(60, 8, fmt.Sprintf("Rp %s", formatCurrency(invoice.SellingPrice)))
	pdf.Ln(8)

	pdf.SetFont("Arial", "B", 11)
	pdf.Cell(70, 8, "Final Price:")
	pdf.SetFont("Arial", "", 11)
	pdf.Cell(60, 8, fmt.Sprintf("Rp %s", formatCurrency(invoice.FinalPrice)))
	pdf.Ln(8)

	pdf.SetFont("Arial", "B", 11)
	pdf.Cell(70, 8, "Profit:")
	pdf.SetFont("Arial", "", 11)
	pdf.Cell(60, 8, fmt.Sprintf("Rp %s", formatCurrency(invoice.ProfitAmount)))
	pdf.Ln(15)

	// Payment method
	pdf.SetFont("Arial", "B", 11)
	pdf.Cell(40, 8, "Payment Method:")
	pdf.SetFont("Arial", "", 11)
	pdf.Cell(60, 8, string(invoice.PaymentMethod))
	pdf.Ln(15)

	// Notes
	if invoice.Notes != nil && *invoice.Notes != "" {
		pdf.SetFont("Arial", "B", 11)
		pdf.Cell(190, 8, "Notes:")
		pdf.Ln(6)
		pdf.SetFont("Arial", "", 10)
		pdf.MultiCell(190, 6, *invoice.Notes, "", "", false)
		pdf.Ln(10)
	}

	// Footer
	pdf.SetY(-30)
	pdf.SetFont("Arial", "", 9)
	pdf.Cell(190, 6, "Thank you for your business!")
	pdf.Ln(4)
	pdf.Cell(190, 6, fmt.Sprintf("Generated on: %s", time.Now().Format("2006-01-02 15:04:05")))

	var buf bytes.Buffer
	err = pdf.Output(&buf)
	if err != nil {
		return nil, fmt.Errorf("failed to generate PDF: %w", err)
	}

	return buf.Bytes(), nil
}

func (s *invoiceServiceImpl) GeneratePurchaseInvoicePDF(ctx context.Context, invoiceID int) ([]byte, error) {
	// Get purchase invoice data
	invoice, err := s.purchaseService.GetPurchaseInvoiceByID(ctx, invoiceID)
	if err != nil {
		return nil, fmt.Errorf("failed to get purchase invoice: %w", err)
	}

	pdf := gofpdf.New("P", "mm", "A4", "")
	pdf.AddPage()

	// Set font
	pdf.SetFont("Arial", "B", 16)
	
	// Header
	pdf.Cell(190, 10, "PURCHASE INVOICE")
	pdf.Ln(15)

	// Company info
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(50, 8, "POS Vehicle System")
	pdf.Ln(6)
	pdf.SetFont("Arial", "", 10)
	pdf.Cell(50, 6, "Vehicle Sales & Repair Center")
	pdf.Ln(15)

	// Invoice details
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(30, 8, "Invoice #:")
	pdf.SetFont("Arial", "", 12)
	pdf.Cell(60, 8, invoice.InvoiceNumber)
	pdf.Ln(8)

	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(30, 8, "Date:")
	pdf.SetFont("Arial", "", 12)
	pdf.Cell(60, 8, invoice.TransactionDate.Format("2006-01-02"))
	pdf.Ln(8)

	// Show supplier info if available
	supplierName := "N/A"
	if invoice.Supplier != nil {
		supplierName = invoice.Supplier.Name
	}
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(30, 8, "Supplier:")
	pdf.SetFont("Arial", "", 12)
	pdf.Cell(60, 8, supplierName)
	pdf.Ln(15)

	// Pricing details
	pdf.SetFont("Arial", "B", 14)
	pdf.Cell(190, 10, "Purchase Details")
	pdf.Ln(10)

	pdf.SetFont("Arial", "B", 11)
	pdf.Cell(70, 8, "Purchase Price:")
	pdf.SetFont("Arial", "", 11)
	pdf.Cell(60, 8, fmt.Sprintf("Rp %s", formatCurrency(invoice.PurchasePrice)))
	pdf.Ln(8)

	pdf.SetFont("Arial", "B", 11)
	pdf.Cell(70, 8, "Final Price:")
	pdf.SetFont("Arial", "", 11)
	pdf.Cell(60, 8, fmt.Sprintf("Rp %s", formatCurrency(invoice.FinalPrice)))
	pdf.Ln(8)

	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(70, 8, "Total Amount:")
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(60, 8, fmt.Sprintf("Rp %s", formatCurrency(invoice.FinalPrice)))
	pdf.Ln(15)

	// Payment method
	pdf.SetFont("Arial", "B", 11)
	pdf.Cell(40, 8, "Payment Method:")
	pdf.SetFont("Arial", "", 11)
	pdf.Cell(60, 8, string(invoice.PaymentMethod))
	pdf.Ln(15)

	// Notes
	if invoice.Notes != nil && *invoice.Notes != "" {
		pdf.SetFont("Arial", "B", 11)
		pdf.Cell(190, 8, "Notes:")
		pdf.Ln(6)
		pdf.SetFont("Arial", "", 10)
		pdf.MultiCell(190, 6, *invoice.Notes, "", "", false)
		pdf.Ln(10)
	}

	// Footer
	pdf.SetY(-30)
	pdf.SetFont("Arial", "", 9)
	pdf.Cell(190, 6, "Purchase Invoice for Vehicle Acquisition")
	pdf.Ln(4)
	pdf.Cell(190, 6, fmt.Sprintf("Generated on: %s", time.Now().Format("2006-01-02 15:04:05")))

	var buf bytes.Buffer
	err = pdf.Output(&buf)
	if err != nil {
		return nil, fmt.Errorf("failed to generate PDF: %w", err)
	}

	return buf.Bytes(), nil
}

func (s *invoiceServiceImpl) GenerateWorkOrderPDF(ctx context.Context, workOrderID int) ([]byte, error) {
	// Get work order data
	workOrder, err := s.workOrderService.GetWorkOrderByID(ctx, workOrderID)
	if err != nil {
		return nil, fmt.Errorf("failed to get work order: %w", err)
	}

	pdf := gofpdf.New("P", "mm", "A4", "")
	pdf.AddPage()

	// Set font
	pdf.SetFont("Arial", "B", 16)
	
	// Header
	pdf.Cell(190, 10, "WORK ORDER")
	pdf.Ln(15)

	// Company info
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(50, 8, "POS Vehicle System")
	pdf.Ln(6)
	pdf.SetFont("Arial", "", 10)
	pdf.Cell(50, 6, "Vehicle Sales & Repair Center")
	pdf.Ln(15)

	// Work order details
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(30, 8, "Work Order #:")
	pdf.SetFont("Arial", "", 12)
	pdf.Cell(60, 8, workOrder.WONumber)
	pdf.Ln(8)

	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(30, 8, "Date:")
	pdf.SetFont("Arial", "", 12)
	pdf.Cell(60, 8, workOrder.CreatedAt.Format("2006-01-02"))
	pdf.Ln(8)

	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(30, 8, "Status:")
	pdf.SetFont("Arial", "", 12)
	pdf.Cell(60, 8, string(workOrder.Status))
	pdf.Ln(15)

	// Work description
	pdf.SetFont("Arial", "B", 14)
	pdf.Cell(190, 10, "Work Description")
	pdf.Ln(10)

	pdf.SetFont("Arial", "", 11)
	pdf.MultiCell(190, 6, workOrder.Description, "", "", false)
	pdf.Ln(10)

	// Cost summary
	pdf.SetFont("Arial", "B", 14)
	pdf.Cell(190, 10, "Cost Summary")
	pdf.Ln(10)

	pdf.SetFont("Arial", "B", 11)
	pdf.Cell(70, 8, "Labor Cost:")
	pdf.SetFont("Arial", "", 11)
	pdf.Cell(60, 8, fmt.Sprintf("Rp %s", formatCurrency(workOrder.LaborCost)))
	pdf.Ln(8)

	pdf.SetFont("Arial", "B", 11)
	pdf.Cell(70, 8, "Parts Cost:")
	pdf.SetFont("Arial", "", 11)
	pdf.Cell(60, 8, fmt.Sprintf("Rp %s", formatCurrency(workOrder.TotalPartsCost)))
	pdf.Ln(8)

	totalCost := workOrder.LaborCost + workOrder.TotalPartsCost
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(70, 8, "Total Cost:")
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(60, 8, fmt.Sprintf("Rp %s", formatCurrency(totalCost)))
	pdf.Ln(15)

	// Progress
	pdf.SetFont("Arial", "B", 11)
	pdf.Cell(40, 8, "Progress:")
	pdf.SetFont("Arial", "", 11)
	pdf.Cell(60, 8, fmt.Sprintf("%d%%", workOrder.ProgressPercentage))
	pdf.Ln(15)

	// Notes
	if workOrder.Notes != nil && *workOrder.Notes != "" {
		pdf.SetFont("Arial", "B", 11)
		pdf.Cell(190, 8, "Notes:")
		pdf.Ln(6)
		pdf.SetFont("Arial", "", 10)
		pdf.MultiCell(190, 6, *workOrder.Notes, "", "", false)
		pdf.Ln(10)
	}

	// Footer
	pdf.SetY(-30)
	pdf.SetFont("Arial", "", 9)
	pdf.Cell(190, 6, "Work Order Document")
	pdf.Ln(4)
	pdf.Cell(190, 6, fmt.Sprintf("Generated on: %s", time.Now().Format("2006-01-02 15:04:05")))

	var buf bytes.Buffer
	err = pdf.Output(&buf)
	if err != nil {
		return nil, fmt.Errorf("failed to generate PDF: %w", err)
	}

	return buf.Bytes(), nil
}

func (s *invoiceServiceImpl) GenerateReportPDF(ctx context.Context, reportType string, data interface{}) ([]byte, error) {
	pdf := gofpdf.New("P", "mm", "A4", "")
	pdf.AddPage()

	// Set font
	pdf.SetFont("Arial", "B", 16)
	
	// Header
	pdf.Cell(190, 10, "BUSINESS REPORT")
	pdf.Ln(15)

	// Company info
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(50, 8, "POS Vehicle System")
	pdf.Ln(6)
	pdf.SetFont("Arial", "", 10)
	pdf.Cell(50, 6, "Vehicle Sales & Repair Center")
	pdf.Ln(15)

	// Report type and date
	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(30, 8, "Report Type:")
	pdf.SetFont("Arial", "", 12)
	pdf.Cell(60, 8, reportType)
	pdf.Ln(8)

	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(30, 8, "Generated:")
	pdf.SetFont("Arial", "", 12)
	pdf.Cell(60, 8, time.Now().Format("2006-01-02 15:04:05"))
	pdf.Ln(15)

	// Report content based on type
	switch reportType {
	case "daily_sales":
		if reportData, ok := data.(map[string]interface{}); ok {
			pdf.SetFont("Arial", "B", 14)
			pdf.Cell(190, 10, "Daily Sales Report")
			pdf.Ln(10)

			if date, exists := reportData["date"]; exists {
				pdf.SetFont("Arial", "B", 11)
				pdf.Cell(30, 8, "Date:")
				pdf.SetFont("Arial", "", 11)
				pdf.Cell(60, 8, fmt.Sprintf("%v", date))
				pdf.Ln(8)
			}

			if totalSales, exists := reportData["total_sales"]; exists {
				pdf.SetFont("Arial", "B", 11)
				pdf.Cell(50, 8, "Total Sales:")
				pdf.SetFont("Arial", "", 11)
				pdf.Cell(60, 8, fmt.Sprintf("%v", totalSales))
				pdf.Ln(8)
			}
		}

	case "daily_purchases":
		if reportData, ok := data.(map[string]interface{}); ok {
			pdf.SetFont("Arial", "B", 14)
			pdf.Cell(190, 10, "Daily Purchase Report")
			pdf.Ln(10)

			if date, exists := reportData["date"]; exists {
				pdf.SetFont("Arial", "B", 11)
				pdf.Cell(30, 8, "Date:")
				pdf.SetFont("Arial", "", 11)
				pdf.Cell(60, 8, fmt.Sprintf("%v", date))
				pdf.Ln(8)
			}
		}

	default:
		pdf.SetFont("Arial", "", 11)
		pdf.Cell(190, 8, "Report data not available or unsupported report type")
		pdf.Ln(10)
	}

	// Footer
	pdf.SetY(-30)
	pdf.SetFont("Arial", "", 9)
	pdf.Cell(190, 6, "This is a system generated report")
	pdf.Ln(4)
	pdf.Cell(190, 6, fmt.Sprintf("POS Vehicle System - %s", time.Now().Format("2006-01-02")))

	var buf bytes.Buffer
	err := pdf.Output(&buf)
	if err != nil {
		return nil, fmt.Errorf("failed to generate PDF: %w", err)
	}

	return buf.Bytes(), nil
}

func (s *invoiceServiceImpl) SendInvoiceEmail(ctx context.Context, invoiceID int, email string) error {
	// TODO: Implement email sending functionality
	return fmt.Errorf("email sending not implemented yet")
}

// Helper function to format currency
func formatCurrency(amount float64) string {
	// Simple number formatting with thousand separators
	str := fmt.Sprintf("%.0f", amount)
	
	// Add thousand separators
	n := len(str)
	if n <= 3 {
		return str
	}
	
	result := ""
	for i, char := range str {
		if i > 0 && (n-i)%3 == 0 {
			result += ","
		}
		result += string(char)
	}
	
	return result
}