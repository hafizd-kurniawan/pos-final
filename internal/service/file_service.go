package service

import (
	"context"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/google/uuid"
)

type fileService struct {
	uploadDir string
}

// NewFileService creates a new file service
func NewFileService(uploadDir string) FileService {
	return &fileService{
		uploadDir: uploadDir,
	}
}

func (s *fileService) SaveFile(ctx context.Context, file *multipart.FileHeader, folder string) (string, error) {
	if file == nil {
		return "", fmt.Errorf("file is required")
	}

	// Validate file size (max 10MB)
	if file.Size > 10*1024*1024 {
		return "", fmt.Errorf("file size too large (max 10MB)")
	}

	// Create upload directory if it doesn't exist
	uploadPath := filepath.Join(s.uploadDir, folder)
	if err := os.MkdirAll(uploadPath, 0755); err != nil {
		return "", fmt.Errorf("failed to create upload directory: %w", err)
	}

	// Generate unique filename
	ext := filepath.Ext(file.Filename)
	filename := fmt.Sprintf("%s_%d%s", uuid.New().String(), time.Now().Unix(), ext)
	filePath := filepath.Join(uploadPath, filename)

	// Open uploaded file
	src, err := file.Open()
	if err != nil {
		return "", fmt.Errorf("failed to open uploaded file: %w", err)
	}
	defer src.Close()

	// Create destination file
	dst, err := os.Create(filePath)
	if err != nil {
		return "", fmt.Errorf("failed to create destination file: %w", err)
	}
	defer dst.Close()

	// Copy file content
	if _, err := io.Copy(dst, src); err != nil {
		return "", fmt.Errorf("failed to save file: %w", err)
	}

	// Return relative path from upload directory
	relativePath := filepath.Join(folder, filename)
	return relativePath, nil
}

func (s *fileService) DeleteFile(ctx context.Context, filePath string) error {
	if filePath == "" {
		return fmt.Errorf("file path is required")
	}

	fullPath := filepath.Join(s.uploadDir, filePath)
	
	// Check if file exists
	if _, err := os.Stat(fullPath); os.IsNotExist(err) {
		return fmt.Errorf("file does not exist")
	}

	// Delete file
	if err := os.Remove(fullPath); err != nil {
		return fmt.Errorf("failed to delete file: %w", err)
	}

	return nil
}

func (s *fileService) ValidateImage(file *multipart.FileHeader) error {
	if file == nil {
		return fmt.Errorf("file is required")
	}

	// Check file size (max 5MB for images)
	if file.Size > 5*1024*1024 {
		return fmt.Errorf("image file size too large (max 5MB)")
	}

	// Check file extension
	ext := strings.ToLower(filepath.Ext(file.Filename))
	allowedExts := []string{".jpg", ".jpeg", ".png", ".gif", ".webp"}
	
	valid := false
	for _, allowedExt := range allowedExts {
		if ext == allowedExt {
			valid = true
			break
		}
	}
	
	if !valid {
		return fmt.Errorf("invalid image format. Allowed: %s", strings.Join(allowedExts, ", "))
	}

	// Validate MIME type
	src, err := file.Open()
	if err != nil {
		return fmt.Errorf("failed to open file for validation: %w", err)
	}
	defer src.Close()

	buffer := make([]byte, 512)
	_, err = src.Read(buffer)
	if err != nil {
		return fmt.Errorf("failed to read file for validation: %w", err)
	}

	contentType := http.DetectContentType(buffer)
	allowedTypes := []string{
		"image/jpeg", "image/jpg", "image/png", 
		"image/gif", "image/webp",
	}
	
	valid = false
	for _, allowedType := range allowedTypes {
		if contentType == allowedType {
			valid = true
			break
		}
	}
	
	if !valid {
		return fmt.Errorf("invalid image content type: %s", contentType)
	}

	return nil
}

func (s *fileService) ValidateDocument(file *multipart.FileHeader) error {
	if file == nil {
		return fmt.Errorf("file is required")
	}

	// Check file size (max 10MB for documents)
	if file.Size > 10*1024*1024 {
		return fmt.Errorf("document file size too large (max 10MB)")
	}

	// Check file extension
	ext := strings.ToLower(filepath.Ext(file.Filename))
	allowedExts := []string{".pdf", ".doc", ".docx", ".jpg", ".jpeg", ".png"}
	
	valid := false
	for _, allowedExt := range allowedExts {
		if ext == allowedExt {
			valid = true
			break
		}
	}
	
	if !valid {
		return fmt.Errorf("invalid document format. Allowed: %s", strings.Join(allowedExts, ", "))
	}

	return nil
}

func (s *fileService) GetFileURL(filePath string) string {
	if filePath == "" {
		return ""
	}
	// Return URL path for serving static files
	return "/static/uploads/" + filePath
}