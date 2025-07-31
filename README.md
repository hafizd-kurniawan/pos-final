# POS Final - Point of Sale System

A comprehensive Point of Sale (POS) system for vehicle sales, repairs, and spare parts management built with Go, Gin, PostgreSQL, and clean architecture principles.

## Features

### 🚗 Vehicle Management
- Vehicle inventory tracking
- Multiple vehicle categories (Mobil, Motor, Truk)
- Photo management (9 angles per vehicle)
- Status tracking (Available, In Repair, Sold, Reserved)
- Purchase price, repair cost, and selling price tracking

### 👥 User Management
- Role-based access control (Admin, Kasir, Mekanik)
- JWT authentication
- User profile management

### 🛒 Sales & Purchase Management
- Purchase invoices from customers/suppliers
- Sales invoices to customers
- Payment method tracking (Cash, Transfer)
- Transfer proof upload
- Profit calculation

### 🔧 Work Order Management
- Work order creation and assignment
- Mechanic assignment
- Progress tracking
- Parts usage tracking
- Labor cost calculation

### 📦 Inventory Management
- Spare parts catalog
- Stock level monitoring
- Low stock alerts
- Stock movement history
- Barcode support

### 📊 Reporting
- Daily reports
- Sales reports
- Purchase reports
- Inventory reports
- Customer transaction summary

### 🔔 Notifications
- Work order assignments
- Low stock alerts
- Work order updates
- Daily report notifications

## Tech Stack

- **Backend**: Go 1.21+ with Gin framework
- **Database**: PostgreSQL 15
- **Authentication**: JWT tokens
- **Architecture**: Clean Architecture
- **Containerization**: Docker & Docker Compose
- **Documentation**: Built-in API documentation

## Project Structure

```
pos-final/
├── cmd/
│   └── server/          # Main application entry point
├── internal/
│   ├── config/          # Configuration management
│   ├── domain/          # Domain models and entities
│   ├── repository/      # Data access layer
│   ├── service/         # Business logic layer
│   ├── handler/         # HTTP handlers
│   └── middleware/      # Authentication & authorization
├── migrations/          # Database migrations
├── docker/             # Docker configuration
├── templates/          # Invoice templates
├── static/             # Static files and uploads
├── docs/               # API documentation
├── docker-compose.yml  # Docker Compose configuration
├── Makefile           # Build and deployment commands
└── README.md          # Project documentation
```

## Quick Start

### Prerequisites
- Docker and Docker Compose
- Go 1.21+ (for local development)
- Make (optional, for using Makefile commands)

### 1. Clone the Repository
```bash
git clone <repository-url>
cd pos-final
```

### 2. Setup Development Environment
```bash
# Start all services (database + application)
make dev

# Or manually:
docker-compose up -d
make migrate
make seed
```

### 3. Access the Application
- **API Base URL**: http://localhost:8080
- **Health Check**: http://localhost:8080/health
- **Database**: postgresql://pos_user:pos_password@localhost:5432/pos_db

## API Documentation

### Authentication

#### Login
```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

#### Register
```bash
POST /api/v1/auth/register
Content-Type: application/json

{
  "username": "newuser",
  "email": "user@example.com",
  "password": "password123",
  "full_name": "New User",
  "phone": "081234567890",
  "role": "kasir"
}
```

### Protected Endpoints

All protected endpoints require Authorization header:
```
Authorization: Bearer <jwt_token>
```

#### User Profile
```bash
GET /api/v1/auth/profile
Authorization: Bearer <jwt_token>
```

#### Change Password
```bash
POST /api/v1/auth/change-password
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "old_password": "oldpass123",
  "new_password": "newpass123"
}
```

## Role-Based Access Control

### Admin Role
- Full system access
- User management
- System configuration
- All reports and analytics

### Kasir Role
- Sales management
- Customer management
- Invoice generation
- Sales reports

### Mekanik Role
- Work order management
- Parts usage tracking
- Work order updates
- Inventory for repairs

## Database Schema

The system uses PostgreSQL with the following main entities:

- **Users**: System users with role-based access
- **Customers**: Customer information and transaction history
- **Suppliers**: Supplier information for parts/vehicles
- **Vehicle Categories**: Classification of vehicles
- **Vehicles**: Vehicle inventory with detailed information
- **Vehicle Photos**: Multiple photos per vehicle
- **Purchase Invoices**: Vehicle purchases from customers/suppliers
- **Sales Invoices**: Vehicle sales to customers
- **Work Orders**: Repair and maintenance jobs
- **Spare Parts**: Parts inventory management
- **Work Order Parts**: Parts used in work orders
- **Stock Movements**: Inventory movement history
- **Notifications**: System notifications
- **Daily Reports**: Automated daily business reports

## Development Commands

```bash
# Build application
make build

# Run locally
make run

# Start development environment
make dev

# Database operations
make migrate          # Run migrations
make seed            # Insert dummy data
make reset-db        # Reset database
make db-shell        # Connect to database

# Docker operations
make docker-up       # Start services
make docker-down     # Stop services
make docker-logs     # View logs

# Code quality
make fmt            # Format code
make lint           # Run linter
```

## Default Users

The system comes with pre-configured users for testing:

| Username | Password   | Role     | Email              |
|----------|------------|----------|-------------------|
| admin    | admin123   | admin    | admin@pos.com     |
| kasir1   | kasir123   | kasir    | kasir1@pos.com    |
| mekanik1 | mekanik123 | mekanik  | mekanik1@pos.com  |
| mekanik2 | mekanik123 | mekanik  | mekanik2@pos.com  |

## Configuration

Configuration is managed through environment variables. Copy `.env.example` to `.env` and modify as needed:

```bash
cp .env.example .env
```

Key configuration options:
- `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`: Database connection
- `JWT_SECRET`: Secret key for JWT tokens
- `SERVER_PORT`: API server port
- `UPLOAD_PATH`: File upload directory
- `LOG_LEVEL`: Logging level

## API Response Format

All API responses follow a consistent format:

### Success Response
```json
{
  "message": "Operation successful",
  "data": {
    // Response data here
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

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the API endpoints using the health check endpoint