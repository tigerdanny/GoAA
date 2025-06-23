

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
