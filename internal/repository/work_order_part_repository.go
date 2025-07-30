package repository

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"time"

	"github.com/jmoiron/sqlx"
)

type workOrderPartRepository struct {
	db *sqlx.DB
}

// NewWorkOrderPartRepository creates a new work order part repository
func NewWorkOrderPartRepository(db *sqlx.DB) WorkOrderPartRepository {
	return &workOrderPartRepository{db: db}
}

func (r *workOrderPartRepository) Create(ctx context.Context, workOrderPart *domain.WorkOrderPart) error {
	query := `
		INSERT INTO work_order_parts (
			work_order_id, spare_part_id, quantity_used, unit_cost,
			total_cost, used_by, usage_date, used_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id
	`
	
	err := r.db.QueryRowContext(ctx, query,
		workOrderPart.WorkOrderID, workOrderPart.SparePartID, workOrderPart.QuantityUsed,
		workOrderPart.UnitCost, workOrderPart.TotalCost, workOrderPart.UsedBy,
		workOrderPart.UsageDate, workOrderPart.UsedAt,
	).Scan(&workOrderPart.ID)
	
	if err != nil {
		return fmt.Errorf("failed to create work order part: %w", err)
	}
	
	return nil
}

func (r *workOrderPartRepository) GetByID(ctx context.Context, id int) (*domain.WorkOrderPart, error) {
	var workOrderPart domain.WorkOrderPart
	query := `
		SELECT wop.id, wop.work_order_id, wop.spare_part_id, wop.quantity_used,
			   wop.unit_cost, wop.total_cost, wop.used_by, wop.usage_date,
			   wop.deleted_at, wop.deleted_by, wop.used_at,
			   -- Spare part details
			   sp.id as "spare_part.id", sp.part_code as "spare_part.part_code",
			   sp.name as "spare_part.name", sp.brand as "spare_part.brand",
			   sp.unit as "spare_part.unit",
			   -- User details
			   u.id as "user.id", u.username as "user.username",
			   u.full_name as "user.full_name"
		FROM work_order_parts wop
		LEFT JOIN spare_parts sp ON wop.spare_part_id = sp.id AND sp.deleted_at IS NULL
		LEFT JOIN users u ON wop.used_by = u.id AND u.deleted_at IS NULL
		WHERE wop.id = $1 AND wop.deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &workOrderPart, query, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get work order part: %w", err)
	}
	
	return &workOrderPart, nil
}

func (r *workOrderPartRepository) ListByWorkOrderID(ctx context.Context, workOrderID int) ([]*domain.WorkOrderPart, error) {
	var workOrderParts []*domain.WorkOrderPart
	query := `
		SELECT wop.id, wop.work_order_id, wop.spare_part_id, wop.quantity_used,
			   wop.unit_cost, wop.total_cost, wop.used_by, wop.usage_date,
			   wop.deleted_at, wop.deleted_by, wop.used_at,
			   -- Spare part details
			   sp.id as "spare_part.id", sp.part_code as "spare_part.part_code",
			   sp.name as "spare_part.name", sp.brand as "spare_part.brand",
			   sp.unit as "spare_part.unit",
			   -- User details
			   u.id as "user.id", u.username as "user.username",
			   u.full_name as "user.full_name"
		FROM work_order_parts wop
		LEFT JOIN spare_parts sp ON wop.spare_part_id = sp.id AND sp.deleted_at IS NULL
		LEFT JOIN users u ON wop.used_by = u.id AND u.deleted_at IS NULL
		WHERE wop.work_order_id = $1 AND wop.deleted_at IS NULL
		ORDER BY wop.used_at DESC
	`
	
	err := r.db.SelectContext(ctx, &workOrderParts, query, workOrderID)
	if err != nil {
		return nil, fmt.Errorf("failed to list work order parts by work order ID: %w", err)
	}
	
	return workOrderParts, nil
}

func (r *workOrderPartRepository) ListBySparePartID(ctx context.Context, sparePartID int, offset, limit int) ([]*domain.WorkOrderPart, error) {
	var workOrderParts []*domain.WorkOrderPart
	query := `
		SELECT wop.id, wop.work_order_id, wop.spare_part_id, wop.quantity_used,
			   wop.unit_cost, wop.total_cost, wop.used_by, wop.usage_date,
			   wop.deleted_at, wop.deleted_by, wop.used_at,
			   -- User details
			   u.id as "user.id", u.username as "user.username",
			   u.full_name as "user.full_name"
		FROM work_order_parts wop
		LEFT JOIN users u ON wop.used_by = u.id AND u.deleted_at IS NULL
		WHERE wop.spare_part_id = $1 AND wop.deleted_at IS NULL
		ORDER BY wop.used_at DESC
		LIMIT $2 OFFSET $3
	`
	
	err := r.db.SelectContext(ctx, &workOrderParts, query, sparePartID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list work order parts by spare part ID: %w", err)
	}
	
	return workOrderParts, nil
}

func (r *workOrderPartRepository) Update(ctx context.Context, workOrderPart *domain.WorkOrderPart) error {
	query := `
		UPDATE work_order_parts SET
			quantity_used = $2, unit_cost = $3, total_cost = $4,
			usage_date = $5
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query,
		workOrderPart.ID, workOrderPart.QuantityUsed, workOrderPart.UnitCost,
		workOrderPart.TotalCost, workOrderPart.UsageDate,
	)
	
	if err != nil {
		return fmt.Errorf("failed to update work order part: %w", err)
	}
	
	return nil
}

func (r *workOrderPartRepository) SoftDelete(ctx context.Context, id int, deletedBy int) error {
	query := `
		UPDATE work_order_parts SET 
			deleted_at = CURRENT_TIMESTAMP, deleted_by = $2
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query, id, deletedBy)
	if err != nil {
		return fmt.Errorf("failed to soft delete work order part: %w", err)
	}
	
	return nil
}

func (r *workOrderPartRepository) GetDailyUsage(ctx context.Context, date time.Time) (int, float64, error) {
	var count int
	var totalValue float64
	
	startOfDay := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, date.Location())
	endOfDay := startOfDay.Add(24 * time.Hour)
	
	query := `
		SELECT COUNT(*), COALESCE(SUM(total_cost), 0)
		FROM work_order_parts 
		WHERE deleted_at IS NULL 
		  AND usage_date >= $1 
		  AND usage_date < $2
	`
	
	err := r.db.QueryRowContext(ctx, query, startOfDay, endOfDay).Scan(&count, &totalValue)
	if err != nil {
		return 0, 0, fmt.Errorf("failed to get daily usage: %w", err)
	}
	
	return count, totalValue, nil
}