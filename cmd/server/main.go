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
	// customerRepo := repository.NewCustomerRepository(db.GetDB())
	// vehicleRepo := repository.NewVehicleRepository(db.GetDB())

	// Initialize services
	authService := service.NewAuthService(userRepo, cfg.JWT.Secret, cfg.GetJWTDuration())

	// Initialize handlers
	authHandler := handler.NewAuthHandler(authService)

	// Initialize Gin router
	router := gin.New()

	// Add middlewares
	router.Use(middleware.Logger())
	router.Use(middleware.Recovery())
	router.Use(middleware.CORS())

	// Setup routes
	setupRoutes(router, authHandler, cfg)

	// Start server
	serverAddr := fmt.Sprintf(":%d", cfg.Server.Port)
	log.Printf("Server starting on port %d", cfg.Server.Port)
	
	if err := router.Run(serverAddr); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

func setupRoutes(router *gin.Engine, authHandler *handler.AuthHandler, cfg *config.Config) {
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

		// Admin-only routes
		admin := protected.Group("/admin")
		admin.Use(middleware.RequireAdmin())
		{
			admin.GET("/users", func(c *gin.Context) {
				c.JSON(200, gin.H{"message": "Admin users endpoint - TODO"})
			})
		}

		// Kasir routes (admin + kasir)
		kasir := protected.Group("/kasir")
		kasir.Use(middleware.RequireAdminOrKasir())
		{
			kasir.GET("/dashboard", func(c *gin.Context) {
				c.JSON(200, gin.H{"message": "Kasir dashboard - TODO"})
			})
		}

		// Mekanik routes
		mekanik := protected.Group("/mekanik")
		mekanik.Use(middleware.RequireMekanik())
		{
			mekanik.GET("/work-orders", func(c *gin.Context) {
				c.JSON(200, gin.H{"message": "Mekanik work orders - TODO"})
			})
		}

		// Common protected routes
		protected.GET("/customers", func(c *gin.Context) {
			c.JSON(200, gin.H{"message": "Customers endpoint - TODO"})
		})
		
		protected.GET("/vehicles", func(c *gin.Context) {
			c.JSON(200, gin.H{"message": "Vehicles endpoint - TODO"})
		})
		
		protected.GET("/spare-parts", func(c *gin.Context) {
			c.JSON(200, gin.H{"message": "Spare parts endpoint - TODO"})
		})
	}
}