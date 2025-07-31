-- PostgreSQL Migration for POS System
-- Converted from MySQL DDL

-- Enable UUID extension for better ID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabel Users dan Roles
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) CHECK (role IN ('admin', 'kasir', 'mekanik')) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for users
CREATE INDEX idx_users_deleted_at ON users(deleted_at);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_username ON users(username);

-- Tabel Customers
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    customer_code VARCHAR(20) UNIQUE NOT NULL, -- CR-0001, CR-0002
    name VARCHAR(100) NOT NULL,
    ktp_number VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_customers_deleted_at ON customers(deleted_at);
CREATE INDEX idx_customers_customer_code ON customers(customer_code);

-- Tabel Suppliers
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    supplier_code VARCHAR(20) UNIQUE NOT NULL, -- SUP-0001
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_suppliers_deleted_at ON suppliers(deleted_at);
CREATE INDEX idx_suppliers_supplier_code ON suppliers(supplier_code);

-- Tabel Vehicle Categories
CREATE TABLE vehicle_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL, -- mobil, motor
    description TEXT,
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_vehicle_categories_deleted_at ON vehicle_categories(deleted_at);

-- Tabel Vehicles
CREATE TABLE vehicles (
    id SERIAL PRIMARY KEY,
    vehicle_code VARCHAR(20) UNIQUE NOT NULL,
    category_id INTEGER NOT NULL,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    chassis_number VARCHAR(50),
    engine_number VARCHAR(50),
    plate_number VARCHAR(20),
    color VARCHAR(30),
    fuel_type VARCHAR(20),
    transmission VARCHAR(20),
    
    -- Harga
    purchase_price DECIMAL(15,2), -- harga beli dari customer
    repair_cost DECIMAL(15,2) DEFAULT 0, -- total biaya perbaikan
    hpp DECIMAL(15,2), -- purchase_price + repair_cost
    selling_price DECIMAL(15,2), -- harga jual
    
    -- Status
    status VARCHAR(20) CHECK (status IN ('available', 'in_repair', 'sold', 'reserved')) DEFAULT 'available',
    condition_notes TEXT, -- "baret samping kanan, knalpot bocor"
    
    -- Foto primary untuk thumbnail
    primary_photo VARCHAR(255),
    
    -- Tracking untuk report
    purchased_date DATE, -- tanggal dibeli
    sold_date DATE, -- tanggal terjual
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES vehicle_categories(id),
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_vehicles_deleted_at ON vehicles(deleted_at);
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_vehicles_category ON vehicles(category_id);
CREATE INDEX idx_vehicles_vehicle_code ON vehicles(vehicle_code);

-- Tabel Vehicle Photos (9 angle)
CREATE TABLE vehicle_photos (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    photo_type VARCHAR(20) CHECK (photo_type IN ('depan', 'belakang', 'interior', 'mesin', 'kerusakan', 'samping_kiri', 'samping_kanan', 'dashboard', 'bagasi')) NOT NULL,
    photo_path VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    description TEXT,
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_vehicle_photos_deleted_at ON vehicle_photos(deleted_at);
CREATE INDEX idx_vehicle_photos_vehicle_id ON vehicle_photos(vehicle_id);

-- Tabel Purchase Invoices (Pembelian dari Customer/Supplier)
CREATE TABLE purchase_invoices (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(30) UNIQUE NOT NULL, -- PUR-20250724-001, SUP-20250724-001
    transaction_type VARCHAR(20) CHECK (transaction_type IN ('customer', 'supplier')) NOT NULL,
    customer_id INTEGER NULL, -- jika beli dari customer
    supplier_id INTEGER NULL, -- jika beli dari supplier
    vehicle_id INTEGER NOT NULL,
    purchase_price DECIMAL(15,2) NOT NULL,
    negotiated_price DECIMAL(15,2),
    final_price DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(20) CHECK (payment_method IN ('cash', 'transfer')) NOT NULL,
    transfer_proof VARCHAR(255), -- path bukti transfer
    notes TEXT,
    created_by INTEGER NOT NULL,
    
    -- Untuk daily report
    transaction_date DATE NOT NULL,
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_purchase_invoices_deleted_at ON purchase_invoices(deleted_at);
CREATE INDEX idx_purchase_invoices_transaction_date ON purchase_invoices(transaction_date);
CREATE INDEX idx_purchase_invoices_invoice_number ON purchase_invoices(invoice_number);

-- Tabel Sales Invoices (Penjualan ke Customer)
CREATE TABLE sales_invoices (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(30) UNIQUE NOT NULL, -- SAL-20250724-004
    customer_id INTEGER NOT NULL,
    vehicle_id INTEGER NOT NULL,
    selling_price DECIMAL(15,2) NOT NULL,
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    final_price DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(20) CHECK (payment_method IN ('cash', 'transfer')) NOT NULL,
    transfer_proof VARCHAR(255),
    notes TEXT,
    created_by INTEGER NOT NULL,
    
    -- Untuk daily report
    transaction_date DATE NOT NULL,
    profit_amount DECIMAL(15,2) DEFAULT 0, -- final_price - hpp
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_sales_invoices_deleted_at ON sales_invoices(deleted_at);
CREATE INDEX idx_sales_invoices_transaction_date ON sales_invoices(transaction_date);
CREATE INDEX idx_sales_invoices_invoice_number ON sales_invoices(invoice_number);

-- Tabel Work Orders
CREATE TABLE work_orders (
    id SERIAL PRIMARY KEY,
    wo_number VARCHAR(30) UNIQUE NOT NULL, -- WO-20250724-003
    vehicle_id INTEGER NOT NULL,
    description TEXT NOT NULL, -- "Ganti kampas rem + service AC"
    assigned_mechanic_id INTEGER NOT NULL,
    status VARCHAR(20) CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')) DEFAULT 'pending',
    progress_percentage INTEGER DEFAULT 0, -- 0-100
    total_parts_cost DECIMAL(15,2) DEFAULT 0,
    labor_cost DECIMAL(15,2) DEFAULT 0,
    total_cost DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    created_by INTEGER NOT NULL,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (assigned_mechanic_id) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_work_orders_deleted_at ON work_orders(deleted_at);
CREATE INDEX idx_work_orders_status ON work_orders(status);
CREATE INDEX idx_work_orders_mechanic ON work_orders(assigned_mechanic_id);
CREATE INDEX idx_work_orders_wo_number ON work_orders(wo_number);

-- Tabel Spare Parts
CREATE TABLE spare_parts (
    id SERIAL PRIMARY KEY,
    part_code VARCHAR(30) UNIQUE NOT NULL,
    barcode VARCHAR(50),
    name VARCHAR(100) NOT NULL,
    brand VARCHAR(50),
    category VARCHAR(50),
    description TEXT,
    cost_price DECIMAL(12,2) NOT NULL,
    selling_price DECIMAL(12,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    min_stock_level INTEGER DEFAULT 5, -- untuk alert low stock
    unit VARCHAR(20) DEFAULT 'pcs',
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_spare_parts_deleted_at ON spare_parts(deleted_at);
CREATE INDEX idx_spare_parts_stock ON spare_parts(stock_quantity);
CREATE INDEX idx_spare_parts_part_code ON spare_parts(part_code);

-- Tabel Work Order Parts (Parts yang digunakan dalam WO)
CREATE TABLE work_order_parts (
    id SERIAL PRIMARY KEY,
    work_order_id INTEGER NOT NULL,
    spare_part_id INTEGER NOT NULL,
    quantity_used INTEGER NOT NULL,
    unit_cost DECIMAL(12,2) NOT NULL,
    total_cost DECIMAL(12,2) NOT NULL,
    used_by INTEGER NOT NULL, -- mekanik yang menggunakan
    
    -- Untuk daily report
    usage_date DATE NOT NULL,
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (work_order_id) REFERENCES work_orders(id),
    FOREIGN KEY (spare_part_id) REFERENCES spare_parts(id),
    FOREIGN KEY (used_by) REFERENCES users(id),
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_work_order_parts_deleted_at ON work_order_parts(deleted_at);
CREATE INDEX idx_work_order_parts_usage_date ON work_order_parts(usage_date);

-- Tabel Stock Movements (History pergerakan stok)
CREATE TABLE stock_movements (
    id SERIAL PRIMARY KEY,
    spare_part_id INTEGER NOT NULL,
    movement_type VARCHAR(20) CHECK (movement_type IN ('in', 'out')) NOT NULL,
    quantity INTEGER NOT NULL,
    reference_type VARCHAR(20) CHECK (reference_type IN ('work_order', 'purchase', 'adjustment')) NOT NULL,
    reference_id INTEGER, -- ID dari work_order, purchase, dll
    notes TEXT,
    created_by INTEGER NOT NULL,
    
    -- Untuk daily report
    movement_date DATE NOT NULL,
    unit_cost DECIMAL(12,2) DEFAULT 0,
    total_value DECIMAL(15,2) DEFAULT 0,
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (spare_part_id) REFERENCES spare_parts(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_stock_movements_deleted_at ON stock_movements(deleted_at);
CREATE INDEX idx_stock_movements_movement_date ON stock_movements(movement_date);

-- Tabel Notifications
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    type VARCHAR(30) CHECK (type IN ('work_order_assigned', 'low_stock', 'work_order_update', 'daily_report')) NOT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    reference_type VARCHAR(50), -- 'work_order', 'spare_part', 'report'
    reference_id INTEGER,
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX idx_notifications_deleted_at ON notifications(deleted_at);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read);

-- Tabel Customer Transaction Summary (untuk CRM)
CREATE TABLE customer_transaction_summary (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    total_purchases INTEGER DEFAULT 0, -- total kendaraan dibeli dari customer
    total_sales INTEGER DEFAULT 0, -- total kendaraan dijual ke customer
    total_purchase_amount DECIMAL(15,2) DEFAULT 0,
    total_sales_amount DECIMAL(15,2) DEFAULT 0,
    last_transaction_date TIMESTAMP NULL,
    
    -- Soft Delete
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INTEGER NULL,
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (deleted_by) REFERENCES users(id),
    UNIQUE (customer_id)
);

CREATE INDEX idx_customer_transaction_summary_deleted_at ON customer_transaction_summary(deleted_at);

-- Tabel Daily Reports (Laporan harian sederhana)
CREATE TABLE daily_reports (
    id SERIAL PRIMARY KEY,
    report_date DATE NOT NULL UNIQUE,
    
    -- Transaksi Hari Ini
    total_sales_today INTEGER DEFAULT 0,
    total_sales_amount DECIMAL(15,2) DEFAULT 0,
    total_profit_today DECIMAL(15,2) DEFAULT 0,
    
    total_purchases_today INTEGER DEFAULT 0,
    total_purchase_amount DECIMAL(15,2) DEFAULT 0,
    
    -- Cash Flow
    cash_in DECIMAL(15,2) DEFAULT 0, -- dari penjualan
    cash_out DECIMAL(15,2) DEFAULT 0, -- untuk pembelian
    net_cash_flow DECIMAL(15,2) DEFAULT 0,
    
    -- Work Orders
    new_work_orders INTEGER DEFAULT 0,
    completed_work_orders INTEGER DEFAULT 0,
    pending_work_orders INTEGER DEFAULT 0,
    
    -- Inventory
    parts_used_today INTEGER DEFAULT 0,
    parts_value_used DECIMAL(15,2) DEFAULT 0,
    low_stock_items INTEGER DEFAULT 0,
    
    -- Vehicles
    vehicles_available INTEGER DEFAULT 0,
    vehicles_in_repair INTEGER DEFAULT 0,
    vehicles_sold_today INTEGER DEFAULT 0,
    vehicles_purchased_today INTEGER DEFAULT 0,
    
    -- Best Performers
    best_selling_user_id INTEGER NULL,
    most_active_mechanic_id INTEGER NULL,
    
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    generated_by INTEGER NULL,
    
    FOREIGN KEY (best_selling_user_id) REFERENCES users(id),
    FOREIGN KEY (most_active_mechanic_id) REFERENCES users(id),
    FOREIGN KEY (generated_by) REFERENCES users(id)
);

-- Additional composite indexes untuk reporting
CREATE INDEX idx_sales_date_deleted ON sales_invoices(transaction_date, deleted_at);
CREATE INDEX idx_purchase_date_deleted ON purchase_invoices(transaction_date, deleted_at);
CREATE INDEX idx_work_orders_date_status ON work_orders(created_at, status, deleted_at);

-- Create trigger function for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_suppliers_updated_at BEFORE UPDATE ON suppliers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vehicle_categories_updated_at BEFORE UPDATE ON vehicle_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON vehicles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_work_orders_updated_at BEFORE UPDATE ON work_orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_spare_parts_updated_at BEFORE UPDATE ON spare_parts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customer_transaction_summary_updated_at BEFORE UPDATE ON customer_transaction_summary FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();