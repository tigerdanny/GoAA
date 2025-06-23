/// MQTT 主題配置
class MqttTopics {
  // 基礎前綴
  static const String _basePrefix = 'goaa';
  
  // ==================== 好友功能群組 ====================
  static const String _friendsGroup = '$_basePrefix/friends';
  
  /// 好友功能 - 個人狀態主題（每個用戶發布自己的狀態）
  static String friendUserStatus(String userId) => '$_friendsGroup/$userId/status';
  
  /// 好友功能 - 萬用字元訂閱（監聽所有好友狀態）
  static const String friendsAllUsersStatus = '$_friendsGroup/+/status';
  
  /// 好友功能 - 好友請求主題
  static String friendsUserRequests(String userId) => '$_friendsGroup/$userId/requests';
  static String friendsUserResponses(String userId) => '$_friendsGroup/$userId/responses';
  
  /// 好友功能 - 萬用字元訂閱（監聽所有好友請求和回應）
  static const String friendsAllUsersRequests = '$_friendsGroup/+/requests';
  static const String friendsAllUsersResponses = '$_friendsGroup/+/responses';
  
  // ==================== 用戶搜索功能 ====================
  
  /// 用戶搜索 - 搜索請求主題（公共廣播）
  static const String userSearchRequest = '$_basePrefix/user/search/request';
  
  /// 用戶搜索 - 搜索響應主題（個人接收）
  static String userSearchResponse(String requesterId) => '$_basePrefix/user/search/response/$requesterId';
  
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
    if (isUserSearchTopic(topic)) return 'friends'; // 用戶搜索歸類到好友群組
    if (isExpensesGroupTopic(topic)) return 'expenses';
    if (isSystemGroupTopic(topic)) return 'system';
    return null;
  }
  
  /// 從好友狀態主題中提取用戶ID
  static String? extractUserIdFromFriendStatusTopic(String topic) {
    // 匹配 goaa/friends/{userId}/status 格式
    final regex = RegExp(r'^goaa/friends/([^/]+)/status$');
    final match = regex.firstMatch(topic);
    return match?.group(1);
  }
  
  /// 從好友請求主題中提取用戶ID
  static String? extractUserIdFromFriendRequestTopic(String topic) {
    // 匹配 goaa/friends/{userId}/requests 或 goaa/friends/{userId}/responses 格式
    final regex = RegExp(r'^goaa/friends/([^/]+)/(requests|responses)$');
    final match = regex.firstMatch(topic);
    return match?.group(1);
  }
  
  /// 從主題中提取用戶ID（通用方法）
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
  
  /// 檢查主題是否為好友狀態主題
  static bool isFriendStatusTopic(String topic) {
    return topic.startsWith('$_friendsGroup/') && topic.endsWith('/status');
  }
  
  /// 檢查主題是否為好友請求主題
  static bool isFriendRequestTopic(String topic) {
    return topic.startsWith('$_friendsGroup/') && 
           (topic.endsWith('/requests') || topic.endsWith('/responses'));
  }
  
  /// 檢查主題是否為用戶搜索主題
  static bool isUserSearchTopic(String topic) {
    return topic.startsWith('$_basePrefix/user/search/');
  }
  
  /// 檢查主題是否為用戶搜索請求主題
  static bool isUserSearchRequestTopic(String topic) {
    return topic == userSearchRequest;
  }
  
  /// 檢查主題是否為用戶搜索響應主題
  static bool isUserSearchResponseTopic(String topic) {
    return topic.startsWith('$_basePrefix/user/search/response/');
  }
  
  /// 從用戶搜索響應主題中提取請求者ID
  static String? extractRequesterIdFromSearchResponseTopic(String topic) {
    // 匹配 goaa/user/search/response/{requesterId} 格式
    final regex = RegExp(r'^goaa/user/search/response/([^/]+)$');
    final match = regex.firstMatch(topic);
    return match?.group(1);
  }
  
  /// 獲取所有需要訂閱的好友功能主題
  static List<String> getFriendsSubscriptionTopics(String userId) {
    return [
      // 訂閱所有好友的狀態變化（使用萬用字元）
      friendsAllUsersStatus,
      
      // 訂閱發送給自己的好友請求
      friendsUserRequests(userId),
      
      // 訂閱發送給自己的好友回應
      friendsUserResponses(userId),
      
      // 訂閱用戶搜索功能
      userSearchRequest, // 監聽搜索請求
      userSearchResponse(userId), // 監聽發送給自己的搜索響應
      
      // 可選：訂閱所有好友請求和回應（如果需要全局監控）
      // friendsAllUsersRequests,
      // friendsAllUsersResponses,
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
