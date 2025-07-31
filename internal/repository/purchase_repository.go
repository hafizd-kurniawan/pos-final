package repository

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"time"

	"github.com/jmoiron/sqlx"
)

type purchaseInvoiceRepository struct {
	db *sqlx.DB
}

// NewPurchaseInvoiceRepository creates a new purchase invoice repository
func NewPurchaseInvoiceRepository(db *sqlx.DB) PurchaseInvoiceRepository {
	return &purchaseInvoiceRepository{db: db}
}

func (r *purchaseInvoiceRepository) Create(ctx context.Context, invoice *domain.PurchaseInvoice) error {
	query := `
		INSERT INTO purchase_invoices (
			invoice_number, transaction_type, customer_id, supplier_id, vehicle_id,
			purchase_price, negotiated_price, final_price, payment_method,
			transfer_proof, notes, created_by, transaction_date
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
		RETURNING id, created_at, updated_at
	`
	
	err := r.db.QueryRowContext(ctx, query,
		invoice.InvoiceNumber, invoice.TransactionType, invoice.CustomerID,
		invoice.SupplierID, invoice.VehicleID, invoice.PurchasePrice,
		invoice.NegotiatedPrice, invoice.FinalPrice, invoice.PaymentMethod,
		invoice.TransferProof, invoice.Notes, invoice.CreatedBy, invoice.TransactionDate,
	).Scan(&invoice.ID, &invoice.CreatedAt, &invoice.UpdatedAt)
	
	if err != nil {
		return fmt.Errorf("failed to create purchase invoice: %w", err)
	}
	
	return nil
}

func (r *purchaseInvoiceRepository) GetByID(ctx context.Context, id int) (*domain.PurchaseInvoice, error) {
	var invoice domain.PurchaseInvoice
	query := `
		SELECT pi.id, pi.invoice_number, pi.transaction_type, pi.customer_id,
			   pi.supplier_id, pi.vehicle_id, pi.purchase_price, pi.negotiated_price,
			   pi.final_price, pi.payment_method, pi.transfer_proof, pi.notes,
			   pi.created_by, pi.transaction_date, pi.deleted_at, pi.deleted_by,
			   pi.created_at, pi.updated_at,
			   -- Customer details
			   c.id as "customer.id", c.customer_code as "customer.customer_code",
			   c.name as "customer.name", c.phone as "customer.phone",
			   c.email as "customer.email", c.address as "customer.address",
			   -- Supplier details  
			   s.id as "supplier.id", s.supplier_code as "supplier.supplier_code",
			   s.name as "supplier.name", s.phone as "supplier.phone",
			   s.email as "supplier.email", s.address as "supplier.address",
			   -- Vehicle details
			   v.id as "vehicle.id", v.vehicle_code as "vehicle.vehicle_code",
			   v.brand as "vehicle.brand", v.model as "vehicle.model",
			   v.year as "vehicle.year", v.status as "vehicle.status",
			   -- Creator details
			   u.id as "creator.id", u.username as "creator.username",
			   u.full_name as "creator.full_name", u.role as "creator.role"
		FROM purchase_invoices pi
		LEFT JOIN customers c ON pi.customer_id = c.id AND c.deleted_at IS NULL
		LEFT JOIN suppliers s ON pi.supplier_id = s.id AND s.deleted_at IS NULL  
		LEFT JOIN vehicles v ON pi.vehicle_id = v.id AND v.deleted_at IS NULL
		LEFT JOIN users u ON pi.created_by = u.id AND u.deleted_at IS NULL
		WHERE pi.id = $1 AND pi.deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &invoice, query, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get purchase invoice: %w", err)
	}
	
	return &invoice, nil
}

func (r *purchaseInvoiceRepository) GetByInvoiceNumber(ctx context.Context, invoiceNumber string) (*domain.PurchaseInvoice, error) {
	var invoice domain.PurchaseInvoice
	query := `
		SELECT pi.id, pi.invoice_number, pi.transaction_type, pi.customer_id,
			   pi.supplier_id, pi.vehicle_id, pi.purchase_price, pi.negotiated_price,
			   pi.final_price, pi.payment_method, pi.transfer_proof, pi.notes,
			   pi.created_by, pi.transaction_date, pi.deleted_at, pi.deleted_by,
			   pi.created_at, pi.updated_at
		FROM purchase_invoices pi
		WHERE pi.invoice_number = $1 AND pi.deleted_at IS NULL
	`
	
	err := r.db.GetContext(ctx, &invoice, query, invoiceNumber)
	if err != nil {
		return nil, fmt.Errorf("failed to get purchase invoice by number: %w", err)
	}
	
	return &invoice, nil
}

func (r *purchaseInvoiceRepository) List(ctx context.Context, offset, limit int) ([]*domain.PurchaseInvoice, error) {
	var invoices []*domain.PurchaseInvoice
	query := `
		SELECT pi.id, pi.invoice_number, pi.transaction_type, pi.customer_id,
			   pi.supplier_id, pi.vehicle_id, pi.purchase_price, pi.negotiated_price,
			   pi.final_price, pi.payment_method, pi.transfer_proof, pi.notes,
			   pi.created_by, pi.transaction_date, pi.deleted_at, pi.deleted_by,
			   pi.created_at, pi.updated_at,
			   -- Customer details
			   c.name as "customer.name", c.customer_code as "customer.customer_code",
			   -- Supplier details  
			   s.name as "supplier.name", s.supplier_code as "supplier.supplier_code",
			   -- Vehicle details
			   v.vehicle_code as "vehicle.vehicle_code", v.brand as "vehicle.brand",
			   v.model as "vehicle.model", v.status as "vehicle.status",
			   -- Creator details
			   u.full_name as "creator.full_name", u.username as "creator.username"
		FROM purchase_invoices pi
		LEFT JOIN customers c ON pi.customer_id = c.id AND c.deleted_at IS NULL
		LEFT JOIN suppliers s ON pi.supplier_id = s.id AND s.deleted_at IS NULL  
		LEFT JOIN vehicles v ON pi.vehicle_id = v.id AND v.deleted_at IS NULL
		LEFT JOIN users u ON pi.created_by = u.id AND u.deleted_at IS NULL
		WHERE pi.deleted_at IS NULL
		ORDER BY pi.created_at DESC
		LIMIT $1 OFFSET $2
	`
	
	err := r.db.SelectContext(ctx, &invoices, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list purchase invoices: %w", err)
	}
	
	return invoices, nil
}

func (r *purchaseInvoiceRepository) ListByDateRange(ctx context.Context, startDate, endDate time.Time, offset, limit int) ([]*domain.PurchaseInvoice, error) {
	var invoices []*domain.PurchaseInvoice
	query := `
		SELECT pi.id, pi.invoice_number, pi.transaction_type, pi.customer_id,
			   pi.supplier_id, pi.vehicle_id, pi.purchase_price, pi.negotiated_price,
			   pi.final_price, pi.payment_method, pi.transfer_proof, pi.notes,
			   pi.created_by, pi.transaction_date, pi.deleted_at, pi.deleted_by,
			   pi.created_at, pi.updated_at
		FROM purchase_invoices pi
		WHERE pi.deleted_at IS NULL 
		  AND pi.transaction_date >= $1 
		  AND pi.transaction_date <= $2
		ORDER BY pi.transaction_date DESC
		LIMIT $3 OFFSET $4
	`
	
	err := r.db.SelectContext(ctx, &invoices, query, startDate, endDate, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list purchase invoices by date range: %w", err)
	}
	
	return invoices, nil
}

func (r *purchaseInvoiceRepository) ListByTransactionType(ctx context.Context, transactionType domain.TransactionType, offset, limit int) ([]*domain.PurchaseInvoice, error) {
	var invoices []*domain.PurchaseInvoice
	query := `
		SELECT pi.id, pi.invoice_number, pi.transaction_type, pi.customer_id,
			   pi.supplier_id, pi.vehicle_id, pi.purchase_price, pi.negotiated_price,
			   pi.final_price, pi.payment_method, pi.transfer_proof, pi.notes,
			   pi.created_by, pi.transaction_date, pi.deleted_at, pi.deleted_by,
			   pi.created_at, pi.updated_at
		FROM purchase_invoices pi
		WHERE pi.deleted_at IS NULL AND pi.transaction_type = $1
		ORDER BY pi.created_at DESC
		LIMIT $2 OFFSET $3
	`
	
	err := r.db.SelectContext(ctx, &invoices, query, transactionType, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list purchase invoices by transaction type: %w", err)
	}
	
	return invoices, nil
}

func (r *purchaseInvoiceRepository) Update(ctx context.Context, invoice *domain.PurchaseInvoice) error {
	query := `
		UPDATE purchase_invoices SET
			transaction_type = $2, customer_id = $3, supplier_id = $4,
			purchase_price = $5, negotiated_price = $6, final_price = $7,
			payment_method = $8, transfer_proof = $9, notes = $10,
			transaction_date = $11, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query,
		invoice.ID, invoice.TransactionType, invoice.CustomerID, invoice.SupplierID,
		invoice.PurchasePrice, invoice.NegotiatedPrice, invoice.FinalPrice,
		invoice.PaymentMethod, invoice.TransferProof, invoice.Notes, invoice.TransactionDate,
	)
	
	if err != nil {
		return fmt.Errorf("failed to update purchase invoice: %w", err)
	}
	
	return nil
}

func (r *purchaseInvoiceRepository) SoftDelete(ctx context.Context, id int, deletedBy int) error {
	query := `
		UPDATE purchase_invoices SET 
			deleted_at = CURRENT_TIMESTAMP, deleted_by = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query, id, deletedBy)
	if err != nil {
		return fmt.Errorf("failed to soft delete purchase invoice: %w", err)
	}
	
	return nil
}

func (r *purchaseInvoiceRepository) Count(ctx context.Context) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM purchase_invoices WHERE deleted_at IS NULL`
	
	err := r.db.QueryRowContext(ctx, query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count purchase invoices: %w", err)
	}
	
	return count, nil
}

func (r *purchaseInvoiceRepository) GenerateInvoiceNumber(ctx context.Context, transactionType domain.TransactionType) (string, error) {
	var count int
	today := time.Now().Format("20060102")
	
	prefix := "PUR"
	if transactionType == domain.TransactionTypeCustomer {
		prefix = "PUR-CUS"
	} else if transactionType == domain.TransactionTypeSupplier {
		prefix = "PUR-SUP"
	}
	
	query := `
		SELECT COUNT(*) FROM purchase_invoices 
		WHERE invoice_number LIKE $1 AND deleted_at IS NULL
	`
	
	err := r.db.QueryRowContext(ctx, query, fmt.Sprintf("%s-%s%%", prefix, today)).Scan(&count)
	if err != nil {
		return "", fmt.Errorf("failed to count invoices for number generation: %w", err)
	}
	
	invoiceNumber := fmt.Sprintf("%s-%s-%04d", prefix, today, count+1)
	return invoiceNumber, nil
}

func (r *purchaseInvoiceRepository) GetDailyTotal(ctx context.Context, date time.Time) (float64, int, error) {
	var total float64
	var count int
	
	startOfDay := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, date.Location())
	endOfDay := startOfDay.Add(24 * time.Hour)
	
	query := `
		SELECT COALESCE(SUM(final_price), 0), COUNT(*)
		FROM purchase_invoices 
		WHERE deleted_at IS NULL 
		  AND transaction_date >= $1 
		  AND transaction_date < $2
	`
	
	err := r.db.QueryRowContext(ctx, query, startOfDay, endOfDay).Scan(&total, &count)
	if err != nil {
		return 0, 0, fmt.Errorf("failed to get daily purchase total: %w", err)
	}
	
	return total, count, nil
}