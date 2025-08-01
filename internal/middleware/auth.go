package middleware

import (
	"fmt"
	"log"
	"net/http"
	"pos-final/internal/domain"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

// JWTClaims represents the JWT claims
type JWTClaims struct {
	UserID   int              `json:"user_id"`
	Username string           `json:"username"`
	Role     domain.UserRole  `json:"role"`
	jwt.RegisteredClaims
}

// JWTMiddleware creates a JWT authentication middleware
func JWTMiddleware(secretKey string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get the authorization header
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Authorization header required",
			})
			c.Abort()
			return
		}

		// Check if it starts with "Bearer "
		if !strings.HasPrefix(authHeader, "Bearer ") {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Invalid authorization header format",
			})
			c.Abort()
			return
		}

		// Extract the token
		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		
		// Parse and validate the token
		token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
			return []byte(secretKey), nil
		})

		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Invalid token",
			})
			c.Abort()
			return
		}

		// Check if token is valid
		if claims, ok := token.Claims.(*JWTClaims); ok && token.Valid {
			// Set user information in context
			c.Set("user_id", claims.UserID)
			c.Set("username", claims.Username)
			c.Set("role", claims.Role)
			c.Next()
		} else {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Invalid token claims",
			})
			c.Abort()
			return
		}
	}
}

// RequireRole creates a middleware that requires specific roles
func RequireRole(allowedRoles ...domain.UserRole) gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole, exists := c.Get("role")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "User role not found in context",
			})
			c.Abort()
			return
		}

		role, ok := userRole.(domain.UserRole)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Invalid user role",
			})
			c.Abort()
			return
		}

		// Check if the user's role is in the allowed roles
		for _, allowedRole := range allowedRoles {
			if role == allowedRole {
				c.Next()
				return
			}
		}

		c.JSON(http.StatusForbidden, gin.H{
			"error": "Insufficient permissions",
		})
		c.Abort()
	}
}

// RequireAdmin creates a middleware that requires admin role
func RequireAdmin() gin.HandlerFunc {
	return RequireRole(domain.RoleAdmin)
}

// RequireKasir creates a middleware that requires kasir role
func RequireKasir() gin.HandlerFunc {
	return RequireRole(domain.RoleKasir)
}

// RequireMekanik creates a middleware that requires mekanik role
func RequireMekanik() gin.HandlerFunc {
	return RequireRole(domain.RoleMekanik)
}

// RequireAdminOrKasir creates a middleware that requires admin or kasir role
func RequireAdminOrKasir() gin.HandlerFunc {
	return RequireRole(domain.RoleAdmin, domain.RoleKasir)
}

// GenerateJWT generates a JWT token for a user
func GenerateJWT(user *domain.User, secretKey string, expiryDuration time.Duration) (string, error) {
	claims := &JWTClaims{
		UserID:   user.ID,
		Username: user.Username,
		Role:     user.Role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(expiryDuration)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Issuer:    "pos-system",
			Subject:   user.Username,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secretKey))
}

// ParseJWT parses and validates a JWT token
func ParseJWT(tokenString, secretKey string) (*JWTClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(secretKey), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*JWTClaims); ok && token.Valid {
		return claims, nil
	}

	return nil, jwt.ErrTokenInvalidClaims
}

// CORS middleware for handling Cross-Origin Resource Sharing
func CORS() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Ultra-detailed CORS debugging
		log.Printf("🌍 ===== CORS MIDDLEWARE ULTRA-DEBUG =====")
		log.Printf("🔗 Request URL: %s %s", c.Request.Method, c.Request.URL.String())
		log.Printf("🌐 Client IP: %s", c.ClientIP())
		log.Printf("🔍 Origin Header: %s", c.GetHeader("Origin"))
		log.Printf("🔍 Referer Header: %s", c.GetHeader("Referer"))
		log.Printf("🔍 User-Agent: %s", c.Request.UserAgent())
		log.Printf("🔍 Host Header: %s", c.GetHeader("Host"))
		
		// Log all request headers for CORS analysis
		log.Printf("📋 ALL REQUEST HEADERS:")
		for name, values := range c.Request.Header {
			for _, value := range values {
				if name == "Authorization" && len(value) > 20 {
					log.Printf("  %s: %s...", name, value[:20])
				} else {
					log.Printf("  %s: %s", name, value)
				}
			}
		}
		
		// Set CORS headers with detailed logging
		log.Printf("🛡️  SETTING CORS HEADERS:")
		
		c.Header("Access-Control-Allow-Origin", "*")
		log.Printf("  ✅ Access-Control-Allow-Origin: *")
		
		c.Header("Access-Control-Allow-Credentials", "true")
		log.Printf("  ✅ Access-Control-Allow-Credentials: true")
		
		allowedHeaders := "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With"
		c.Header("Access-Control-Allow-Headers", allowedHeaders)
		log.Printf("  ✅ Access-Control-Allow-Headers: %s", allowedHeaders)
		
		allowedMethods := "POST, OPTIONS, GET, PUT, DELETE, PATCH"
		c.Header("Access-Control-Allow-Methods", allowedMethods)
		log.Printf("  ✅ Access-Control-Allow-Methods: %s", allowedMethods)
		
		// Enhanced OPTIONS handling
		if c.Request.Method == "OPTIONS" {
			log.Printf("🔍 OPTIONS REQUEST DETECTED - CORS Preflight")
			log.Printf("  📋 Access-Control-Request-Method: %s", c.GetHeader("Access-Control-Request-Method"))
			log.Printf("  📋 Access-Control-Request-Headers: %s", c.GetHeader("Access-Control-Request-Headers"))
			log.Printf("  ✅ Responding with 204 No Content")
			log.Printf("🌍 ===== END CORS PREFLIGHT HANDLING =====")
			c.AbortWithStatus(204)
			return
		}
		
		log.Printf("  ⏭️  Proceeding to next middleware/handler")
		log.Printf("🌍 ===== END CORS MIDDLEWARE =====")
		c.Next()
	}
}

// Logger middleware for request logging
func Logger() gin.HandlerFunc {
	return gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		// Ultra-detailed request/response logging
		logBuilder := fmt.Sprintf("🚀 ===== REQUEST COMPLETED =====\n")
		logBuilder += fmt.Sprintf("⏰ Timestamp: %s\n", param.TimeStamp.Format("2006/01/02 - 15:04:05"))
		logBuilder += fmt.Sprintf("🌐 Client IP: %s\n", param.ClientIP)
		logBuilder += fmt.Sprintf("📡 Method: %s\n", param.Method)
		logBuilder += fmt.Sprintf("🔗 Path: %s\n", param.Path)
		logBuilder += fmt.Sprintf("📋 Protocol: %s\n", param.Request.Proto)
		logBuilder += fmt.Sprintf("📊 Status Code: %d\n", param.StatusCode)
		logBuilder += fmt.Sprintf("⚡ Latency: %s\n", param.Latency)
		logBuilder += fmt.Sprintf("🤖 User Agent: %s\n", param.Request.UserAgent())
		
		if param.ErrorMessage != "" {
			logBuilder += fmt.Sprintf("❌ Error: %s\n", param.ErrorMessage)
		}
		
		// Request body information
		bodyInfo := getRequestBody(param.Request)
		logBuilder += fmt.Sprintf("📦 Request Body: %s\n", bodyInfo)
		
		logBuilder += fmt.Sprintf("🚀 ===== END REQUEST LOG =====\n")
		
		return logBuilder
	})
}

// Enhanced Logger that logs both request start and completion
func UltraLogger() gin.HandlerFunc {
	return func(c *gin.Context) {
		startTime := time.Now()
		
		// Log request start with ultra detail
		log.Printf("🔥 ===== INCOMING REQUEST ULTRA-DEBUG =====")
		log.Printf("⏰ Request Start Time: %s", startTime.Format("2006/01/02 - 15:04:05.000"))
		log.Printf("🌐 Client IP: %s", c.ClientIP())
		log.Printf("📡 HTTP Method: %s", c.Request.Method)
		log.Printf("🔗 Request URL: %s", c.Request.URL.String())
		log.Printf("📂 Request Path: %s", c.Request.URL.Path)
		log.Printf("🔍 Query String: %s", c.Request.URL.RawQuery)
		log.Printf("📋 Protocol: %s", c.Request.Proto)
		log.Printf("🏠 Host: %s", c.Request.Host)
		log.Printf("🔍 Remote Address: %s", c.Request.RemoteAddr)
		log.Printf("🤖 User Agent: %s", c.Request.UserAgent())
		
		// Log all headers (safely)
		log.Printf("📋 REQUEST HEADERS:")
		for name, values := range c.Request.Header {
			for _, value := range values {
				if strings.ToLower(name) == "authorization" && len(value) > 20 {
					log.Printf("  %s: %s...[TRUNCATED]", name, value[:20])
				} else {
					log.Printf("  %s: %s", name, value)
				}
			}
		}
		
		// Content analysis
		contentType := c.GetHeader("Content-Type")
		contentLength := c.GetHeader("Content-Length")
		log.Printf("📦 Content-Type: %s", contentType)
		log.Printf("📏 Content-Length: %s", contentLength)
		
		// Request size analysis
		if c.Request.ContentLength > 0 {
			log.Printf("📊 Request Body Size: %d bytes", c.Request.ContentLength)
		}
		
		log.Printf("⏭️  Processing request...")
		
		// Process the request
		c.Next()
		
		// Log response details
		endTime := time.Now()
		latency := endTime.Sub(startTime)
		
		log.Printf("📤 ===== RESPONSE DETAILS =====")
		log.Printf("⏰ Response Time: %s", endTime.Format("2006/01/02 - 15:04:05.000"))
		log.Printf("⚡ Processing Latency: %v", latency)
		log.Printf("📊 HTTP Status: %d", c.Writer.Status())
		log.Printf("📏 Response Size: %d bytes", c.Writer.Size())
		
		// Log response headers
		log.Printf("📋 RESPONSE HEADERS:")
		for name, values := range c.Writer.Header() {
			for _, value := range values {
				log.Printf("  %s: %s", name, value)
			}
		}
		
		// Performance analysis
		if latency > 1*time.Second {
			log.Printf("🐌 SLOW REQUEST WARNING: %v latency", latency)
		} else if latency > 500*time.Millisecond {
			log.Printf("⚠️  MODERATE LATENCY: %v", latency)
		} else {
			log.Printf("⚡ FAST REQUEST: %v", latency)
		}
		
		log.Printf("🔥 ===== END REQUEST PROCESSING =====")
	}
}

// Helper function to safely extract request body information
func getRequestBody(req *http.Request) string {
	if req.Body == nil {
		return "empty"
	}
	
	contentType := req.Header.Get("Content-Type")
	contentLength := req.Header.Get("Content-Length")
	
	if contentLength == "" || contentLength == "0" {
		return "empty"
	}
	
	return fmt.Sprintf("type=%s, length=%s", contentType, contentLength)
}

// Recovery middleware for panic recovery
func Recovery() gin.HandlerFunc {
	return gin.RecoveryWithWriter(gin.DefaultWriter, func(c *gin.Context, err interface{}) {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Internal server error",
		})
	})
}