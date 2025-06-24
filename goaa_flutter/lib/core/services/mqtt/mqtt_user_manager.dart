import 'dart:async';
import 'package:flutter/foundation.dart';
import 'mqtt_models.dart';
import 'mqtt_connection_manager.dart';

/// MQTT 用戶管理器
class MqttUserManager {
  final MqttConnectionManager _connectionManager;
  
  // 在線用戶列表
  final Map<String, OnlineUser> _onlineUsers = {};
  final StreamController<List<OnlineUser>> _onlineUsersController = StreamController<List<OnlineUser>>.broadcast();

  // 用戶清理定時器
  Timer? _userCleanupTimer;

  MqttUserManager(this._connectionManager) {
    _startUserCleanup();
    _connectionManager.messageStream.listen(_handleMessage);
  }

  // Getters
  Stream<List<OnlineUser>> get onlineUsersStream => _onlineUsersController.stream;
  List<OnlineUser> get onlineUsers => _onlineUsers.values.toList();

  /// 搜索在線用戶
  List<OnlineUser> searchOnlineUsers(String query) {
    final lowerQuery = query.toLowerCase();
    return _onlineUsers.values
        .where((user) =>
            user.userName.toLowerCase().contains(lowerQuery) ||
            user.userCode.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 處理消息
  void _handleMessage(GoaaMqttMessage message) {
    switch (message.type) {
      case GoaaMqttMessageType.userOnline:
        _handleUserOnline(message);
        break;
      case GoaaMqttMessageType.userOffline:
        _handleUserOffline(message);
        break;
      case GoaaMqttMessageType.heartbeat:
        _handleHeartbeat(message);
        break;
      default:
        break;
    }
  }

  /// 處理用戶上線
  void _handleUserOnline(GoaaMqttMessage message) {
    try {
      final user = OnlineUser(
        userId: message.data['userId'],
        userName: message.data['userName'],
        avatar: message.data['avatar'],
        lastSeen: message.timestamp,
      );

      _onlineUsers[user.userId] = user;
      _notifyUsersChanged();
    } catch (e) {
      debugPrint('處理用戶上線失敗: $e');
    }
  }

  /// 處理用戶離線
  void _handleUserOffline(GoaaMqttMessage message) {
    try {
      final userId = message.data['userId'];
      if (userId != null) {
        _onlineUsers.remove(userId);
        _notifyUsersChanged();
      }
    } catch (e) {
      debugPrint('處理用戶離線失敗: $e');
    }
  }

  /// 處理心跳
  void _handleHeartbeat(GoaaMqttMessage message) {
    try {
      final userId = message.data['userId'];
      if (userId != null && _onlineUsers.containsKey(userId)) {
        final existingUser = _onlineUsers[userId]!;
        _onlineUsers[userId] = OnlineUser(
          userId: existingUser.userId,
          userName: existingUser.userName,
          avatar: existingUser.avatar,
          lastSeen: message.timestamp,
        );
        _notifyUsersChanged();
      }
    } catch (e) {
      debugPrint('處理心跳失敗: $e');
    }
  }

  /// 開始用戶清理
  void _startUserCleanup() {
    _userCleanupTimer?.cancel();
    _userCleanupTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _cleanupOfflineUsers();
    });
  }

  /// 清理離線用戶
  void _cleanupOfflineUsers() {
    final now = DateTime.now();
    final toRemove = <String>[];

    for (final entry in _onlineUsers.entries) {
      final timeSinceLastSeen = now.difference(entry.value.lastSeen);
      if (timeSinceLastSeen.inMinutes > 5) {
        toRemove.add(entry.key);
      }
    }

    if (toRemove.isNotEmpty) {
      for (final userId in toRemove) {
        _onlineUsers.remove(userId);
      }
      _notifyUsersChanged();
    }
  }

  /// 通知用戶列表變化
  void _notifyUsersChanged() {
    _onlineUsersController.add(onlineUsers);
  }

  /// 清理資源
  void dispose() {
    _userCleanupTimer?.cancel();
    _onlineUsersController.close();
  }
} 
