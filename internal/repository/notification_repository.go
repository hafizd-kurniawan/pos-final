package repository

import (
	"context"
	"database/sql"
	"fmt"
	"pos-final/internal/domain"
	"time"

	"github.com/jmoiron/sqlx"
)

type notificationRepository struct {
	db *sqlx.DB
}

func NewNotificationRepository(db *sqlx.DB) NotificationRepository {
	return &notificationRepository{db: db}
}

func (r *notificationRepository) Create(ctx context.Context, notification *domain.Notification) error {
	query := `
		INSERT INTO notifications (user_id, type, title, message, reference_type, reference_id)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at
	`
	
	err := r.db.QueryRowContext(
		ctx, query,
		notification.UserID,
		notification.Type,
		notification.Title,
		notification.Message,
		notification.ReferenceType,
		notification.ReferenceID,
	).Scan(&notification.ID, &notification.CreatedAt)
	
	if err != nil {
		return fmt.Errorf("failed to create notification: %w", err)
	}
	
	return nil
}

func (r *notificationRepository) GetByID(ctx context.Context, id int) (*domain.Notification, error) {
	query := `
		SELECT n.id, n.user_id, n.type, n.title, n.message, n.is_read, 
		       n.reference_type, n.reference_id, n.created_at,
		       u.id, u.username, u.email, u.role
		FROM notifications n
		JOIN users u ON n.user_id = u.id
		WHERE n.id = $1 AND n.deleted_at IS NULL
	`
	
	var notification domain.Notification
	var user domain.User
	
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&notification.ID,
		&notification.UserID,
		&notification.Type,
		&notification.Title,
		&notification.Message,
		&notification.IsRead,
		&notification.ReferenceType,
		&notification.ReferenceID,
		&notification.CreatedAt,
		&user.ID,
		&user.Username,
		&user.Email,
		&user.Role,
	)
	
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("notification not found")
		}
		return nil, fmt.Errorf("failed to get notification: %w", err)
	}
	
	notification.User = &user
	return &notification, nil
}

func (r *notificationRepository) ListByUserID(ctx context.Context, userID int, offset, limit int) ([]*domain.Notification, error) {
	query := `
		SELECT n.id, n.user_id, n.type, n.title, n.message, n.is_read, 
		       n.reference_type, n.reference_id, n.created_at
		FROM notifications n
		WHERE n.user_id = $1 AND n.deleted_at IS NULL
		ORDER BY n.created_at DESC
		LIMIT $2 OFFSET $3
	`
	
	rows, err := r.db.QueryContext(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list notifications: %w", err)
	}
	defer rows.Close()
	
	var notifications []*domain.Notification
	for rows.Next() {
		var notification domain.Notification
		err := rows.Scan(
			&notification.ID,
			&notification.UserID,
			&notification.Type,
			&notification.Title,
			&notification.Message,
			&notification.IsRead,
			&notification.ReferenceType,
			&notification.ReferenceID,
			&notification.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan notification: %w", err)
		}
		notifications = append(notifications, &notification)
	}
	
	return notifications, nil
}

func (r *notificationRepository) ListUnreadByUserID(ctx context.Context, userID int, offset, limit int) ([]*domain.Notification, error) {
	query := `
		SELECT n.id, n.user_id, n.type, n.title, n.message, n.is_read, 
		       n.reference_type, n.reference_id, n.created_at
		FROM notifications n
		WHERE n.user_id = $1 AND n.is_read = false AND n.deleted_at IS NULL
		ORDER BY n.created_at DESC
		LIMIT $2 OFFSET $3
	`
	
	rows, err := r.db.QueryContext(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list unread notifications: %w", err)
	}
	defer rows.Close()
	
	var notifications []*domain.Notification
	for rows.Next() {
		var notification domain.Notification
		err := rows.Scan(
			&notification.ID,
			&notification.UserID,
			&notification.Type,
			&notification.Title,
			&notification.Message,
			&notification.IsRead,
			&notification.ReferenceType,
			&notification.ReferenceID,
			&notification.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan notification: %w", err)
		}
		notifications = append(notifications, &notification)
	}
	
	return notifications, nil
}

func (r *notificationRepository) CountByUserID(ctx context.Context, userID int) (int, error) {
	query := `
		SELECT COUNT(*) FROM notifications 
		WHERE user_id = $1 AND deleted_at IS NULL
	`
	
	var count int
	err := r.db.QueryRowContext(ctx, query, userID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count notifications: %w", err)
	}
	
	return count, nil
}

func (r *notificationRepository) CountUnreadByUserID(ctx context.Context, userID int) (int, error) {
	query := `
		SELECT COUNT(*) FROM notifications 
		WHERE user_id = $1 AND is_read = false AND deleted_at IS NULL
	`
	
	var count int
	err := r.db.QueryRowContext(ctx, query, userID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count unread notifications: %w", err)
	}
	
	return count, nil
}

func (r *notificationRepository) MarkAsRead(ctx context.Context, id int) error {
	query := `
		UPDATE notifications 
		SET is_read = true 
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to mark notification as read: %w", err)
	}
	
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	
	if rowsAffected == 0 {
		return fmt.Errorf("notification not found")
	}
	
	return nil
}

func (r *notificationRepository) MarkAllAsReadByUserID(ctx context.Context, userID int) error {
	query := `
		UPDATE notifications 
		SET is_read = true 
		WHERE user_id = $1 AND is_read = false AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query, userID)
	if err != nil {
		return fmt.Errorf("failed to mark all notifications as read: %w", err)
	}
	
	return nil
}

func (r *notificationRepository) Delete(ctx context.Context, id, deletedBy int) error {
	query := `
		UPDATE notifications 
		SET deleted_at = NOW(), deleted_by = $2 
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	result, err := r.db.ExecContext(ctx, query, id, deletedBy)
	if err != nil {
		return fmt.Errorf("failed to delete notification: %w", err)
	}
	
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	
	if rowsAffected == 0 {
		return fmt.Errorf("notification not found")
	}
	
	return nil
}

func (r *notificationRepository) DeleteAllByUserID(ctx context.Context, userID, deletedBy int) error {
	query := `
		UPDATE notifications 
		SET deleted_at = NOW(), deleted_by = $2 
		WHERE user_id = $1 AND deleted_at IS NULL
	`
	
	_, err := r.db.ExecContext(ctx, query, userID, deletedBy)
	if err != nil {
		return fmt.Errorf("failed to delete all notifications: %w", err)
	}
	
	return nil
}

func (r *notificationRepository) GetNotificationsByType(ctx context.Context, notificationType domain.NotificationType, offset, limit int) ([]*domain.Notification, error) {
	query := `
		SELECT n.id, n.user_id, n.type, n.title, n.message, n.is_read, 
		       n.reference_type, n.reference_id, n.created_at,
		       u.id, u.username, u.email, u.role
		FROM notifications n
		JOIN users u ON n.user_id = u.id
		WHERE n.type = $1 AND n.deleted_at IS NULL
		ORDER BY n.created_at DESC
		LIMIT $2 OFFSET $3
	`
	
	rows, err := r.db.QueryContext(ctx, query, notificationType, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list notifications by type: %w", err)
	}
	defer rows.Close()
	
	var notifications []*domain.Notification
	for rows.Next() {
		var notification domain.Notification
		var user domain.User
		
		err := rows.Scan(
			&notification.ID,
			&notification.UserID,
			&notification.Type,
			&notification.Title,
			&notification.Message,
			&notification.IsRead,
			&notification.ReferenceType,
			&notification.ReferenceID,
			&notification.CreatedAt,
			&user.ID,
			&user.Username,
			&user.Email,
			&user.Role,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan notification: %w", err)
		}
		
		notification.User = &user
		notifications = append(notifications, &notification)
	}
	
	return notifications, nil
}

func (r *notificationRepository) Count(ctx context.Context) (int, error) {
	query := `SELECT COUNT(*) FROM notifications WHERE deleted_at IS NULL`
	
	var count int
	err := r.db.QueryRowContext(ctx, query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count notifications: %w", err)
	}
	
	return count, nil
}

func (r *notificationRepository) Update(ctx context.Context, notification *domain.Notification) error {
	query := `
		UPDATE notifications 
		SET title = $2, message = $3, is_read = $4, reference_type = $5, reference_id = $6
		WHERE id = $1 AND deleted_at IS NULL
	`
	
	result, err := r.db.ExecContext(
		ctx, query,
		notification.ID,
		notification.Title,
		notification.Message,
		notification.IsRead,
		notification.ReferenceType,
		notification.ReferenceID,
	)
	if err != nil {
		return fmt.Errorf("failed to update notification: %w", err)
	}
	
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	
	if rowsAffected == 0 {
		return fmt.Errorf("notification not found")
	}
	
	return nil
}

func (r *notificationRepository) SoftDelete(ctx context.Context, id int, deletedBy int) error {
	return r.Delete(ctx, id, deletedBy)
}

func (r *notificationRepository) CleanupOldNotifications(ctx context.Context, olderThan time.Time) error {
	query := `
		DELETE FROM notifications 
		WHERE created_at < $1 AND (is_read = true OR deleted_at IS NOT NULL)
	`
	
	result, err := r.db.ExecContext(ctx, query, olderThan)
	if err != nil {
		return fmt.Errorf("failed to cleanup old notifications: %w", err)
	}
	
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	
	// Log cleanup info (in a real app, use proper logging)
	fmt.Printf("Cleaned up %d old notifications\n", rowsAffected)
	
	return nil
}