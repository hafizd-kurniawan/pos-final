package middleware

import (
	"fmt"
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
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Credentials", "true")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Header("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE, PATCH")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}

// Logger middleware for request logging
func Logger() gin.HandlerFunc {
	return gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		return fmt.Sprintf("%s - [%s] \"%s %s %s %d %s \"%s\" %s\"\n",
			param.ClientIP,
			param.TimeStamp.Format(time.RFC1123),
			param.Method,
			param.Path,
			param.Request.Proto,
			param.StatusCode,
			param.Latency,
			param.Request.UserAgent(),
			param.ErrorMessage,
		)
	})
}

// Recovery middleware for panic recovery
func Recovery() gin.HandlerFunc {
	return gin.RecoveryWithWriter(gin.DefaultWriter, func(c *gin.Context, err interface{}) {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Internal server error",
		})
	})
}