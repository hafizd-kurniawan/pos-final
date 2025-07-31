package repository

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"strings"

	"github.com/jmoiron/sqlx"
)

type vehicleRepository struct {
	db *sqlx.DB
}

// NewVehicleRepository creates a new vehicle repository
func NewVehicleRepository(db *sqlx.DB) VehicleRepository {
	return &vehicleRepository{db: db}
}

func (r *vehicleRepository) Create(ctx context.Context, vehicle *domain.Vehicle) error {
	query := `
		INSERT INTO vehicles (
			vehicle_code, category_id, brand, model, year, chassis_number, engine_number,
			plate_number, color, fuel_type, transmission, purchase_price, repair_cost,
			hpp, selling_price, status, condition_notes, primary_photo, purchased_date
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
		RETURNING id, created_at, updated_at
	`
	
	err := r.db.QueryRowContext(ctx, query,
		vehicle.VehicleCode, vehicle.CategoryID, vehicle.Brand, vehicle.Model, vehicle.Year,
		vehicle.ChassisNumber, vehicle.EngineNumber, vehicle.PlateNumber, vehicle.Color,
		vehicle.FuelType, vehicle.Transmission, vehicle.PurchasePrice, vehicle.RepairCost,
		vehicle.HPP, vehicle.SellingPrice, vehicle.Status, vehicle.ConditionNotes,
		vehicle.PrimaryPhoto, vehicle.PurchasedDate,
	).Scan(&vehicle.ID, &vehicle.CreatedAt, &vehicle.UpdatedAt)
	
	if err != nil {
		return fmt.Errorf("failed to create vehicle: %w", err)
	}
	
	return nil
}

func (r *vehicleRepository) GetByID(ctx context.Context, id int) (*domain.Vehicle, error) {
	var vehicle domain.Vehicle
	query := `
		SELECT v.id, v.vehicle_code, v.category_id, v.brand, v.model, v.year,
			   v.chassis_number, v.engine_number, v.plate_number, v.color, v.fuel_type,
			   v.transmission, v.purchase_price, v.repair_cost, v.hpp, v.selling_price,
			   v.status, v.condition_notes, v.primary_photo, v.purchased_date, v.sold_date,
			   v.deleted_at, v.deleted_by, v.created_at, v.updated_at,
			   vc.id as "category.id", vc.name as "category.name", vc.description as "category.description"
		FROM vehicles v
		LEFT JOIN vehicle_categories vc ON v.category_id = vc.id AND vc.deleted_at IS NULL
		WHERE v.id = $1 AND v.deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &vehicle, query, id)
	if err != nil {
		if IsNoRowsError(err) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get vehicle by ID: %w", err)
	}
	
	return &vehicle, nil
}

func (r *vehicleRepository) GetByVehicleCode(ctx context.Context, vehicleCode string) (*domain.Vehicle, error) {
	var vehicle domain.Vehicle
	query := `
		SELECT v.id, v.vehicle_code, v.category_id, v.brand, v.model, v.year,
			   v.chassis_number, v.engine_number, v.plate_number, v.color, v.fuel_type,
			   v.transmission, v.purchase_price, v.repair_cost, v.hpp, v.selling_price,
			   v.status, v.condition_notes, v.primary_photo, v.purchased_date, v.sold_date,
			   v.deleted_at, v.deleted_by, v.created_at, v.updated_at,
			   vc.id as "category.id", vc.name as "category.name", vc.description as "category.description"
		FROM vehicles v
		LEFT JOIN vehicle_categories vc ON v.category_id = vc.id AND vc.deleted_at IS NULL
		WHERE v.vehicle_code = $1 AND v.deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &vehicle, query, vehicleCode)
	if err != nil {
		if IsNoRowsError(err) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to get vehicle by vehicle code: %w", err)
	}
	
	return &vehicle, nil
}

func (r *vehicleRepository) List(ctx context.Context, offset, limit int) ([]*domain.Vehicle, error) {
	var vehicles []*domain.Vehicle
	query := `
		SELECT v.id, v.vehicle_code, v.category_id, v.brand, v.model, v.year,
			   v.chassis_number, v.engine_number, v.plate_number, v.color, v.fuel_type,
			   v.transmission, v.purchase_price, v.repair_cost, v.hpp, v.selling_price,
			   v.status, v.condition_notes, v.primary_photo, v.purchased_date, v.sold_date,
			   v.deleted_at, v.deleted_by, v.created_at, v.updated_at,
			   vc.id as "category.id", vc.name as "category.name", vc.description as "category.description"
		FROM vehicles v
		LEFT JOIN vehicle_categories vc ON v.category_id = vc.id AND vc.deleted_at IS NULL
		WHERE v.deleted_at IS NULL
		ORDER BY v.created_at DESC
		LIMIT $1 OFFSET $2
	`
	
	err := r.db.SelectContext(ctx, &vehicles, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list vehicles: %w", err)
	}
	
	return vehicles, nil
}

func (r *vehicleRepository) ListByStatus(ctx context.Context, status domain.VehicleStatus, offset, limit int) ([]*domain.Vehicle, error) {
	var vehicles []*domain.Vehicle
	query := `
		SELECT v.id, v.vehicle_code, v.category_id, v.brand, v.model, v.year,
			   v.chassis_number, v.engine_number, v.plate_number, v.color, v.fuel_type,
			   v.transmission, v.purchase_price, v.repair_cost, v.hpp, v.selling_price,
			   v.status, v.condition_notes, v.primary_photo, v.purchased_date, v.sold_date,
			   v.deleted_at, v.deleted_by, v.created_at, v.updated_at,
			   vc.id as "category.id", vc.name as "category.name", vc.description as "category.description"
		FROM vehicles v
		LEFT JOIN vehicle_categories vc ON v.category_id = vc.id AND vc.deleted_at IS NULL
		WHERE v.status = $1 AND v.deleted_at IS NULL
		ORDER BY v.created_at DESC
		LIMIT $2 OFFSET $3
	`
	
	err := r.db.SelectContext(ctx, &vehicles, query, status, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list vehicles by status: %w", err)
	}
	
	return vehicles, nil
}

func (r *vehicleRepository) ListByCategory(ctx context.Context, categoryID int, offset, limit int) ([]*domain.Vehicle, error) {
	var vehicles []*domain.Vehicle
	query := `
		SELECT v.id, v.vehicle_code, v.category_id, v.brand, v.model, v.year,
			   v.chassis_number, v.engine_number, v.plate_number, v.color, v.fuel_type,
			   v.transmission, v.purchase_price, v.repair_cost, v.hpp, v.selling_price,
			   v.status, v.condition_notes, v.primary_photo, v.purchased_date, v.sold_date,
			   v.deleted_at, v.deleted_by, v.created_at, v.updated_at,
			   vc.id as "category.id", vc.name as "category.name", vc.description as "category.description"
		FROM vehicles v
		LEFT JOIN vehicle_categories vc ON v.category_id = vc.id AND vc.deleted_at IS NULL
		WHERE v.category_id = $1 AND v.deleted_at IS NULL
		ORDER BY v.created_at DESC
		LIMIT $2 OFFSET $3
	`
	
	err := r.db.SelectContext(ctx, &vehicles, query, categoryID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list vehicles by category: %w", err)
	}
	
	return vehicles, nil
}

func (r *vehicleRepository) Update(ctx context.Context, vehicle *domain.Vehicle) error {
	query := `
		UPDATE vehicles
		SET brand = $2, model = $3, year = $4, chassis_number = $5, engine_number = $6,
			plate_number = $7, color = $8, fuel_type = $9, transmission = $10,
			purchase_price = $11, repair_cost = $12, hpp = $13, selling_price = $14,
			status = $15, condition_notes = $16, primary_photo = $17, sold_date = $18,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
		RETURNING updated_at
	`
	
	err := r.db.QueryRowContext(ctx, query,
		vehicle.ID, vehicle.Brand, vehicle.Model, vehicle.Year, vehicle.ChassisNumber,
		vehicle.EngineNumber, vehicle.PlateNumber, vehicle.Color, vehicle.FuelType,
		vehicle.Transmission, vehicle.PurchasePrice, vehicle.RepairCost, vehicle.HPP,
		vehicle.SellingPrice, vehicle.Status, vehicle.ConditionNotes, vehicle.PrimaryPhoto,
		vehicle.SoldDate,
	).Scan(&vehicle.UpdatedAt)
	
	if err != nil {
		return fmt.Errorf("failed to update vehicle: %w", err)
	}
	
	return nil
}

func (r *vehicleRepository) SoftDelete(ctx context.Context, id int, deletedBy int) error {
	query := `
		UPDATE vehicles
		SET deleted_at = CURRENT_TIMESTAMP, deleted_by = $2
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	result, err := r.db.ExecContext(ctx, query, id, deletedBy)
	if err != nil {
		return fmt.Errorf("failed to delete vehicle: %w", err)
	}
	
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	
	if rowsAffected == 0 {
		return fmt.Errorf("vehicle not found or already deleted")
	}
	
	return nil
}

func (r *vehicleRepository) Count(ctx context.Context) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM vehicles WHERE deleted_at IS NULL`
	
	err := r.db.GetContext(ctx, &count, query)
	if err != nil {
		return 0, fmt.Errorf("failed to count vehicles: %w", err)
	}
	
	return count, nil
}

func (r *vehicleRepository) CountByStatus(ctx context.Context, status domain.VehicleStatus) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM vehicles WHERE status = $1 AND deleted_at IS NULL`
	
	err := r.db.GetContext(ctx, &count, query, status)
	if err != nil {
		return 0, fmt.Errorf("failed to count vehicles by status: %w", err)
	}
	
	return count, nil
}

func (r *vehicleRepository) Search(ctx context.Context, query string, offset, limit int) ([]*domain.Vehicle, error) {
	var vehicles []*domain.Vehicle
	searchQuery := `
		SELECT v.id, v.vehicle_code, v.category_id, v.brand, v.model, v.year,
			   v.chassis_number, v.engine_number, v.plate_number, v.color, v.fuel_type,
			   v.transmission, v.purchase_price, v.repair_cost, v.hpp, v.selling_price,
			   v.status, v.condition_notes, v.primary_photo, v.purchased_date, v.sold_date,
			   v.deleted_at, v.deleted_by, v.created_at, v.updated_at,
			   vc.id as "category.id", vc.name as "category.name", vc.description as "category.description"
		FROM vehicles v
		LEFT JOIN vehicle_categories vc ON v.category_id = vc.id AND vc.deleted_at IS NULL
		WHERE v.deleted_at IS NULL
		AND (
			v.vehicle_code ILIKE $1 OR
			v.brand ILIKE $1 OR
			v.model ILIKE $1 OR
			v.plate_number ILIKE $1 OR
			v.chassis_number ILIKE $1 OR
			v.engine_number ILIKE $1
		)
		ORDER BY v.created_at DESC
		LIMIT $2 OFFSET $3
	`
	
	searchTerm := "%" + strings.ToLower(query) + "%"
	err := r.db.SelectContext(ctx, &vehicles, searchQuery, searchTerm, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to search vehicles: %w", err)
	}
	
	return vehicles, nil
}

func (r *vehicleRepository) GenerateVehicleCode(ctx context.Context) (string, error) {
	var lastNumber int
	query := `
		SELECT COALESCE(MAX(CAST(SUBSTRING(vehicle_code FROM 4) AS INTEGER)), 0)
		FROM vehicles
		WHERE vehicle_code LIKE 'VH-%'
		AND deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &lastNumber, query)
	if err != nil {
		return "", fmt.Errorf("failed to generate vehicle code: %w", err)
	}
	
	return fmt.Sprintf("VH-%04d", lastNumber+1), nil
}

func (r *vehicleRepository) UpdateStatus(ctx context.Context, id int, status domain.VehicleStatus) error {
	query := `
		UPDATE vehicles
		SET status = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	result, err := r.db.ExecContext(ctx, query, id, status)
	if err != nil {
		return fmt.Errorf("failed to update vehicle status: %w", err)
	}
	
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	
	if rowsAffected == 0 {
		return fmt.Errorf("vehicle not found")
	}
	
	return nil
}