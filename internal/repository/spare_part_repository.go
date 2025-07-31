package repository

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"strings"

	"github.com/jmoiron/sqlx"
)

type sparePartRepository struct {
	db *sqlx.DB
}

// NewSparePartRepository creates a new spare part repository
func NewSparePartRepository(db *sqlx.DB) SparePartRepository {
	return &sparePartRepository{db: db}
}

func (r *sparePartRepository) Create(ctx context.Context, sparePart *domain.SparePart) error {
	query := `
		INSERT INTO spare_parts (
			part_code, barcode, name, brand, category, description,
			cost_price, selling_price, stock_quantity, min_stock_level, unit
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id, created_at, updated_at
	`
	
	err := r.db.QueryRowContext(ctx, query,
		sparePart.PartCode, sparePart.Barcode, sparePart.Name, sparePart.Brand,
		sparePart.Category, sparePart.Description, sparePart.CostPrice,
		sparePart.SellingPrice, sparePart.StockQuantity, sparePart.MinStockLevel,
		sparePart.Unit,
	).Scan(&sparePart.ID, &sparePart.CreatedAt, &sparePart.UpdatedAt)
	
	if err != nil {
		return fmt.Errorf("failed to create spare part: %w", err)
	}
	
	return nil
}

func (r *sparePartRepository) GetByID(ctx context.Context, id int) (*domain.SparePart, error) {
	var sparePart domain.SparePart
	query := `
		SELECT id, part_code, barcode, name, brand, category, description,
			   cost_price, selling_price, stock_quantity, min_stock_level, unit,
			   deleted_at, deleted_by, created_at, updated_at
		FROM spare_parts
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &sparePart, query, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get spare part: %w", err)
	}
	
	return &sparePart, nil
}

func (r *sparePartRepository) GetByPartCode(ctx context.Context, partCode string) (*domain.SparePart, error) {
	var sparePart domain.SparePart
	query := `
		SELECT id, part_code, barcode, name, brand, category, description,
			   cost_price, selling_price, stock_quantity, min_stock_level, unit,
			   deleted_at, deleted_by, created_at, updated_at
		FROM spare_parts
		WHERE part_code = $1 AND deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &sparePart, query, partCode)
	if err != nil {
		return nil, fmt.Errorf("failed to get spare part by code: %w", err)
	}
	
	return &sparePart, nil
}

func (r *sparePartRepository) GetByBarcode(ctx context.Context, barcode string) (*domain.SparePart, error) {
	var sparePart domain.SparePart
	query := `
		SELECT id, part_code, barcode, name, brand, category, description,
			   cost_price, selling_price, stock_quantity, min_stock_level, unit,
			   deleted_at, deleted_by, created_at, updated_at
		FROM spare_parts
		WHERE barcode = $1 AND deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &sparePart, query, barcode)
	if err != nil {
		return nil, fmt.Errorf("failed to get spare part by barcode: %w", err)
	}
	
	return &sparePart, nil
}

func (r *sparePartRepository) List(ctx context.Context, offset, limit int) ([]*domain.SparePart, error) {
	var spareParts []*domain.SparePart
	query := `
		SELECT id, part_code, barcode, name, brand, category, description,
			   cost_price, selling_price, stock_quantity, min_stock_level, unit,
			   deleted_at, deleted_by, created_at, updated_at
		FROM spare_parts
		WHERE deleted_at IS NULL
		ORDER BY name ASC
		LIMIT $1 OFFSET $2
	`
	
	err := r.db.SelectContext(ctx, &spareParts, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list spare parts: %w", err)
	}
	
	return spareParts, nil
}

func (r *sparePartRepository) ListLowStock(ctx context.Context, offset, limit int) ([]*domain.SparePart, error) {
	var spareParts []*domain.SparePart
	query := `
		SELECT id, part_code, barcode, name, brand, category, description,
			   cost_price, selling_price, stock_quantity, min_stock_level, unit,
			   deleted_at, deleted_by, created_at, updated_at
		FROM spare_parts
		WHERE deleted_at IS NULL AND stock_quantity <= min_stock_level
		ORDER BY (stock_quantity::float / min_stock_level::float) ASC, name ASC
		LIMIT $1 OFFSET $2
	`
	
	err := r.db.SelectContext(ctx, &spareParts, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list low stock spare parts: %w", err)
	}
	
	return spareParts, nil
}

func (r *sparePartRepository) Update(ctx context.Context, sparePart *domain.SparePart) error {
	query := `
		UPDATE spare_parts SET
			barcode = $2, name = $3, brand = $4, category = $5, description = $6,
			cost_price = $7, selling_price = $8, min_stock_level = $9, unit = $10,
			updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query,
		sparePart.ID, sparePart.Barcode, sparePart.Name, sparePart.Brand,
		sparePart.Category, sparePart.Description, sparePart.CostPrice,
		sparePart.SellingPrice, sparePart.MinStockLevel, sparePart.Unit,
	)
	
	if err != nil {
		return fmt.Errorf("failed to update spare part: %w", err)
	}
	
	return nil
}

func (r *sparePartRepository) SoftDelete(ctx context.Context, id int, deletedBy int) error {
	query := `
		UPDATE spare_parts SET 
			deleted_at = CURRENT_TIMESTAMP, deleted_by = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query, id, deletedBy)
	if err != nil {
		return fmt.Errorf("failed to soft delete spare part: %w", err)
	}
	
	return nil
}

func (r *sparePartRepository) Count(ctx context.Context) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM spare_parts WHERE deleted_at IS NULL`
	
	err := r.db.QueryRowContext(ctx, query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count spare parts: %w", err)
	}
	
	return count, nil
}

func (r *sparePartRepository) CountLowStock(ctx context.Context) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM spare_parts WHERE deleted_at IS NULL AND stock_quantity <= min_stock_level`
	
	err := r.db.QueryRowContext(ctx, query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count low stock spare parts: %w", err)
	}
	
	return count, nil
}

func (r *sparePartRepository) Search(ctx context.Context, query string, offset, limit int) ([]*domain.SparePart, error) {
	var spareParts []*domain.SparePart
	searchQuery := `
		SELECT id, part_code, barcode, name, brand, category, description,
			   cost_price, selling_price, stock_quantity, min_stock_level, unit,
			   deleted_at, deleted_by, created_at, updated_at
		FROM spare_parts
		WHERE deleted_at IS NULL AND (
			LOWER(name) LIKE LOWER($1) OR
			LOWER(brand) LIKE LOWER($1) OR
			LOWER(category) LIKE LOWER($1) OR
			LOWER(part_code) LIKE LOWER($1) OR
			LOWER(barcode) LIKE LOWER($1)
		)
		ORDER BY name ASC
		LIMIT $2 OFFSET $3
	`
	
	searchTerm := "%" + strings.ToLower(query) + "%"
	err := r.db.SelectContext(ctx, &spareParts, searchQuery, searchTerm, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to search spare parts: %w", err)
	}
	
	return spareParts, nil
}

func (r *sparePartRepository) GeneratePartCode(ctx context.Context) (string, error) {
	var count int
	query := `SELECT COUNT(*) FROM spare_parts WHERE deleted_at IS NULL`
	
	err := r.db.QueryRowContext(ctx, query).Scan(&count)
	if err != nil {
		return "", fmt.Errorf("failed to count spare parts for code generation: %w", err)
	}
	
	partCode := fmt.Sprintf("SP-%06d", count+1)
	return partCode, nil
}

func (r *sparePartRepository) UpdateStock(ctx context.Context, id int, quantity int) error {
	query := `
		UPDATE spare_parts SET 
			stock_quantity = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query, id, quantity)
	if err != nil {
		return fmt.Errorf("failed to update spare part stock: %w", err)
	}
	
	return nil
}

func (r *sparePartRepository) AdjustStock(ctx context.Context, id int, adjustment int) error {
	query := `
		UPDATE spare_parts SET 
			stock_quantity = stock_quantity + $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query, id, adjustment)
	if err != nil {
		return fmt.Errorf("failed to adjust spare part stock: %w", err)
	}
	
	return nil
}