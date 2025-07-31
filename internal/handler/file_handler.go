package handler

import (
	"net/http"
	"pos-final/internal/service"
	"strconv"

	"github.com/gin-gonic/gin"
)

type FileHandler struct {
	fileService    service.FileService
	vehicleService service.VehicleService
	salesService   service.SalesService
	purchaseService service.PurchaseService
}

// NewFileHandler creates a new file handler
func NewFileHandler(
	fileService service.FileService,
	vehicleService service.VehicleService,
	salesService service.SalesService,
	purchaseService service.PurchaseService,
) *FileHandler {
	return &FileHandler{
		fileService:     fileService,
		vehicleService:  vehicleService,
		salesService:    salesService,
		purchaseService: purchaseService,
	}
}

type UploadResponse struct {
	FilePath string `json:"file_path"`
	FileURL  string `json:"file_url"`
	Message  string `json:"message"`
}

// UploadVehiclePhoto uploads a photo for a vehicle
func (h *FileHandler) UploadVehiclePhoto(c *gin.Context) {
	// Get vehicle ID from URL
	vehicleIDStr := c.Param("id")
	vehicleID, err := strconv.Atoi(vehicleIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid vehicle ID",
			"message": "Vehicle ID must be a number",
		})
		return
	}

	// Check if vehicle exists
	vehicle, err := h.vehicleService.GetVehicleByID(c.Request.Context(), vehicleID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Vehicle not found",
			"message": err.Error(),
		})
		return
	}

	// Get uploaded file
	file, err := c.FormFile("photo")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "No file uploaded",
			"message": "Please select a photo file",
		})
		return
	}

	// Validate image file
	if err := h.fileService.ValidateImage(file); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid image file",
			"message": err.Error(),
		})
		return
	}

	// Save file
	filePath, err := h.fileService.SaveFile(c.Request.Context(), file, "vehicles")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to upload photo",
			"message": err.Error(),
		})
		return
	}

	// Update vehicle primary photo if not set
	if vehicle.PrimaryPhoto == nil {
		vehicle.PrimaryPhoto = &filePath
		if err := h.vehicleService.UpdateVehicle(c.Request.Context(), vehicle); err != nil {
			// Photo uploaded but failed to update vehicle, continue anyway
			c.JSON(http.StatusCreated, gin.H{
				"message":  "Photo uploaded successfully, but failed to set as primary",
				"file_path": filePath,
				"file_url":  h.fileService.GetFileURL(filePath),
				"warning":  "Please set as primary photo manually",
			})
			return
		}
	}

	fileURL := h.fileService.GetFileURL(filePath)

	response := UploadResponse{
		FilePath: filePath,
		FileURL:  fileURL,
		Message:  "Vehicle photo uploaded successfully",
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": response.Message,
		"data":    response,
	})
}

// UploadSalesTransferProof uploads transfer proof for sales invoice
func (h *FileHandler) UploadSalesTransferProof(c *gin.Context) {
	// Get sales invoice ID from URL
	salesIDStr := c.Param("id")
	salesID, err := strconv.Atoi(salesIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid sales invoice ID",
			"message": "Sales invoice ID must be a number",
		})
		return
	}

	// Check if sales invoice exists
	salesInvoice, err := h.salesService.GetSalesInvoiceByID(c.Request.Context(), salesID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Sales invoice not found",
			"message": err.Error(),
		})
		return
	}

	// Get uploaded file
	file, err := c.FormFile("transfer_proof")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "No file uploaded",
			"message": "Please select a transfer proof file",
		})
		return
	}

	// Validate document file
	if err := h.fileService.ValidateDocument(file); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid document file",
			"message": err.Error(),
		})
		return
	}

	// Save file
	filePath, err := h.fileService.SaveFile(c.Request.Context(), file, "transfer_proofs/sales")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to upload transfer proof",
			"message": err.Error(),
		})
		return
	}

	// Update sales invoice with transfer proof
	salesInvoice.TransferProof = &filePath
	if err := h.salesService.UpdateSalesInvoice(c.Request.Context(), salesInvoice); err != nil {
		// File uploaded but failed to update invoice
		c.JSON(http.StatusCreated, gin.H{
			"message":   "Transfer proof uploaded successfully, but failed to link to invoice",
			"file_path": filePath,
			"file_url":  h.fileService.GetFileURL(filePath),
			"warning":   "Please update the invoice manually",
		})
		return
	}

	fileURL := h.fileService.GetFileURL(filePath)

	response := UploadResponse{
		FilePath: filePath,
		FileURL:  fileURL,
		Message:  "Transfer proof uploaded successfully",
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": response.Message,
		"data":    response,
	})
}

// UploadPurchaseTransferProof uploads transfer proof for purchase invoice
func (h *FileHandler) UploadPurchaseTransferProof(c *gin.Context) {
	// Get purchase invoice ID from URL
	purchaseIDStr := c.Param("id")
	purchaseID, err := strconv.Atoi(purchaseIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid purchase invoice ID",
			"message": "Purchase invoice ID must be a number",
		})
		return
	}

	// Check if purchase invoice exists
	_, err = h.purchaseService.GetPurchaseInvoiceByID(c.Request.Context(), purchaseID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Purchase invoice not found",
			"message": err.Error(),
		})
		return
	}

	// Get uploaded file
	file, err := c.FormFile("transfer_proof")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "No file uploaded",
			"message": "Please select a transfer proof file",
		})
		return
	}

	// Validate document file
	if err := h.fileService.ValidateDocument(file); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid document file",
			"message": err.Error(),
		})
		return
	}

	// Save file
	filePath, err := h.fileService.SaveFile(c.Request.Context(), file, "transfer_proofs/purchases")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to upload transfer proof",
			"message": err.Error(),
		})
		return
	}

	// Update purchase invoice with transfer proof path
	// Note: This would require updating the purchase service to handle transfer proof updates
	// For now, just return success with file info

	fileURL := h.fileService.GetFileURL(filePath)

	response := UploadResponse{
		FilePath: filePath,
		FileURL:  fileURL,
		Message:  "Transfer proof uploaded successfully",
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": response.Message,
		"data":    response,
		"note":    "Transfer proof uploaded. Please update the purchase invoice manually.",
	})
}

// DeleteFile deletes an uploaded file
func (h *FileHandler) DeleteFile(c *gin.Context) {
	var req struct {
		FilePath string `json:"file_path" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request",
			"message": err.Error(),
		})
		return
	}

	if err := h.fileService.DeleteFile(c.Request.Context(), req.FilePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to delete file",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "File deleted successfully",
	})
}