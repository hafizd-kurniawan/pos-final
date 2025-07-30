package service

import (
	"context"
	"mime/multipart"
	"pos-final/internal/domain"
	"time"
)

// AuthService defines methods for authentication and authorization
type AuthService interface {
	Login(ctx context.Context, username, password string) (*domain.User, string, error)
	Register(ctx context.Context, user *domain.User, password string) error
	ValidateToken(token string) (*domain.User, error)
	RefreshToken(ctx context.Context, userID int) (string, error)
	ChangePassword(ctx context.Context, userID int, oldPassword, newPassword string) error
	ResetPassword(ctx context.Context, email string) error
}

// UserService defines methods for user management
type UserService interface {
	CreateUser(ctx context.Context, user *domain.User, password string) error
	GetUserByID(ctx context.Context, id int) (*domain.User, error)
	GetUserByUsername(ctx context.Context, username string) (*domain.User, error)
	ListUsers(ctx context.Context, page, limit int) ([]*domain.User, int, error)
	UpdateUser(ctx context.Context, user *domain.User) error
	DeleteUser(ctx context.Context, id int, deletedBy int) error
	GetUsersByRole(ctx context.Context, role domain.UserRole) ([]*domain.User, error)
	ActivateUser(ctx context.Context, id int, isActive bool) error
}

// CustomerService defines methods for customer management
type CustomerService interface {
	CreateCustomer(ctx context.Context, customer *domain.Customer) error
	GetCustomerByID(ctx context.Context, id int) (*domain.Customer, error)
	GetCustomerByCode(ctx context.Context, customerCode string) (*domain.Customer, error)
	ListCustomers(ctx context.Context, page, limit int) ([]*domain.Customer, int, error)
	SearchCustomers(ctx context.Context, query string, page, limit int) ([]*domain.Customer, int, error)
	UpdateCustomer(ctx context.Context, customer *domain.Customer) error
	DeleteCustomer(ctx context.Context, id int, deletedBy int) error
}

// SupplierService defines methods for supplier management
type SupplierService interface {
	CreateSupplier(ctx context.Context, supplier *domain.Supplier) error
	GetSupplierByID(ctx context.Context, id int) (*domain.Supplier, error)
	GetSupplierByCode(ctx context.Context, supplierCode string) (*domain.Supplier, error)
	ListSuppliers(ctx context.Context, page, limit int) ([]*domain.Supplier, int, error)
	SearchSuppliers(ctx context.Context, query string, page, limit int) ([]*domain.Supplier, int, error)
	UpdateSupplier(ctx context.Context, supplier *domain.Supplier) error
	DeleteSupplier(ctx context.Context, id int, deletedBy int) error
}

// VehicleCategoryService defines methods for vehicle category management
type VehicleCategoryService interface {
	CreateCategory(ctx context.Context, category *domain.VehicleCategory) error
	GetCategoryByID(ctx context.Context, id int) (*domain.VehicleCategory, error)
	ListCategories(ctx context.Context, page, limit int) ([]*domain.VehicleCategory, int, error)
	UpdateCategory(ctx context.Context, category *domain.VehicleCategory) error
	DeleteCategory(ctx context.Context, id int, deletedBy int) error
}

// VehicleService defines methods for vehicle management
type VehicleService interface {
	CreateVehicle(ctx context.Context, vehicle *domain.Vehicle) error
	GetVehicleByID(ctx context.Context, id int) (*domain.Vehicle, error)
	GetVehicleByCode(ctx context.Context, vehicleCode string) (*domain.Vehicle, error)
	ListVehicles(ctx context.Context, page, limit int) ([]*domain.Vehicle, int, error)
	ListVehiclesByStatus(ctx context.Context, status domain.VehicleStatus, page, limit int) ([]*domain.Vehicle, int, error)
	ListVehiclesByCategory(ctx context.Context, categoryID int, page, limit int) ([]*domain.Vehicle, int, error)
	SearchVehicles(ctx context.Context, query string, page, limit int) ([]*domain.Vehicle, int, error)
	UpdateVehicle(ctx context.Context, vehicle *domain.Vehicle) error
	DeleteVehicle(ctx context.Context, id int, deletedBy int) error
	UpdateVehicleStatus(ctx context.Context, id int, status domain.VehicleStatus) error
	CalculateHPP(ctx context.Context, vehicleID int) error
}

// VehiclePhotoService defines methods for vehicle photo management
type VehiclePhotoService interface {
	UploadPhoto(ctx context.Context, vehicleID int, photoType domain.VehiclePhotoType, file *multipart.FileHeader, description string) (*domain.VehiclePhoto, error)
	GetPhotosByVehicleID(ctx context.Context, vehicleID int) ([]*domain.VehiclePhoto, error)
	SetPrimaryPhoto(ctx context.Context, vehicleID int, photoID int) error
	DeletePhoto(ctx context.Context, id int, deletedBy int) error
	UpdatePhotoDescription(ctx context.Context, id int, description string) error
}

// PurchaseService defines methods for purchase management
type PurchaseService interface {
	CreatePurchaseInvoice(ctx context.Context, invoice *domain.PurchaseInvoice) error
	GetPurchaseInvoiceByID(ctx context.Context, id int) (*domain.PurchaseInvoice, error)
	GetPurchaseInvoiceByNumber(ctx context.Context, invoiceNumber string) (*domain.PurchaseInvoice, error)
	ListPurchaseInvoices(ctx context.Context, page, limit int) ([]*domain.PurchaseInvoice, int, error)
	ListPurchaseInvoicesByDateRange(ctx context.Context, startDate, endDate time.Time, page, limit int) ([]*domain.PurchaseInvoice, int, error)
	UpdatePurchaseInvoice(ctx context.Context, invoice *domain.PurchaseInvoice) error
	DeletePurchaseInvoice(ctx context.Context, id int, deletedBy int) error
	UploadTransferProof(ctx context.Context, invoiceID int, file *multipart.FileHeader) error
	GetDailyPurchaseReport(ctx context.Context, date time.Time) (float64, int, error)
}

// SalesService defines methods for sales management
type SalesService interface {
	CreateSalesInvoice(ctx context.Context, invoice *domain.SalesInvoice) error
	GetSalesInvoiceByID(ctx context.Context, id int) (*domain.SalesInvoice, error)
	GetSalesInvoiceByNumber(ctx context.Context, invoiceNumber string) (*domain.SalesInvoice, error)
	ListSalesInvoices(ctx context.Context, page, limit int) ([]*domain.SalesInvoice, int, error)
	ListSalesInvoicesByDateRange(ctx context.Context, startDate, endDate time.Time, page, limit int) ([]*domain.SalesInvoice, int, error)
	ListSalesInvoicesByCustomer(ctx context.Context, customerID int, page, limit int) ([]*domain.SalesInvoice, int, error)
	UpdateSalesInvoice(ctx context.Context, invoice *domain.SalesInvoice) error
	DeleteSalesInvoice(ctx context.Context, id int, deletedBy int) error
	UploadTransferProof(ctx context.Context, invoiceID int, file *multipart.FileHeader) error
	GetDailySalesReport(ctx context.Context, date time.Time) (float64, float64, int, error) // amount, profit, count
	GenerateInvoicePDF(ctx context.Context, invoiceID int) ([]byte, error)
}

// WorkOrderService defines methods for work order management
type WorkOrderService interface {
	CreateWorkOrder(ctx context.Context, workOrder *domain.WorkOrder) error
	GetWorkOrderByID(ctx context.Context, id int) (*domain.WorkOrder, error)
	GetWorkOrderByNumber(ctx context.Context, woNumber string) (*domain.WorkOrder, error)
	ListWorkOrders(ctx context.Context, page, limit int) ([]*domain.WorkOrder, int, error)
	ListWorkOrdersByStatus(ctx context.Context, status domain.WorkOrderStatus, page, limit int) ([]*domain.WorkOrder, int, error)
	ListWorkOrdersByMechanic(ctx context.Context, mechanicID int, page, limit int) ([]*domain.WorkOrder, int, error)
	UpdateWorkOrder(ctx context.Context, workOrder *domain.WorkOrder) error
	DeleteWorkOrder(ctx context.Context, id int, deletedBy int) error
	UpdateWorkOrderStatus(ctx context.Context, id int, status domain.WorkOrderStatus) error
	UpdateWorkOrderProgress(ctx context.Context, id int, progress int) error
	StartWorkOrder(ctx context.Context, id int) error
	CompleteWorkOrder(ctx context.Context, id int) error
	AssignMechanic(ctx context.Context, id int, mechanicID int) error
	UsePartInWorkOrder(ctx context.Context, workOrderID int, partID int, quantity int, usedBy int) error
}

// SparePartService defines methods for spare part management
type SparePartService interface {
	CreateSparePart(ctx context.Context, sparePart *domain.SparePart) error
	GetSparePartByID(ctx context.Context, id int) (*domain.SparePart, error)
	GetSparePartByCode(ctx context.Context, partCode string) (*domain.SparePart, error)
	GetSparePartByBarcode(ctx context.Context, barcode string) (*domain.SparePart, error)
	ListSpareParts(ctx context.Context, page, limit int) ([]*domain.SparePart, int, error)
	ListLowStockParts(ctx context.Context, page, limit int) ([]*domain.SparePart, int, error)
	SearchSpareParts(ctx context.Context, query string, page, limit int) ([]*domain.SparePart, int, error)
	UpdateSparePart(ctx context.Context, sparePart *domain.SparePart) error
	DeleteSparePart(ctx context.Context, id int, deletedBy int) error
	AdjustStock(ctx context.Context, partID int, adjustment int, notes string, adjustedBy int) error
	CheckLowStock(ctx context.Context) ([]*domain.SparePart, error)
}

// StockMovementService defines methods for stock movement management
type StockMovementService interface {
	CreateStockMovement(ctx context.Context, movement *domain.StockMovement) error
	GetStockMovementByID(ctx context.Context, id int) (*domain.StockMovement, error)
	ListStockMovementsByPart(ctx context.Context, sparePartID int, page, limit int) ([]*domain.StockMovement, int, error)
	ListStockMovementsByDateRange(ctx context.Context, startDate, endDate time.Time, page, limit int) ([]*domain.StockMovement, int, error)
	ListStockMovementsByType(ctx context.Context, movementType domain.MovementType, page, limit int) ([]*domain.StockMovement, int, error)
	GetStockHistory(ctx context.Context, sparePartID int) ([]*domain.StockMovement, error)
}

// NotificationService defines methods for notification management
type NotificationService interface {
	CreateNotification(ctx context.Context, notification *domain.Notification) error
	GetNotificationByID(ctx context.Context, id int) (*domain.Notification, error)
	ListNotificationsByUser(ctx context.Context, userID int, page, limit int) ([]*domain.Notification, int, error)
	ListUnreadNotificationsByUser(ctx context.Context, userID int, page, limit int) ([]*domain.Notification, int, error)
	MarkNotificationAsRead(ctx context.Context, id int) error
	MarkAllNotificationsAsRead(ctx context.Context, userID int) error
	DeleteNotification(ctx context.Context, id int, deletedBy int) error
	NotifyWorkOrderAssigned(ctx context.Context, workOrderID int, mechanicID int) error
	NotifyLowStock(ctx context.Context, partID int) error
	NotifyWorkOrderUpdate(ctx context.Context, workOrderID int, message string) error
	GetUnreadCount(ctx context.Context, userID int) (int, error)
}

// ReportService defines methods for report generation
type ReportService interface {
	GenerateDailyReport(ctx context.Context, date time.Time, generatedBy int) (*domain.DailyReport, error)
	GetDailyReport(ctx context.Context, date time.Time) (*domain.DailyReport, error)
	ListDailyReports(ctx context.Context, startDate, endDate time.Time, page, limit int) ([]*domain.DailyReport, int, error)
	GetSalesReport(ctx context.Context, startDate, endDate time.Time) (map[string]interface{}, error)
	GetPurchaseReport(ctx context.Context, startDate, endDate time.Time) (map[string]interface{}, error)
	GetInventoryReport(ctx context.Context) (map[string]interface{}, error)
	GetProfitLossReport(ctx context.Context, startDate, endDate time.Time) (map[string]interface{}, error)
	GetVehicleReport(ctx context.Context) (map[string]interface{}, error)
	GetWorkOrderReport(ctx context.Context, startDate, endDate time.Time) (map[string]interface{}, error)
	GetCustomerReport(ctx context.Context) (map[string]interface{}, error)
}

// FileService defines methods for file management
type FileService interface {
	SaveFile(ctx context.Context, file *multipart.FileHeader, folder string) (string, error)
	DeleteFile(ctx context.Context, filePath string) error
	ValidateImage(file *multipart.FileHeader) error
	ValidateDocument(file *multipart.FileHeader) error
	GetFileURL(filePath string) string
}

// InvoiceService defines methods for invoice generation
type InvoiceService interface {
	GenerateSalesInvoicePDF(ctx context.Context, invoiceID int) ([]byte, error)
	GeneratePurchaseInvoicePDF(ctx context.Context, invoiceID int) ([]byte, error)
	GenerateWorkOrderPDF(ctx context.Context, workOrderID int) ([]byte, error)
	GenerateReportPDF(ctx context.Context, reportType string, data interface{}) ([]byte, error)
	SendInvoiceEmail(ctx context.Context, invoiceID int, email string) error
}

// DashboardService defines methods for dashboard data
type DashboardService interface {
	GetDashboardStats(ctx context.Context, userID int, role domain.UserRole) (map[string]interface{}, error)
	GetRecentActivities(ctx context.Context, userID int, role domain.UserRole, limit int) ([]map[string]interface{}, error)
	GetPerformanceMetrics(ctx context.Context, startDate, endDate time.Time) (map[string]interface{}, error)
	GetInventoryAlerts(ctx context.Context) (map[string]interface{}, error)
}