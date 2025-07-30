package repository

import (
	"context"
	"pos-final/internal/domain"
	"time"
)

// UserRepository defines methods for user data access
type UserRepository interface {
	Create(ctx context.Context, user *domain.User) error
	GetByID(ctx context.Context, id int) (*domain.User, error)
	GetByUsername(ctx context.Context, username string) (*domain.User, error)
	GetByEmail(ctx context.Context, email string) (*domain.User, error)
	List(ctx context.Context, offset, limit int) ([]*domain.User, error)
	Update(ctx context.Context, user *domain.User) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	Count(ctx context.Context) (int, error)
	GetByRole(ctx context.Context, role domain.UserRole) ([]*domain.User, error)
}

// CustomerRepository defines methods for customer data access
type CustomerRepository interface {
	Create(ctx context.Context, customer *domain.Customer) error
	GetByID(ctx context.Context, id int) (*domain.Customer, error)
	GetByCustomerCode(ctx context.Context, customerCode string) (*domain.Customer, error)
	List(ctx context.Context, offset, limit int) ([]*domain.Customer, error)
	Update(ctx context.Context, customer *domain.Customer) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	Count(ctx context.Context) (int, error)
	Search(ctx context.Context, query string, offset, limit int) ([]*domain.Customer, error)
	GenerateCustomerCode(ctx context.Context) (string, error)
}

// SupplierRepository defines methods for supplier data access
type SupplierRepository interface {
	Create(ctx context.Context, supplier *domain.Supplier) error
	GetByID(ctx context.Context, id int) (*domain.Supplier, error)
	GetBySupplierCode(ctx context.Context, supplierCode string) (*domain.Supplier, error)
	List(ctx context.Context, offset, limit int) ([]*domain.Supplier, error)
	Update(ctx context.Context, supplier *domain.Supplier) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	Count(ctx context.Context) (int, error)
	Search(ctx context.Context, query string, offset, limit int) ([]*domain.Supplier, error)
	GenerateSupplierCode(ctx context.Context) (string, error)
}

// VehicleCategoryRepository defines methods for vehicle category data access
type VehicleCategoryRepository interface {
	Create(ctx context.Context, category *domain.VehicleCategory) error
	GetByID(ctx context.Context, id int) (*domain.VehicleCategory, error)
	List(ctx context.Context, offset, limit int) ([]*domain.VehicleCategory, error)
	Update(ctx context.Context, category *domain.VehicleCategory) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	Count(ctx context.Context) (int, error)
}

// VehicleRepository defines methods for vehicle data access
type VehicleRepository interface {
	Create(ctx context.Context, vehicle *domain.Vehicle) error
	GetByID(ctx context.Context, id int) (*domain.Vehicle, error)
	GetByVehicleCode(ctx context.Context, vehicleCode string) (*domain.Vehicle, error)
	List(ctx context.Context, offset, limit int) ([]*domain.Vehicle, error)
	ListByStatus(ctx context.Context, status domain.VehicleStatus, offset, limit int) ([]*domain.Vehicle, error)
	ListByCategory(ctx context.Context, categoryID int, offset, limit int) ([]*domain.Vehicle, error)
	Update(ctx context.Context, vehicle *domain.Vehicle) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	Count(ctx context.Context) (int, error)
	CountByStatus(ctx context.Context, status domain.VehicleStatus) (int, error)
	Search(ctx context.Context, query string, offset, limit int) ([]*domain.Vehicle, error)
	GenerateVehicleCode(ctx context.Context) (string, error)
	UpdateStatus(ctx context.Context, id int, status domain.VehicleStatus) error
}

// VehiclePhotoRepository defines methods for vehicle photo data access
type VehiclePhotoRepository interface {
	Create(ctx context.Context, photo *domain.VehiclePhoto) error
	GetByID(ctx context.Context, id int) (*domain.VehiclePhoto, error)
	ListByVehicleID(ctx context.Context, vehicleID int) ([]*domain.VehiclePhoto, error)
	Update(ctx context.Context, photo *domain.VehiclePhoto) error
	Delete(ctx context.Context, id int) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	SetPrimary(ctx context.Context, vehicleID int, photoID int) error
}

// PurchaseInvoiceRepository defines methods for purchase invoice data access
type PurchaseInvoiceRepository interface {
	Create(ctx context.Context, invoice *domain.PurchaseInvoice) error
	GetByID(ctx context.Context, id int) (*domain.PurchaseInvoice, error)
	GetByInvoiceNumber(ctx context.Context, invoiceNumber string) (*domain.PurchaseInvoice, error)
	List(ctx context.Context, offset, limit int) ([]*domain.PurchaseInvoice, error)
	ListByDateRange(ctx context.Context, startDate, endDate time.Time, offset, limit int) ([]*domain.PurchaseInvoice, error)
	ListByTransactionType(ctx context.Context, transactionType domain.TransactionType, offset, limit int) ([]*domain.PurchaseInvoice, error)
	Update(ctx context.Context, invoice *domain.PurchaseInvoice) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	Count(ctx context.Context) (int, error)
	GenerateInvoiceNumber(ctx context.Context, transactionType domain.TransactionType) (string, error)
	GetDailyTotal(ctx context.Context, date time.Time) (float64, int, error)
}

// SalesInvoiceRepository defines methods for sales invoice data access
type SalesInvoiceRepository interface {
	Create(ctx context.Context, invoice *domain.SalesInvoice) error
	GetByID(ctx context.Context, id int) (*domain.SalesInvoice, error)
	GetByInvoiceNumber(ctx context.Context, invoiceNumber string) (*domain.SalesInvoice, error)
	List(ctx context.Context, offset, limit int) ([]*domain.SalesInvoice, error)
	ListByDateRange(ctx context.Context, startDate, endDate time.Time, offset, limit int) ([]*domain.SalesInvoice, error)
	ListByCustomer(ctx context.Context, customerID int, offset, limit int) ([]*domain.SalesInvoice, error)
	Update(ctx context.Context, invoice *domain.SalesInvoice) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	Count(ctx context.Context) (int, error)
	GenerateInvoiceNumber(ctx context.Context) (string, error)
	GetDailyTotal(ctx context.Context, date time.Time) (float64, float64, int, error) // amount, profit, count
}

// WorkOrderRepository defines methods for work order data access
type WorkOrderRepository interface {
	Create(ctx context.Context, workOrder *domain.WorkOrder) error
	GetByID(ctx context.Context, id int) (*domain.WorkOrder, error)
	GetByWONumber(ctx context.Context, woNumber string) (*domain.WorkOrder, error)
	List(ctx context.Context, offset, limit int) ([]*domain.WorkOrder, error)
	ListByStatus(ctx context.Context, status domain.WorkOrderStatus, offset, limit int) ([]*domain.WorkOrder, error)
	ListByMechanic(ctx context.Context, mechanicID int, offset, limit int) ([]*domain.WorkOrder, error)
	Update(ctx context.Context, workOrder *domain.WorkOrder) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	Count(ctx context.Context) (int, error)
	CountByStatus(ctx context.Context, status domain.WorkOrderStatus) (int, error)
	GenerateWONumber(ctx context.Context) (string, error)
	UpdateStatus(ctx context.Context, id int, status domain.WorkOrderStatus) error
	UpdateProgress(ctx context.Context, id int, progress int) error
}

// SparePartRepository defines methods for spare part data access
type SparePartRepository interface {
	Create(ctx context.Context, sparePart *domain.SparePart) error
	GetByID(ctx context.Context, id int) (*domain.SparePart, error)
	GetByPartCode(ctx context.Context, partCode string) (*domain.SparePart, error)
	GetByBarcode(ctx context.Context, barcode string) (*domain.SparePart, error)
	List(ctx context.Context, offset, limit int) ([]*domain.SparePart, error)
	ListLowStock(ctx context.Context, offset, limit int) ([]*domain.SparePart, error)
	Update(ctx context.Context, sparePart *domain.SparePart) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	Count(ctx context.Context) (int, error)
	CountLowStock(ctx context.Context) (int, error)
	Search(ctx context.Context, query string, offset, limit int) ([]*domain.SparePart, error)
	GeneratePartCode(ctx context.Context) (string, error)
	UpdateStock(ctx context.Context, id int, quantity int) error
	AdjustStock(ctx context.Context, id int, adjustment int) error
}

// WorkOrderPartRepository defines methods for work order part data access
type WorkOrderPartRepository interface {
	Create(ctx context.Context, workOrderPart *domain.WorkOrderPart) error
	GetByID(ctx context.Context, id int) (*domain.WorkOrderPart, error)
	ListByWorkOrderID(ctx context.Context, workOrderID int) ([]*domain.WorkOrderPart, error)
	ListBySparePartID(ctx context.Context, sparePartID int, offset, limit int) ([]*domain.WorkOrderPart, error)
	Update(ctx context.Context, workOrderPart *domain.WorkOrderPart) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	GetDailyUsage(ctx context.Context, date time.Time) (int, float64, error) // count, value
}

// StockMovementRepository defines methods for stock movement data access
type StockMovementRepository interface {
	Create(ctx context.Context, movement *domain.StockMovement) error
	GetByID(ctx context.Context, id int) (*domain.StockMovement, error)
	ListBySparePartID(ctx context.Context, sparePartID int, offset, limit int) ([]*domain.StockMovement, error)
	ListByDateRange(ctx context.Context, startDate, endDate time.Time, offset, limit int) ([]*domain.StockMovement, error)
	ListByMovementType(ctx context.Context, movementType domain.MovementType, offset, limit int) ([]*domain.StockMovement, error)
	Update(ctx context.Context, movement *domain.StockMovement) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	Count(ctx context.Context) (int, error)
}

// NotificationRepository defines methods for notification data access
type NotificationRepository interface {
	Create(ctx context.Context, notification *domain.Notification) error
	GetByID(ctx context.Context, id int) (*domain.Notification, error)
	ListByUserID(ctx context.Context, userID int, offset, limit int) ([]*domain.Notification, error)
	ListUnreadByUserID(ctx context.Context, userID int, offset, limit int) ([]*domain.Notification, error)
	Update(ctx context.Context, notification *domain.Notification) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	MarkAsRead(ctx context.Context, id int) error
	MarkAllAsReadByUserID(ctx context.Context, userID int) error
	Count(ctx context.Context) (int, error)
	CountUnreadByUserID(ctx context.Context, userID int) (int, error)
}

// CustomerTransactionSummaryRepository defines methods for customer transaction summary data access
type CustomerTransactionSummaryRepository interface {
	Create(ctx context.Context, summary *domain.CustomerTransactionSummary) error
	GetByCustomerID(ctx context.Context, customerID int) (*domain.CustomerTransactionSummary, error)
	List(ctx context.Context, offset, limit int) ([]*domain.CustomerTransactionSummary, error)
	Update(ctx context.Context, summary *domain.CustomerTransactionSummary) error
	SoftDelete(ctx context.Context, id int, deletedBy int) error
	UpdatePurchaseStats(ctx context.Context, customerID int, amount float64) error
	UpdateSalesStats(ctx context.Context, customerID int, amount float64) error
}

// DailyReportRepository defines methods for daily report data access
type DailyReportRepository interface {
	Create(ctx context.Context, report *domain.DailyReport) error
	GetByDate(ctx context.Context, date time.Time) (*domain.DailyReport, error)
	GetByID(ctx context.Context, id int) (*domain.DailyReport, error)
	List(ctx context.Context, offset, limit int) ([]*domain.DailyReport, error)
	ListByDateRange(ctx context.Context, startDate, endDate time.Time, offset, limit int) ([]*domain.DailyReport, error)
	Update(ctx context.Context, report *domain.DailyReport) error
	Delete(ctx context.Context, id int) error
	Count(ctx context.Context) (int, error)
	GetLatest(ctx context.Context) (*domain.DailyReport, error)
}