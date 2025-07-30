package service

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"pos-final/internal/repository"
	"strings"
)

type vehicleService struct {
	vehicleRepo repository.VehicleRepository
}

// NewVehicleService creates a new vehicle service
func NewVehicleService(vehicleRepo repository.VehicleRepository) VehicleService {
	return &vehicleService{
		vehicleRepo: vehicleRepo,
	}
}

func (s *vehicleService) CreateVehicle(ctx context.Context, vehicle *domain.Vehicle) error {
	// Validate required fields
	if err := s.validateVehicle(vehicle); err != nil {
		return err
	}

	// Check if vehicle code already exists
	if vehicle.VehicleCode != "" {
		existing, err := s.vehicleRepo.GetByVehicleCode(ctx, vehicle.VehicleCode)
		if err != nil {
			return fmt.Errorf("failed to check existing vehicle code: %w", err)
		}
		if existing != nil {
			return fmt.Errorf("vehicle code already exists")
		}
	} else {
		// Generate vehicle code if not provided
		vehicleCode, err := s.vehicleRepo.GenerateVehicleCode(ctx)
		if err != nil {
			return fmt.Errorf("failed to generate vehicle code: %w", err)
		}
		vehicle.VehicleCode = vehicleCode
	}

	// Set default status if not provided
	if vehicle.Status == "" {
		vehicle.Status = domain.VehicleStatusAvailable
	}

	// Calculate HPP if not provided
	if vehicle.HPP == nil || *vehicle.HPP == 0 {
		hpp := 0.0
		if vehicle.PurchasePrice != nil {
			hpp += *vehicle.PurchasePrice
		}
		hpp += vehicle.RepairCost
		vehicle.HPP = &hpp
	}

	// Create vehicle
	if err := s.vehicleRepo.Create(ctx, vehicle); err != nil {
		return fmt.Errorf("failed to create vehicle: %w", err)
	}

	return nil
}

func (s *vehicleService) GetVehicleByID(ctx context.Context, id int) (*domain.Vehicle, error) {
	if id <= 0 {
		return nil, fmt.Errorf("invalid vehicle ID")
	}

	vehicle, err := s.vehicleRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get vehicle: %w", err)
	}

	if vehicle == nil {
		return nil, fmt.Errorf("vehicle not found")
	}

	return vehicle, nil
}

func (s *vehicleService) GetVehicleByCode(ctx context.Context, vehicleCode string) (*domain.Vehicle, error) {
	if vehicleCode == "" {
		return nil, fmt.Errorf("vehicle code is required")
	}

	vehicle, err := s.vehicleRepo.GetByVehicleCode(ctx, vehicleCode)
	if err != nil {
		return nil, fmt.Errorf("failed to get vehicle: %w", err)
	}

	if vehicle == nil {
		return nil, fmt.Errorf("vehicle not found")
	}

	return vehicle, nil
}

func (s *vehicleService) ListVehicles(ctx context.Context, page, limit int) ([]*domain.Vehicle, int, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	vehicles, err := s.vehicleRepo.List(ctx, offset, limit)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list vehicles: %w", err)
	}

	total, err := s.vehicleRepo.Count(ctx)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count vehicles: %w", err)
	}

	return vehicles, total, nil
}

func (s *vehicleService) ListVehiclesByStatus(ctx context.Context, status domain.VehicleStatus, page, limit int) ([]*domain.Vehicle, int, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	vehicles, err := s.vehicleRepo.ListByStatus(ctx, status, offset, limit)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list vehicles by status: %w", err)
	}

	total, err := s.vehicleRepo.CountByStatus(ctx, status)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count vehicles by status: %w", err)
	}

	return vehicles, total, nil
}

func (s *vehicleService) ListVehiclesByCategory(ctx context.Context, categoryID int, page, limit int) ([]*domain.Vehicle, int, error) {
	if categoryID <= 0 {
		return nil, 0, fmt.Errorf("invalid category ID")
	}

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	vehicles, err := s.vehicleRepo.ListByCategory(ctx, categoryID, offset, limit)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list vehicles by category: %w", err)
	}

	// For simplicity, return the count of vehicles returned
	// In production, you might want to implement a separate count method for category
	total := len(vehicles)

	return vehicles, total, nil
}

func (s *vehicleService) SearchVehicles(ctx context.Context, query string, page, limit int) ([]*domain.Vehicle, int, error) {
	if query == "" {
		return s.ListVehicles(ctx, page, limit)
	}

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	vehicles, err := s.vehicleRepo.Search(ctx, query, offset, limit)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to search vehicles: %w", err)
	}

	// For search, we return the count of search results
	total := len(vehicles)

	return vehicles, total, nil
}

func (s *vehicleService) UpdateVehicle(ctx context.Context, vehicle *domain.Vehicle) error {
	if vehicle.ID <= 0 {
		return fmt.Errorf("invalid vehicle ID")
	}

	// Validate required fields
	if err := s.validateVehicle(vehicle); err != nil {
		return err
	}

	// Check if vehicle exists
	existing, err := s.vehicleRepo.GetByID(ctx, vehicle.ID)
	if err != nil {
		return fmt.Errorf("failed to check existing vehicle: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("vehicle not found")
	}

	// Recalculate HPP
	hpp := 0.0
	if vehicle.PurchasePrice != nil {
		hpp += *vehicle.PurchasePrice
	}
	hpp += vehicle.RepairCost
	vehicle.HPP = &hpp

	// Update vehicle
	if err := s.vehicleRepo.Update(ctx, vehicle); err != nil {
		return fmt.Errorf("failed to update vehicle: %w", err)
	}

	return nil
}

func (s *vehicleService) DeleteVehicle(ctx context.Context, id int, deletedBy int) error {
	if id <= 0 {
		return fmt.Errorf("invalid vehicle ID")
	}

	if deletedBy <= 0 {
		return fmt.Errorf("invalid deleted by user ID")
	}

	// Check if vehicle exists
	existing, err := s.vehicleRepo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to check existing vehicle: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("vehicle not found")
	}

	// Check if vehicle can be deleted (not sold or in active repair)
	if existing.Status == domain.VehicleStatusSold {
		return fmt.Errorf("cannot delete sold vehicle")
	}
	if existing.Status == domain.VehicleStatusInRepair {
		return fmt.Errorf("cannot delete vehicle that is currently in repair")
	}

	// Soft delete vehicle
	if err := s.vehicleRepo.SoftDelete(ctx, id, deletedBy); err != nil {
		return fmt.Errorf("failed to delete vehicle: %w", err)
	}

	return nil
}

func (s *vehicleService) UpdateVehicleStatus(ctx context.Context, id int, status domain.VehicleStatus) error {
	if id <= 0 {
		return fmt.Errorf("invalid vehicle ID")
	}

	if !isValidVehicleStatus(status) {
		return fmt.Errorf("invalid vehicle status")
	}

	// Check if vehicle exists
	existing, err := s.vehicleRepo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to check existing vehicle: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("vehicle not found")
	}

	// Update status
	if err := s.vehicleRepo.UpdateStatus(ctx, id, status); err != nil {
		return fmt.Errorf("failed to update vehicle status: %w", err)
	}

	return nil
}

func (s *vehicleService) CalculateHPP(ctx context.Context, vehicleID int) error {
	if vehicleID <= 0 {
		return fmt.Errorf("invalid vehicle ID")
	}

	// Get vehicle
	vehicle, err := s.vehicleRepo.GetByID(ctx, vehicleID)
	if err != nil {
		return fmt.Errorf("failed to get vehicle: %w", err)
	}
	if vehicle == nil {
		return fmt.Errorf("vehicle not found")
	}

	// Calculate HPP (Purchase Price + Repair Cost)
	hpp := 0.0
	if vehicle.PurchasePrice != nil {
		hpp += *vehicle.PurchasePrice
	}
	hpp += vehicle.RepairCost
	vehicle.HPP = &hpp

	// Update vehicle
	if err := s.vehicleRepo.Update(ctx, vehicle); err != nil {
		return fmt.Errorf("failed to update vehicle HPP: %w", err)
	}

	return nil
}

func (s *vehicleService) validateVehicle(vehicle *domain.Vehicle) error {
	if vehicle == nil {
		return fmt.Errorf("vehicle is required")
	}

	if strings.TrimSpace(vehicle.Brand) == "" {
		return fmt.Errorf("vehicle brand is required")
	}

	if strings.TrimSpace(vehicle.Model) == "" {
		return fmt.Errorf("vehicle model is required")
	}

	if vehicle.Year <= 0 {
		return fmt.Errorf("vehicle year is required and must be positive")
	}

	if vehicle.Year < 1900 || vehicle.Year > 2030 {
		return fmt.Errorf("vehicle year must be between 1900 and 2030")
	}

	if vehicle.PurchasePrice != nil && *vehicle.PurchasePrice < 0 {
		return fmt.Errorf("purchase price cannot be negative")
	}

	if vehicle.RepairCost < 0 {
		return fmt.Errorf("repair cost cannot be negative")
	}

	if vehicle.SellingPrice != nil && *vehicle.SellingPrice < 0 {
		return fmt.Errorf("selling price cannot be negative")
	}

	// Validate chassis number if provided
	if vehicle.ChassisNumber != nil && strings.TrimSpace(*vehicle.ChassisNumber) != "" {
		chassisNumber := strings.TrimSpace(*vehicle.ChassisNumber)
		if len(chassisNumber) < 5 {
			return fmt.Errorf("chassis number must be at least 5 characters")
		}
	}

	// Validate engine number if provided
	if vehicle.EngineNumber != nil && strings.TrimSpace(*vehicle.EngineNumber) != "" {
		engineNumber := strings.TrimSpace(*vehicle.EngineNumber)
		if len(engineNumber) < 3 {
			return fmt.Errorf("engine number must be at least 3 characters")
		}
	}

	return nil
}

func isValidVehicleStatus(status domain.VehicleStatus) bool {
	switch status {
	case domain.VehicleStatusAvailable, domain.VehicleStatusInRepair, domain.VehicleStatusSold:
		return true
	default:
		return false
	}
}