import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  
  NotificationProvider(this._apiService);
  
  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnread => _unreadCount > 0;
  
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _notifications.clear();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get<List<dynamic>>('/notifications');
      
      if (response.isSuccess && response.rawData != null) {
        final data = response.rawData!['data'] as List<dynamic>;
        _notifications = data
            .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
            .toList();
        
        await loadUnreadCount();
      } else {
        _setError(response.error ?? 'Failed to load notifications');
      }
    } catch (e) {
      _setError('Error loading notifications: $e');
    }
    
    _setLoading(false);
  }
  
  Future<void> loadUnreadCount() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/notifications/unread/count'
      );
      
      if (response.isSuccess && response.rawData != null) {
        _unreadCount = response.rawData!['data']['count'] as int? ?? 0;
        notifyListeners();
      }
    } catch (e) {
      // Silent failure for unread count
      debugPrint('Error loading unread count: $e');
    }
  }
  
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.put('/notifications/$notificationId/read');
      
      if (response.isSuccess) {
        // Update notification in list
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final notification = _notifications[index];
          if (!notification.isRead) {
            _notifications[index] = NotificationModel(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              type: notification.type,
              isRead: true,
              createdAt: notification.createdAt,
            );
            _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
            notifyListeners();
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.put('/notifications/read-all');
      
      if (response.isSuccess) {
        // Update all notifications to read
        _notifications = _notifications.map((n) => NotificationModel(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        )).toList();
        _unreadCount = 0;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _apiService.delete('/notifications/$notificationId');
      
      if (response.isSuccess) {
        final removedNotification = _notifications.firstWhere(
          (n) => n.id == notificationId,
          orElse: () => NotificationModel(
            id: 0, title: '', message: '', type: '', isRead: true, createdAt: DateTime.now()
          ),
        );
        
        _notifications.removeWhere((n) => n.id == notificationId);
        
        if (!removedNotification.isRead && removedNotification.id != 0) {
          _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }
  
  void _clearError() {
    _setError(null);
  }
  
  void clearError() {
    _clearError();
  }
}