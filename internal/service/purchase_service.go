package service

import (
	"context"
	"fmt"
	"mime/multipart"
	"pos-final/internal/domain"
	"pos-final/internal/repository"
	"time"
)

type purchaseService struct {
	purchaseRepo repository.PurchaseInvoiceRepository
	vehicleRepo  repository.VehicleRepository
	workOrderRepo repository.WorkOrderRepository
	userRepo     repository.UserRepository
}

// NewPurchaseService creates a new purchase service
func NewPurchaseService(
	purchaseRepo repository.PurchaseInvoiceRepository,
	vehicleRepo repository.VehicleRepository,
	workOrderRepo repository.WorkOrderRepository,
	userRepo repository.UserRepository,
) PurchaseService {
	return &purchaseService{
		purchaseRepo: purchaseRepo,
		vehicleRepo:  vehicleRepo,
		workOrderRepo: workOrderRepo,
		userRepo:     userRepo,
	}
}

func (s *purchaseService) CreatePurchaseInvoice(ctx context.Context, invoice *domain.PurchaseInvoice) error {
	// Generate invoice number if not provided
	if invoice.InvoiceNumber == "" {
		invoiceNumber, err := s.purchaseRepo.GenerateInvoiceNumber(ctx, invoice.TransactionType)
		if err != nil {
			return fmt.Errorf("failed to generate invoice number: %w", err)
		}
		invoice.InvoiceNumber = invoiceNumber
	}

	// Set transaction date if not provided
	if invoice.TransactionDate.IsZero() {
		invoice.TransactionDate = time.Now()
	}

	// Set final price if not calculated
	if invoice.FinalPrice == 0 {
		if invoice.NegotiatedPrice != nil {
			invoice.FinalPrice = *invoice.NegotiatedPrice
		} else {
			invoice.FinalPrice = invoice.PurchasePrice
		}
	}

	// Create the purchase invoice
	if err := s.purchaseRepo.Create(ctx, invoice); err != nil {
		return fmt.Errorf("failed to create purchase invoice: %w", err)
	}

	// Update vehicle information
	vehicle, err := s.vehicleRepo.GetByID(ctx, invoice.VehicleID)
	if err != nil {
		return fmt.Errorf("failed to get vehicle: %w", err)
	}

	// Update vehicle with purchase information
	vehicle.PurchasePrice = &invoice.FinalPrice
	vehicle.Status = domain.VehicleStatusInRepair
	vehicle.PurchasedDate = &invoice.TransactionDate
	
	if err := s.vehicleRepo.Update(ctx, vehicle); err != nil {
		return fmt.Errorf("failed to update vehicle: %w", err)
	}

	// Auto-create work order for the purchased vehicle
	if err := s.createWorkOrderForPurchasedVehicle(ctx, invoice); err != nil {
		return fmt.Errorf("failed to create work order: %w", err)
	}

	return nil
}

func (s *purchaseService) createWorkOrderForPurchasedVehicle(ctx context.Context, invoice *domain.PurchaseInvoice) error {
	// Get available mechanics
	mechanics, err := s.userRepo.GetByRole(ctx, domain.RoleMekanik)
	if err != nil {
		return fmt.Errorf("failed to get mechanics: %w", err)
	}

	if len(mechanics) == 0 {
		return fmt.Errorf("no mechanics available to assign work order")
	}

	// Generate work order number
	woNumber, err := s.workOrderRepo.GenerateWONumber(ctx)
	if err != nil {
		return fmt.Errorf("failed to generate work order number: %w", err)
	}

	// Create work order
	workOrder := &domain.WorkOrder{
		WONumber:            woNumber,
		VehicleID:           invoice.VehicleID,
		Description:         fmt.Sprintf("Initial inspection and repair assessment for purchased vehicle %s", getVehicleDescription(invoice)),
		AssignedMechanicID:  mechanics[0].ID, // Assign to first available mechanic
		Status:              domain.WorkOrderStatusPending,
		ProgressPercentage:  0,
		TotalPartsCost:      0,
		LaborCost:           0,
		TotalCost:           0,
		CreatedBy:           invoice.CreatedBy,
	}

	if err := s.workOrderRepo.Create(ctx, workOrder); err != nil {
		return fmt.Errorf("failed to create work order: %w", err)
	}

	return nil
}

func getVehicleDescription(invoice *domain.PurchaseInvoice) string {
	if invoice.Vehicle != nil {
		return fmt.Sprintf("%s %s %d", invoice.Vehicle.Brand, invoice.Vehicle.Model, invoice.Vehicle.Year)
	}
	return "Unknown Vehicle"
}

func (s *purchaseService) GetPurchaseInvoiceByID(ctx context.Context, id int) (*domain.PurchaseInvoice, error) {
	return s.purchaseRepo.GetByID(ctx, id)
}

func (s *purchaseService) GetPurchaseInvoiceByNumber(ctx context.Context, invoiceNumber string) (*domain.PurchaseInvoice, error) {
	return s.purchaseRepo.GetByInvoiceNumber(ctx, invoiceNumber)
}

func (s *purchaseService) ListPurchaseInvoices(ctx context.Context, page, limit int) ([]*domain.PurchaseInvoice, int, error) {
	offset := (page - 1) * limit
	invoices, err := s.purchaseRepo.List(ctx, offset, limit)
	if err != nil {
		return nil, 0, err
	}

	count, err := s.purchaseRepo.Count(ctx)
	if err != nil {
		return nil, 0, err
	}

	return invoices, count, nil
}

func (s *purchaseService) ListPurchaseInvoicesByDateRange(ctx context.Context, startDate, endDate time.Time, page, limit int) ([]*domain.PurchaseInvoice, int, error) {
	offset := (page - 1) * limit
	invoices, err := s.purchaseRepo.ListByDateRange(ctx, startDate, endDate, offset, limit)
	if err != nil {
		return nil, 0, err
	}

	count, err := s.purchaseRepo.Count(ctx)
	if err != nil {
		return nil, 0, err
	}

	return invoices, count, nil
}

func (s *purchaseService) UpdatePurchaseInvoice(ctx context.Context, invoice *domain.PurchaseInvoice) error {
	return s.purchaseRepo.Update(ctx, invoice)
}

func (s *purchaseService) DeletePurchaseInvoice(ctx context.Context, id int, deletedBy int) error {
	return s.purchaseRepo.SoftDelete(ctx, id, deletedBy)
}

func (s *purchaseService) UploadTransferProof(ctx context.Context, invoiceID int, file *multipart.FileHeader) error {
	// TODO: Implement file upload logic
	// This would save the file and update the invoice with the file path
	return fmt.Errorf("transfer proof upload not implemented yet")
}

func (s *purchaseService) GetDailyPurchaseReport(ctx context.Context, date time.Time) (float64, int, error) {
	return s.purchaseRepo.GetDailyTotal(ctx, date)
}