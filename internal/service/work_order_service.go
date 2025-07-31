package service

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"pos-final/internal/repository"
	"time"
)

type workOrderService struct {
	workOrderRepo     repository.WorkOrderRepository
	vehicleRepo       repository.VehicleRepository
	sparePartRepo     repository.SparePartRepository
	workOrderPartRepo repository.WorkOrderPartRepository
	userRepo          repository.UserRepository
}

// NewWorkOrderService creates a new work order service
func NewWorkOrderService(
	workOrderRepo repository.WorkOrderRepository,
	vehicleRepo repository.VehicleRepository,
	sparePartRepo repository.SparePartRepository,
	workOrderPartRepo repository.WorkOrderPartRepository,
	userRepo repository.UserRepository,
) WorkOrderService {
	return &workOrderService{
		workOrderRepo:     workOrderRepo,
		vehicleRepo:       vehicleRepo,
		sparePartRepo:     sparePartRepo,
		workOrderPartRepo: workOrderPartRepo,
		userRepo:          userRepo,
	}
}

func (s *workOrderService) CreateWorkOrder(ctx context.Context, workOrder *domain.WorkOrder) error {
	// Generate WO number if not provided
	if workOrder.WONumber == "" {
		woNumber, err := s.workOrderRepo.GenerateWONumber(ctx)
		if err != nil {
			return fmt.Errorf("failed to generate work order number: %w", err)
		}
		workOrder.WONumber = woNumber
	}

	// Validate assigned mechanic
	if workOrder.AssignedMechanicID > 0 {
		mechanic, err := s.userRepo.GetByID(ctx, workOrder.AssignedMechanicID)
		if err != nil {
			return fmt.Errorf("failed to get assigned mechanic: %w", err)
		}
		if mechanic.Role != domain.RoleMekanik {
			return fmt.Errorf("assigned user is not a mechanic")
		}
	}

	// Calculate total cost
	workOrder.TotalCost = workOrder.TotalPartsCost + workOrder.LaborCost

	// Create the work order
	if err := s.workOrderRepo.Create(ctx, workOrder); err != nil {
		return fmt.Errorf("failed to create work order: %w", err)
	}

	return nil
}

func (s *workOrderService) GetWorkOrderByID(ctx context.Context, id int) (*domain.WorkOrder, error) {
	return s.workOrderRepo.GetByID(ctx, id)
}

func (s *workOrderService) GetWorkOrderByNumber(ctx context.Context, woNumber string) (*domain.WorkOrder, error) {
	return s.workOrderRepo.GetByWONumber(ctx, woNumber)
}

func (s *workOrderService) ListWorkOrders(ctx context.Context, page, limit int) ([]*domain.WorkOrder, int, error) {
	offset := (page - 1) * limit
	workOrders, err := s.workOrderRepo.List(ctx, offset, limit)
	if err != nil {
		return nil, 0, err
	}

	count, err := s.workOrderRepo.Count(ctx)
	if err != nil {
		return nil, 0, err
	}

	return workOrders, count, nil
}

func (s *workOrderService) ListWorkOrdersByStatus(ctx context.Context, status domain.WorkOrderStatus, page, limit int) ([]*domain.WorkOrder, int, error) {
	offset := (page - 1) * limit
	workOrders, err := s.workOrderRepo.ListByStatus(ctx, status, offset, limit)
	if err != nil {
		return nil, 0, err
	}

	count, err := s.workOrderRepo.CountByStatus(ctx, status)
	if err != nil {
		return nil, 0, err
	}

	return workOrders, count, nil
}

func (s *workOrderService) ListWorkOrdersByMechanic(ctx context.Context, mechanicID int, page, limit int) ([]*domain.WorkOrder, int, error) {
	offset := (page - 1) * limit
	workOrders, err := s.workOrderRepo.ListByMechanic(ctx, mechanicID, offset, limit)
	if err != nil {
		return nil, 0, err
	}

	// Count by getting all and filtering (could be optimized)
	allWorkOrders, err := s.workOrderRepo.ListByMechanic(ctx, mechanicID, 0, 1000)
	if err != nil {
		return nil, 0, err
	}

	return workOrders, len(allWorkOrders), nil
}

func (s *workOrderService) UpdateWorkOrder(ctx context.Context, workOrder *domain.WorkOrder) error {
	// Recalculate total cost
	workOrder.TotalCost = workOrder.TotalPartsCost + workOrder.LaborCost

	if err := s.workOrderRepo.Update(ctx, workOrder); err != nil {
		return fmt.Errorf("failed to update work order: %w", err)
	}

	return nil
}

func (s *workOrderService) DeleteWorkOrder(ctx context.Context, id int, deletedBy int) error {
	return s.workOrderRepo.SoftDelete(ctx, id, deletedBy)
}

func (s *workOrderService) UpdateWorkOrderStatus(ctx context.Context, id int, status domain.WorkOrderStatus) error {
	return s.workOrderRepo.UpdateStatus(ctx, id, status)
}

func (s *workOrderService) UpdateWorkOrderProgress(ctx context.Context, id int, progress int) error {
	if progress < 0 || progress > 100 {
		return fmt.Errorf("progress must be between 0 and 100")
	}
	return s.workOrderRepo.UpdateProgress(ctx, id, progress)
}

func (s *workOrderService) StartWorkOrder(ctx context.Context, id int) error {
	// Update status to in progress
	if err := s.workOrderRepo.UpdateStatus(ctx, id, domain.WorkOrderStatusInProgress); err != nil {
		return fmt.Errorf("failed to start work order: %w", err)
	}

	return nil
}

func (s *workOrderService) CompleteWorkOrder(ctx context.Context, id int) error {
	// Get the work order
	workOrder, err := s.workOrderRepo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to get work order: %w", err)
	}

	// Update status to completed
	if err := s.workOrderRepo.UpdateStatus(ctx, id, domain.WorkOrderStatusCompleted); err != nil {
		return fmt.Errorf("failed to complete work order: %w", err)
	}

	// Update vehicle HPP (Harga Pokok Penjualan)
	if err := s.updateVehicleHPP(ctx, workOrder.VehicleID); err != nil {
		return fmt.Errorf("failed to update vehicle HPP: %w", err)
	}

	// Update vehicle status to available
	if err := s.vehicleRepo.UpdateStatus(ctx, workOrder.VehicleID, domain.VehicleStatusAvailable); err != nil {
		return fmt.Errorf("failed to update vehicle status: %w", err)
	}

	return nil
}

func (s *workOrderService) updateVehicleHPP(ctx context.Context, vehicleID int) error {
	// Get vehicle
	vehicle, err := s.vehicleRepo.GetByID(ctx, vehicleID)
	if err != nil {
		return fmt.Errorf("failed to get vehicle: %w", err)
	}

	// Calculate total repair cost from all completed work orders for this vehicle
	totalRepairCost := float64(0)
	
	// Get all work orders for this vehicle
	allWorkOrders, err := s.workOrderRepo.ListByStatus(ctx, domain.WorkOrderStatusCompleted, 0, 1000)
	if err != nil {
		return fmt.Errorf("failed to get completed work orders: %w", err)
	}

	for _, wo := range allWorkOrders {
		if wo.VehicleID == vehicleID {
			totalRepairCost += wo.TotalCost
		}
	}

	// Update vehicle repair cost and HPP
	vehicle.RepairCost = totalRepairCost
	
	// HPP = Purchase Price + Total Repair Cost
	if vehicle.PurchasePrice != nil {
		hpp := *vehicle.PurchasePrice + totalRepairCost
		vehicle.HPP = &hpp
	}

	if err := s.vehicleRepo.Update(ctx, vehicle); err != nil {
		return fmt.Errorf("failed to update vehicle: %w", err)
	}

	return nil
}

func (s *workOrderService) AssignMechanic(ctx context.Context, id int, mechanicID int) error {
	// Validate mechanic
	mechanic, err := s.userRepo.GetByID(ctx, mechanicID)
	if err != nil {
		return fmt.Errorf("failed to get mechanic: %w", err)
	}
	if mechanic.Role != domain.RoleMekanik {
		return fmt.Errorf("user is not a mechanic")
	}

	// Get work order
	workOrder, err := s.workOrderRepo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to get work order: %w", err)
	}

	// Update assigned mechanic
	workOrder.AssignedMechanicID = mechanicID
	if err := s.workOrderRepo.Update(ctx, workOrder); err != nil {
		return fmt.Errorf("failed to assign mechanic: %w", err)
	}

	return nil
}

func (s *workOrderService) UsePartInWorkOrder(ctx context.Context, workOrderID int, partID int, quantity int, usedBy int) error {
	// Get spare part
	sparePart, err := s.sparePartRepo.GetByID(ctx, partID)
	if err != nil {
		return fmt.Errorf("failed to get spare part: %w", err)
	}

	// Check if enough stock
	if sparePart.StockQuantity < quantity {
		return fmt.Errorf("insufficient stock: available %d, requested %d", sparePart.StockQuantity, quantity)
	}

	// Calculate costs
	unitCost := sparePart.CostPrice
	totalCost := unitCost * float64(quantity)

	// Create work order part record
	workOrderPart := &domain.WorkOrderPart{
		WorkOrderID:  workOrderID,
		SparePartID:  partID,
		QuantityUsed: quantity,
		UnitCost:     unitCost,
		TotalCost:    totalCost,
		UsedBy:       usedBy,
		UsageDate:    time.Now(),
		UsedAt:       time.Now(),
	}

	if err := s.workOrderPartRepo.Create(ctx, workOrderPart); err != nil {
		return fmt.Errorf("failed to create work order part record: %w", err)
	}

	// Reduce stock
	newStock := sparePart.StockQuantity - quantity
	if err := s.sparePartRepo.UpdateStock(ctx, partID, newStock); err != nil {
		return fmt.Errorf("failed to update spare part stock: %w", err)
	}

	// Update work order total parts cost
	if err := s.updateWorkOrderPartsCost(ctx, workOrderID); err != nil {
		return fmt.Errorf("failed to update work order parts cost: %w", err)
	}

	return nil
}

func (s *workOrderService) updateWorkOrderPartsCost(ctx context.Context, workOrderID int) error {
	// Get all parts used in this work order
	workOrderParts, err := s.workOrderPartRepo.ListByWorkOrderID(ctx, workOrderID)
	if err != nil {
		return fmt.Errorf("failed to get work order parts: %w", err)
	}

	// Calculate total parts cost
	totalPartsCost := float64(0)
	for _, part := range workOrderParts {
		totalPartsCost += part.TotalCost
	}

	// Get work order and update
	workOrder, err := s.workOrderRepo.GetByID(ctx, workOrderID)
	if err != nil {
		return fmt.Errorf("failed to get work order: %w", err)
	}

	workOrder.TotalPartsCost = totalPartsCost
	workOrder.TotalCost = workOrder.TotalPartsCost + workOrder.LaborCost

	if err := s.workOrderRepo.Update(ctx, workOrder); err != nil {
		return fmt.Errorf("failed to update work order: %w", err)
	}

	return nil
}