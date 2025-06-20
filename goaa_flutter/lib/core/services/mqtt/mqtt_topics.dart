/// MQTT 主題配置
class MqttTopics {
  // 基礎前綴
  static const String _basePrefix = 'goaa';
  
  // ==================== 好友功能群組 ====================
  static const String _friendsGroup = '$_basePrefix/friends';
  
  /// 好友功能 - 全局主題
  static const String friendsUserOnline = '$_friendsGroup/users/online';
  static const String friendsUserOffline = '$_friendsGroup/users/offline';
  static const String friendsUserHeartbeat = '$_friendsGroup/users/heartbeat';
  
  /// 好友功能 - 個人主題
  static String friendsUserRequests(String userId) => '$_friendsGroup/users/$userId/requests';
  static String friendsUserResponses(String userId) => '$_friendsGroup/users/$userId/responses';
  static String friendsUserStatus(String userId) => '$_friendsGroup/users/$userId/status';
  
  // ==================== 帳務功能群組 ====================
  static const String _expensesGroup = '$_basePrefix/expenses';
  
  /// 帳務功能 - 群組主題
  static String expensesGroupShares(String groupId) => '$_expensesGroup/groups/$groupId/shares';
  static String expensesGroupUpdates(String groupId) => '$_expensesGroup/groups/$groupId/updates';
  static String expensesGroupSettlements(String groupId) => '$_expensesGroup/groups/$groupId/settlements';
  static String expensesGroupMembers(String groupId) => '$_expensesGroup/groups/$groupId/members';
  
  /// 帳務功能 - 個人主題
  static String expensesUserNotifications(String userId) => '$_expensesGroup/users/$userId/notifications';
  static String expensesUserInvitations(String userId) => '$_expensesGroup/users/$userId/invitations';
  static String expensesUserSettlements(String userId) => '$_expensesGroup/users/$userId/settlements';
  static String expensesUserUpdates(String userId) => '$_expensesGroup/users/$userId/updates';
  
  // ==================== 系統功能群組 ====================
  static const String _systemGroup = '$_basePrefix/system';
  
  /// 系統功能主題
  static const String systemAnnouncements = '$_systemGroup/announcements';
  static const String systemMaintenance = '$_systemGroup/maintenance';
  static String systemUserSession(String userId) => '$_systemGroup/users/$userId/session';
  
  // ==================== 主題匹配工具 ====================
  
  /// 檢查主題是否屬於好友功能群組
  static bool isFriendsGroupTopic(String topic) {
    return topic.startsWith(_friendsGroup);
  }
  
  /// 檢查主題是否屬於帳務功能群組
  static bool isExpensesGroupTopic(String topic) {
    return topic.startsWith(_expensesGroup);
  }
  
  /// 檢查主題是否屬於系統功能群組
  static bool isSystemGroupTopic(String topic) {
    return topic.startsWith(_systemGroup);
  }
  
  /// 從主題中提取群組類型
  static String? getTopicGroup(String topic) {
    if (isFriendsGroupTopic(topic)) return 'friends';
    if (isExpensesGroupTopic(topic)) return 'expenses';
    if (isSystemGroupTopic(topic)) return 'system';
    return null;
  }
  
  /// 從主題中提取用戶ID
  static String? extractUserIdFromTopic(String topic) {
    final regex = RegExp(r'/users/([^/]+)/');
    final match = regex.firstMatch(topic);
    return match?.group(1);
  }
  
  /// 從主題中提取群組ID
  static String? extractGroupIdFromTopic(String topic) {
    final regex = RegExp(r'/groups/([^/]+)/');
    final match = regex.firstMatch(topic);
    return match?.group(1);
  }
  
  /// 獲取所有需要訂閱的好友功能主題
  static List<String> getFriendsSubscriptionTopics(String userId) {
    return [
      friendsUserOnline,
      friendsUserOffline,
      friendsUserHeartbeat,
      friendsUserRequests(userId),
      friendsUserResponses(userId),
      friendsUserStatus(userId),
    ];
  }
  
  /// 獲取所有需要訂閱的帳務功能主題
  static List<String> getExpensesSubscriptionTopics(String userId, List<String> groupIds) {
    final topics = <String>[
      expensesUserNotifications(userId),
      expensesUserInvitations(userId),
      expensesUserSettlements(userId),
      expensesUserUpdates(userId),
    ];
    
    // 添加用戶所在群組的主題
    for (final groupId in groupIds) {
      topics.addAll([
        expensesGroupShares(groupId),
        expensesGroupUpdates(groupId),
        expensesGroupSettlements(groupId),
        expensesGroupMembers(groupId),
      ]);
    }
    
    return topics;
  }
  
  /// 獲取所有需要訂閱的系統功能主題
  static List<String> getSystemSubscriptionTopics(String userId) {
    return [
      systemAnnouncements,
      systemMaintenance,
      systemUserSession(userId),
    ];
  }
}
