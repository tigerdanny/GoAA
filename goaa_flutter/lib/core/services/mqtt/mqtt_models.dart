/// MQTT模型類定義

/// 在線用戶模型
class OnlineUser {
  final String id;
  final String userId;
  final String userCode;
  final String userName;
  final String name;
  final String email;
  final String phone;
  final DateTime lastSeen;
  final bool isOnline;

  OnlineUser({
    required this.id,
    required this.userId,
    required this.userCode,
    required this.userName,
    required this.name,
    required this.email,
    required this.phone,
    required this.lastSeen,
    this.isOnline = false,
  });

  OnlineUser copyWith({
    String? id,
    String? userId,
    String? userCode,
    String? userName,
    String? name,
    String? email,
    String? phone,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return OnlineUser(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userCode: userCode ?? this.userCode,
      userName: userName ?? this.userName,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userCode': userCode,
    'userName': userName,
    'name': name,
    'email': email,
    'phone': phone,
    'lastSeen': lastSeen.toIso8601String(),
    'isOnline': isOnline,
  };

  factory OnlineUser.fromJson(Map<String, dynamic> json) => OnlineUser(
    id: json['id'] as String,
    userId: json['userId'] as String? ?? json['id'] as String,
    userCode: json['userCode'] as String? ?? json['id'] as String,
    userName: json['userName'] as String? ?? json['name'] as String,
    name: json['name'] as String,
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    lastSeen: DateTime.parse(json['lastSeen'] as String),
    isOnline: json['isOnline'] as bool? ?? false,
  );
}

/// GOAA MQTT消息模型
class GoaaMqttMessage {
  final String id;
  final String type;
  final String topic;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? fromUserId;
  final String? toUserId;

  GoaaMqttMessage({
    required this.id,
    required this.type,
    required this.topic,
    required this.data,
    required this.timestamp,
    this.fromUserId,
    this.toUserId,
  });

  GoaaMqttMessage copyWith({
    String? id,
    String? type,
    String? topic,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    String? fromUserId,
    String? toUserId,
  }) {
    return GoaaMqttMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      topic: topic ?? this.topic,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'topic': topic,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'fromUserId': fromUserId,
    'toUserId': toUserId,
  };

  factory GoaaMqttMessage.fromJson(Map<String, dynamic> json) => GoaaMqttMessage(
    id: json['id'] as String,
    type: json['type'] as String,
    topic: json['topic'] as String,
    data: json['data'] as Map<String, dynamic>,
    timestamp: DateTime.parse(json['timestamp'] as String),
    fromUserId: json['fromUserId'] as String?,
    toUserId: json['toUserId'] as String?,
  );
}

/// 用戶搜索結果模型
class UserSearchResult {
  final String id;
  final String userId;
  final String userCode;
  final String userName;
  final String name;
  final String email;
  final String phone;
  final double matchScore;
  final bool isOnline;

  UserSearchResult({
    required this.id,
    required this.userId,
    required this.userCode,
    required this.userName,
    required this.name,
    required this.email,
    required this.phone,
    this.matchScore = 1.0,
    this.isOnline = false,
  });

  UserSearchResult copyWith({
    String? id,
    String? userId,
    String? userCode,
    String? userName,
    String? name,
    String? email,
    String? phone,
    double? matchScore,
    bool? isOnline,
  }) {
    return UserSearchResult(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userCode: userCode ?? this.userCode,
      userName: userName ?? this.userName,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      matchScore: matchScore ?? this.matchScore,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userCode': userCode,
    'userName': userName,
    'name': name,
    'email': email,
    'phone': phone,
    'matchScore': matchScore,
    'isOnline': isOnline,
  };

  factory UserSearchResult.fromJson(Map<String, dynamic> json) => UserSearchResult(
    id: json['id'] as String,
    userId: json['userId'] as String? ?? json['id'] as String,
    userCode: json['userCode'] as String? ?? json['id'] as String,
    userName: json['userName'] as String? ?? json['name'] as String,
    name: json['name'] as String,
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    matchScore: json['matchScore'] as double? ?? 1.0,
    isOnline: json['isOnline'] as bool? ?? false,
  );
}

/// 待處理的好友請求模型
class PendingFriendRequest {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String fromUserEmail;
  final String fromUserPhone;
  final String targetName;
  final String targetEmail;
  final String targetPhone;
  final DateTime requestTime;
  final String status;
  final String? message;

  PendingFriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserEmail,
    required this.fromUserPhone,
    required this.targetName,
    required this.targetEmail,
    required this.targetPhone,
    required this.requestTime,
    this.status = 'pending',
    this.message,
  });

  PendingFriendRequest copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? fromUserEmail,
    String? fromUserPhone,
    String? targetName,
    String? targetEmail,
    String? targetPhone,
    DateTime? requestTime,
    String? status,
    String? message,
  }) {
    return PendingFriendRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserEmail: fromUserEmail ?? this.fromUserEmail,
      fromUserPhone: fromUserPhone ?? this.fromUserPhone,
      targetName: targetName ?? this.targetName,
      targetEmail: targetEmail ?? this.targetEmail,
      targetPhone: targetPhone ?? this.targetPhone,
      requestTime: requestTime ?? this.requestTime,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUserId': fromUserId,
    'fromUserName': fromUserName,
    'fromUserEmail': fromUserEmail,
    'fromUserPhone': fromUserPhone,
    'targetName': targetName,
    'targetEmail': targetEmail,
    'targetPhone': targetPhone,
    'requestTime': requestTime.toIso8601String(),
    'status': status,
    'message': message,
  };

  factory PendingFriendRequest.fromJson(Map<String, dynamic> json) => PendingFriendRequest(
    id: json['id'] as String,
    fromUserId: json['fromUserId'] as String,
    fromUserName: json['fromUserName'] as String,
    fromUserEmail: json['fromUserEmail'] as String? ?? '',
    fromUserPhone: json['fromUserPhone'] as String? ?? '',
    targetName: json['targetName'] as String? ?? '',
    targetEmail: json['targetEmail'] as String? ?? '',
    targetPhone: json['targetPhone'] as String? ?? '',
    requestTime: DateTime.parse(json['requestTime'] as String),
    status: json['status'] as String? ?? 'pending',
    message: json['message'] as String?,
  );
} 
