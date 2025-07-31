package service

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"pos-final/internal/repository"
	"strings"
)

type customerService struct {
	customerRepo repository.CustomerRepository
}

// NewCustomerService creates a new customer service
func NewCustomerService(customerRepo repository.CustomerRepository) CustomerService {
	return &customerService{
		customerRepo: customerRepo,
	}
}

func (s *customerService) CreateCustomer(ctx context.Context, customer *domain.Customer) error {
	// Validate required fields
	if err := s.validateCustomer(customer); err != nil {
		return err
	}

	// Check if customer code already exists
	if customer.CustomerCode != "" {
		existing, err := s.customerRepo.GetByCustomerCode(ctx, customer.CustomerCode)
		if err != nil {
			return fmt.Errorf("failed to check existing customer code: %w", err)
		}
		if existing != nil {
			return fmt.Errorf("customer code already exists")
		}
	} else {
		// Generate customer code if not provided
		customerCode, err := s.customerRepo.GenerateCustomerCode(ctx)
		if err != nil {
			return fmt.Errorf("failed to generate customer code: %w", err)
		}
		customer.CustomerCode = customerCode
	}

	// Create customer
	if err := s.customerRepo.Create(ctx, customer); err != nil {
		return fmt.Errorf("failed to create customer: %w", err)
	}

	return nil
}

func (s *customerService) GetCustomerByID(ctx context.Context, id int) (*domain.Customer, error) {
	if id <= 0 {
		return nil, fmt.Errorf("invalid customer ID")
	}

	customer, err := s.customerRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get customer: %w", err)
	}

	if customer == nil {
		return nil, fmt.Errorf("customer not found")
	}

	return customer, nil
}

func (s *customerService) GetCustomerByCode(ctx context.Context, customerCode string) (*domain.Customer, error) {
	if customerCode == "" {
		return nil, fmt.Errorf("customer code is required")
	}

	customer, err := s.customerRepo.GetByCustomerCode(ctx, customerCode)
	if err != nil {
		return nil, fmt.Errorf("failed to get customer: %w", err)
	}

	if customer == nil {
		return nil, fmt.Errorf("customer not found")
	}

	return customer, nil
}

func (s *customerService) ListCustomers(ctx context.Context, page, limit int) ([]*domain.Customer, int, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	customers, err := s.customerRepo.List(ctx, offset, limit)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list customers: %w", err)
	}

	total, err := s.customerRepo.Count(ctx)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count customers: %w", err)
	}

	return customers, total, nil
}

func (s *customerService) SearchCustomers(ctx context.Context, query string, page, limit int) ([]*domain.Customer, int, error) {
	if query == "" {
		return s.ListCustomers(ctx, page, limit)
	}

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	customers, err := s.customerRepo.Search(ctx, query, offset, limit)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to search customers: %w", err)
	}

	// For search, we return the count of search results
	// In a production system, you might want to implement a separate count method for search
	total := len(customers)

	return customers, total, nil
}

func (s *customerService) UpdateCustomer(ctx context.Context, customer *domain.Customer) error {
	if customer.ID <= 0 {
		return fmt.Errorf("invalid customer ID")
	}

	// Validate required fields
	if err := s.validateCustomer(customer); err != nil {
		return err
	}

	// Check if customer exists
	existing, err := s.customerRepo.GetByID(ctx, customer.ID)
	if err != nil {
		return fmt.Errorf("failed to check existing customer: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("customer not found")
	}

	// Update customer
	if err := s.customerRepo.Update(ctx, customer); err != nil {
		return fmt.Errorf("failed to update customer: %w", err)
	}

	return nil
}

func (s *customerService) DeleteCustomer(ctx context.Context, id int, deletedBy int) error {
	if id <= 0 {
		return fmt.Errorf("invalid customer ID")
	}

	if deletedBy <= 0 {
		return fmt.Errorf("invalid deleted by user ID")
	}

	// Check if customer exists
	existing, err := s.customerRepo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to check existing customer: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("customer not found")
	}

	// TODO: Check if customer has any active transactions before deleting
	// This would require checking sales invoices, purchase invoices, etc.

	// Soft delete customer
	if err := s.customerRepo.SoftDelete(ctx, id, deletedBy); err != nil {
		return fmt.Errorf("failed to delete customer: %w", err)
	}

	return nil
}

func (s *customerService) validateCustomer(customer *domain.Customer) error {
	if customer == nil {
		return fmt.Errorf("customer is required")
	}

	if strings.TrimSpace(customer.Name) == "" {
		return fmt.Errorf("customer name is required")
	}

	if customer.Phone == nil || strings.TrimSpace(*customer.Phone) == "" {
		return fmt.Errorf("customer phone is required")
	}

	// Validate KTP number if provided
	if customer.KTPNumber != nil && strings.TrimSpace(*customer.KTPNumber) != "" {
		ktpNumber := strings.TrimSpace(*customer.KTPNumber)
		if len(ktpNumber) != 16 {
			return fmt.Errorf("KTP number must be 16 digits")
		}
		// Check if all characters are digits
		for _, char := range ktpNumber {
			if char < '0' || char > '9' {
				return fmt.Errorf("KTP number must contain only digits")
			}
		}
	}

	// Validate email format if provided
	if customer.Email != nil && strings.TrimSpace(*customer.Email) != "" {
		email := strings.TrimSpace(*customer.Email)
		if !strings.Contains(email, "@") || !strings.Contains(email, ".") {
			return fmt.Errorf("invalid email format")
		}
	}

	return nil
}