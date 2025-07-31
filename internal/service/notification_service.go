package service

import (
	"context"
	"fmt"
	"pos-final/internal/domain"
	"pos-final/internal/repository"
	"time"
)

type notificationService struct {
	notificationRepo repository.NotificationRepository
	userRepo         repository.UserRepository
}

func NewNotificationService(notificationRepo repository.NotificationRepository, userRepo repository.UserRepository) NotificationService {
	return &notificationService{
		notificationRepo: notificationRepo,
		userRepo:         userRepo,
	}
}

func (s *notificationService) CreateNotification(ctx context.Context, notification *domain.Notification) error {
	// Validate the notification
	if notification.UserID == 0 {
		return fmt.Errorf("user ID is required")
	}
	
	if notification.Title == "" {
		return fmt.Errorf("notification title is required")
	}
	
	if notification.Message == "" {
		return fmt.Errorf("notification message is required")
	}
	
	// Verify user exists
	_, err := s.userRepo.GetByID(ctx, notification.UserID)
	if err != nil {
		return fmt.Errorf("user not found: %w", err)
	}
	
	// Set defaults
	notification.IsRead = false
	
	return s.notificationRepo.Create(ctx, notification)
}

func (s *notificationService) GetNotificationByID(ctx context.Context, id int) (*domain.Notification, error) {
	if id <= 0 {
		return nil, fmt.Errorf("invalid notification ID")
	}
	
	return s.notificationRepo.GetByID(ctx, id)
}

func (s *notificationService) ListNotificationsByUser(ctx context.Context, userID int, page, limit int) ([]*domain.Notification, int, error) {
	if userID <= 0 {
		return nil, 0, fmt.Errorf("invalid user ID")
	}
	
	if page < 1 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}
	
	offset := (page - 1) * limit
	
	notifications, err := s.notificationRepo.ListByUserID(ctx, userID, offset, limit)
	if err != nil {
		return nil, 0, err
	}
	
	total, err := s.notificationRepo.CountByUserID(ctx, userID)
	if err != nil {
		return nil, 0, err
	}
	
	return notifications, total, nil
}

func (s *notificationService) ListUnreadNotificationsByUser(ctx context.Context, userID int, page, limit int) ([]*domain.Notification, int, error) {
	if userID <= 0 {
		return nil, 0, fmt.Errorf("invalid user ID")
	}
	
	if page < 1 {
		page = 1
	}
	if limit <= 0 {
		limit = 20
	}
	
	offset := (page - 1) * limit
	
	notifications, err := s.notificationRepo.ListUnreadByUserID(ctx, userID, offset, limit)
	if err != nil {
		return nil, 0, err
	}
	
	total, err := s.notificationRepo.CountUnreadByUserID(ctx, userID)
	if err != nil {
		return nil, 0, err
	}
	
	return notifications, total, nil
}

func (s *notificationService) MarkNotificationAsRead(ctx context.Context, id int) error {
	if id <= 0 {
		return fmt.Errorf("invalid notification ID")
	}
	
	return s.notificationRepo.MarkAsRead(ctx, id)
}

func (s *notificationService) MarkAllNotificationsAsRead(ctx context.Context, userID int) error {
	if userID <= 0 {
		return fmt.Errorf("invalid user ID")
	}
	
	return s.notificationRepo.MarkAllAsReadByUserID(ctx, userID)
}

func (s *notificationService) DeleteNotification(ctx context.Context, id int, deletedBy int) error {
	if id <= 0 {
		return fmt.Errorf("invalid notification ID")
	}
	
	if deletedBy <= 0 {
		return fmt.Errorf("invalid deletedBy user ID")
	}
	
	return s.notificationRepo.SoftDelete(ctx, id, deletedBy)
}

func (s *notificationService) GetUnreadCount(ctx context.Context, userID int) (int, error) {
	if userID <= 0 {
		return 0, fmt.Errorf("invalid user ID")
	}
	
	return s.notificationRepo.CountUnreadByUserID(ctx, userID)
}

// Helper methods for creating specific notification types

func (s *notificationService) NotifyWorkOrderAssigned(ctx context.Context, workOrderID int, mechanicID int) error {
	notification := &domain.Notification{
		UserID:        mechanicID,
		Type:          domain.NotificationTypeWorkOrderAssigned,
		Title:         "New Work Order Assigned",
		Message:       fmt.Sprintf("You have been assigned a new work order #%d", workOrderID),
		ReferenceType: stringPtr("work_order"),
		ReferenceID:   &workOrderID,
	}
	
	return s.CreateNotification(ctx, notification)
}

func (s *notificationService) NotifyLowStock(ctx context.Context, partID int) error {
	// TODO: Get spare part details and notify relevant users
	// For now, this is a placeholder implementation
	return fmt.Errorf("NotifyLowStock implementation pending")
}

func (s *notificationService) NotifyWorkOrderUpdate(ctx context.Context, workOrderID int, message string) error {
	// TODO: Get work order details and notify the assigned mechanic
	// For now, this is a placeholder implementation
	return fmt.Errorf("NotifyWorkOrderUpdate implementation pending")
}

func (s *notificationService) NotifyDailyReport(ctx context.Context, userID int, date time.Time) error {
	notification := &domain.Notification{
		UserID:        userID,
		Type:          domain.NotificationTypeDailyReport,
		Title:         "Daily Report Available",
		Message:       fmt.Sprintf("Daily report for %s is now available", date.Format("2006-01-02")),
		ReferenceType: stringPtr("report"),
	}
	
	return s.CreateNotification(ctx, notification)
}

// Broadcast notifications to multiple users
func (s *notificationService) BroadcastNotification(ctx context.Context, userIDs []int, notificationType domain.NotificationType, title, message string) error {
	if len(userIDs) == 0 {
		return fmt.Errorf("no users specified for broadcast")
	}
	
	for _, userID := range userIDs {
		notification := &domain.Notification{
			UserID:  userID,
			Type:    notificationType,
			Title:   title,
			Message: message,
		}
		
		err := s.CreateNotification(ctx, notification)
		if err != nil {
			// Log error but continue with other users
			fmt.Printf("Failed to create notification for user %d: %v\n", userID, err)
		}
	}
	
	return nil
}

// Send notification to all admins
func (s *notificationService) NotifyAdmins(ctx context.Context, notificationType domain.NotificationType, title, message string) error {
	// Get all admin users
	users, err := s.userRepo.GetByRole(ctx, domain.RoleAdmin)
	if err != nil {
		return fmt.Errorf("failed to get admin users: %w", err)
	}
	
	var adminIDs []int
	for _, user := range users {
		adminIDs = append(adminIDs, user.ID)
	}
	
	return s.BroadcastNotification(ctx, adminIDs, notificationType, title, message)
}

// Send notification to all kasir
func (s *notificationService) NotifyKasir(ctx context.Context, notificationType domain.NotificationType, title, message string) error {
	// Get all kasir users
	users, err := s.userRepo.GetByRole(ctx, domain.RoleKasir)
	if err != nil {
		return fmt.Errorf("failed to get kasir users: %w", err)
	}
	
	var kasirIDs []int
	for _, user := range users {
		kasirIDs = append(kasirIDs, user.ID)
	}
	
	return s.BroadcastNotification(ctx, kasirIDs, notificationType, title, message)
}

// Cleanup old notifications (to be called periodically)
func (s *notificationService) CleanupOldNotifications(ctx context.Context, olderThanDays int) error {
	// TODO: Implement cleanup functionality
	return fmt.Errorf("cleanup functionality not implemented yet")
}

// Helper function to create string pointer
func stringPtr(s string) *string {
	return &s
}