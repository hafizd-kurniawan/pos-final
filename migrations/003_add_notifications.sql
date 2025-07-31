-- Add notifications table for system notifications

CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    deleted_at TIMESTAMP,
    deleted_by INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT fk_notifications_user_id 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
        
    CONSTRAINT fk_notifications_deleted_by 
        FOREIGN KEY (deleted_by) 
        REFERENCES users(id) 
        ON DELETE SET NULL
);

-- Create indexes for better performance
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read) WHERE deleted_at IS NULL;

-- Add check constraint for notification types
ALTER TABLE notifications 
ADD CONSTRAINT chk_notification_type 
CHECK (type IN ('work_order_assigned', 'low_stock', 'work_order_update', 'daily_report'));

COMMENT ON TABLE notifications IS 'System notifications for users';
COMMENT ON COLUMN notifications.type IS 'Type of notification: work_order_assigned, low_stock, work_order_update, daily_report';
COMMENT ON COLUMN notifications.reference_type IS 'Optional reference type (work_order, spare_part, report, etc.)';
COMMENT ON COLUMN notifications.reference_id IS 'Optional reference ID for the related entity';