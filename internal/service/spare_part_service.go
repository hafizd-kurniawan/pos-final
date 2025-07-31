package service

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"pos-final/internal/repository"
	"strings"
)

type sparePartService struct {
	sparePartRepo repository.SparePartRepository
}

// NewSparePartService creates a new spare part service
func NewSparePartService(sparePartRepo repository.SparePartRepository) SparePartService {
	return &sparePartService{
		sparePartRepo: sparePartRepo,
	}
}

func (s *sparePartService) CreateSparePart(ctx context.Context, sparePart *domain.SparePart) error {
	// Validate required fields
	if err := s.validateSparePart(sparePart); err != nil {
		return err
	}

	// Check if part code already exists
	if sparePart.PartCode != "" {
		existing, err := s.sparePartRepo.GetByPartCode(ctx, sparePart.PartCode)
		if err != nil {
			return fmt.Errorf("failed to check existing part code: %w", err)
		}
		if existing != nil {
			return fmt.Errorf("part code already exists")
		}
	} else {
		// Generate part code if not provided
		partCode, err := s.sparePartRepo.GeneratePartCode(ctx)
		if err != nil {
			return fmt.Errorf("failed to generate part code: %w", err)
		}
		sparePart.PartCode = partCode
	}

	// Check if barcode already exists if provided
	if sparePart.Barcode != nil && *sparePart.Barcode != "" {
		existing, err := s.sparePartRepo.GetByBarcode(ctx, *sparePart.Barcode)
		if err != nil {
			return fmt.Errorf("failed to check existing barcode: %w", err)
		}
		if existing != nil {
			return fmt.Errorf("barcode already exists")
		}
	}

	// Set default values
	if sparePart.StockQuantity < 0 {
		sparePart.StockQuantity = 0
	}
	if sparePart.MinStockLevel <= 0 {
		sparePart.MinStockLevel = 5 // Default minimum stock level
	}

	// Create spare part
	if err := s.sparePartRepo.Create(ctx, sparePart); err != nil {
		return fmt.Errorf("failed to create spare part: %w", err)
	}

	return nil
}

func (s *sparePartService) GetSparePartByID(ctx context.Context, id int) (*domain.SparePart, error) {
	if id <= 0 {
		return nil, fmt.Errorf("invalid spare part ID")
	}

	sparePart, err := s.sparePartRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get spare part: %w", err)
	}

	if sparePart == nil {
		return nil, fmt.Errorf("spare part not found")
	}

	return sparePart, nil
}

func (s *sparePartService) GetSparePartByCode(ctx context.Context, partCode string) (*domain.SparePart, error) {
	if partCode == "" {
		return nil, fmt.Errorf("part code is required")
	}

	sparePart, err := s.sparePartRepo.GetByPartCode(ctx, partCode)
	if err != nil {
		return nil, fmt.Errorf("failed to get spare part: %w", err)
	}

	if sparePart == nil {
		return nil, fmt.Errorf("spare part not found")
	}

	return sparePart, nil
}

func (s *sparePartService) GetSparePartByBarcode(ctx context.Context, barcode string) (*domain.SparePart, error) {
	if barcode == "" {
		return nil, fmt.Errorf("barcode is required")
	}

	sparePart, err := s.sparePartRepo.GetByBarcode(ctx, barcode)
	if err != nil {
		return nil, fmt.Errorf("failed to get spare part: %w", err)
	}

	if sparePart == nil {
		return nil, fmt.Errorf("spare part not found")
	}

	return sparePart, nil
}

func (s *sparePartService) ListSpareParts(ctx context.Context, page, limit int) ([]*domain.SparePart, int, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	spareParts, err := s.sparePartRepo.List(ctx, offset, limit)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list spare parts: %w", err)
	}

	total, err := s.sparePartRepo.Count(ctx)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count spare parts: %w", err)
	}

	return spareParts, total, nil
}

func (s *sparePartService) ListLowStockParts(ctx context.Context, page, limit int) ([]*domain.SparePart, int, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	spareParts, err := s.sparePartRepo.ListLowStock(ctx, offset, limit)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list low stock parts: %w", err)
	}

	total, err := s.sparePartRepo.CountLowStock(ctx)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count low stock parts: %w", err)
	}

	return spareParts, total, nil
}

func (s *sparePartService) SearchSpareParts(ctx context.Context, query string, page, limit int) ([]*domain.SparePart, int, error) {
	if query == "" {
		return s.ListSpareParts(ctx, page, limit)
	}

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	spareParts, err := s.sparePartRepo.Search(ctx, query, offset, limit)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to search spare parts: %w", err)
	}

	// For search, we return the count of search results
	total := len(spareParts)

	return spareParts, total, nil
}

func (s *sparePartService) UpdateSparePart(ctx context.Context, sparePart *domain.SparePart) error {
	if sparePart.ID <= 0 {
		return fmt.Errorf("invalid spare part ID")
	}

	// Validate required fields
	if err := s.validateSparePart(sparePart); err != nil {
		return err
	}

	// Check if spare part exists
	existing, err := s.sparePartRepo.GetByID(ctx, sparePart.ID)
	if err != nil {
		return fmt.Errorf("failed to check existing spare part: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("spare part not found")
	}

	// Check if barcode is being updated and if it conflicts
	if sparePart.Barcode != nil && *sparePart.Barcode != "" {
		if existing.Barcode == nil || *existing.Barcode != *sparePart.Barcode {
			conflicting, err := s.sparePartRepo.GetByBarcode(ctx, *sparePart.Barcode)
			if err != nil {
				return fmt.Errorf("failed to check existing barcode: %w", err)
			}
			if conflicting != nil && conflicting.ID != sparePart.ID {
				return fmt.Errorf("barcode already exists")
			}
		}
	}

	// Update spare part
	if err := s.sparePartRepo.Update(ctx, sparePart); err != nil {
		return fmt.Errorf("failed to update spare part: %w", err)
	}

	return nil
}

func (s *sparePartService) DeleteSparePart(ctx context.Context, id int, deletedBy int) error {
	if id <= 0 {
		return fmt.Errorf("invalid spare part ID")
	}

	if deletedBy <= 0 {
		return fmt.Errorf("invalid deleted by user ID")
	}

	// Check if spare part exists
	existing, err := s.sparePartRepo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to check existing spare part: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("spare part not found")
	}

	// TODO: Check if spare part is used in any active work orders before deleting

	// Soft delete spare part
	if err := s.sparePartRepo.SoftDelete(ctx, id, deletedBy); err != nil {
		return fmt.Errorf("failed to delete spare part: %w", err)
	}

	return nil
}

func (s *sparePartService) AdjustStock(ctx context.Context, partID int, adjustment int, notes string, adjustedBy int) error {
	if partID <= 0 {
		return fmt.Errorf("invalid spare part ID")
	}

	if adjustedBy <= 0 {
		return fmt.Errorf("invalid adjusted by user ID")
	}

	// Check if spare part exists
	existing, err := s.sparePartRepo.GetByID(ctx, partID)
	if err != nil {
		return fmt.Errorf("failed to check existing spare part: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("spare part not found")
	}

	// Check if adjustment would result in negative stock
	newStock := existing.StockQuantity + adjustment
	if newStock < 0 {
		return fmt.Errorf("adjustment would result in negative stock (current: %d, adjustment: %d)", existing.StockQuantity, adjustment)
	}

	// Adjust stock
	if err := s.sparePartRepo.AdjustStock(ctx, partID, adjustment); err != nil {
		return fmt.Errorf("failed to adjust stock: %w", err)
	}

	// TODO: Create stock movement record for audit trail

	return nil
}

func (s *sparePartService) CheckLowStock(ctx context.Context) ([]*domain.SparePart, error) {
	// Get all low stock parts without pagination
	spareParts, err := s.sparePartRepo.ListLowStock(ctx, 0, 1000) // Get up to 1000 low stock items
	if err != nil {
		return nil, fmt.Errorf("failed to check low stock: %w", err)
	}

	return spareParts, nil
}

func (s *sparePartService) validateSparePart(sparePart *domain.SparePart) error {
	if sparePart == nil {
		return fmt.Errorf("spare part is required")
	}

	if strings.TrimSpace(sparePart.Name) == "" {
		return fmt.Errorf("spare part name is required")
	}

	if sparePart.CostPrice < 0 {
		return fmt.Errorf("cost price cannot be negative")
	}

	if sparePart.SellingPrice < 0 {
		return fmt.Errorf("selling price cannot be negative")
	}

	if sparePart.StockQuantity < 0 {
		return fmt.Errorf("stock quantity cannot be negative")
	}

	if sparePart.MinStockLevel < 0 {
		return fmt.Errorf("minimum stock level cannot be negative")
	}

	// Validate barcode format if provided
	if sparePart.Barcode != nil && strings.TrimSpace(*sparePart.Barcode) != "" {
		barcode := strings.TrimSpace(*sparePart.Barcode)
		if len(barcode) < 3 {
			return fmt.Errorf("barcode must be at least 3 characters")
		}
	}

	// Validate unit if provided
	if sparePart.Unit != "" && strings.TrimSpace(sparePart.Unit) != "" {
		unit := strings.TrimSpace(sparePart.Unit)
		if len(unit) > 20 {
			return fmt.Errorf("unit must be less than 20 characters")
		}
	}

	return nil
}