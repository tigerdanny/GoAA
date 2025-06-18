/// GOAA MQTT 消息類型
enum GoaaMqttMessageType {
  userOnline,      // 用戶上線
  userOffline,     // 用戶離線
  friendRequest,   // 好友請求
  friendAccept,    // 接受好友
  friendReject,    // 拒絕好友
  message,         // 普通消息
  expenseShare,    // 分帳分享
  heartbeat,       // 心跳
}

/// GOAA MQTT 消息模型
class GoaaMqttMessage {
  final String id;
  final GoaaMqttMessageType type;
  final String fromUserId;
  final String? toUserId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  GoaaMqttMessage({
    required this.id,
    required this.type,
    required this.fromUserId,
    this.toUserId,
    required this.data,
    required this.timestamp,
  });

  factory GoaaMqttMessage.fromJson(Map<String, dynamic> json) {
    return GoaaMqttMessage(
      id: json['id'],
      type: GoaaMqttMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoaaMqttMessageType.message,
      ),
      fromUserId: json['fromUserId'],
      toUserId: json['toUserId'],
      data: json['data'] ?? {},
      timestamp: DateTime.parse(json['timestamp']),
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
