package repository

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"time"

	"github.com/jmoiron/sqlx"
)

type workOrderRepository struct {
	db *sqlx.DB
}

// NewWorkOrderRepository creates a new work order repository
func NewWorkOrderRepository(db *sqlx.DB) WorkOrderRepository {
	return &workOrderRepository{db: db}
}

func (r *workOrderRepository) Create(ctx context.Context, workOrder *domain.WorkOrder) error {
	query := `
		INSERT INTO work_orders (
			wo_number, vehicle_id, description, assigned_mechanic_id, status,
			progress_percentage, total_parts_cost, labor_cost, total_cost,
			notes, created_by, started_at, completed_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
		RETURNING id, created_at, updated_at
	`
	
	err := r.db.QueryRowContext(ctx, query,
		workOrder.WONumber, workOrder.VehicleID, workOrder.Description,
		workOrder.AssignedMechanicID, workOrder.Status, workOrder.ProgressPercentage,
		workOrder.TotalPartsCost, workOrder.LaborCost, workOrder.TotalCost,
		workOrder.Notes, workOrder.CreatedBy, workOrder.StartedAt, workOrder.CompletedAt,
	).Scan(&workOrder.ID, &workOrder.CreatedAt, &workOrder.UpdatedAt)
	
	if err != nil {
		return fmt.Errorf("failed to create work order: %w", err)
	}
	
	return nil
}

func (r *workOrderRepository) GetByID(ctx context.Context, id int) (*domain.WorkOrder, error) {
	var workOrder domain.WorkOrder
	query := `
		SELECT wo.id, wo.wo_number, wo.vehicle_id, wo.description, wo.assigned_mechanic_id,
			   wo.status, wo.progress_percentage, wo.total_parts_cost, wo.labor_cost,
			   wo.total_cost, wo.notes, wo.created_by, wo.started_at, wo.completed_at,
			   wo.deleted_at, wo.deleted_by, wo.created_at, wo.updated_at,
			   -- Vehicle details
			   v.id as "vehicle.id", v.vehicle_code as "vehicle.vehicle_code",
			   v.brand as "vehicle.brand", v.model as "vehicle.model",
			   v.year as "vehicle.year", v.status as "vehicle.status",
			   -- Assigned mechanic details
			   m.id as "assigned_mechanic.id", m.username as "assigned_mechanic.username",
			   m.full_name as "assigned_mechanic.full_name", m.role as "assigned_mechanic.role",
			   -- Creator details
			   c.id as "creator.id", c.username as "creator.username",
			   c.full_name as "creator.full_name", c.role as "creator.role"
		FROM work_orders wo
		LEFT JOIN vehicles v ON wo.vehicle_id = v.id AND v.deleted_at IS NULL
		LEFT JOIN users m ON wo.assigned_mechanic_id = m.id AND m.deleted_at IS NULL
		LEFT JOIN users c ON wo.created_by = c.id AND c.deleted_at IS NULL
		WHERE wo.id = $1 AND wo.deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &workOrder, query, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get work order: %w", err)
	}
	
	return &workOrder, nil
}

func (r *workOrderRepository) GetByWONumber(ctx context.Context, woNumber string) (*domain.WorkOrder, error) {
	var workOrder domain.WorkOrder
	query := `
		SELECT wo.id, wo.wo_number, wo.vehicle_id, wo.description, wo.assigned_mechanic_id,
			   wo.status, wo.progress_percentage, wo.total_parts_cost, wo.labor_cost,
			   wo.total_cost, wo.notes, wo.created_by, wo.started_at, wo.completed_at,
			   wo.deleted_at, wo.deleted_by, wo.created_at, wo.updated_at
		FROM work_orders wo
		WHERE wo.wo_number = $1 AND wo.deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &workOrder, query, woNumber)
	if err != nil {
		return nil, fmt.Errorf("failed to get work order by number: %w", err)
	}
	
	return &workOrder, nil
}

func (r *workOrderRepository) List(ctx context.Context, offset, limit int) ([]*domain.WorkOrder, error) {
	var workOrders []*domain.WorkOrder
	query := `
		SELECT wo.id, wo.wo_number, wo.vehicle_id, wo.description, wo.assigned_mechanic_id,
			   wo.status, wo.progress_percentage, wo.total_parts_cost, wo.labor_cost,
			   wo.total_cost, wo.notes, wo.created_by, wo.started_at, wo.completed_at,
			   wo.deleted_at, wo.deleted_by, wo.created_at, wo.updated_at,
			   -- Vehicle details
			   v.vehicle_code as "vehicle.vehicle_code", v.brand as "vehicle.brand",
			   v.model as "vehicle.model", v.status as "vehicle.status",
			   -- Assigned mechanic details
			   m.username as "assigned_mechanic.username", m.full_name as "assigned_mechanic.full_name",
			   -- Creator details
			   c.username as "creator.username", c.full_name as "creator.full_name"
		FROM work_orders wo
		LEFT JOIN vehicles v ON wo.vehicle_id = v.id AND v.deleted_at IS NULL
		LEFT JOIN users m ON wo.assigned_mechanic_id = m.id AND m.deleted_at IS NULL
		LEFT JOIN users c ON wo.created_by = c.id AND c.deleted_at IS NULL
		WHERE wo.deleted_at IS NULL
		ORDER BY wo.created_at DESC
		LIMIT $1 OFFSET $2
	`
	
	err := r.db.SelectContext(ctx, &workOrders, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list work orders: %w", err)
	}
	
	return workOrders, nil
}

func (r *workOrderRepository) ListByStatus(ctx context.Context, status domain.WorkOrderStatus, offset, limit int) ([]*domain.WorkOrder, error) {
	var workOrders []*domain.WorkOrder
	query := `
		SELECT wo.id, wo.wo_number, wo.vehicle_id, wo.description, wo.assigned_mechanic_id,
			   wo.status, wo.progress_percentage, wo.total_parts_cost, wo.labor_cost,
			   wo.total_cost, wo.notes, wo.created_by, wo.started_at, wo.completed_at,
			   wo.deleted_at, wo.deleted_by, wo.created_at, wo.updated_at,
			   -- Vehicle details
			   v.vehicle_code as "vehicle.vehicle_code", v.brand as "vehicle.brand",
			   v.model as "vehicle.model", v.status as "vehicle.status",
			   -- Assigned mechanic details
			   m.username as "assigned_mechanic.username", m.full_name as "assigned_mechanic.full_name",
			   -- Creator details
			   c.username as "creator.username", c.full_name as "creator.full_name"
		FROM work_orders wo
		LEFT JOIN vehicles v ON wo.vehicle_id = v.id AND v.deleted_at IS NULL
		LEFT JOIN users m ON wo.assigned_mechanic_id = m.id AND m.deleted_at IS NULL
		LEFT JOIN users c ON wo.created_by = c.id AND c.deleted_at IS NULL
		WHERE wo.deleted_at IS NULL AND wo.status = $1
		ORDER BY wo.created_at DESC
		LIMIT $2 OFFSET $3
	`
	
	err := r.db.SelectContext(ctx, &workOrders, query, status, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list work orders by status: %w", err)
	}
	
	return workOrders, nil
}

func (r *workOrderRepository) ListByMechanic(ctx context.Context, mechanicID int, offset, limit int) ([]*domain.WorkOrder, error) {
	var workOrders []*domain.WorkOrder
	query := `
		SELECT wo.id, wo.wo_number, wo.vehicle_id, wo.description, wo.assigned_mechanic_id,
			   wo.status, wo.progress_percentage, wo.total_parts_cost, wo.labor_cost,
			   wo.total_cost, wo.notes, wo.created_by, wo.started_at, wo.completed_at,
			   wo.deleted_at, wo.deleted_by, wo.created_at, wo.updated_at,
			   -- Vehicle details
			   v.vehicle_code as "vehicle.vehicle_code", v.brand as "vehicle.brand",
			   v.model as "vehicle.model", v.status as "vehicle.status"
		FROM work_orders wo
		LEFT JOIN vehicles v ON wo.vehicle_id = v.id AND v.deleted_at IS NULL
		WHERE wo.deleted_at IS NULL AND wo.assigned_mechanic_id = $1
		ORDER BY wo.created_at DESC
		LIMIT $2 OFFSET $3
	`
	
	err := r.db.SelectContext(ctx, &workOrders, query, mechanicID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list work orders by mechanic: %w", err)
	}
	
	return workOrders, nil
}

func (r *workOrderRepository) Update(ctx context.Context, workOrder *domain.WorkOrder) error {
	query := `
		UPDATE work_orders SET
			description = $2, assigned_mechanic_id = $3, status = $4,
			progress_percentage = $5, total_parts_cost = $6, labor_cost = $7,
			total_cost = $8, notes = $9, started_at = $10, completed_at = $11,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query,
		workOrder.ID, workOrder.Description, workOrder.AssignedMechanicID,
		workOrder.Status, workOrder.ProgressPercentage, workOrder.TotalPartsCost,
		workOrder.LaborCost, workOrder.TotalCost, workOrder.Notes,
		workOrder.StartedAt, workOrder.CompletedAt,
	)
	
	if err != nil {
		return fmt.Errorf("failed to update work order: %w", err)
	}
	
	return nil
}

func (r *workOrderRepository) SoftDelete(ctx context.Context, id int, deletedBy int) error {
	query := `
		UPDATE work_orders SET 
			deleted_at = CURRENT_TIMESTAMP, deleted_by = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query, id, deletedBy)
	if err != nil {
		return fmt.Errorf("failed to soft delete work order: %w", err)
	}
	
	return nil
}

func (r *workOrderRepository) ListByDateRange(ctx context.Context, startDate, endDate time.Time, offset, limit int) ([]*domain.WorkOrder, error) {
	query := `
		SELECT wo.id, wo.wo_number, wo.vehicle_id, wo.description, wo.assigned_mechanic_id, 
		       wo.status, wo.progress_percentage, wo.total_parts_cost, wo.labor_cost, 
		       wo.total_cost, wo.notes, wo.created_by, wo.started_at, wo.completed_at, 
		       wo.created_at, wo.updated_at,
		       v.id, v.vehicle_code, v.brand, v.model, v.year, v.plate_number,
		       u.id, u.username, u.email,
		       c.id, c.username, c.email
		FROM work_orders wo
		LEFT JOIN vehicles v ON wo.vehicle_id = v.id
		LEFT JOIN users u ON wo.assigned_mechanic_id = u.id  
		LEFT JOIN users c ON wo.created_by = c.id
		WHERE wo.deleted_at IS NULL 
		  AND wo.created_at >= $1 
		  AND wo.created_at <= $2
		ORDER BY wo.created_at DESC
		LIMIT $3 OFFSET $4
	`
	
	rows, err := r.db.QueryContext(ctx, query, startDate, endDate, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list work orders by date range: %w", err)
	}
	defer rows.Close()
	
	var workOrders []*domain.WorkOrder
	for rows.Next() {
		var wo domain.WorkOrder
		var vehicle domain.Vehicle
		var mechanic domain.User
		var creator domain.User
		
		err := rows.Scan(
			&wo.ID, &wo.WONumber, &wo.VehicleID, &wo.Description, &wo.AssignedMechanicID,
			&wo.Status, &wo.ProgressPercentage, &wo.TotalPartsCost, &wo.LaborCost,
			&wo.TotalCost, &wo.Notes, &wo.CreatedBy, &wo.StartedAt, &wo.CompletedAt,
			&wo.CreatedAt, &wo.UpdatedAt,
			&vehicle.ID, &vehicle.VehicleCode, &vehicle.Brand, &vehicle.Model, &vehicle.Year, &vehicle.PlateNumber,
			&mechanic.ID, &mechanic.Username, &mechanic.Email,
			&creator.ID, &creator.Username, &creator.Email,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan work order: %w", err)
		}
		
		wo.Vehicle = &vehicle
		wo.AssignedMechanic = &mechanic
		wo.Creator = &creator
		workOrders = append(workOrders, &wo)
	}
	
	return workOrders, nil
}

func (r *workOrderRepository) Count(ctx context.Context) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM work_orders WHERE deleted_at IS NULL`
	
	err := r.db.QueryRowContext(ctx, query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count work orders: %w", err)
	}
	
	return count, nil
}

func (r *workOrderRepository) CountByStatus(ctx context.Context, status domain.WorkOrderStatus) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM work_orders WHERE deleted_at IS NULL AND status = $1`
	
	err := r.db.QueryRowContext(ctx, query, status).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count work orders by status: %w", err)
	}
	
	return count, nil
}

func (r *workOrderRepository) GenerateWONumber(ctx context.Context) (string, error) {
	var count int
	today := time.Now().Format("20060102")
	
	query := `
		SELECT COUNT(*) FROM work_orders 
		WHERE wo_number LIKE $1 AND deleted_at IS NULL
	`
	
	err := r.db.QueryRowContext(ctx, query, fmt.Sprintf("WO-%s%%", today)).Scan(&count)
	if err != nil {
		return "", fmt.Errorf("failed to count work orders for number generation: %w", err)
	}
	
	woNumber := fmt.Sprintf("WO-%s-%04d", today, count+1)
	return woNumber, nil
}

func (r *workOrderRepository) UpdateStatus(ctx context.Context, id int, status domain.WorkOrderStatus) error {
	var query string
	var args []interface{}
	
	if status == domain.WorkOrderStatusInProgress {
		query = `
			UPDATE work_orders SET 
				status = $2, started_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
			WHERE id = $1 AND deleted_at IS NULL
		`
		args = []interface{}{id, status}
	} else if status == domain.WorkOrderStatusCompleted {
		query = `
			UPDATE work_orders SET 
				status = $2, progress_percentage = 100, completed_at = CURRENT_TIMESTAMP, 
				updated_at = CURRENT_TIMESTAMP
			WHERE id = $1 AND deleted_at IS NULL
		`
		args = []interface{}{id, status}
	} else {
		query = `
			UPDATE work_orders SET 
				status = $2, updated_at = CURRENT_TIMESTAMP
			WHERE id = $1 AND deleted_at IS NULL
		`
		args = []interface{}{id, status}
	}
	
	_, err := r.db.ExecContext(ctx, query, args...)
	if err != nil {
		return fmt.Errorf("failed to update work order status: %w", err)
	}
	
	return nil
}

func (r *workOrderRepository) UpdateProgress(ctx context.Context, id int, progress int) error {
	query := `
		UPDATE work_orders SET 
			progress_percentage = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query, id, progress)
	if err != nil {
		return fmt.Errorf("failed to update work order progress: %w", err)
	}
	
	return nil
}