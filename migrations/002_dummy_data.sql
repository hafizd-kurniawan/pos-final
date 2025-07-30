-- Insert dummy data for testing

-- Insert Vehicle Categories
INSERT INTO vehicle_categories (name, description) VALUES
('Mobil', 'Kendaraan roda empat'),
('Motor', 'Kendaraan roda dua'),
('Truk', 'Kendaraan angkutan berat');

-- Insert Users
INSERT INTO users (username, email, password_hash, full_name, phone, role, is_active) VALUES
-- Password: admin123
('admin', 'admin@pos.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator', '081234567890', 'admin', true),
-- Password: kasir123
('kasir1', 'kasir1@pos.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Kasir Satu', '081234567891', 'kasir', true),
-- Password: mekanik123
('mekanik1', 'mekanik1@pos.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Mekanik Satu', '081234567892', 'mekanik', true),
('mekanik2', 'mekanik2@pos.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Mekanik Dua', '081234567893', 'mekanik', true);

-- Insert Customers
INSERT INTO customers (customer_code, name, ktp_number, phone, email, address) VALUES
('CR-0001', 'Budi Santoso', '3201234567890123', '081234567894', 'budi@email.com', 'Jl. Raya No. 1, Jakarta'),
('CR-0002', 'Siti Rahayu', '3201234567890124', '081234567895', 'siti@email.com', 'Jl. Sudirman No. 2, Jakarta'),
('CR-0003', 'Ahmad Wijaya', '3201234567890125', '081234567896', 'ahmad@email.com', 'Jl. Thamrin No. 3, Jakarta'),
('CR-0004', 'Dewi Lestari', '3201234567890126', '081234567897', 'dewi@email.com', 'Jl. Gatot Subroto No. 4, Jakarta'),
('CR-0005', 'Rudi Hermawan', '3201234567890127', '081234567898', 'rudi@email.com', 'Jl. Kuningan No. 5, Jakarta');

-- Insert Suppliers
INSERT INTO suppliers (supplier_code, name, contact_person, phone, email, address) VALUES
('SUP-0001', 'PT. Honda Motor', 'Agus Siswanto', '0212345678', 'honda@supplier.com', 'Jl. Industri Raya No. 10, Jakarta'),
('SUP-0002', 'PT. Yamaha Indonesia', 'Rina Sari', '0212345679', 'yamaha@supplier.com', 'Jl. Pabrik No. 20, Jakarta'),
('SUP-0003', 'CV. Spare Part Murah', 'Joko Widodo', '0212345680', 'sparepart@supplier.com', 'Jl. Otomotif No. 30, Jakarta');

-- Insert Vehicles
INSERT INTO vehicles (vehicle_code, category_id, brand, model, year, chassis_number, engine_number, plate_number, color, fuel_type, transmission, purchase_price, repair_cost, hpp, selling_price, status, condition_notes, purchased_date) VALUES
('VH-0001', 1, 'Toyota', 'Avanza', 2020, 'TOY123456789', 'ENG123456789', 'B 1234 ABC', 'Silver', 'Bensin', 'Manual', 150000000, 5000000, 155000000, 175000000, 'available', 'Kondisi baik, service rutin', '2024-01-15'),
('VH-0002', 1, 'Honda', 'Brio', 2019, 'HON123456789', 'ENG123456790', 'B 5678 DEF', 'Putih', 'Bensin', 'Manual', 120000000, 3000000, 123000000, 140000000, 'available', 'Kondisi sangat baik', '2024-01-20'),
('VH-0003', 2, 'Honda', 'Vario 150', 2021, 'VAR123456789', 'ENG123456791', 'B 9012 GHI', 'Merah', 'Bensin', 'Automatic', 20000000, 1000000, 21000000, 24000000, 'available', 'Kondisi prima', '2024-02-01'),
('VH-0004', 2, 'Yamaha', 'NMAX', 2020, 'YAM123456789', 'ENG123456792', 'B 3456 JKL', 'Biru', 'Bensin', 'Automatic', 25000000, 2000000, 27000000, 31000000, 'in_repair', 'Perlu ganti rem', '2024-02-10'),
('VH-0005', 1, 'Daihatsu', 'Ayla', 2018, 'DAI123456789', 'ENG123456793', 'B 7890 MNO', 'Hitam', 'Bensin', 'Manual', 95000000, 8000000, 103000000, 120000000, 'sold', 'Terjual ke CR-0001', '2024-01-25');

-- Insert Spare Parts
INSERT INTO spare_parts (part_code, barcode, name, brand, category, description, cost_price, selling_price, stock_quantity, min_stock_level, unit) VALUES
('SP-0001', '1234567890123', 'Kampas Rem Depan', 'Brembo', 'Rem', 'Kampas rem untuk mobil sedan', 150000, 200000, 25, 5, 'set'),
('SP-0002', '1234567890124', 'Filter Oli', 'Mann', 'Filter', 'Filter oli untuk mesin 1500cc', 50000, 75000, 50, 10, 'pcs'),
('SP-0003', '1234567890125', 'Ban Motor 90/80-14', 'Michelin', 'Ban', 'Ban tubeless untuk motor matic', 300000, 400000, 20, 5, 'pcs'),
('SP-0004', '1234567890126', 'Oli Mesin 10W-40', 'Shell', 'Pelumas', 'Oli mesin semi sintetik', 80000, 120000, 30, 8, 'liter'),
('SP-0005', '1234567890127', 'Aki Mobil 12V 45AH', 'GS Astra', 'Elektrik', 'Aki kering maintenance free', 500000, 650000, 15, 3, 'pcs'),
('SP-0006', '1234567890128', 'Lampu Depan H4', 'Osram', 'Elektrik', 'Lampu halogen 12V 60/55W', 75000, 100000, 40, 10, 'pcs'),
('SP-0007', '1234567890129', 'Rantai Motor 428', 'DID', 'Transmisi', 'Rantai untuk motor bebek 150cc', 200000, 280000, 12, 3, 'set'),
('SP-0008', '1234567890130', 'Kabel Busi', 'NGK', 'Elektrik', 'Kabel busi racing untuk mobil', 250000, 350000, 18, 5, 'set');

-- Insert Work Orders
INSERT INTO work_orders (wo_number, vehicle_id, description, assigned_mechanic_id, status, progress_percentage, total_parts_cost, labor_cost, total_cost, notes, created_by) VALUES
('WO-20240801-001', 4, 'Ganti kampas rem + service berkala', 3, 'in_progress', 50, 400000, 200000, 600000, 'Sedang dikerjakan', 1),
('WO-20240801-002', 1, 'Service AC + ganti filter kabin', 4, 'pending', 0, 150000, 100000, 250000, 'Menunggu spare part', 1),
('WO-20240801-003', 3, 'Ganti oli mesin + filter oli', 3, 'completed', 100, 195000, 50000, 245000, 'Selesai dikerjakan', 2);

-- Insert Work Order Parts
INSERT INTO work_order_parts (work_order_id, spare_part_id, quantity_used, unit_cost, total_cost, used_by, usage_date) VALUES
(1, 1, 1, 200000, 200000, 3, '2024-08-01'),
(1, 4, 2, 120000, 240000, 3, '2024-08-01'),
(3, 2, 1, 75000, 75000, 3, '2024-08-01'),
(3, 4, 1, 120000, 120000, 3, '2024-08-01');

-- Insert Stock Movements
INSERT INTO stock_movements (spare_part_id, movement_type, quantity, reference_type, reference_id, notes, created_by, movement_date, unit_cost, total_value) VALUES
(1, 'out', 1, 'work_order', 1, 'Digunakan untuk WO-20240801-001', 3, '2024-08-01', 150000, 150000),
(4, 'out', 2, 'work_order', 1, 'Digunakan untuk WO-20240801-001', 3, '2024-08-01', 80000, 160000),
(2, 'out', 1, 'work_order', 3, 'Digunakan untuk WO-20240801-003', 3, '2024-08-01', 50000, 50000),
(4, 'out', 1, 'work_order', 3, 'Digunakan untuk WO-20240801-003', 3, '2024-08-01', 80000, 80000),
(1, 'in', 10, 'purchase', null, 'Pembelian stock kampas rem', 1, '2024-07-15', 150000, 1500000),
(2, 'in', 20, 'purchase', null, 'Pembelian stock filter oli', 1, '2024-07-15', 50000, 1000000);

-- Insert Purchase Invoices
INSERT INTO purchase_invoices (invoice_number, transaction_type, customer_id, supplier_id, vehicle_id, purchase_price, negotiated_price, final_price, payment_method, notes, created_by, transaction_date) VALUES
('PUR-20240115-001', 'customer', 1, null, 1, 160000000, 150000000, 150000000, 'transfer', 'Pembelian Toyota Avanza dari customer', 2, '2024-01-15'),
('PUR-20240120-001', 'customer', 2, null, 2, 125000000, 120000000, 120000000, 'cash', 'Pembelian Honda Brio dari customer', 2, '2024-01-20'),
('PUR-20240201-001', 'customer', 3, null, 3, 22000000, 20000000, 20000000, 'transfer', 'Pembelian Honda Vario dari customer', 2, '2024-02-01'),
('PUR-20240210-001', 'customer', 4, null, 4, 27000000, 25000000, 25000000, 'cash', 'Pembelian Yamaha NMAX dari customer', 2, '2024-02-10'),
('PUR-20240125-001', 'customer', 5, null, 5, 100000000, 95000000, 95000000, 'transfer', 'Pembelian Daihatsu Ayla dari customer', 2, '2024-01-25');

-- Insert Sales Invoices
INSERT INTO sales_invoices (invoice_number, customer_id, vehicle_id, selling_price, discount_percentage, discount_amount, final_price, payment_method, notes, created_by, transaction_date, profit_amount) VALUES
('SAL-20240301-001', 1, 5, 120000000, 2.5, 3000000, 117000000, 'transfer', 'Penjualan Daihatsu Ayla ke customer lama', 2, '2024-03-01', 14000000);

-- Insert Notifications
INSERT INTO notifications (user_id, type, title, message, is_read, reference_type, reference_id) VALUES
(3, 'work_order_assigned', 'Work Order Baru', 'Anda mendapat work order baru: WO-20240801-001', false, 'work_order', 1),
(4, 'work_order_assigned', 'Work Order Baru', 'Anda mendapat work order baru: WO-20240801-002', false, 'work_order', 2),
(1, 'low_stock', 'Stock Rendah', 'Stock spare part SP-0007 (Rantai Motor 428) sudah di bawah minimum', false, 'spare_part', 7),
(1, 'low_stock', 'Stock Rendah', 'Stock spare part SP-0005 (Aki Mobil 12V 45AH) sudah di bawah minimum', false, 'spare_part', 5);

-- Insert Customer Transaction Summary
INSERT INTO customer_transaction_summary (customer_id, total_purchases, total_sales, total_purchase_amount, total_sales_amount, last_transaction_date) VALUES
(1, 1, 1, 150000000, 117000000, '2024-03-01'),
(2, 1, 0, 120000000, 0, '2024-01-20'),
(3, 1, 0, 20000000, 0, '2024-02-01'),
(4, 1, 0, 25000000, 0, '2024-02-10'),
(5, 1, 0, 95000000, 0, '2024-01-25');

-- Insert Daily Reports
INSERT INTO daily_reports (
    report_date, total_sales_today, total_sales_amount, total_profit_today,
    total_purchases_today, total_purchase_amount, cash_in, cash_out, net_cash_flow,
    new_work_orders, completed_work_orders, pending_work_orders,
    parts_used_today, parts_value_used, low_stock_items,
    vehicles_available, vehicles_in_repair, vehicles_sold_today, vehicles_purchased_today,
    generated_by
) VALUES
('2024-08-01', 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 1, 4, 440000, 2, 3, 1, 0, 0, 1);

-- Update stock quantities after movements
UPDATE spare_parts SET stock_quantity = stock_quantity - 1 WHERE id = 1; -- Kampas rem: 25 - 1 = 24
UPDATE spare_parts SET stock_quantity = stock_quantity - 3 WHERE id = 4; -- Oli mesin: 30 - 3 = 27  
UPDATE spare_parts SET stock_quantity = stock_quantity - 1 WHERE id = 2; -- Filter oli: 50 - 1 = 49

-- Update vehicle status for sold vehicle
UPDATE vehicles SET sold_date = '2024-03-01' WHERE id = 5;