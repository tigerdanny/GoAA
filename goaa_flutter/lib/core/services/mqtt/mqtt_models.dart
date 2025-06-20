/// GOAA MQTT 消息類型
enum GoaaMqttMessageType {
  // 好友功能群組
  userOnline,           // 用戶上線
  userOffline,          // 用戶離線
  friendRequest,        // 好友請求
  friendAccept,         // 接受好友
  friendReject,         // 拒絕好友
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
}

/// GOAA MQTT 消息模型
class GoaaMqttMessage {
  final String id;
  final GoaaMqttMessageType type;
  final String fromUserId;
  final String? toUserId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String group; // 消息所屬群組

  GoaaMqttMessage({
    required this.id,
    required this.type,
    required this.fromUserId,
    this.toUserId,
    required this.data,
    required this.timestamp,
    required this.group,
  });

  factory GoaaMqttMessage.fromJson(Map<String, dynamic> json) {
    return GoaaMqttMessage(
      id: json['id'],
      type: GoaaMqttMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoaaMqttMessageType.friendRequest,
      ),
      fromUserId: json['fromUserId'],
      toUserId: json['toUserId'],
      data: json['data'] ?? {},
      timestamp: DateTime.parse(json['timestamp']),
      group: json['group'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'group': group,
    };
  }
}

/// 在線用戶信息
class OnlineUser {
  final String userId;
  final String userName;
  final String userCode;
  final String? avatar;
  final DateTime lastSeen;

  OnlineUser({
    required this.userId,
    required this.userName,
    required this.userCode,
    this.avatar,
    required this.lastSeen,
  });

  factory OnlineUser.fromJson(Map<String, dynamic> json) {
    return OnlineUser(
      userId: json['userId'],
      userName: json['userName'],
      userCode: json['userCode'],
      avatar: json['avatar'],
      lastSeen: DateTime.parse(json['lastSeen']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userCode': userCode,
      'avatar': avatar,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }
} 
