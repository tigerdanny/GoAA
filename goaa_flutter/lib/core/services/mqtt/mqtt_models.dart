

/// GOAA MQTT 消息類型
enum GoaaMqttMessageType {
  // 好友功能群組
  userOnline,           // 用戶上線
  userOffline,          // 用戶離線
  friendRequest,        // 好友請求（第一階段：簡單通知）
  friendAccept,         // 接受好友（第二階段：發送完整信息）
  friendReject,         // 拒絕好友
  friendInfoShare,      // 好友信息分享（第二階段：完整個人信息）
  heartbeat,            // 心跳
  
  // 帳務功能群組
  expenseShare,         // 分帳分享
  expenseUpdate,        // 帳務更新
  expenseSettlement,    // 結算通知
  expenseNotification,  // 帳務通知
  groupInvitation,      // 群組邀請
  
  // 系統功能群組
  systemAnnouncement,   // 系統公告
  systemMaintenance,    // 系統維護
  
  // 用戶搜索
  userSearchRequest,
  userSearchResponse,
  
  // 群組功能
  groupMessage,
  groupJoin,
  groupLeave,
  
  // 記帳功能
  expenseCreate,
  expenseDelete,
}

/// 消息類型擴展方法
extension GoaaMqttMessageTypeExtension on GoaaMqttMessageType {
  /// 獲取消息類型的英文標識符
  String get identifier {
    switch (this) {
      // 好友功能群組
      case GoaaMqttMessageType.userOnline:
        return 'ONLINE';
      case GoaaMqttMessageType.userOffline:
        return 'OFFLINE';
      case GoaaMqttMessageType.friendRequest:
        return 'FREQ';
      case GoaaMqttMessageType.friendAccept:
        return 'FACC';
      case GoaaMqttMessageType.friendReject:
        return 'FREJ';
      case GoaaMqttMessageType.friendInfoShare:
        return 'FINFO';
      case GoaaMqttMessageType.heartbeat:
        return 'BEAT';
      
      // 帳務功能群組
      case GoaaMqttMessageType.expenseShare:
        return 'ESHARE';
      case GoaaMqttMessageType.expenseUpdate:
        return 'EUPD';
      case GoaaMqttMessageType.expenseSettlement:
        return 'ESETT';
      case GoaaMqttMessageType.expenseNotification:
        return 'ENOTIF';
      case GoaaMqttMessageType.groupInvitation:
        return 'GINV';
      
      // 系統功能群組
      case GoaaMqttMessageType.systemAnnouncement:
        return 'SYSANN';
      case GoaaMqttMessageType.systemMaintenance:
        return 'SYSMNT';
      
      // 用戶搜索
      case GoaaMqttMessageType.userSearchRequest:
        return 'SREQ';
      case GoaaMqttMessageType.userSearchResponse:
        return 'SRESP';
      
      // 群組功能
      case GoaaMqttMessageType.groupMessage:
        return 'GMSG';
      case GoaaMqttMessageType.groupJoin:
        return 'GJOIN';
      case GoaaMqttMessageType.groupLeave:
        return 'GLEAVE';
      
      // 記帳功能
      case GoaaMqttMessageType.expenseCreate:
        return 'ECREATE';
      case GoaaMqttMessageType.expenseDelete:
        return 'EDEL';
    }
  }

  /// 獲取消息類型的中文描述
  String get description {
    switch (this) {
      // 好友功能群組
      case GoaaMqttMessageType.userOnline:
        return '用戶上線';
      case GoaaMqttMessageType.userOffline:
        return '用戶離線';
      case GoaaMqttMessageType.friendRequest:
        return '好友請求';
      case GoaaMqttMessageType.friendAccept:
        return '接受好友';
      case GoaaMqttMessageType.friendReject:
        return '拒絕好友';
      case GoaaMqttMessageType.friendInfoShare:
        return '好友信息分享';
      case GoaaMqttMessageType.heartbeat:
        return '心跳';
      
      // 帳務功能群組
      case GoaaMqttMessageType.expenseShare:
        return '分帳分享';
      case GoaaMqttMessageType.expenseUpdate:
        return '帳務更新';
      case GoaaMqttMessageType.expenseSettlement:
        return '結算通知';
      case GoaaMqttMessageType.expenseNotification:
        return '帳務通知';
      case GoaaMqttMessageType.groupInvitation:
        return '群組邀請';
      
      // 系統功能群組
      case GoaaMqttMessageType.systemAnnouncement:
        return '系統公告';
      case GoaaMqttMessageType.systemMaintenance:
        return '系統維護';
      
      // 用戶搜索
      case GoaaMqttMessageType.userSearchRequest:
        return '用戶搜索請求';
      case GoaaMqttMessageType.userSearchResponse:
        return '用戶搜索響應';
      
      // 群組功能
      case GoaaMqttMessageType.groupMessage:
        return '群組消息';
      case GoaaMqttMessageType.groupJoin:
        return '加入群組';
      case GoaaMqttMessageType.groupLeave:
        return '離開群組';
      
      // 記帳功能
      case GoaaMqttMessageType.expenseCreate:
        return '創建記帳';
      case GoaaMqttMessageType.expenseDelete:
        return '刪除記帳';
    }
  }
}



/// GOAA MQTT 消息模型
class GoaaMqttMessage {
  final String id;
  final GoaaMqttMessageType type;
  final String fromUserId;
  final String toUserId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String group; // 消息所屬群組

  GoaaMqttMessage({
    required this.id,
    required this.type,
    required this.fromUserId,
    required this.toUserId,
    required this.data,
    DateTime? timestamp,
    required this.group,
  }) : timestamp = timestamp ?? DateTime.now();

  factory GoaaMqttMessage.fromJson(Map<String, dynamic> json) {
    return GoaaMqttMessage(
      id: json['id'] ?? '',
      type: GoaaMqttMessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => GoaaMqttMessageType.heartbeat,
      ),
      fromUserId: json['fromUserId'] ?? '',
      toUserId: json['toUserId'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      group: json['group'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'group': group,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoaaMqttMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 在線用戶信息
class OnlineUser {
  final String userId;
  final String userName;
  final String userCode;
  final String? avatar;
  final DateTime lastSeen;
  final String status; // 'online', 'offline', 'away'

  OnlineUser({
    required this.userId,
    required this.userName,
    required this.userCode,
    this.avatar,
    required this.lastSeen,
    this.status = 'online',
  });

  factory OnlineUser.fromJson(Map<String, dynamic> json) {
    return OnlineUser(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userCode: json['userCode'] ?? '',
      avatar: json['avatar'],
      lastSeen: DateTime.tryParse(json['lastSeen'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'online',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userCode': userCode,
      'avatar': avatar,
      'lastSeen': lastSeen.toIso8601String(),
      'status': status,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnlineUser && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

/// 用戶搜索結果
class UserSearchResult {
  final String userId;
  final String userName;
  final String userCode;
  final String? email;
  final String? phone;
  final double matchScore; // 匹配度 0.0-1.0

  UserSearchResult({
    required this.userId,
    required this.userName,
    required this.userCode,
    this.email,
    this.phone,
    this.matchScore = 1.0,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userCode: json['userCode'] ?? '',
      email: json['email']?.isEmpty == true ? null : json['email'],
      phone: json['phone']?.isEmpty == true ? null : json['phone'],
      matchScore: (json['matchScore'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userCode': userCode,
      'email': email,
      'phone': phone,
      'matchScore': matchScore,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSearchResult && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

/// MQTT 連接狀態
enum MqttConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

/// MQTT 連接配置
class MqttConfig {
  final String host;
  final int port;
  final String clientId;
  final String? username;
  final String? password;
  final bool useSSL;
  final int keepAliveSeconds;
  final int connectionTimeoutSeconds;

  const MqttConfig({
    required this.host,
    this.port = 1883,
    required this.clientId,
    this.username,
    this.password,
    this.useSSL = false,
    this.keepAliveSeconds = 60,
    this.connectionTimeoutSeconds = 30,
  });
} 
