import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/repositories/user_repository.dart';
import '../../core/database/repositories/group_repository.dart';
import '../../core/database/database.dart';
import '../../core/widgets/language_switch_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../personal_info/personal_info_screen.dart';
import '../friends/friends_screen.dart';
import '../about/about_screen.dart';
import '../account_settings/account_settings_screen.dart';
import '../reminder_settings/reminder_settings_screen.dart';
import '../interface_settings/interface_settings_screen.dart';

/// 首頁主界面
/// 展示用戶的群組列表、快速操作和統計概覽
class HomeScreen extends StatefulWidget {
  // 预加载数据
  final User? preloadedUser;
  final List<Group>? preloadedGroups;
  final Map<int, Map<String, dynamic>>? preloadedGroupStats;
  final Map<String, dynamic>? preloadedStats;

  const HomeScreen({
    super.key,
    this.preloadedUser,
    this.preloadedGroups,
    this.preloadedGroupStats,
    this.preloadedStats,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Repository實例
  final UserRepository _userRepository = UserRepository();
  final GroupRepository _groupRepository = GroupRepository();

  // 狀態數據
  User? _currentUser;
  List<Group> _groups = [];
  final Map<int, Map<String, dynamic>> _groupStats = {}; // 群組統計數據
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // 如果有预加载数据，直接使用；否则加载数据
    if (widget.preloadedUser != null) {
      _usePreloadedData();
    } else {
      _loadData();
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  /// 使用预加载的数据
  void _usePreloadedData() {
    _currentUser = widget.preloadedUser;
    _groups = widget.preloadedGroups ?? [];
    _groupStats.clear();
    _groupStats.addAll(widget.preloadedGroupStats ?? {});
    _stats = widget.preloadedStats ?? {};
    
    setState(() => _isLoading = false);
    _animationController.forward();
  }

  /// 获取基于时间的问候语
  String _getTimeBasedGreeting(AppLocalizations? l10n, String userName) {
    final now = DateTime.now();
    final hour = now.hour;
    
    // 确保用户名不为空
    final finalUserName = userName.isNotEmpty ? userName : (l10n?.defaultUser ?? '用戶');
    
    String greeting;
    if (hour >= 5 && hour < 12) {
      // 早上 5:00-11:59
      greeting = l10n?.goodMorning(finalUserName) ?? '早安，$finalUserName';
    } else if (hour >= 12 && hour < 17) {
      // 下午 12:00-16:59
      greeting = l10n?.goodAfternoon(finalUserName) ?? '午安，$finalUserName';
    } else if (hour >= 17 && hour < 21) {
      // 傍晚 17:00-20:59
      greeting = l10n?.goodEvening(finalUserName) ?? '晚安，$finalUserName';
    } else {
      // 夜晚 21:00-4:59
      greeting = l10n?.goodNight(finalUserName) ?? '深夜好，$finalUserName';
    }
    
    return greeting;
  }

  /// 加載資料庫數據
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // 加載當前用戶
      _currentUser = await _userRepository.getCurrentUser();
      
      if (_currentUser != null) {
        // 加載用戶群組
        _groups = await _groupRepository.getUserGroups(_currentUser!.id);
        
        // 清空並重新加載每個群組的統計數據
        _groupStats.clear();
        for (final group in _groups) {
          _groupStats[group.id] = await _groupRepository.getGroupStats(group.id);
        }
        
        // 加載統計數據
        _stats = await _userRepository.getUserStats(_currentUser!.id);
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('加載數據失敗: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GOAA Logo - 填满方形容器
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/goaa_logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover, // 确保logo填满整个容器
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // 加载指示器
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.loading ?? '載入中...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      drawer: _buildDrawer(l10n),
      drawerScrimColor: Colors.black.withValues(alpha: 0.3),
      drawerEdgeDragWidth: 60, // 增加滑动感应区域
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                _buildHeader(l10n),
                _buildQuickStats(),
                _buildSectionTitle(l10n?.myGroups ?? '我的群組'),
                _buildGroupsList(),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100), // 為浮動按鈕留空間
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 构建侧滑菜单 - 改善流畅度，现代化设计，优化动画
  Widget _buildDrawer(AppLocalizations? l10n) {
    return Theme(
      data: Theme.of(context).copyWith(
        // 自定义drawer的动画时长
        drawerTheme: DrawerThemeData(
          backgroundColor: AppColors.background,
          elevation: 16,
          shadowColor: Colors.black.withValues(alpha: 0.2),
        ),
      ),
      child: Drawer(
        backgroundColor: AppColors.background,
        elevation: 16,
        width: MediaQuery.of(context).size.width * 0.75, // 设置drawer宽度为屏幕的75%
        child: SafeArea(
          child: Column(
            children: [
              // 菜单头部
              _buildDrawerHeader(l10n),
              
              // 菜单选项
              Expanded(
                child: Container(
                  color: AppColors.background,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    physics: const ClampingScrollPhysics(), // 改善滚动性能
                    children: [
                      _buildDrawerItem(
                        icon: Icons.person_outlined,
                        title: l10n?.personalInfo ?? '個人資訊',
                        onTap: () => _navigateToPersonalInfo(),
                      ),
                      _buildDrawerItem(
                        icon: Icons.people_outlined,
                        title: l10n?.friendsInfo ?? '好友資訊',
                        onTap: () => _navigateToFriendsInfo(),
                      ),
                      _buildDrawerItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: l10n?.accountSettings ?? '帳務設定',
                        onTap: () => _navigateToAccountSettings(),
                      ),
                      _buildDrawerItem(
                        icon: Icons.notifications_outlined,
                        title: l10n?.reminderSettings ?? '提醒設定',
                        onTap: () => _navigateToReminderSettings(),
                      ),
                      _buildDrawerItem(
                        icon: Icons.palette_outlined,
                        title: l10n?.interface ?? '介面設定',
                        onTap: () => _navigateToInterfaceSettings(),
                      ),
                      const Divider(height: 1),
                      _buildDrawerItem(
                        icon: Icons.info_outlined,
                        title: l10n?.about ?? '關於應用',
                        onTap: () => _navigateToAbout(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 底部语言切换
              Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(16),
                child: const LanguageSwitchButton(showLabel: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建侧滑菜单头部 - 现代化纯净设计
  Widget _buildDrawerHeader(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 用户头像 - 纯净圆形设计
          Hero(
            tag: 'drawer_user_avatar',
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/goaa_logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // 用户信息 - 现代化文字设计
          Text(
            _getTimeBasedGreeting(l10n, _currentUser?.name ?? l10n?.defaultUser ?? '用戶'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              l10n?.userCode(_currentUser?.userCode ?? 'N/A') ?? '用戶代碼：${_currentUser?.userCode ?? "N/A"}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建侧滑菜单项目 - 现代化卡片设计
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          HapticFeedback.lightImpact();
          onTap();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// 構建頂部標題區域 - 菜单图标紧贴左边缘，优化设计
  Widget _buildHeader(AppLocalizations? l10n) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 20, 24, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Row(
          children: [
            // 菜单按钮 - 三条横线紧贴左边缘
            GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
                HapticFeedback.lightImpact();
              },
              behavior: HitTestBehavior.opaque, // 确保整个区域都可以点击
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 12, 16, 12), // 左边距为0，让图标紧贴边缘
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16), // 给图标添加最小的左边距
                      child: Icon(
                        Icons.menu,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 18, // 稍微缩小箭头
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // 用戶頭像 - 純圓形设计
            Hero(
              tag: 'user_avatar',
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/goaa_logo.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // 歡迎文字 - 现代化布局
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTimeBasedGreeting(l10n, _currentUser?.name ?? l10n?.defaultUser ?? '用戶'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      l10n?.userCode(_currentUser?.userCode ?? 'N/A') ?? '用戶代碼：${_currentUser?.userCode ?? "N/A"}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 構建快速統計卡片
  Widget _buildQuickStats() {
    final l10n = AppLocalizations.of(context);
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.group,
                title: l10n?.participatedGroups ?? '參與群組',
                amount: '${_stats['groupCount'] ?? 0}',
                color: AppColors.primary,
                isPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.account_balance_wallet,
                title: l10n?.totalExpenses ?? '總支出',
                amount: l10n?.moneyFormat(l10n.currency, (_stats['totalPaid'] ?? 0.0).toStringAsFixed(2)) ?? '\$${(_stats['totalPaid'] ?? 0.0).toStringAsFixed(2)} NT',
                color: AppColors.warning,
                isPositive: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 構建統計卡片
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppColors.success : AppColors.error,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 構建區段標題
  Widget _buildSectionTitle(String title) {
    final l10n = AppLocalizations.of(context);
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _viewAllGroups(),
              child: Text(
                l10n?.viewAll ?? '查看全部',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 構建群組列表
  Widget _buildGroupsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final group = _groups[index];
          return _buildGroupCard(group, index);
        },
        childCount: _groups.length,
      ),
    );
  }

  /// 構建群組卡片
  Widget _buildGroupCard(Group group, int index) {
    final l10n = AppLocalizations.of(context);
    final stats = _groupStats[group.id] ?? {};
    final memberCount = stats['memberCount'] ?? 0;
    final totalAmount = stats['totalAmount'] ?? 0.0;
    final lastActivity = stats['lastActivity'] as DateTime?;
    
    // 為群組分配顏色
    final color = AppColors.groupColors[index % AppColors.groupColors.length];
    
    // 格式化最近活動時間
    String formatLastActivity(DateTime? dateTime) {
      if (dateTime == null) return l10n?.noActivity ?? '無活動';
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return l10n?.timeAgo_days(difference.inDays) ?? '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        return l10n?.timeAgo_hours(difference.inHours) ?? '${difference.inHours}小時前';
      } else if (difference.inMinutes > 0) {
        return l10n?.timeAgo_minutes(difference.inMinutes) ?? '${difference.inMinutes}分鐘前';
      } else {
        return l10n?.timeAgo_justNow ?? '剛才';
      }
    }

    return Container(
      margin: EdgeInsets.fromLTRB(
        24,
        index == 0 ? 0 : 8,
        24,
        index == _groups.length - 1 ? 0 : 8,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: AppColors.textPrimary.withValues(alpha: 0.1),
        child: InkWell(
          onTap: () => _enterGroup(group),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // 群組圖標
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 背景圖案
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          // 主圖標
                          const Icon(
                            Icons.group,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 群組信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$memberCount${l10n?.members ?? "位成員"} • ${formatLastActivity(lastActivity)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 金額 - 确保使用正确的格式
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          totalAmount >= 0 
                              ? l10n?.positiveMoneyFormat(l10n.currency, totalAmount.toStringAsFixed(2)) ?? '+\$${totalAmount.toStringAsFixed(2)} NT'
                              : l10n?.negativeMoneyFormat(l10n.currency, totalAmount.abs().toStringAsFixed(2)) ?? '-\$${totalAmount.abs().toStringAsFixed(2)} NT',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.getMoneyColor(totalAmount),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: totalAmount == 0 
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            totalAmount == 0 ? (l10n?.settled ?? '已結清') : (l10n?.hasActivity ?? '有活動'),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: totalAmount == 0 
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 群組描述
                if (group.description != null && group.description!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            group.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 構建浮動操作按鈕
  Widget _buildFloatingActionButton() {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: 200,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showQuickActions(),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n?.quickBilling ?? '快速分帳',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 交互方法
  void _viewAllGroups() {
    HapticFeedback.lightImpact();
    // 導航到群組列表頁面
  }

  void _enterGroup(Group group) {
    HapticFeedback.lightImpact();
    // 導航到群組詳情頁面
  }

  void _showQuickActions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickActionsSheet(),
    );
  }

  /// 構建快速操作底部表單
  Widget _buildQuickActionsSheet() {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n?.quickActions ?? '快速操作',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionItem(
                  icon: Icons.add,
                  title: l10n?.addExpense ?? '添加支出',
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.pop(context);
                    // 導航到添加支出頁面
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionItem(
                  icon: Icons.group_add,
                  title: l10n?.createGroup ?? '創建群組',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    // 導航到創建群組頁面
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionItem(
                  icon: Icons.receipt_long,
                  title: l10n?.scanReceipt ?? '掃描收據',
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.pop(context);
                    // 開啟相機掃描功能
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionItem(
                  icon: Icons.account_balance,
                  title: l10n?.settlementRecords ?? '結算記錄',
                  color: AppColors.info,
                  onTap: () {
                    Navigator.pop(context);
                    // 導航到結算記錄頁面
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 構建快速操作項目
  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 导航方法 - 更新为独立页面
  void _navigateToPersonalInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
    );
  }

  void _navigateToFriendsInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FriendsScreen()),
    );
  }

  void _navigateToAccountSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
    );
  }

  void _navigateToReminderSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReminderSettingsScreen()),
    );
  }

  void _navigateToInterfaceSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InterfaceSettingsScreen()),
    );
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }
} 
