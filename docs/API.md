# POS System API Documentation

## Base URL
```
http://localhost:8080/api/v1
```

## Authentication

All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## Response Format

### Success Response
```json
{
  "message": "Operation successful",
  "data": {
    // Response data
  }
}
```

### Error Response
```json
{
  "error": "Error message",
  "details": "Additional error details (optional)"
}
```

## Authentication Endpoints

### POST /auth/login
Login to the system.

**Request Body:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@pos.com",
      "full_name": "Administrator",
      "phone": "081234567890",
      "role": "admin",
      "is_active": true,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### POST /auth/register
Register a new user (Admin only).

**Request Body:**
```json
{
  "username": "newuser",
  "email": "user@example.com",
  "password": "password123",
  "full_name": "New User",
  "phone": "081234567890",
  "role": "kasir"
}
```

### GET /auth/profile
Get current user profile (Protected).

### POST /auth/refresh
Refresh JWT token (Protected).

### POST /auth/change-password
Change user password (Protected).

**Request Body:**
```json
{
  "old_password": "oldpass123",
  "new_password": "newpass123"
}
```

## User Management (Admin Only)

### GET /admin/users
List all users.

**Query Parameters:**
- `page` (int): Page number (default: 1)
- `limit` (int): Items per page (default: 10)

### POST /admin/users
Create a new user.

### GET /admin/users/{id}
Get user by ID.

### PUT /admin/users/{id}
Update user.

### DELETE /admin/users/{id}
Soft delete user.

## Customer Management

### GET /customers
List customers.

**Query Parameters:**
- `page` (int): Page number
- `limit` (int): Items per page
- `search` (string): Search term

### POST /customers
Create customer.

**Request Body:**
```json
{
  "name": "John Doe",
  "ktp_number": "3201234567890123",
  "phone": "081234567890",
  "email": "john@example.com",
  "address": "Jl. Example No. 123"
}
```

### GET /customers/{id}
Get customer by ID.

### PUT /customers/{id}
Update customer.

### DELETE /customers/{id}
Soft delete customer.

### GET /customers/search
Search customers.

**Query Parameters:**
- `q` (string): Search query
- `page` (int): Page number
- `limit` (int): Items per page

## Supplier Management

### GET /suppliers
List suppliers.

### POST /suppliers
Create supplier.

**Request Body:**
```json
{
  "name": "PT. Supplier",
  "contact_person": "Contact Name",
  "phone": "0212345678",
  "email": "supplier@example.com",
  "address": "Jl. Supplier No. 456"
}
```

### GET /suppliers/{id}
Get supplier by ID.

### PUT /suppliers/{id}
Update supplier.

### DELETE /suppliers/{id}
Soft delete supplier.

## Vehicle Categories

### GET /vehicle-categories
List vehicle categories.

### POST /vehicle-categories
Create vehicle category (Admin only).

**Request Body:**
```json
{
  "name": "Mobil",
  "description": "Kendaraan roda empat"
}
```

### GET /vehicle-categories/{id}
Get category by ID.

### PUT /vehicle-categories/{id}
Update category (Admin only).

### DELETE /vehicle-categories/{id}
Delete category (Admin only).

## Vehicle Management

### GET /vehicles
List vehicles.

**Query Parameters:**
- `page` (int): Page number
- `limit` (int): Items per page
- `status` (string): Filter by status
- `category_id` (int): Filter by category
- `search` (string): Search term

### POST /vehicles
Add new vehicle.

**Request Body:**
```json
{
  "category_id": 1,
  "brand": "Toyota",
  "model": "Avanza",
  "year": 2020,
  "chassis_number": "TOY123456789",
  "engine_number": "ENG123456789",
  "plate_number": "B 1234 ABC",
  "color": "Silver",
  "fuel_type": "Bensin",
  "transmission": "Manual",
  "purchase_price": 150000000,
  "selling_price": 175000000,
  "condition_notes": "Kondisi baik"
}
```

### GET /vehicles/{id}
Get vehicle by ID.

### PUT /vehicles/{id}
Update vehicle.

### DELETE /vehicles/{id}
Soft delete vehicle.

### PUT /vehicles/{id}/status
Update vehicle status.

**Request Body:**
```json
{
  "status": "available"
}
```

### POST /vehicles/{id}/photos
Upload vehicle photo.

**Form Data:**
- `photo` (file): Image file
- `photo_type` (string): Photo type (depan, belakang, etc.)
- `description` (string): Photo description

### GET /vehicles/{id}/photos
Get vehicle photos.

### DELETE /vehicles/photos/{photo_id}
Delete vehicle photo.

## Purchase Management

### GET /purchases
List purchase invoices.

**Query Parameters:**
- `page` (int): Page number
- `limit` (int): Items per page
- `type` (string): customer or supplier
- `start_date` (date): Filter start date
- `end_date` (date): Filter end date

### POST /purchases
Create purchase invoice.

**Request Body:**
```json
{
  "transaction_type": "customer",
  "customer_id": 1,
  "vehicle_id": 1,
  "purchase_price": 150000000,
  "negotiated_price": 145000000,
  "final_price": 145000000,
  "payment_method": "cash",
  "notes": "Purchase from customer"
}
```

### GET /purchases/{id}
Get purchase invoice by ID.

### PUT /purchases/{id}
Update purchase invoice.

### DELETE /purchases/{id}
Soft delete purchase invoice.

### POST /purchases/{id}/transfer-proof
Upload transfer proof.

**Form Data:**
- `transfer_proof` (file): Transfer proof image

## Sales Management

### GET /sales
List sales invoices.

### POST /sales
Create sales invoice.

**Request Body:**
```json
{
  "customer_id": 1,
  "vehicle_id": 1,
  "selling_price": 175000000,
  "discount_percentage": 2.5,
  "discount_amount": 4375000,
  "final_price": 170625000,
  "payment_method": "transfer",
  "notes": "Sale to loyal customer"
}
```

### GET /sales/{id}
Get sales invoice by ID.

### PUT /sales/{id}
Update sales invoice.

### DELETE /sales/{id}
Soft delete sales invoice.

### GET /sales/{id}/pdf
Generate sales invoice PDF.

### POST /sales/{id}/transfer-proof
Upload transfer proof.

## Work Order Management (Mekanik + Admin)

### GET /work-orders
List work orders.

**Query Parameters:**
- `status` (string): Filter by status
- `mechanic_id` (int): Filter by mechanic

### POST /work-orders
Create work order.

**Request Body:**
```json
{
  "vehicle_id": 1,
  "description": "Ganti kampas rem + service AC",
  "assigned_mechanic_id": 3,
  "labor_cost": 200000,
  "notes": "Urgent repair"
}
```

### GET /work-orders/{id}
Get work order by ID.

### PUT /work-orders/{id}
Update work order.

### DELETE /work-orders/{id}
Soft delete work order.

### PUT /work-orders/{id}/status
Update work order status.

**Request Body:**
```json
{
  "status": "in_progress"
}
```

### PUT /work-orders/{id}/progress
Update work order progress.

**Request Body:**
```json
{
  "progress_percentage": 75
}
```

### POST /work-orders/{id}/parts
Add parts to work order.

**Request Body:**
```json
{
  "spare_part_id": 1,
  "quantity_used": 2,
  "unit_cost": 150000
}
```

### GET /work-orders/{id}/parts
Get work order parts.

## Spare Parts Management

### GET /spare-parts
List spare parts.

**Query Parameters:**
- `search` (string): Search term
- `low_stock` (bool): Filter low stock items

### POST /spare-parts
Create spare part.

**Request Body:**
```json
{
  "name": "Kampas Rem Depan",
  "brand": "Brembo",
  "category": "Rem",
  "description": "Kampas rem untuk mobil sedan",
  "cost_price": 150000,
  "selling_price": 200000,
  "stock_quantity": 25,
  "min_stock_level": 5,
  "unit": "set"
}
```

### GET /spare-parts/{id}
Get spare part by ID.

### PUT /spare-parts/{id}
Update spare part.

### DELETE /spare-parts/{id}
Soft delete spare part.

### POST /spare-parts/{id}/adjust-stock
Adjust stock quantity.

**Request Body:**
```json
{
  "adjustment": 10,
  "notes": "Stock replenishment"
}
```

### GET /spare-parts/low-stock
Get low stock items.

## Stock Movement

### GET /stock-movements
List stock movements.

**Query Parameters:**
- `spare_part_id` (int): Filter by spare part
- `movement_type` (string): in or out
- `start_date` (date): Filter start date
- `end_date` (date): Filter end date

### POST /stock-movements
Create stock movement.

**Request Body:**
```json
{
  "spare_part_id": 1,
  "movement_type": "in",
  "quantity": 10,
  "reference_type": "purchase",
  "unit_cost": 150000,
  "notes": "Stock replenishment"
}
```

## Notifications

### GET /notifications
List user notifications.

**Query Parameters:**
- `unread_only` (bool): Filter unread notifications

### GET /notifications/unread-count
Get unread notification count.

### PUT /notifications/{id}/read
Mark notification as read.

### PUT /notifications/read-all
Mark all notifications as read.

## Reports

### GET /reports/daily
Get daily reports.

**Query Parameters:**
- `date` (date): Specific date
- `start_date` (date): Start date range
- `end_date` (date): End date range

### POST /reports/daily/generate
Generate daily report.

**Request Body:**
```json
{
  "date": "2024-08-01"
}
```

### GET /reports/sales
Get sales report.

**Query Parameters:**
- `start_date` (date): Start date
- `end_date` (date): End date

### GET /reports/purchases
Get purchase report.

### GET /reports/inventory
Get inventory report.

### GET /reports/profit-loss
Get profit & loss report.

### GET /reports/vehicles
Get vehicle report.

### GET /reports/customers
Get customer report.

## Dashboard

### GET /dashboard/stats
Get dashboard statistics.

### GET /dashboard/recent-activities
Get recent activities.

### GET /dashboard/performance
Get performance metrics.

### GET /dashboard/alerts
Get inventory alerts.

## Error Codes

| Code | Message | Description |
|------|---------|-------------|
| 400 | Bad Request | Invalid request data |
| 401 | Unauthorized | Missing or invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource already exists |
| 422 | Unprocessable Entity | Validation failed |
| 500 | Internal Server Error | Server error |

## Rate Limiting

- API requests are limited to 1000 requests per hour per user
- File uploads are limited to 10MB per file
- Bulk operations are limited to 100 items per request

## Pagination

List endpoints support pagination:

**Request:**
```
GET /api/v1/customers?page=1&limit=10
```

**Response:**
```json
{
  "message": "Customers retrieved successfully",
  "data": {
    "items": [...],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 100,
      "total_pages": 10
    }
  }
}
```

## File Upload

Supported formats:
- Images: JPG, PNG, GIF (max 5MB)
- Documents: PDF (max 10MB)

Upload endpoints use multipart/form-data.