package main

import (
	"fmt"
	"log"
	"pos-final/internal/config"
	"pos-final/internal/handler"
	"pos-final/internal/middleware"
	"pos-final/internal/repository"
	"pos-final/internal/service"

	"github.com/gin-gonic/gin"
)

func main() {
	// Load configuration
	cfg := config.LoadConfig()

	// Set Gin mode
	gin.SetMode(cfg.Server.GinMode)

	// Initialize database
	db, err := repository.NewDatabase(cfg.GetDatabaseDSN())
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Initialize repositories
	userRepo := repository.NewUserRepository(db.GetDB())
	customerRepo := repository.NewCustomerRepository(db.GetDB())
	vehicleRepo := repository.NewVehicleRepository(db.GetDB())
	purchaseRepo := repository.NewPurchaseInvoiceRepository(db.GetDB())
	salesRepo := repository.NewSalesInvoiceRepository(db.GetDB())
	workOrderRepo := repository.NewWorkOrderRepository(db.GetDB())
	sparePartRepo := repository.NewSparePartRepository(db.GetDB())
	workOrderPartRepo := repository.NewWorkOrderPartRepository(db.GetDB())

	// Initialize services
	authService := service.NewAuthService(userRepo, cfg.JWT.Secret, cfg.GetJWTDuration())
	userService := service.NewUserService(userRepo)
	customerService := service.NewCustomerService(customerRepo)
	vehicleService := service.NewVehicleService(vehicleRepo)
	sparePartService := service.NewSparePartService(sparePartRepo)
	purchaseService := service.NewPurchaseService(purchaseRepo, vehicleRepo, workOrderRepo, userRepo)
	salesService := service.NewSalesService(salesRepo, vehicleRepo)
	workOrderService := service.NewWorkOrderService(workOrderRepo, vehicleRepo, sparePartRepo, workOrderPartRepo, userRepo)

	// Initialize handlers
	authHandler := handler.NewAuthHandler(authService)
	adminHandler := handler.NewAdminHandler(userService)
	customerHandler := handler.NewCustomerHandler(customerService)
	vehicleHandler := handler.NewVehicleHandler(vehicleService)
	sparePartHandler := handler.NewSparePartHandler(sparePartService)
	dashboardHandler := handler.NewDashboardHandler(customerService, vehicleService, sparePartService, salesService, purchaseService, workOrderService)
	purchaseHandler := handler.NewPurchaseHandler(purchaseService)
	salesHandler := handler.NewSalesHandler(salesService)
	workOrderHandler := handler.NewWorkOrderHandler(workOrderService)

	// Initialize Gin router
	router := gin.New()

	// Add middlewares
	router.Use(middleware.Logger())
	router.Use(middleware.Recovery())
	router.Use(middleware.CORS())

	// Setup routes
	setupRoutes(router, authHandler, adminHandler, customerHandler, vehicleHandler, sparePartHandler, dashboardHandler, purchaseHandler, salesHandler, workOrderHandler, cfg)

	// Start server
	serverAddr := fmt.Sprintf(":%d", cfg.Server.Port)
	log.Printf("Server starting on port %d", cfg.Server.Port)
	
	if err := router.Run(serverAddr); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

func setupRoutes(
	router *gin.Engine, 
	authHandler *handler.AuthHandler,
	adminHandler *handler.AdminHandler,
	customerHandler *handler.CustomerHandler,
	vehicleHandler *handler.VehicleHandler,
	sparePartHandler *handler.SparePartHandler,
	dashboardHandler *handler.DashboardHandler,
	purchaseHandler *handler.PurchaseHandler,
	salesHandler *handler.SalesHandler,
	workOrderHandler *handler.WorkOrderHandler,
	cfg *config.Config,
) {
	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "POS System API is running",
		})
	})

	// API version 1
	v1 := router.Group("/api/v1")

	// Auth routes (public)
	auth := v1.Group("/auth")
	{
		auth.POST("/login", authHandler.Login)
		auth.POST("/register", authHandler.Register)
	}

	// Protected routes
	protected := v1.Group("/")
	protected.Use(middleware.JWTMiddleware(cfg.JWT.Secret))
	{
		// Auth protected routes
		authProtected := protected.Group("/auth")
		{
			authProtected.GET("/profile", authHandler.GetProfile)
			authProtected.POST("/refresh", authHandler.RefreshToken)
			authProtected.POST("/change-password", authHandler.ChangePassword)
		}

		// Purchase Invoice routes (admin + kasir)
		purchases := protected.Group("/purchases")
		purchases.Use(middleware.RequireAdminOrKasir())
		{
			purchases.POST("/", purchaseHandler.CreatePurchaseInvoice)
			purchases.GET("/", purchaseHandler.ListPurchaseInvoices)
			purchases.GET("/:id", purchaseHandler.GetPurchaseInvoice)
			purchases.GET("/reports/daily", purchaseHandler.GetDailyPurchaseReport)
		}

		// Sales Invoice routes (admin + kasir)
		sales := protected.Group("/sales")
		sales.Use(middleware.RequireAdminOrKasir())
		{
			sales.POST("/", salesHandler.CreateSalesInvoice)
			sales.GET("/", salesHandler.ListSalesInvoices)
			sales.GET("/:id", salesHandler.GetSalesInvoice)
			sales.PUT("/:id", salesHandler.UpdateSalesInvoice)
			sales.DELETE("/:id", salesHandler.DeleteSalesInvoice)
			sales.GET("/reports/daily", salesHandler.GetDailySalesReport)
		}

		// Work Order routes (admin + mechanic)
		workOrders := protected.Group("/work-orders")
		{
			workOrders.POST("/", middleware.RequireAdmin(), workOrderHandler.CreateWorkOrder)
			workOrders.GET("/", workOrderHandler.ListWorkOrders)
			workOrders.GET("/my", middleware.RequireMekanik(), workOrderHandler.ListMyWorkOrders)
			workOrders.GET("/:id", workOrderHandler.GetWorkOrder)
			workOrders.PUT("/:id/start", workOrderHandler.StartWorkOrder)
			workOrders.PUT("/:id/complete", workOrderHandler.CompleteWorkOrder)
			workOrders.PUT("/:id/progress", workOrderHandler.UpdateProgress)
			workOrders.PUT("/:id/assign", middleware.RequireAdmin(), workOrderHandler.AssignMechanic)
			workOrders.POST("/:id/use-part", workOrderHandler.UsePart)
		}

		// Admin-only routes
		admin := protected.Group("/admin")
		admin.Use(middleware.RequireAdmin())
		{
			// User management
			admin.GET("/users", adminHandler.ListUsers)
			admin.POST("/users", adminHandler.CreateUser)
			admin.GET("/users/:id", adminHandler.GetUser)
			admin.PUT("/users/:id", adminHandler.UpdateUser)
			admin.PUT("/users/:id/password", adminHandler.ChangeUserPassword)
			admin.PUT("/users/:id/activate", adminHandler.ActivateUser)
			admin.DELETE("/users/:id", adminHandler.DeleteUser)
			
			// Admin dashboard
			admin.GET("/dashboard", dashboardHandler.GetDashboardStats)
		}

		// Kasir routes (admin + kasir)
		kasir := protected.Group("/kasir")
		kasir.Use(middleware.RequireAdminOrKasir())
		{
			kasir.GET("/dashboard", dashboardHandler.GetKasirDashboard)
		}

		// Mechanic routes (mekanik only)
		mechanic := protected.Group("/mechanic")
		mechanic.Use(middleware.RequireMekanik())
		{
			mechanic.GET("/dashboard", dashboardHandler.GetMekanikDashboard)
		}

		// Customer routes (all authenticated users can view, admin + kasir can manage)
		customers := protected.Group("/customers")
		{
			customers.GET("/", customerHandler.ListCustomers)
			customers.GET("/:id", customerHandler.GetCustomer)
		}
		
		customersManage := protected.Group("/customers")
		customersManage.Use(middleware.RequireAdminOrKasir())
		{
			customersManage.POST("/", customerHandler.CreateCustomer)
			customersManage.PUT("/:id", customerHandler.UpdateCustomer)
			customersManage.DELETE("/:id", customerHandler.DeleteCustomer)
		}
		
		// Vehicle routes (all authenticated users can view, admin + kasir can manage)
		vehicles := protected.Group("/vehicles")
		{
			vehicles.GET("/", vehicleHandler.ListVehicles)
			vehicles.GET("/:id", vehicleHandler.GetVehicle)
		}
		
		vehiclesManage := protected.Group("/vehicles")
		vehiclesManage.Use(middleware.RequireAdminOrKasir())
		{
			vehiclesManage.POST("/", vehicleHandler.CreateVehicle)
			vehiclesManage.PUT("/:id", vehicleHandler.UpdateVehicle)
			vehiclesManage.PUT("/:id/status", vehicleHandler.UpdateVehicleStatus)
			vehiclesManage.DELETE("/:id", vehicleHandler.DeleteVehicle)
		}
		
		// Spare Parts routes (all authenticated users can view, admin + kasir can manage)
		spareParts := protected.Group("/spare-parts")
		{
			spareParts.GET("/", sparePartHandler.ListSpareParts)
			spareParts.GET("/low-stock", sparePartHandler.CheckLowStock)
			spareParts.GET("/:id", sparePartHandler.GetSparePart)
			spareParts.GET("/code/:code", sparePartHandler.GetSparePartByCode)
			spareParts.GET("/barcode/:barcode", sparePartHandler.GetSparePartByBarcode)
		}
		
		sparePartsManage := protected.Group("/spare-parts")
		sparePartsManage.Use(middleware.RequireAdminOrKasir())
		{
			sparePartsManage.POST("/", sparePartHandler.CreateSparePart)
			sparePartsManage.PUT("/:id", sparePartHandler.UpdateSparePart)
			sparePartsManage.POST("/:id/adjust-stock", sparePartHandler.AdjustStock)
			sparePartsManage.DELETE("/:id", sparePartHandler.DeleteSparePart)
		}
	}
}