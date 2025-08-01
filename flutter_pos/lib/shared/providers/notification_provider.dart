import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../../core/config/app_config.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnread => _unreadCount > 0;

  // Load notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _notifications.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get(
        AppConfig.notificationsEndpoint,
        queryParams: {
          'page': '1',
          'limit': '50',
        },
      );

      final data = response['data'] as Map<String, dynamic>;
      final notificationList = data['notifications'] as List<dynamic>;

      _notifications = notificationList
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();

      // Update unread count
      _unreadCount = _notifications.where((n) => !n.isRead).length;

      notifyListeners();
    } catch (e) {
      _setError('Failed to load notifications: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load unread count only
  Future<void> loadUnreadCount() async {
    try {
      final response = await _apiService.get(AppConfig.unreadCountEndpoint);
      final data = response['data'] as Map<String, dynamic>;
      
      _unreadCount = (data['count'] as num).toInt();
      notifyListeners();
    } catch (e) {
      // Silently fail for unread count
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.put('${AppConfig.notificationsEndpoint}/$notificationId/read', {});
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to mark notification as read: ${e.toString()}');
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.put('${AppConfig.notificationsEndpoint}/read-all', {});
      
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _unreadCount = 0;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to mark all notifications as read: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Add notification (for real-time updates)
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Get notifications by type
  List<AppNotification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get unread notifications
  List<AppNotification> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Get recent notifications (last 24 hours)
  List<AppNotification> get recentNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _notifications
        .where((n) => n.createdAt.isAfter(yesterday))
        .toList();
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'data': data,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  bool get isWorkOrder => type == 'work_order';
  bool get isLowStock => type == 'low_stock';
  bool get isSales => type == 'sales';
  bool get isPurchase => type == 'purchase';
  bool get isGeneral => type == 'general';
}