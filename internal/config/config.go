package config

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	Database DatabaseConfig
	Server   ServerConfig
	JWT      JWTConfig
	Upload   UploadConfig
	Invoice  InvoiceConfig
	Log      LogConfig
}

type DatabaseConfig struct {
	Host     string
	Port     int
	User     string
	Password string
	Name     string
	SSLMode  string
}

type ServerConfig struct {
	Port    int
	GinMode string
}

type JWTConfig struct {
	Secret      string
	ExpiryHours int
}

type UploadConfig struct {
	MaxSize int64
	Path    string
}

type InvoiceConfig struct {
	TemplatePath string
}

type LogConfig struct {
	Level string
	File  string
}

func LoadConfig() *Config {
	// Load .env file if it exists
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	config := &Config{
		Database: DatabaseConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnvInt("DB_PORT", 5432),
			User:     getEnv("DB_USER", "pos_user"),
			Password: getEnv("DB_PASSWORD", "pos_password"),
			Name:     getEnv("DB_NAME", "pos_db"),
			SSLMode:  getEnv("DB_SSL_MODE", "disable"),
		},
		Server: ServerConfig{
			Port:    getEnvInt("SERVER_PORT", 8080),
			GinMode: getEnv("GIN_MODE", "debug"),
		},
		JWT: JWTConfig{
			Secret:      getEnv("JWT_SECRET", "your-super-secret-jwt-key"),
			ExpiryHours: getEnvInt("JWT_EXPIRY_HOURS", 24),
		},
		Upload: UploadConfig{
			MaxSize: int64(getEnvInt("MAX_UPLOAD_SIZE", 10485760)), // 10MB
			Path:    getEnv("UPLOAD_PATH", "./static/uploads"),
		},
		Invoice: InvoiceConfig{
			TemplatePath: getEnv("INVOICE_TEMPLATE_PATH", "./templates"),
		},
		Log: LogConfig{
			Level: getEnv("LOG_LEVEL", "debug"),
			File:  getEnv("LOG_FILE", "./logs/app.log"),
		},
	}

	return config
}

func (c *Config) GetDatabaseDSN() string {
	return fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
		c.Database.Host,
		c.Database.Port,
		c.Database.User,
		c.Database.Password,
		c.Database.Name,
		c.Database.SSLMode,
	)
}

func (c *Config) GetJWTDuration() time.Duration {
	return time.Duration(c.JWT.ExpiryHours) * time.Hour
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}