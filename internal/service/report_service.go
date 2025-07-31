package service

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"pos-final/internal/repository"
	"time"
)

type reportService struct {
	salesRepo       repository.SalesInvoiceRepository
	purchaseRepo    repository.PurchaseInvoiceRepository
	workOrderRepo   repository.WorkOrderRepository
	vehicleRepo     repository.VehicleRepository
	sparePartRepo   repository.SparePartRepository
	customerRepo    repository.CustomerRepository
	userRepo        repository.UserRepository
}

func NewReportService(
	salesRepo repository.SalesInvoiceRepository,
	purchaseRepo repository.PurchaseInvoiceRepository,
	workOrderRepo repository.WorkOrderRepository,
	vehicleRepo repository.VehicleRepository,
	sparePartRepo repository.SparePartRepository,
	customerRepo repository.CustomerRepository,
	userRepo repository.UserRepository,
) ReportService {
	return &reportService{
		salesRepo:     salesRepo,
		purchaseRepo:  purchaseRepo,
		workOrderRepo: workOrderRepo,
		vehicleRepo:   vehicleRepo,
		sparePartRepo: sparePartRepo,
		customerRepo:  customerRepo,
		userRepo:      userRepo,
	}
}

func (s *reportService) GenerateDailyReport(ctx context.Context, date time.Time, generatedBy int) (*domain.DailyReport, error) {
	// Get daily statistics
	startDate := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, date.Location())
	_ = startDate.Add(24 * time.Hour) // endDate for future use

	// For now, create a basic daily report
	// TODO: Implement proper daily report generation with actual data
	report := &domain.DailyReport{
		ReportDate:              date,
		TotalSalesToday:         0,
		TotalSalesAmount:        0,
		TotalProfitToday:        0,
		TotalPurchasesToday:     0,
		TotalPurchaseAmount:     0,
		CashIn:                  0,
		CashOut:                 0,
		NetCashFlow:             0,
		NewWorkOrders:           0,
		CompletedWorkOrders:     0,
		PendingWorkOrders:       0,
		PartsUsedToday:          0,
		PartsValueUsed:          0,
		LowStockItems:           0,
		VehiclesAvailable:       0,
		VehiclesInRepair:        0,
		VehiclesSoldToday:       0,
		VehiclesPurchasedToday:  0,
		BestSellingUserID:       nil,
		MostActiveMechanicID:    nil,
		GeneratedAt:             time.Now(),
		GeneratedBy:             &generatedBy,
	}

	return report, nil
}

func (s *reportService) GetDailyReport(ctx context.Context, date time.Time) (*domain.DailyReport, error) {
	// TODO: Implement when DailyReportRepository is available
	return s.GenerateDailyReport(ctx, date, 1) // For now, generate on-the-fly
}

func (s *reportService) ListDailyReports(ctx context.Context, startDate, endDate time.Time, page, limit int) ([]*domain.DailyReport, int, error) {
	// TODO: Implement when DailyReportRepository is available
	return nil, 0, fmt.Errorf("daily reports list not implemented yet")
}

func (s *reportService) GetSalesReport(ctx context.Context, startDate, endDate time.Time) (map[string]interface{}, error) {
	// Get sales data for the date range
	// For now, use simplified logic since we need to implement the repository method
	// TODO: Implement proper date range queries in repository
	salesInvoices, err := s.salesRepo.List(ctx, 0, 1000)
	if err != nil {
		return nil, fmt.Errorf("failed to get sales invoices: %w", err)
	}

	// Filter by date range (simplified approach)
	var filteredSales []*domain.SalesInvoice
	for _, sale := range salesInvoices {
		if sale.TransactionDate.After(startDate) && sale.TransactionDate.Before(endDate) {
			filteredSales = append(filteredSales, sale)
		}
	}

	// Calculate metrics
	var totalAmount, totalProfit float64
	var paymentMethods = make(map[string]int)
	var dailySales = make(map[string]float64)
	var topCustomers = make(map[int]float64)

	for _, sale := range filteredSales {
		totalAmount += sale.FinalPrice
		totalProfit += sale.ProfitAmount
		
		// Payment method breakdown
		paymentMethods[string(sale.PaymentMethod)]++
		
		// Daily sales
		dateKey := sale.TransactionDate.Format("2006-01-02")
		dailySales[dateKey] += sale.FinalPrice
		
		// Top customers
		topCustomers[sale.CustomerID] += sale.FinalPrice
	}

	profitMargin := float64(0)
	if totalAmount > 0 {
		profitMargin = (totalProfit / totalAmount) * 100
	}

	avgSale := float64(0)
	if len(filteredSales) > 0 {
		avgSale = totalAmount / float64(len(filteredSales))
	}

	return map[string]interface{}{
		"period": map[string]interface{}{
			"start_date": startDate.Format("2006-01-02"),
			"end_date":   endDate.Format("2006-01-02"),
		},
		"summary": map[string]interface{}{
			"total_sales":    len(filteredSales),
			"total_amount":   totalAmount,
			"total_profit":   totalProfit,
			"profit_margin":  profitMargin,
			"average_sale":   avgSale,
		},
		"payment_methods": paymentMethods,
		"daily_breakdown": dailySales,
		"top_customers":   topCustomers,
	}, nil
}

func (s *reportService) GetPurchaseReport(ctx context.Context, startDate, endDate time.Time) (map[string]interface{}, error) {
	// Get purchase data for the date range
	// For now, use simplified logic since we need to implement the repository method
	purchaseInvoices, err := s.purchaseRepo.List(ctx, 0, 1000)
	if err != nil {
		return nil, fmt.Errorf("failed to get purchase invoices: %w", err)
	}

	// Filter by date range (simplified approach)
	var filteredPurchases []*domain.PurchaseInvoice
	for _, purchase := range purchaseInvoices {
		if purchase.TransactionDate.After(startDate) && purchase.TransactionDate.Before(endDate) {
			filteredPurchases = append(filteredPurchases, purchase)
		}
	}

	// Calculate metrics
	var totalAmount, totalNegotiated float64
	var paymentMethods = make(map[string]int)
	var dailyPurchases = make(map[string]float64)
	var suppliers = make(map[int]float64)

	for _, purchase := range filteredPurchases {
		totalAmount += purchase.FinalPrice
		if purchase.NegotiatedPrice != nil {
			totalNegotiated += *purchase.NegotiatedPrice
		}
		
		// Payment method breakdown
		paymentMethods[string(purchase.PaymentMethod)]++
		
		// Daily purchases
		dateKey := purchase.TransactionDate.Format("2006-01-02")
		dailyPurchases[dateKey] += purchase.FinalPrice
		
		// Suppliers (if available)
		if purchase.SupplierID != nil {
			suppliers[*purchase.SupplierID] += purchase.FinalPrice
		}
	}

	avgPurchase := float64(0)
	if len(filteredPurchases) > 0 {
		avgPurchase = totalAmount / float64(len(filteredPurchases))
	}

	return map[string]interface{}{
		"period": map[string]interface{}{
			"start_date": startDate.Format("2006-01-02"),
			"end_date":   endDate.Format("2006-01-02"),
		},
		"summary": map[string]interface{}{
			"total_purchases":      len(filteredPurchases),
			"total_amount":         totalAmount,
			"total_negotiated":     totalNegotiated,
			"average_purchase":     avgPurchase,
		},
		"payment_methods":  paymentMethods,
		"daily_breakdown":  dailyPurchases,
		"supplier_breakdown": suppliers,
	}, nil
}

func (s *reportService) GetInventoryReport(ctx context.Context) (map[string]interface{}, error) {
	// Get all spare parts
	spareParts, err := s.sparePartRepo.List(ctx, 0, 1000)
	if err != nil {
		return nil, fmt.Errorf("failed to get spare parts: %w", err)
	}

	// Get all vehicles
	vehicles, err := s.vehicleRepo.List(ctx, 0, 1000)
	if err != nil {
		return nil, fmt.Errorf("failed to get vehicles: %w", err)
	}

	// Calculate spare parts metrics
	var totalPartsValue float64
	var lowStockCount, outOfStockCount int
	var partsByCategory = make(map[string]int)

	for _, part := range spareParts {
		totalPartsValue += float64(part.StockQuantity) * part.CostPrice
		
		if part.StockQuantity <= part.MinStockLevel {
			if part.StockQuantity == 0 {
				outOfStockCount++
			} else {
				lowStockCount++
			}
		}
		
		// Parts by category (if you have categories)
		category := "General"
		if part.Category != nil {
			category = *part.Category
		}
		partsByCategory[category]++
	}

	// Calculate vehicle metrics
	var vehiclesByStatus = make(map[string]int)
	var totalVehicleValue float64

	for _, vehicle := range vehicles {
		vehiclesByStatus[string(vehicle.Status)]++
		if vehicle.HPP != nil {
			totalVehicleValue += *vehicle.HPP
		}
	}

	return map[string]interface{}{
		"spare_parts": map[string]interface{}{
			"total_parts":      len(spareParts),
			"total_value":      totalPartsValue,
			"low_stock_count":  lowStockCount,
			"out_of_stock":     outOfStockCount,
			"parts_by_category": partsByCategory,
		},
		"vehicles": map[string]interface{}{
			"total_vehicles":     len(vehicles),
			"total_value":        totalVehicleValue,
			"vehicles_by_status": vehiclesByStatus,
		},
		"alerts": map[string]interface{}{
			"low_stock_parts":  lowStockCount,
			"out_of_stock":     outOfStockCount,
		},
	}, nil
}

func (s *reportService) GetProfitLossReport(ctx context.Context, startDate, endDate time.Time) (map[string]interface{}, error) {
	// Get sales and purchase data
	salesData, err := s.GetSalesReport(ctx, startDate, endDate)
	if err != nil {
		return nil, fmt.Errorf("failed to get sales data: %w", err)
	}

	purchaseData, err := s.GetPurchaseReport(ctx, startDate, endDate)
	if err != nil {
		return nil, fmt.Errorf("failed to get purchase data: %w", err)
	}

	// Extract values
	salesSummary := salesData["summary"].(map[string]interface{})
	purchaseSummary := purchaseData["summary"].(map[string]interface{})

	totalRevenue := salesSummary["total_amount"].(float64)
	totalProfit := salesSummary["total_profit"].(float64)
	totalPurchases := purchaseSummary["total_amount"].(float64)

	// Calculate net profit/loss
	netProfit := totalProfit // Simplified - in reality, you'd subtract operational costs

	return map[string]interface{}{
		"period": map[string]interface{}{
			"start_date": startDate.Format("2006-01-02"),
			"end_date":   endDate.Format("2006-01-02"),
		},
		"revenue": map[string]interface{}{
			"total_sales_revenue": totalRevenue,
			"gross_profit":        totalProfit,
		},
		"costs": map[string]interface{}{
			"cost_of_goods_sold": totalPurchases,
			"operational_costs":  0, // TODO: Add operational costs tracking
		},
		"profit": map[string]interface{}{
			"gross_profit": totalProfit,
			"net_profit":   netProfit,
			"profit_margin": func() float64 {
				if totalRevenue > 0 {
					return (netProfit / totalRevenue) * 100
				}
				return 0
			}(),
		},
	}, nil
}

func (s *reportService) GetVehicleReport(ctx context.Context) (map[string]interface{}, error) {
	// Get all vehicles
	vehicles, err := s.vehicleRepo.List(ctx, 0, 1000)
	if err != nil {
		return nil, fmt.Errorf("failed to get vehicles: %w", err)
	}

	// Calculate metrics
	var statusBreakdown = make(map[string]int)
	var brandBreakdown = make(map[string]int)
	var yearBreakdown = make(map[int]int)
	var totalInventoryValue float64

	for _, vehicle := range vehicles {
		statusBreakdown[string(vehicle.Status)]++
		brandBreakdown[vehicle.Brand]++
		yearBreakdown[vehicle.Year]++
		
		if vehicle.HPP != nil {
			totalInventoryValue += *vehicle.HPP
		}
	}

	// Calculate average values
	avgPurchasePrice := float64(0)
	avgSellingPrice := float64(0)
	avgRepairCost := float64(0)
	vehicleCount := 0

	for _, vehicle := range vehicles {
		if vehicle.PurchasePrice != nil {
			avgPurchasePrice += *vehicle.PurchasePrice
			vehicleCount++
		}
		if vehicle.SellingPrice != nil {
			avgSellingPrice += *vehicle.SellingPrice
		}
		avgRepairCost += vehicle.RepairCost
	}

	if vehicleCount > 0 {
		avgPurchasePrice /= float64(vehicleCount)
		avgSellingPrice /= float64(len(vehicles))
		avgRepairCost /= float64(len(vehicles))
	}

	return map[string]interface{}{
		"summary": map[string]interface{}{
			"total_vehicles":       len(vehicles),
			"total_inventory_value": totalInventoryValue,
			"average_purchase_price": avgPurchasePrice,
			"average_selling_price":  avgSellingPrice,
			"average_repair_cost":    avgRepairCost,
		},
		"breakdown": map[string]interface{}{
			"by_status": statusBreakdown,
			"by_brand":  brandBreakdown,
			"by_year":   yearBreakdown,
		},
	}, nil
}

func (s *reportService) GetWorkOrderReport(ctx context.Context, startDate, endDate time.Time) (map[string]interface{}, error) {
	// Get work orders for the date range
	workOrders, err := s.workOrderRepo.ListByDateRange(ctx, startDate, endDate, 0, 1000)
	if err != nil {
		return nil, fmt.Errorf("failed to get work orders: %w", err)
	}

	// Calculate metrics
	var statusBreakdown = make(map[string]int)
	var mechanicWorkload = make(map[int]int)
	var totalLaborCost, totalPartsCost float64
	var completedOrders int
	var totalCompletionTime float64

	for _, wo := range workOrders {
		statusBreakdown[string(wo.Status)]++
		mechanicWorkload[wo.AssignedMechanicID]++
		totalLaborCost += wo.LaborCost
		totalPartsCost += wo.TotalPartsCost
		
		if wo.Status == domain.WorkOrderStatusCompleted && wo.StartedAt != nil && wo.CompletedAt != nil {
			completedOrders++
			duration := wo.CompletedAt.Sub(*wo.StartedAt)
			totalCompletionTime += duration.Hours()
		}
	}

	avgCompletionTime := float64(0)
	if completedOrders > 0 {
		avgCompletionTime = totalCompletionTime / float64(completedOrders)
	}

	return map[string]interface{}{
		"period": map[string]interface{}{
			"start_date": startDate.Format("2006-01-02"),
			"end_date":   endDate.Format("2006-01-02"),
		},
		"summary": map[string]interface{}{
			"total_work_orders":     len(workOrders),
			"completed_orders":      completedOrders,
			"completion_rate":       float64(completedOrders) / float64(len(workOrders)) * 100,
			"total_labor_cost":      totalLaborCost,
			"total_parts_cost":      totalPartsCost,
			"avg_completion_time":   avgCompletionTime,
		},
		"breakdown": map[string]interface{}{
			"by_status":   statusBreakdown,
			"by_mechanic": mechanicWorkload,
		},
	}, nil
}

func (s *reportService) GetCustomerReport(ctx context.Context) (map[string]interface{}, error) {
	// Get all customers
	customers, err := s.customerRepo.List(ctx, 0, 1000)
	if err != nil {
		return nil, fmt.Errorf("failed to get customers: %w", err)
	}

	// Get sales data to analyze customer transactions
	salesInvoices, err := s.salesRepo.List(ctx, 0, 1000)
	if err != nil {
		return nil, fmt.Errorf("failed to get sales invoices: %w", err)
	}

	// Calculate customer metrics
	var customerTransactions = make(map[int]int)
	var customerTotalSpent = make(map[int]float64)
	var totalRevenue float64

	for _, sale := range salesInvoices {
		customerTransactions[sale.CustomerID]++
		customerTotalSpent[sale.CustomerID] += sale.FinalPrice
		totalRevenue += sale.FinalPrice
	}

	// Find top customers
	type customerMetric struct {
		CustomerID   int     `json:"customer_id"`
		Name         string  `json:"name"`
		Transactions int     `json:"transactions"`
		TotalSpent   float64 `json:"total_spent"`
	}

	var topCustomers []customerMetric
	for _, customer := range customers {
		transactions := customerTransactions[customer.ID]
		totalSpent := customerTotalSpent[customer.ID]
		
		if transactions > 0 {
			topCustomers = append(topCustomers, customerMetric{
				CustomerID:   customer.ID,
				Name:         customer.Name,
				Transactions: transactions,
				TotalSpent:   totalSpent,
			})
		}
	}

	// Calculate averages
	avgTransactionsPerCustomer := float64(0)
	avgSpentPerCustomer := float64(0)
	activeCustomers := len(topCustomers)

	if activeCustomers > 0 {
		totalTransactions := 0
		for _, metric := range topCustomers {
			totalTransactions += metric.Transactions
		}
		avgTransactionsPerCustomer = float64(totalTransactions) / float64(activeCustomers)
		avgSpentPerCustomer = totalRevenue / float64(activeCustomers)
	}

	return map[string]interface{}{
		"summary": map[string]interface{}{
			"total_customers":              len(customers),
			"active_customers":             activeCustomers,
			"customer_retention_rate":      float64(activeCustomers) / float64(len(customers)) * 100,
			"avg_transactions_per_customer": avgTransactionsPerCustomer,
			"avg_spent_per_customer":       avgSpentPerCustomer,
			"total_revenue":                totalRevenue,
		},
		"top_customers": topCustomers,
	}, nil
}