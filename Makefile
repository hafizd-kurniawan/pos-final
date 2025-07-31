# Makefile for POS System

.PHONY: help build run test clean docker-up docker-down migrate seed

# Variables
BINARY_NAME=pos-server
DOCKER_COMPOSE=docker-compose

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the application
	@echo "Building application..."
	@go build -o bin/$(BINARY_NAME) cmd/server/main.go

run: ## Run the application locally
	@echo "Running application..."
	@go run cmd/server/main.go

test: ## Run tests
	@echo "Running tests..."
	@go test -v ./...

clean: ## Clean build artifacts
	@echo "Cleaning..."
	@rm -rf bin/
	@go clean

docker-up: ## Start Docker services
	@echo "Starting Docker services..."
	@$(DOCKER_COMPOSE) up -d

docker-down: ## Stop Docker services
	@echo "Stopping Docker services..."
	@$(DOCKER_COMPOSE) down

docker-logs: ## Show Docker logs
	@$(DOCKER_COMPOSE) logs -f

docker-build: ## Build Docker image
	@echo "Building Docker image..."
	@$(DOCKER_COMPOSE) build

migrate: ## Run database migrations
	@echo "Running database migrations..."
	@docker exec -i pos_postgres psql -U pos_user -d pos_db < migrations/001_init_schema.sql

seed: ## Seed database with dummy data
	@echo "Seeding database with dummy data..."
	@docker exec -i pos_postgres psql -U pos_user -d pos_db < migrations/002_dummy_data.sql

db-setup: docker-up migrate seed ## Setup database with migrations and dummy data
	@echo "Database setup completed!"

dev: docker-up ## Start development environment
	@echo "Starting development environment..."
	@sleep 5
	@make migrate
	@make seed
	@echo "Development environment ready!"
	@echo "Database: postgresql://pos_user:pos_password@localhost:5432/pos_db"
	@echo "API will run on: http://localhost:8080"

logs: ## Show application logs
	@$(DOCKER_COMPOSE) logs -f app

db-shell: ## Connect to database shell
	@docker exec -it pos_postgres psql -U pos_user -d pos_db

reset-db: docker-down docker-up migrate seed ## Reset database
	@echo "Database reset completed!"

fmt: ## Format Go code
	@echo "Formatting Go code..."
	@go fmt ./...

lint: ## Run linter
	@echo "Running linter..."
	@golangci-lint run

deps: ## Download dependencies
	@echo "Downloading dependencies..."
	@go mod download
	@go mod tidy

install-tools: ## Install development tools
	@echo "Installing development tools..."
	@go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

vendor: ## Create vendor directory
	@echo "Creating vendor directory..."
	@go mod vendor

production-build: ## Build for production
	@echo "Building for production..."
	@CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w -s' -o bin/$(BINARY_NAME) cmd/server/main.go

deploy: production-build ## Deploy application
	@echo "Deploying application..."
	@$(DOCKER_COMPOSE) -f docker-compose.prod.yml up -d --build