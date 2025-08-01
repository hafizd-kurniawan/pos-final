package repository

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"time"

	"github.com/jmoiron/sqlx"
)

type salesInvoiceRepository struct {
	db *sqlx.DB
}

// NewSalesInvoiceRepository creates a new sales invoice repository
func NewSalesInvoiceRepository(db *sqlx.DB) SalesInvoiceRepository {
	return &salesInvoiceRepository{db: db}
}

func (r *salesInvoiceRepository) Create(ctx context.Context, invoice *domain.SalesInvoice) error {
	query := `
		INSERT INTO sales_invoices (
			invoice_number, customer_id, vehicle_id, selling_price,
			discount_percentage, discount_amount, final_price, payment_method,
			transfer_proof, notes, created_by, transaction_date, profit_amount
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
		RETURNING id, created_at
	`
	
	err := r.db.QueryRowContext(ctx, query,
		invoice.InvoiceNumber, invoice.CustomerID, invoice.VehicleID,
		invoice.SellingPrice, invoice.DiscountPercentage, invoice.DiscountAmount,
		invoice.FinalPrice, invoice.PaymentMethod, invoice.TransferProof,
		invoice.Notes, invoice.CreatedBy, invoice.TransactionDate, invoice.ProfitAmount,
	).Scan(&invoice.ID, &invoice.CreatedAt)
	
	if err != nil {
		return fmt.Errorf("failed to create sales invoice: %w", err)
	}
	
	return nil
}

func (r *salesInvoiceRepository) GetByID(ctx context.Context, id int) (*domain.SalesInvoice, error) {
	var invoice domain.SalesInvoice
	query := `
		SELECT si.id, si.invoice_number, si.customer_id, si.vehicle_id, si.selling_price,
			   si.discount_percentage, si.discount_amount, si.final_price, si.payment_method,
			   si.transfer_proof, si.notes, si.created_by, si.transaction_date,
			   si.profit_amount, si.deleted_at, si.deleted_by, si.created_at,
			   -- Customer details
			   c.id as "customer.id", c.customer_code as "customer.customer_code",
			   c.name as "customer.name", c.phone as "customer.phone",
			   c.email as "customer.email", c.address as "customer.address",
			   -- Vehicle details
			   v.id as "vehicle.id", v.vehicle_code as "vehicle.vehicle_code",
			   v.brand as "vehicle.brand", v.model as "vehicle.model",
			   v.year as "vehicle.year", v.status as "vehicle.status",
			   -- Creator details
			   u.id as "creator.id", u.username as "creator.username",
			   u.full_name as "creator.full_name", u.role as "creator.role"
		FROM sales_invoices si
		LEFT JOIN customers c ON si.customer_id = c.id AND c.deleted_at IS NULL
		LEFT JOIN vehicles v ON si.vehicle_id = v.id AND v.deleted_at IS NULL
		LEFT JOIN users u ON si.created_by = u.id AND u.deleted_at IS NULL
		WHERE si.id = $1 AND si.deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &invoice, query, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get sales invoice: %w", err)
	}
	
	return &invoice, nil
}

func (r *salesInvoiceRepository) GetByInvoiceNumber(ctx context.Context, invoiceNumber string) (*domain.SalesInvoice, error) {
	var invoice domain.SalesInvoice
	query := `
		SELECT si.id, si.invoice_number, si.customer_id, si.vehicle_id, si.selling_price,
			   si.discount_percentage, si.discount_amount, si.final_price, si.payment_method,
			   si.transfer_proof, si.notes, si.created_by, si.transaction_date,
			   si.profit_amount, si.deleted_at, si.deleted_by, si.created_at, si.updated_at
		FROM sales_invoices si
		WHERE si.invoice_number = $1 AND si.deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &invoice, query, invoiceNumber)
	if err != nil {
		return nil, fmt.Errorf("failed to get sales invoice by number: %w", err)
	}
	
	return &invoice, nil
}

func (r *salesInvoiceRepository) List(ctx context.Context, offset, limit int) ([]*domain.SalesInvoice, error) {
	var invoices []*domain.SalesInvoice
	query := `
		SELECT si.id, si.invoice_number, si.customer_id, si.vehicle_id, si.selling_price,
			   si.discount_percentage, si.discount_amount, si.final_price, si.payment_method,
			   si.transfer_proof, si.notes, si.created_by, si.transaction_date,
			   si.profit_amount, si.deleted_at, si.deleted_by, si.created_at, 
			   -- Customer details
			   c.name as "customer.name", c.customer_code as "customer.customer_code",
			   -- Vehicle details
			   v.vehicle_code as "vehicle.vehicle_code", v.brand as "vehicle.brand",
			   v.model as "vehicle.model", v.status as "vehicle.status",
			   -- Creator details
			   u.full_name as "creator.full_name", u.username as "creator.username"
		FROM sales_invoices si
		LEFT JOIN customers c ON si.customer_id = c.id AND c.deleted_at IS NULL
		LEFT JOIN vehicles v ON si.vehicle_id = v.id AND v.deleted_at IS NULL
		LEFT JOIN users u ON si.created_by = u.id AND u.deleted_at IS NULL
		WHERE si.deleted_at IS NULL
		ORDER BY si.created_at DESC
		LIMIT $1 OFFSET $2
	`
	
	err := r.db.SelectContext(ctx, &invoices, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list sales invoices: %w", err)
	}
	
	return invoices, nil
}

func (r *salesInvoiceRepository) ListByDateRange(ctx context.Context, startDate, endDate time.Time, offset, limit int) ([]*domain.SalesInvoice, error) {
	var invoices []*domain.SalesInvoice
	query := `
		SELECT si.id, si.invoice_number, si.customer_id, si.vehicle_id, si.selling_price,
			   si.discount_percentage, si.discount_amount, si.final_price, si.payment_method,
			   si.transfer_proof, si.notes, si.created_by, si.transaction_date,
			   si.profit_amount, si.deleted_at, si.deleted_by, si.created_at, si.updated_at
		FROM sales_invoices si
		WHERE si.deleted_at IS NULL 
		  AND si.transaction_date >= $1 
		  AND si.transaction_date <= $2
		ORDER BY si.transaction_date DESC
		LIMIT $3 OFFSET $4
	`
	
	err := r.db.SelectContext(ctx, &invoices, query, startDate, endDate, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list sales invoices by date range: %w", err)
	}
	
	return invoices, nil
}

func (r *salesInvoiceRepository) ListByCustomer(ctx context.Context, customerID int, offset, limit int) ([]*domain.SalesInvoice, error) {
	var invoices []*domain.SalesInvoice
	query := `
		SELECT si.id, si.invoice_number, si.customer_id, si.vehicle_id, si.selling_price,
			   si.discount_percentage, si.discount_amount, si.final_price, si.payment_method,
			   si.transfer_proof, si.notes, si.created_by, si.transaction_date,
			   si.profit_amount, si.deleted_at, si.deleted_by, si.created_at, 
			   -- Vehicle details
			   v.vehicle_code as "vehicle.vehicle_code", v.brand as "vehicle.brand",
			   v.model as "vehicle.model", v.status as "vehicle.status"
		FROM sales_invoices si
		LEFT JOIN vehicles v ON si.vehicle_id = v.id AND v.deleted_at IS NULL
		WHERE si.deleted_at IS NULL AND si.customer_id = $1
		ORDER BY si.created_at DESC
		LIMIT $2 OFFSET $3
	`
	
	err := r.db.SelectContext(ctx, &invoices, query, customerID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list sales invoices by customer: %w", err)
	}
	
	return invoices, nil
}

func (r *salesInvoiceRepository) Update(ctx context.Context, invoice *domain.SalesInvoice) error {
	query := `
		UPDATE sales_invoices SET
			customer_id = $2, selling_price = $3, discount_percentage = $4,
			discount_amount = $5, final_price = $6, payment_method = $7,
			transfer_proof = $8, notes = $9, transaction_date = $10,
			profit_amount = $11, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query,
		invoice.ID, invoice.CustomerID, invoice.SellingPrice, invoice.DiscountPercentage,
		invoice.DiscountAmount, invoice.FinalPrice, invoice.PaymentMethod,
		invoice.TransferProof, invoice.Notes, invoice.TransactionDate, invoice.ProfitAmount,
	)
	
	if err != nil {
		return fmt.Errorf("failed to update sales invoice: %w", err)
	}
	
	return nil
}

func (r *salesInvoiceRepository) SoftDelete(ctx context.Context, id int, deletedBy int) error {
	query := `
		UPDATE sales_invoices SET 
			deleted_at = CURRENT_TIMESTAMP, deleted_by = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query, id, deletedBy)
	if err != nil {
		return fmt.Errorf("failed to soft delete sales invoice: %w", err)
	}
	
	return nil
}

func (r *salesInvoiceRepository) Count(ctx context.Context) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM sales_invoices WHERE deleted_at IS NULL`
	
	err := r.db.QueryRowContext(ctx, query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count sales invoices: %w", err)
	}
	
	return count, nil
}

func (r *salesInvoiceRepository) GenerateInvoiceNumber(ctx context.Context) (string, error) {
	var count int
	today := time.Now().Format("20060102")
	
	query := `
		SELECT COUNT(*) FROM sales_invoices 
		WHERE invoice_number LIKE $1 AND deleted_at IS NULL
	`
	
	err := r.db.QueryRowContext(ctx, query, fmt.Sprintf("INV-%s%%", today)).Scan(&count)
	if err != nil {
		return "", fmt.Errorf("failed to count invoices for number generation: %w", err)
	}
	
	invoiceNumber := fmt.Sprintf("INV-%s-%04d", today, count+1)
	return invoiceNumber, nil
}

func (r *salesInvoiceRepository) GetDailyTotal(ctx context.Context, date time.Time) (float64, float64, int, error) {
	var totalAmount, totalProfit float64
	var count int
	
	startOfDay := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, date.Location())
	endOfDay := startOfDay.Add(24 * time.Hour)
	
	query := `
		SELECT COALESCE(SUM(final_price), 0), COALESCE(SUM(profit_amount), 0), COUNT(*)
		FROM sales_invoices 
		WHERE deleted_at IS NULL 
		  AND transaction_date >= $1 
		  AND transaction_date < $2
	`
	
	err := r.db.QueryRowContext(ctx, query, startOfDay, endOfDay).Scan(&totalAmount, &totalProfit, &count)
	if err != nil {
		return 0, 0, 0, fmt.Errorf("failed to get daily sales total: %w", err)
	}
	
	return totalAmount, totalProfit, count, nil
}