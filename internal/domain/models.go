package domain

import (
	"database/sql/driver"
	"time"
)

// Base model with common fields
type BaseModel struct {
	ID        int        `json:"id" db:"id"`
	CreatedAt time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt *time.Time `json:"updated_at" db:"updated_at"`
	DeletedAt *time.Time `json:"deleted_at" db:"deleted_at"`
	DeletedBy *int       `json:"deleted_by" db:"deleted_by"`
}

// User roles
type UserRole string

const (
	RoleAdmin   UserRole = "admin"
	RoleKasir   UserRole = "kasir"
	RoleMekanik UserRole = "mekanik"
)

func (ur UserRole) String() string {
	return string(ur)
}

func (ur *UserRole) Scan(value interface{}) error {
	if value == nil {
		*ur = ""
		return nil
	}
	if s, ok := value.(string); ok {
		*ur = UserRole(s)
	}
	return nil
}

func (ur UserRole) Value() (driver.Value, error) {
	return string(ur), nil
}

// User entity
type User struct {
	BaseModel
	Username     string   `json:"username" db:"username"`
	Email        string   `json:"email" db:"email"`
	PasswordHash string   `json:"-" db:"password_hash"`
	FullName     string   `json:"full_name" db:"full_name"`
	Phone        *string  `json:"phone" db:"phone"`
	Role         UserRole `json:"role" db:"role"`
	IsActive     bool     `json:"is_active" db:"is_active"`
}

// Customer entity
type Customer struct {
	BaseModel
	CustomerCode string  `json:"customer_code" db:"customer_code"`
	Name         string  `json:"name" db:"name"`
	KTPNumber    *string `json:"ktp_number" db:"ktp_number"`
	Phone        *string `json:"phone" db:"phone"`
	Email        *string `json:"email" db:"email"`
	Address      *string `json:"address" db:"address"`
}

// Supplier entity
type Supplier struct {
	BaseModel
	SupplierCode  string  `json:"supplier_code" db:"supplier_code"`
	Name          string  `json:"name" db:"name"`
	ContactPerson *string `json:"contact_person" db:"contact_person"`
	Phone         *string `json:"phone" db:"phone"`
	Email         *string `json:"email" db:"email"`
	Address       *string `json:"address" db:"address"`
}

// VehicleCategory entity
type VehicleCategory struct {
	BaseModel
	Name        string  `json:"name" db:"name"`
	Description *string `json:"description" db:"description"`
}

// Vehicle status enum
type VehicleStatus string

const (
	VehicleStatusAvailable VehicleStatus = "available"
	VehicleStatusInRepair  VehicleStatus = "in_repair"
	VehicleStatusSold      VehicleStatus = "sold"
	VehicleStatusReserved  VehicleStatus = "reserved"
)

func (vs VehicleStatus) String() string {
	return string(vs)
}

func (vs *VehicleStatus) Scan(value interface{}) error {
	if value == nil {
		*vs = ""
		return nil
	}
	if s, ok := value.(string); ok {
		*vs = VehicleStatus(s)
	}
	return nil
}

func (vs VehicleStatus) Value() (driver.Value, error) {
	return string(vs), nil
}

// Vehicle entity
type Vehicle struct {
	BaseModel
	VehicleCode    string         `json:"vehicle_code" db:"vehicle_code"`
	CategoryID     int            `json:"category_id" db:"category_id"`
	Brand          string         `json:"brand" db:"brand"`
	Model          string         `json:"model" db:"model"`
	Year           int            `json:"year" db:"year"`
	ChassisNumber  *string        `json:"chassis_number" db:"chassis_number"`
	EngineNumber   *string        `json:"engine_number" db:"engine_number"`
	PlateNumber    *string        `json:"plate_number" db:"plate_number"`
	Color          *string        `json:"color" db:"color"`
	FuelType       *string        `json:"fuel_type" db:"fuel_type"`
	Transmission   *string        `json:"transmission" db:"transmission"`
	PurchasePrice  *float64       `json:"purchase_price" db:"purchase_price"`
	RepairCost     float64        `json:"repair_cost" db:"repair_cost"`
	HPP            *float64       `json:"hpp" db:"hpp"`
	SellingPrice   *float64       `json:"selling_price" db:"selling_price"`
	Status         VehicleStatus  `json:"status" db:"status"`
	ConditionNotes *string        `json:"condition_notes" db:"condition_notes"`
	PrimaryPhoto   *string        `json:"primary_photo" db:"primary_photo"`
	PurchasedDate  *time.Time     `json:"purchased_date" db:"purchased_date"`
	SoldDate       *time.Time     `json:"sold_date" db:"sold_date"`
	Category       *VehicleCategory `json:"category,omitempty"`
}

// VehiclePhoto types
type VehiclePhotoType string

const (
	PhotoTypeDepan       VehiclePhotoType = "depan"
	PhotoTypeBelakang    VehiclePhotoType = "belakang"
	PhotoTypeInterior    VehiclePhotoType = "interior"
	PhotoTypeMesin       VehiclePhotoType = "mesin"
	PhotoTypeKerusakan   VehiclePhotoType = "kerusakan"
	PhotoTypeSampingKiri VehiclePhotoType = "samping_kiri"
	PhotoTypeSampingKanan VehiclePhotoType = "samping_kanan"
	PhotoTypeDashboard   VehiclePhotoType = "dashboard"
	PhotoTypeBagasi      VehiclePhotoType = "bagasi"
)

func (vpt VehiclePhotoType) String() string {
	return string(vpt)
}

func (vpt *VehiclePhotoType) Scan(value interface{}) error {
	if value == nil {
		*vpt = ""
		return nil
	}
	if s, ok := value.(string); ok {
		*vpt = VehiclePhotoType(s)
	}
	return nil
}

func (vpt VehiclePhotoType) Value() (driver.Value, error) {
	return string(vpt), nil
}

// VehiclePhoto entity
type VehiclePhoto struct {
	ID          int              `json:"id" db:"id"`
	VehicleID   int              `json:"vehicle_id" db:"vehicle_id"`
	PhotoType   VehiclePhotoType `json:"photo_type" db:"photo_type"`
	PhotoPath   string           `json:"photo_path" db:"photo_path"`
	IsPrimary   bool             `json:"is_primary" db:"is_primary"`
	Description *string          `json:"description" db:"description"`
	DeletedAt   *time.Time       `json:"deleted_at" db:"deleted_at"`
	DeletedBy   *int             `json:"deleted_by" db:"deleted_by"`
	CreatedAt   time.Time        `json:"created_at" db:"created_at"`
}

// Transaction types
type TransactionType string

const (
	TransactionTypeCustomer TransactionType = "customer"
	TransactionTypeSupplier TransactionType = "supplier"
)

func (tt TransactionType) String() string {
	return string(tt)
}

func (tt *TransactionType) Scan(value interface{}) error {
	if value == nil {
		*tt = ""
		return nil
	}
	if s, ok := value.(string); ok {
		*tt = TransactionType(s)
	}
	return nil
}

func (tt TransactionType) Value() (driver.Value, error) {
	return string(tt), nil
}

// Payment methods
type PaymentMethod string

const (
	PaymentMethodCash     PaymentMethod = "cash"
	PaymentMethodTransfer PaymentMethod = "transfer"
)

func (pm PaymentMethod) String() string {
	return string(pm)
}

func (pm *PaymentMethod) Scan(value interface{}) error {
	if value == nil {
		*pm = ""
		return nil
	}
	if s, ok := value.(string); ok {
		*pm = PaymentMethod(s)
	}
	return nil
}

func (pm PaymentMethod) Value() (driver.Value, error) {
	return string(pm), nil
}

// PurchaseInvoice entity
type PurchaseInvoice struct {
	BaseModel
	InvoiceNumber     string           `json:"invoice_number" db:"invoice_number"`
	TransactionType   TransactionType  `json:"transaction_type" db:"transaction_type"`
	CustomerID        *int             `json:"customer_id" db:"customer_id"`
	SupplierID        *int             `json:"supplier_id" db:"supplier_id"`
	VehicleID         int              `json:"vehicle_id" db:"vehicle_id"`
	PurchasePrice     float64          `json:"purchase_price" db:"purchase_price"`
	NegotiatedPrice   *float64         `json:"negotiated_price" db:"negotiated_price"`
	FinalPrice        float64          `json:"final_price" db:"final_price"`
	PaymentMethod     PaymentMethod    `json:"payment_method" db:"payment_method"`
	TransferProof     *string          `json:"transfer_proof" db:"transfer_proof"`
	Notes             *string          `json:"notes" db:"notes"`
	CreatedBy         int              `json:"created_by" db:"created_by"`
	TransactionDate   time.Time        `json:"transaction_date" db:"transaction_date"`
	Customer          *Customer        `json:"customer,omitempty"`
	Supplier          *Supplier        `json:"supplier,omitempty"`
	Vehicle           *Vehicle         `json:"vehicle,omitempty"`
	Creator           *User            `json:"creator,omitempty"`
}

// SalesInvoice entity
type SalesInvoice struct {
	BaseModel
	InvoiceNumber      string        `json:"invoice_number" db:"invoice_number"`
	CustomerID         int           `json:"customer_id" db:"customer_id"`
	VehicleID          int           `json:"vehicle_id" db:"vehicle_id"`
	SellingPrice       float64       `json:"selling_price" db:"selling_price"`
	DiscountPercentage float64       `json:"discount_percentage" db:"discount_percentage"`
	DiscountAmount     float64       `json:"discount_amount" db:"discount_amount"`
	FinalPrice         float64       `json:"final_price" db:"final_price"`
	PaymentMethod      PaymentMethod `json:"payment_method" db:"payment_method"`
	TransferProof      *string       `json:"transfer_proof" db:"transfer_proof"`
	Notes              *string       `json:"notes" db:"notes"`
	CreatedBy          int           `json:"created_by" db:"created_by"`
	TransactionDate    time.Time     `json:"transaction_date" db:"transaction_date"`
	ProfitAmount       float64       `json:"profit_amount" db:"profit_amount"`
	Customer           *Customer     `json:"customer,omitempty"`
	Vehicle            *Vehicle      `json:"vehicle,omitempty"`
	Creator            *User         `json:"creator,omitempty"`
}

// Work order status
type WorkOrderStatus string

const (
	WorkOrderStatusPending    WorkOrderStatus = "pending"
	WorkOrderStatusInProgress WorkOrderStatus = "in_progress"
	WorkOrderStatusCompleted  WorkOrderStatus = "completed"
	WorkOrderStatusCancelled  WorkOrderStatus = "cancelled"
)

func (wos WorkOrderStatus) String() string {
	return string(wos)
}

func (wos *WorkOrderStatus) Scan(value interface{}) error {
	if value == nil {
		*wos = ""
		return nil
	}
	if s, ok := value.(string); ok {
		*wos = WorkOrderStatus(s)
	}
	return nil
}

func (wos WorkOrderStatus) Value() (driver.Value, error) {
	return string(wos), nil
}

// WorkOrder entity
type WorkOrder struct {
	BaseModel
	WONumber            string          `json:"wo_number" db:"wo_number"`
	VehicleID           int             `json:"vehicle_id" db:"vehicle_id"`
	Description         string          `json:"description" db:"description"`
	AssignedMechanicID  int             `json:"assigned_mechanic_id" db:"assigned_mechanic_id"`
	Status              WorkOrderStatus `json:"status" db:"status"`
	ProgressPercentage  int             `json:"progress_percentage" db:"progress_percentage"`
	TotalPartsCost      float64         `json:"total_parts_cost" db:"total_parts_cost"`
	LaborCost           float64         `json:"labor_cost" db:"labor_cost"`
	TotalCost           float64         `json:"total_cost" db:"total_cost"`
	Notes               *string         `json:"notes" db:"notes"`
	CreatedBy           int             `json:"created_by" db:"created_by"`
	StartedAt           *time.Time      `json:"started_at" db:"started_at"`
	CompletedAt         *time.Time      `json:"completed_at" db:"completed_at"`
	Vehicle             *Vehicle        `json:"vehicle,omitempty"`
	AssignedMechanic    *User           `json:"assigned_mechanic,omitempty"`
	Creator             *User           `json:"creator,omitempty"`
}

// SparePart entity
type SparePart struct {
	BaseModel
	PartCode      string  `json:"part_code" db:"part_code"`
	Barcode       *string `json:"barcode" db:"barcode"`
	Name          string  `json:"name" db:"name"`
	Brand         *string `json:"brand" db:"brand"`
	Category      *string `json:"category" db:"category"`
	Description   *string `json:"description" db:"description"`
	CostPrice     float64 `json:"cost_price" db:"cost_price"`
	SellingPrice  float64 `json:"selling_price" db:"selling_price"`
	StockQuantity int     `json:"stock_quantity" db:"stock_quantity"`
	MinStockLevel int     `json:"min_stock_level" db:"min_stock_level"`
	Unit          string  `json:"unit" db:"unit"`
}

// WorkOrderPart entity
type WorkOrderPart struct {
	ID           int       `json:"id" db:"id"`
	WorkOrderID  int       `json:"work_order_id" db:"work_order_id"`
	SparePartID  int       `json:"spare_part_id" db:"spare_part_id"`
	QuantityUsed int       `json:"quantity_used" db:"quantity_used"`
	UnitCost     float64   `json:"unit_cost" db:"unit_cost"`
	TotalCost    float64   `json:"total_cost" db:"total_cost"`
	UsedBy       int       `json:"used_by" db:"used_by"`
	UsageDate    time.Time `json:"usage_date" db:"usage_date"`
	DeletedAt    *time.Time `json:"deleted_at" db:"deleted_at"`
	DeletedBy    *int      `json:"deleted_by" db:"deleted_by"`
	UsedAt       time.Time `json:"used_at" db:"used_at"`
	SparePart    *SparePart `json:"spare_part,omitempty"`
	User         *User     `json:"user,omitempty"`
}

// Stock movement types and references
type MovementType string
type ReferenceType string

const (
	MovementTypeIn  MovementType = "in"
	MovementTypeOut MovementType = "out"

	ReferenceTypeWorkOrder  ReferenceType = "work_order"
	ReferenceTypePurchase   ReferenceType = "purchase"
	ReferenceTypeAdjustment ReferenceType = "adjustment"
)

func (mt MovementType) String() string {
	return string(mt)
}

func (mt *MovementType) Scan(value interface{}) error {
	if value == nil {
		*mt = ""
		return nil
	}
	if s, ok := value.(string); ok {
		*mt = MovementType(s)
	}
	return nil
}

func (mt MovementType) Value() (driver.Value, error) {
	return string(mt), nil
}

func (rt ReferenceType) String() string {
	return string(rt)
}

func (rt *ReferenceType) Scan(value interface{}) error {
	if value == nil {
		*rt = ""
		return nil
	}
	if s, ok := value.(string); ok {
		*rt = ReferenceType(s)
	}
	return nil
}

func (rt ReferenceType) Value() (driver.Value, error) {
	return string(rt), nil
}

// StockMovement entity
type StockMovement struct {
	ID            int           `json:"id" db:"id"`
	SparePartID   int           `json:"spare_part_id" db:"spare_part_id"`
	MovementType  MovementType  `json:"movement_type" db:"movement_type"`
	Quantity      int           `json:"quantity" db:"quantity"`
	ReferenceType ReferenceType `json:"reference_type" db:"reference_type"`
	ReferenceID   *int          `json:"reference_id" db:"reference_id"`
	Notes         *string       `json:"notes" db:"notes"`
	CreatedBy     int           `json:"created_by" db:"created_by"`
	MovementDate  time.Time     `json:"movement_date" db:"movement_date"`
	UnitCost      float64       `json:"unit_cost" db:"unit_cost"`
	TotalValue    float64       `json:"total_value" db:"total_value"`
	DeletedAt     *time.Time    `json:"deleted_at" db:"deleted_at"`
	DeletedBy     *int          `json:"deleted_by" db:"deleted_by"`
	CreatedAt     time.Time     `json:"created_at" db:"created_at"`
	SparePart     *SparePart    `json:"spare_part,omitempty"`
	Creator       *User         `json:"creator,omitempty"`
}

// Notification types
type NotificationType string

const (
	NotificationTypeWorkOrderAssigned NotificationType = "work_order_assigned"
	NotificationTypeLowStock          NotificationType = "low_stock"
	NotificationTypeWorkOrderUpdate   NotificationType = "work_order_update"
	NotificationTypeDailyReport       NotificationType = "daily_report"
)

func (nt NotificationType) String() string {
	return string(nt)
}

func (nt *NotificationType) Scan(value interface{}) error {
	if value == nil {
		*nt = ""
		return nil
	}
	if s, ok := value.(string); ok {
		*nt = NotificationType(s)
	}
	return nil
}

func (nt NotificationType) Value() (driver.Value, error) {
	return string(nt), nil
}

// Notification entity
type Notification struct {
	ID            int              `json:"id" db:"id"`
	UserID        int              `json:"user_id" db:"user_id"`
	Type          NotificationType `json:"type" db:"type"`
	Title         string           `json:"title" db:"title"`
	Message       string           `json:"message" db:"message"`
	IsRead        bool             `json:"is_read" db:"is_read"`
	ReferenceType *string          `json:"reference_type" db:"reference_type"`
	ReferenceID   *int             `json:"reference_id" db:"reference_id"`
	DeletedAt     *time.Time       `json:"deleted_at" db:"deleted_at"`
	DeletedBy     *int             `json:"deleted_by" db:"deleted_by"`
	CreatedAt     time.Time        `json:"created_at" db:"created_at"`
	User          *User            `json:"user,omitempty"`
}

// CustomerTransactionSummary entity
type CustomerTransactionSummary struct {
	ID                    int        `json:"id" db:"id"`
	CustomerID            int        `json:"customer_id" db:"customer_id"`
	TotalPurchases        int        `json:"total_purchases" db:"total_purchases"`
	TotalSales            int        `json:"total_sales" db:"total_sales"`
	TotalPurchaseAmount   float64    `json:"total_purchase_amount" db:"total_purchase_amount"`
	TotalSalesAmount      float64    `json:"total_sales_amount" db:"total_sales_amount"`
	LastTransactionDate   *time.Time `json:"last_transaction_date" db:"last_transaction_date"`
	DeletedAt             *time.Time `json:"deleted_at" db:"deleted_at"`
	DeletedBy             *int       `json:"deleted_by" db:"deleted_by"`
	UpdatedAt             time.Time  `json:"updated_at" db:"updated_at"`
	Customer              *Customer  `json:"customer,omitempty"`
}

// DailyReport entity
type DailyReport struct {
	ID                      int        `json:"id" db:"id"`
	ReportDate              time.Time  `json:"report_date" db:"report_date"`
	TotalSalesToday         int        `json:"total_sales_today" db:"total_sales_today"`
	TotalSalesAmount        float64    `json:"total_sales_amount" db:"total_sales_amount"`
	TotalProfitToday        float64    `json:"total_profit_today" db:"total_profit_today"`
	TotalPurchasesToday     int        `json:"total_purchases_today" db:"total_purchases_today"`
	TotalPurchaseAmount     float64    `json:"total_purchase_amount" db:"total_purchase_amount"`
	CashIn                  float64    `json:"cash_in" db:"cash_in"`
	CashOut                 float64    `json:"cash_out" db:"cash_out"`
	NetCashFlow             float64    `json:"net_cash_flow" db:"net_cash_flow"`
	NewWorkOrders           int        `json:"new_work_orders" db:"new_work_orders"`
	CompletedWorkOrders     int        `json:"completed_work_orders" db:"completed_work_orders"`
	PendingWorkOrders       int        `json:"pending_work_orders" db:"pending_work_orders"`
	PartsUsedToday          int        `json:"parts_used_today" db:"parts_used_today"`
	PartsValueUsed          float64    `json:"parts_value_used" db:"parts_value_used"`
	LowStockItems           int        `json:"low_stock_items" db:"low_stock_items"`
	VehiclesAvailable       int        `json:"vehicles_available" db:"vehicles_available"`
	VehiclesInRepair        int        `json:"vehicles_in_repair" db:"vehicles_in_repair"`
	VehiclesSoldToday       int        `json:"vehicles_sold_today" db:"vehicles_sold_today"`
	VehiclesPurchasedToday  int        `json:"vehicles_purchased_today" db:"vehicles_purchased_today"`
	BestSellingUserID       *int       `json:"best_selling_user_id" db:"best_selling_user_id"`
	MostActiveMechanicID    *int       `json:"most_active_mechanic_id" db:"most_active_mechanic_id"`
	GeneratedAt             time.Time  `json:"generated_at" db:"generated_at"`
	GeneratedBy             *int       `json:"generated_by" db:"generated_by"`
	BestSellingUser         *User      `json:"best_selling_user,omitempty"`
	MostActiveMechanic      *User      `json:"most_active_mechanic,omitempty"`
	Generator               *User      `json:"generator,omitempty"`
}