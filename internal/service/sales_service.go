package service

import (
	"context"
	"fmt"
	"log"
	"mime/multipart"
	"pos-final/internal/domain"
	"pos-final/internal/repository"
	"time"
)

type salesService struct {
	salesRepo   repository.SalesInvoiceRepository
	vehicleRepo repository.VehicleRepository
}

// NewSalesService creates a new sales service
func NewSalesService(
	salesRepo repository.SalesInvoiceRepository,
	vehicleRepo repository.VehicleRepository,
) SalesService {
	return &salesService{
		salesRepo:   salesRepo,
		vehicleRepo: vehicleRepo,
	}
}

func (s *salesService) CreateSalesInvoice(ctx context.Context, invoice *domain.SalesInvoice) error {
	// Generate invoice number if not provided
	if invoice.InvoiceNumber == "" {
		invoiceNumber, err := s.salesRepo.GenerateInvoiceNumber(ctx)
		if err != nil {
			return fmt.Errorf("failed to generate invoice number: %w", err)
		}
		invoice.InvoiceNumber = invoiceNumber
	}

	// Set transaction date if not provided
	if invoice.TransactionDate.IsZero() {
		invoice.TransactionDate = time.Now()
	}

	// Get vehicle to calculate profit
	vehicle, err := s.vehicleRepo.GetByID(ctx, invoice.VehicleID)
	if err != nil {
		return fmt.Errorf("failed to get vehicle: %w", err)
	}

	// Validate vehicle status
	if vehicle.Status != domain.VehicleStatusAvailable {
		return fmt.Errorf("vehicle is not available for sale (current status: %s)", vehicle.Status)
	}

	// Calculate discount amount if percentage is provided
	if invoice.DiscountPercentage > 0 {
		invoice.DiscountAmount = invoice.SellingPrice * (invoice.DiscountPercentage / 100)
	}

	// Calculate final price
	invoice.FinalPrice = invoice.SellingPrice - invoice.DiscountAmount

	// Calculate profit (Final Price - HPP)
	if vehicle.HPP != nil {
		invoice.ProfitAmount = invoice.FinalPrice - *vehicle.HPP
	} else {
		// If HPP not set, profit is selling price minus purchase price and repair cost
		profit := invoice.FinalPrice
		if vehicle.PurchasePrice != nil {
			profit -= *vehicle.PurchasePrice
		}
		profit -= vehicle.RepairCost
		invoice.ProfitAmount = profit
	}

	// Create the sales invoice
	if err := s.salesRepo.Create(ctx, invoice); err != nil {
		return fmt.Errorf("failed to create sales invoice: %w", err)
	}

	// Update vehicle status to sold
	vehicle.Status = domain.VehicleStatusSold
	vehicle.SellingPrice = &invoice.FinalPrice
	soldDate := invoice.TransactionDate
	vehicle.SoldDate = &soldDate

	if err := s.vehicleRepo.Update(ctx, vehicle); err != nil {
		return fmt.Errorf("failed to update vehicle status: %w", err)
	}

	return nil
}

func (s *salesService) GetSalesInvoiceByID(ctx context.Context, id int) (*domain.SalesInvoice, error) {
	return s.salesRepo.GetByID(ctx, id)
}

func (s *salesService) GetSalesInvoiceByNumber(ctx context.Context, invoiceNumber string) (*domain.SalesInvoice, error) {
	return s.salesRepo.GetByInvoiceNumber(ctx, invoiceNumber)
}

func (s *salesService) ListSalesInvoices(ctx context.Context, page, limit int) ([]*domain.SalesInvoice, int, error) {
	log.Printf("=== Sales Service: ListSalesInvoices ===")
	log.Printf("Parameters: page=%d, limit=%d", page, limit)
	
	offset := (page - 1) * limit
	log.Printf("Calculated offset: %d", offset)
	
	log.Printf("Calling repository.List with offset=%d, limit=%d", offset, limit)
	invoices, err := s.salesRepo.List(ctx, offset, limit)
	if err != nil {
		log.Printf("ERROR: Repository List failed: %v", err)
		return nil, 0, err
	}
	
	log.Printf("Repository.List returned %d invoices", len(invoices))

	log.Printf("Calling repository.Count")
	count, err := s.salesRepo.Count(ctx)
	if err != nil {
		log.Printf("ERROR: Repository Count failed: %v", err)
		return nil, 0, err
	}
	
	log.Printf("Repository.Count returned: %d", count)
	log.Printf("=== End Sales Service: ListSalesInvoices ===")

	return invoices, count, nil
}

func (s *salesService) ListSalesInvoicesByDateRange(ctx context.Context, startDate, endDate time.Time, page, limit int) ([]*domain.SalesInvoice, int, error) {
	offset := (page - 1) * limit
	invoices, err := s.salesRepo.ListByDateRange(ctx, startDate, endDate, offset, limit)
	if err != nil {
		return nil, 0, err
	}

	count, err := s.salesRepo.Count(ctx)
	if err != nil {
		return nil, 0, err
	}

	return invoices, count, nil
}

func (s *salesService) ListSalesInvoicesByCustomer(ctx context.Context, customerID int, page, limit int) ([]*domain.SalesInvoice, int, error) {
	offset := (page - 1) * limit
	invoices, err := s.salesRepo.ListByCustomer(ctx, customerID, offset, limit)
	if err != nil {
		return nil, 0, err
	}

	// Count by getting all and filtering (could be optimized)
	allInvoices, err := s.salesRepo.ListByCustomer(ctx, customerID, 0, 1000)
	if err != nil {
		return nil, 0, err
	}

	return invoices, len(allInvoices), nil
}

func (s *salesService) UpdateSalesInvoice(ctx context.Context, invoice *domain.SalesInvoice) error {
	// Recalculate discount and profit if needed
	if invoice.DiscountPercentage > 0 {
		invoice.DiscountAmount = invoice.SellingPrice * (invoice.DiscountPercentage / 100)
	}
	
	invoice.FinalPrice = invoice.SellingPrice - invoice.DiscountAmount

	// Get vehicle to recalculate profit
	vehicle, err := s.vehicleRepo.GetByID(ctx, invoice.VehicleID)
	if err != nil {
		return fmt.Errorf("failed to get vehicle: %w", err)
	}

	if vehicle.HPP != nil {
		invoice.ProfitAmount = invoice.FinalPrice - *vehicle.HPP
	}

	return s.salesRepo.Update(ctx, invoice)
}

func (s *salesService) DeleteSalesInvoice(ctx context.Context, id int, deletedBy int) error {
	// Get the sales invoice
	invoice, err := s.salesRepo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to get sales invoice: %w", err)
	}

	// Update vehicle status back to available
	if err := s.vehicleRepo.UpdateStatus(ctx, invoice.VehicleID, domain.VehicleStatusAvailable); err != nil {
		return fmt.Errorf("failed to update vehicle status: %w", err)
	}

	// Delete the sales invoice
	return s.salesRepo.SoftDelete(ctx, id, deletedBy)
}

func (s *salesService) UploadTransferProof(ctx context.Context, invoiceID int, file *multipart.FileHeader) error {
	// TODO: Implement file upload logic
	// This would save the file and update the invoice with the file path
	return fmt.Errorf("transfer proof upload not implemented yet")
}

func (s *salesService) GetDailySalesReport(ctx context.Context, date time.Time) (float64, float64, int, error) {
	return s.salesRepo.GetDailyTotal(ctx, date)
}

func (s *salesService) GenerateInvoicePDF(ctx context.Context, invoiceID int) ([]byte, error) {
	// This method is deprecated in favor of the dedicated InvoiceService
	return nil, fmt.Errorf("use InvoiceService.GenerateSalesInvoicePDF instead")
}