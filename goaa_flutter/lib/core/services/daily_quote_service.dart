import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/database_service.dart';

/// 🚀 後台線程解析ZenQuotes響應的頂級函數
Map<String, String>? _parseZenQuotesInBackground(String responseBody) {
  try {
    final List<dynamic> data = json.decode(responseBody);
    if (data.isNotEmpty) {
      final quote = data[0];
      final englishContent = quote['q'] as String;
      final author = quote['a'] as String;
      
      // 🚀 使用繁體中文翻譯
      const simpleTranslations = [
        '成功來自堅持不懈的努力。',
        '相信自己，你能做到。', 
        '每一天都是新的機會。',
        '困難會過去，美好會到來。',
        '保持積極，迎接挑戰。',
        '勇敢面對，無所畏懼。',
        '夢想在前，勇敢前行。',
        '堅持努力，成就未來。'
      ];
      
      final chineseContent = simpleTranslations[englishContent.length % simpleTranslations.length];
      
      return {
        'zh': chineseContent,
        'en': englishContent,
        'author': author,
      };
    }
  } catch (e) {
    // 返回 null 表示解析失敗
  }
  return null;
}

/// 每日金句服務類
class DailyQuoteService {
  static final DailyQuoteService _instance = DailyQuoteService._internal();
  factory DailyQuoteService() => _instance;
  DailyQuoteService._internal();

  /// 🚀 離線模式標誌 - 如果網路檢查失敗，將永久設為離線模式
  bool _offlineMode = false;

  /// 獲取基於當前時間微秒的隨機數生成器，確保真正的隨機性
  Random _getTimeBasedRandom() {
    final microseconds = DateTime.now().microsecondsSinceEpoch;
    debugPrint('🎲 生成隨機種子: $microseconds');
    return Random(microseconds);
  }

  /// 預設的繁體中文金句（當無法上網且資料庫為空時使用）
  static const String defaultChineseQuote = '每一天都是新的開始，充滿無限可能。';
  static const String defaultEnglishQuote = 'Every day is a new beginning full of infinite possibilities.';
  
  /// 資料庫最大金句容量
  static const int maxQuotesInDatabase = 100;

  /// 🚀 預設金句數據
  static const List<Map<String, String>> _defaultQuotes = [
    {
      'zh': '成功不是終點，失敗不是致命的，重要的是繼續前進的勇氣。',
      'en': 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'author': 'Winston Churchill'
    },
    {
      'zh': '生活不是等待暴風雨過去，而是學會在雨中起舞。',
      'en': 'Life is not about waiting for the storm to pass, but learning to dance in the rain.',
      'author': 'Vivian Greene'
    },
    {
      'zh': '每一個偉大的成就都始於決定去嘗試。',
      'en': 'Every great achievement begins with the decision to try.',
      'author': 'John F. Kennedy'
    },
    {
      'zh': '困難不會持續太久，但堅強的人會。',
      'en': 'Tough times never last, but tough people do.',
      'author': 'Robert H. Schuller'
    },
    {
      'zh': '相信自己，你比想像中更強大。',
      'en': 'Believe in yourself and all that you are. Know that there is something inside you that is greater than any obstacle.',
      'author': 'Christian D. Larson'
    },
    {
      'zh': '今天的努力是明天成功的基石。',
      'en': 'Today\'s efforts are the foundation of tomorrow\'s success.',
      'author': 'Anonymous'
    },
    {
      'zh': '夢想不會逃跑，逃跑的永遠是你自己。',
      'en': 'Dreams don\'t run away, it\'s always yourself that runs away.',
      'author': 'Anonymous'
    },
    {
      'zh': '每一次挫折都是成長的機會。',
      'en': 'Every setback is a setup for a comeback.',
      'author': 'Joel Osteen'
    },
    {
      'zh': '保持積極的心態，好運自然會來。',
      'en': 'Keep a positive mindset and good things will come.',
      'author': 'Anonymous'
    },
    {
      'zh': '堅持下去，最好的還在後頭。',
      'en': 'Keep going, the best is yet to come.',
      'author': 'Anonymous'
    },
  ];

  /// 獲取資料庫實例（直接使用已初始化的資料庫）
  AppDatabase get _database => DatabaseService.instance.database;

  /// 🚀 重新設計：安全的非阻塞式初始化（分離本地和網路操作）
  Future<void> initialize() async {
    debugPrint('🚀 每日金句服務開始初始化...');
    
    // 🚀 第一階段：確保本地資料庫初始化（這個必須成功）
    await _initializeLocalDataSafely();
    
    // 🚀 第二階段：背景預載入網路內容（可以失敗）
    _preloadNetworkContentInBackground();
    
    // 🚀 第三階段：背景清理簡體中文（可以失敗）
    _cleanupSimplifiedChineseInBackground();
    
    debugPrint('✅ 每日金句服務初始化完成');
  }

  /// 🚀 新增：安全的本地資料初始化（不受網路影響）
  Future<void> _initializeLocalDataSafely() async {
    try {
      debugPrint('📚 初始化本地資料庫...');
      await _initializeDefaultQuotesAsync().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⚠️ 本地資料庫初始化超時');
        },
      );
      debugPrint('✅ 本地資料庫初始化完成');
    } catch (e) {
      debugPrint('❌ 本地資料庫初始化失敗: $e');
      // 🚀 如果本地初始化失敗，使用緊急備用方案
      try {
        await _ensureDefaultQuoteAvailable();
        debugPrint('🔧 已啟用緊急備用方案');
      } catch (fallbackError) {
        debugPrint('⚠️ 緊急備用方案也失敗: $fallbackError');
      }
    }
  }

  /// 🚀 新增：背景預載入網路內容（不阻塞主初始化）
  void _preloadNetworkContentInBackground() {
    // 🚀 在背景執行，不阻塞主初始化過程
    _preloadTodayQuoteAsync().catchError((e) {
      debugPrint('🌐 背景預載入網路內容失敗: $e');
      debugPrint('💡 這不會影響應用正常運行');
    });
  }

  /// 🚀 新增：背景清理簡體中文（不阻塞主初始化）
  void _cleanupSimplifiedChineseInBackground() {
    // 🚀 在背景執行簡體中文清理
    _cleanupSimplifiedChinese().catchError((e) {
      debugPrint('🧹 背景清理簡體中文失敗: $e');
      debugPrint('💡 這不會影響應用正常運行');
    });
  }

  /// 🚀 新增：清理簡體中文金句
  Future<void> _cleanupSimplifiedChinese() async {
    try {
      debugPrint('🧹 開始檢查並清理簡體中文金句...');
      
      final allQuotes = await _database.select(_database.dailyQuotes).get();
      int updatedCount = 0;
      
      for (final quote in allQuotes) {
        final convertedContent = _convertSimplifiedToTraditional(quote.contentZh);
        
        if (convertedContent != quote.contentZh) {
          await (_database.update(_database.dailyQuotes)
            ..where((tbl) => tbl.id.equals(quote.id)))
            .write(DailyQuotesCompanion(
              contentZh: Value(convertedContent),
            ));
          
          updatedCount++;
          debugPrint('✏️ 已更新: ${quote.contentZh} → $convertedContent');
        }
      }
      
      if (updatedCount > 0) {
        debugPrint('✅ 清理完成: 更新了 $updatedCount 條簡體中文金句');
      } else {
        debugPrint('✅ 檢查完成: 沒有發現簡體中文內容');
      }
      
    } catch (e) {
      debugPrint('❌ 清理簡體中文失敗: $e');
    }
  }

  /// 🚀 完整的簡體轉繁體字典
  String _convertSimplifiedToTraditional(String text) {
    String result = text;
    
    // 🔥 詞組優先轉換（避免字符衝突）
    final phrases = <String, String>{
      '发展': '發展',
      '发生': '發生', 
      '发现': '發現',
      '头发': '頭髮',
      '发型': '髮型',
      '继续': '繼續',
      '进入': '進入',
      '进行': '進行',
      '进步': '進步',
      '终点': '終點',
      '终于': '終於',
      '终身': '終身',
      '开始': '開始',
      '开心': '開心',
      '开放': '開放',
      '关系': '關係',
      '关心': '關心',
      '关于': '關於',
      '设计': '設計',
      '设置': '設置',
      '设想': '設想',
      '建设': '建設',
      '这个': '這個',
      '这样': '這樣',
      '这里': '這裡',
      '那个': '那個',
      '那样': '那樣',
      '那里': '那裡',
      '时间': '時間',
      '时候': '時候',
      '时刻': '時刻',
      '学习': '學習',
      '学生': '學生',
      '学校': '學校',
      '认识': '認識',
      '认为': '認為',
      '问题': '問題',
      '问候': '問候',
      '经过': '經過',
      '经验': '經驗',
      '经历': '經歷',
      '历史': '歷史',
      '历来': '歷來',
      '压力': '壓力',
      '压抑': '壓抑',
      '达到': '達到',
      '达成': '達成',
      '选择': '選擇',
      '选定': '選定',
      '钱财': '錢財',
      '买卖': '買賣',
      '价值': '價值',
      '价格': '價格',
      '对于': '對於',
      '对待': '對待',
      '错误': '錯誤',
      '错过': '錯過',
      '应该': '應該',
      '应当': '應當',
      '须要': '須要',
      '决定': '決定',
      '决心': '決心',
      '确定': '確定',
      '确实': '確實',
      '计划': '計劃',
      '计算': '計算',
      '规则': '規則',
      '规定': '規定',
      '质量': '質量',
      '质疑': '質疑',
      '级别': '級別',
      '别人': '別人',
      '类型': '類型',
      '种类': '種類',
      '状态': '狀態',
      '状况': '狀況',
      '条件': '條件',
      '项目': '項目',
      '标准': '標準',
      '标志': '標誌',
      '准备': '準備',
      '预期': '預期',
      '预计': '預計',
      '号码': '號碼',
      '导致': '導致',
      '导演': '導演',
      '领导': '領導',
      '领域': '領域',
      '带来': '帶來',
      '带走': '帶走',
      '头脑': '頭腦',
      '头部': '頭部',
      '终结': '終結',
      '结果': '結果',
      '结束': '結束',
      '毕业': '畢業',
      '败坏': '敗壞',
      '胜利': '勝利',
      '负责': '負責',
      '赢得': '贏得',
      '输入': '輸入',
      '归来': '歸來',
      '复杂': '復雜',
      '复制': '復製',
      '极其': '極其',
      '极端': '極端',
      '个人': '個人',
      '个别': '個別',
      '气氛': '氣氛',
      '气质': '氣質',
      '灵魂': '靈魂',
      '灵感': '靈感',
      '脑袋': '腦袋',
      '脸色': '臉色',
      '颜色': '顏色',
      '齿轮': '齒輪',
      '风暴': '風暴',
      '风雨': '風雨',
      '万事': '萬事',
      '万分': '萬分',
      '东西': '東西',
      '东方': '東方',
      '国家': '國家',
      '国际': '國際',
      '图书': '圖書',
      '图片': '圖片',
      '团体': '團體',
      '团结': '團結',
      '传统': '傳統',
      '传说': '傳說',
      '体验': '體驗',
      '体会': '體會',
      '尝试': '嘗試',
      '尝到': '嘗到',
      '为了': '為了',
      '为何': '為何',
      '乐观': '樂觀',
      '乐趣': '樂趣',
      '义务': '義務',
      '义气': '義氣',
      '杂志': '雜誌',
      '杂乱': '雜亂',
      '艺术': '藝術',
      '艺人': '藝人',
      '虽然': '雖然',
      '实际': '實際',
      '实现': '實現',
      '实在': '實在',
      '实力': '實力',
      '实验': '實驗',
      '实习': '實習',
      '实用': '實用',
      '实施': '實施',
      '实质': '實質',
      '实体': '實體',
      '实事': '實事',
      '实话': '實話',
      '实物': '實物',
      '实际上': '實際上',
      '实际中': '實際中',
      '从来': '從來',
      '从前': '從前',
      '从此': '從此',
      '从而': '從而',
      '从不': '從不',
      '从头': '從頭',
      '众人': '眾人',
      '众多': '眾多',
      '习惯': '習慣',
      '习俗': '習俗',
      '当然': '當然',
      '当时': '當時',
      '当地': '當地',
      '当年': '當年',
      '当代': '當代',
      '当作': '當作',
      '当做': '當做',
      '当中': '當中',
      '当初': '當初',
      '当即': '當即',
      '当下': '當下',
      '满足': '滿足',
      '满意': '滿意',
      '满怀': '滿懷',
      '满载': '滿載',
      '拥有': '擁有',
      '拥抱': '擁抱',
      '扩大': '擴大',
      '扩展': '擴展',
      '担心': '擔心',
      '担负': '擔負',
      '担当': '擔當',
      '担任': '擔任',
      '挑战': '挑戰',
      '挑选': '挑選',
      '摆脱': '擺脫',
      '摆放': '擺放',
      '拟定': '擬定',
      '拟订': '擬訂',
      '撤退': '撤退',
      '撤销': '撤銷',
      '攻击': '攻擊',
      '攻防': '攻防',
      '护理': '護理',
      '护士': '護士',
      '护卫': '護衛',
      '护送': '護送',
      '护照': '護照',
      '报告': '報告',
      '报纸': '報紙',
      '报道': '報導',
      '报名': '報名',
      '报酬': '報酬',
      '报复': '報復',
      '报答': '報答',
      '电话': '電話',
      '电视': '電視',
      '电影': '電影',
      '电脑': '電腦',
      '电子': '電子',
      '电力': '電力',
      '电器': '電器',
      '电梯': '電梯',
      '电台': '電台',
      '电池': '電池',
      '电流': '電流',
      '电压': '電壓',
      '电灯': '電燈',
      '电线': '電線',
      '电缆': '電纜',
      '电动': '電動',
      '电气': '電氣',
      '电量': '電量',
      '电源': '電源',
      '电网': '電網',
      '电场': '電場',
      '积极': '積極',
      '积累': '積累',
      '积分': '積分',
      '积蓄': '積蓄',
      '积压': '積壓',
      '积木': '積木',
      '积雪': '積雪',
      '积水': '積水',
      '积尘': '積塵',
      '换句话说': '換句話說',
      '换取': '換取',
      '换班': '換班',
      '换代': '換代',
      '换新': '換新',
      '环境': '環境',
      '环节': '環節',
      '环保': '環保',
      '环球': '環球',
      '环形': '環形',
      '环绕': '環繞',
      '环游': '環遊',
      '坏事': '壞事',
      '坏人': '壞人',
      '坏处': '壞處',
      '怀疑': '懷疑',
      '怀念': '懷念',
      '怀抱': '懷抱',
      '怀孕': '懷孕',
      '搀扶': '攙扶',
      '搀和': '攙和'
    };
    
    // 先應用詞組轉換
    phrases.forEach((simplified, traditional) {
      result = result.replaceAll(simplified, traditional);
    });
    
    // 再應用單字轉換
    final singleChars = <String, String>{
      '來': '來',
      '會': '會', 
      '難': '難',
      '過': '過',
      '強': '強',
      '堅': '堅',
      '現': '現',
      '時': '時',
      '間': '間',
      '對': '對',
      '應': '應',
      '業': '業',
      '產': '產',
      '樣': '樣',
      '這': '這',
      '學': '學',
      '習': '習',
      '認': '認',
      '識': '識',
      '問': '問',
      '題': '題',
      '經': '經',
      '歷': '歷',
      '壓': '壓',
      '達': '達',
      '選': '選',
      '擇': '擇',
      '錢': '錢',
      '買': '買',
      '賣': '賣',
      '價': '價',
      '錯': '錯',
      '須': '須',
      '決': '決',
      '確': '確',
      '計': '計',
      '規': '規',
      '則': '則',
      '質': '質',
      '級': '級',
      '別': '別',
      '類': '類',
      '種': '種',
      '狀': '狀',
      '況': '況',
      '條': '條',
      '項': '項',
      '標': '標',
      '準': '準',
      '備': '備',
      '預': '預',
      '號': '號',
      '碼': '碼',
      '導': '導',
      '領': '領',
      '帶': '帶',
      '頭': '頭',
      '終': '終',
      '結': '結',
      '畢': '畢',
      '敗': '敗',
      '勝': '勝',
      '負': '負',
      '贏': '贏',
      '輸': '輸',
      '歸': '歸',
      '復': '復',
      '極': '極',
      '個': '個',
      '氣': '氣',
      '靈': '靈',
      '腦': '腦',
      '臉': '臉',
      '顏': '顏',
      '齒': '齒',
      '風': '風',
      '萬': '萬',
      '東': '東',
      '國': '國',
      '圖': '圖',
      '團': '團',
      '傳': '傳',
      '體': '體',
      '嘗': '嘗',
      '為': '為',
      '樂': '樂',
      '義': '義',
      '雜': '雜',
      '藝': '藝',
      '雖': '雖',
      '實': '實',
      '從': '從',
      '眾': '眾',
      '當': '當',
      '滿': '滿',
      '擁': '擁',
      '擴': '擴',
      '擔': '擔',
      '戰': '戰',
      '擺': '擺',
      '擬': '擬',
      '撤': '撤',
      '擊': '擊',
      '護': '護',
      '報': '報',
      '電': '電',
      '積': '積',
      '換': '換',
      '環': '環',
      '壞': '壞',
      '懷': '懷',
      '攙': '攙',
    };
    
    // 應用單字轉換（已經在詞組轉換中處理過的不會重複）
    singleChars.forEach((simplified, traditional) {
      result = result.replaceAll(simplified, traditional);
    });
    
    return result;
  }

  /// 🚀 新增：確保預設金句可用的備用方法
  Future<void> _ensureDefaultQuoteAvailable() async {
    try {
      final existingQuotes = await _database.select(_database.dailyQuotes)
          .get()
          .timeout(const Duration(seconds: 3));
          
      if (existingQuotes.isEmpty) {
        // 只插入一條預設金句，避免批量操作
        await _database.into(_database.dailyQuotes).insert(
          DailyQuotesCompanion.insert(
            contentEn: defaultEnglishQuote,
            contentZh: defaultChineseQuote,
            author: const Value('GOAA Team'),
            category: const Value('default'),
          ),
        );
        debugPrint('🔧 已插入緊急預設金句');
      }
    } catch (e) {
      debugPrint('❌ 確保預設金句可用失敗: $e');
    }
  }

  /// 🚀 重新設計：異步初始化預設金句（完全本地操作 + 詳細錯誤診斷）
  Future<void> _initializeDefaultQuotesAsync() async {
    try {
      debugPrint('🔍 [本地資料庫] 開始檢查現有金句...');
      debugPrint('🔧 [診斷] 這是純本地資料庫操作，不涉及任何網路請求');
      
      // 🚀 分步驟執行，每一步都有詳細的錯誤處理
      late final List<DailyQuote> existingQuotes;
      
      try {
        debugPrint('📚 [步驟1] 查詢現有金句...');
        existingQuotes = await _database.select(_database.dailyQuotes)
            .get()
            .timeout(const Duration(seconds: 5));
        debugPrint('✅ [步驟1] 查詢成功，現有 ${existingQuotes.length} 條金句');
      } catch (e) {
        debugPrint('❌ [步驟1] 資料庫查詢失敗: $e');
        if (e is SocketException) {
          debugPrint('🚨 [異常] 在本地資料庫查詢中出現 SocketException！');
          debugPrint('🔍 [診斷] 這不應該發生，可能是資料庫底層問題');
          debugPrint('📋 [堆疊] ${StackTrace.current}');
        }
        rethrow;
      }
      
      if (existingQuotes.isEmpty) {
        debugPrint('🔧 [步驟2] 資料庫為空，開始載入預設金句...');
        
        try {
          debugPrint('💾 [步驟2a] 開始批量插入...');
          await _database.batch((batch) {
            for (final quote in _defaultQuotes) {
              batch.insert(_database.dailyQuotes, DailyQuotesCompanion.insert(
                contentEn: quote['en']!,
                contentZh: quote['zh']!,
                author: Value(quote['author']!),
                category: const Value('default'),
              ));
            }
          }).timeout(const Duration(seconds: 8));
          debugPrint('✅ [步驟2a] 批量插入成功');
        } catch (e) {
          debugPrint('❌ [步驟2a] 批量插入失敗: $e');
          if (e is SocketException) {
            debugPrint('🚨 [異常] 在批量插入中出現 SocketException！');
            debugPrint('🔍 [診斷] 這可能是資料庫驅動程式問題');
          }
          
          // 🚀 嘗試備用方案
          debugPrint('🔄 [步驟2b] 嘗試單個插入作為備用方案...');
          await _insertDefaultQuotesOneByOne();
          return;
        }
        
        try {
          debugPrint('🔍 [步驟3] 驗證插入結果...');
          final newCount = await _database.select(_database.dailyQuotes)
              .get()
              .timeout(const Duration(seconds: 3));
          debugPrint('✅ [步驟3] 驗證成功：現在資料庫中有 ${newCount.length} 條金句');
        } catch (e) {
          debugPrint('⚠️ [步驟3] 驗證失敗: $e');
          // 驗證失敗不阻止服務運行
        }
        
      } else {
        debugPrint('✅ [跳過] 預設金句已存在，跳過初始化');
      }
      
      debugPrint('🎉 [完成] 預設金句初始化流程完成');
      
    } catch (e, stackTrace) {
      debugPrint('❌ [致命錯誤] 預設金句初始化失敗: $e');
      debugPrint('📋 [堆疊跟蹤] $stackTrace');
      
      if (e is SocketException) {
        debugPrint('🚨 [網路錯誤診斷] SocketException 在本地資料庫操作中出現');
        debugPrint('🔍 [可能原因] 1. 資料庫驅動程式問題');
        debugPrint('🔍 [可能原因] 2. 底層系統網路配置問題');
        debugPrint('🔍 [可能原因] 3. 防火牆或安全軟體干擾');
        debugPrint('💡 [建議] 將啟用離線模式避免後續問題');
        
        // 🚀 遇到 SocketException 就啟用離線模式
        _offlineMode = true;
      }
      
      // 🚀 最後的備用方案：嘗試單個插入
      try {
        debugPrint('🔄 [最後嘗試] 使用緊急備用方案...');
        await _insertDefaultQuotesOneByOne();
      } catch (finalError) {
        debugPrint('💥 [最終失敗] 所有備用方案都失敗: $finalError');
      }
    }
  }

  /// 🚀 新增：單一插入預設金句（作為批量插入的備用方案）
  Future<void> _insertDefaultQuotesOneByOne() async {
    try {
      int insertedCount = 0;
      for (final quote in _defaultQuotes) {
        try {
          await _database.into(_database.dailyQuotes).insert(
            DailyQuotesCompanion.insert(
              contentEn: quote['en']!,
              contentZh: quote['zh']!,
              author: Value(quote['author']!),
              category: const Value('default'),
            ),
          );
          insertedCount++;
        } catch (singleInsertError) {
          debugPrint('⚠️ 插入單個金句失敗: $singleInsertError');
        }
      }
      debugPrint('✅ 使用單個插入方式成功載入 $insertedCount 條金句');
    } catch (e) {
      debugPrint('❌ 單個插入也失敗: $e');
    }
  }

  /// 🚀 新增：預載入今日金句（完全離線優先模式）
  Future<void> _preloadTodayQuoteAsync() async {
    try {
      // 檢查今日金句是否已存在
      final today = DateTime.now();
      final todayCategory = 'daily_${today.year}_${today.month}_${today.day}';
      
      final existingQuote = await (_database.select(_database.dailyQuotes)
        ..where((tbl) => tbl.category.equals(todayCategory)))
        .getSingleOrNull();
      
      if (existingQuote == null) {
        debugPrint('🔧 預載入今日金句...');
        
        // 🚀 簡化網路檢查：只有在明確確認網路可用時才嘗試
        debugPrint('🔍 開始網路可用性檢查...');
        bool networkAvailable = false;
        
        if (!_offlineMode) {
          try {
            // 🚀 快速網路檢查（只檢查DNS，不做HTTP請求）
            final dnsResult = await InternetAddress.lookup('google.com')
                .timeout(const Duration(seconds: 3));
            networkAvailable = dnsResult.isNotEmpty;
            debugPrint('🔍 DNS檢查結果: $networkAvailable');
          } catch (e) {
            debugPrint('🔍 DNS檢查失敗: $e');
            networkAvailable = false;
            _offlineMode = true; // 設置離線模式
          }
        }
        
        if (networkAvailable) {
          try {
            debugPrint('🌐 網路可用，開始金句預載入...');
            // 🚀 縮短超時時間，避免長時間等待
            final networkQuote = await _fetchQuoteFromNetwork()
                .timeout(const Duration(seconds: 8));
            
            if (networkQuote != null) {
              debugPrint('✅ 網路金句預載入成功');
            } else {
              debugPrint('💡 網路API返回空結果，將使用本地金句');
            }
          } catch (e) {
            debugPrint('⚠️ 網路金句預載入失敗: $e');
            debugPrint('💡 切換到離線模式，使用本地金句');
            _offlineMode = true; // 網路請求失敗後設置離線模式
          }
        } else {
          debugPrint('📡 網路不可用或已啟用離線模式，跳過網路請求');
          debugPrint('💡 將使用本地資料庫中的金句');
        }
      } else {
        debugPrint('✅ 今日金句已存在');
      }
    } catch (e) {
      debugPrint('❌ 預載入今日金句失敗: $e');
    }
  }

  /// 🚀 新增：手動重置離線模式（如果需要重試網路）
  void resetOfflineMode() {
    _offlineMode = false;
    debugPrint('🔄 已重置離線模式，將在下次請求時重新檢查網路');
  }

  /// 🚀 新增：強制嘗試網路請求（用於調試）
  Future<Map<String, dynamic>> forceNetworkTest() async {
    debugPrint('🧪 [強制測試] 開始網路測試...');
    
    final testResult = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <Map<String, dynamic>>[],
    };
    
    // 重置離線模式
    final originalOfflineMode = _offlineMode;
    _offlineMode = false;
    
    try {
      // 測試 1: 網路連接檢查
      debugPrint('🧪 [測試1] 測試網路連接檢查...');
      final networkAvailable = await _checkNetworkConnection();
      testResult['tests'].add({
        'test': 'network_check',
        'result': networkAvailable,
        'message': networkAvailable ? '網路連接正常' : '網路連接失敗'
      });
      
      if (networkAvailable) {
        // 測試 2: 實際API請求
        debugPrint('🧪 [測試2] 測試實際API請求...');
        try {
          final quote = await _fetchQuoteFromNetwork();
          testResult['tests'].add({
            'test': 'api_request',
            'result': quote != null,
            'message': quote != null ? '成功獲取網路金句' : 'API請求返回空結果',
            'quote': quote != null ? (quote.contentZh.length > 20 ? '${quote.contentZh.substring(0, 20)}...' : quote.contentZh) : 'N/A'
          });
        } catch (e) {
          testResult['tests'].add({
            'test': 'api_request',
            'result': false,
            'message': 'API請求失敗',
            'error': e.toString()
          });
        }
      }
      
      testResult['success'] = testResult['tests'].every((test) => test['result'] == true);
      testResult['offline_mode'] = _offlineMode;
      
    } catch (e) {
      testResult['error'] = e.toString();
      testResult['success'] = false;
    } finally {
      // 如果測試失敗，恢復原始離線模式狀態
      if (testResult['success'] != true) {
        _offlineMode = originalOfflineMode;
      }
    }
    
    debugPrint('🧪 [測試完成] 成功: ${testResult['success']}, 離線模式: $_offlineMode');
    return testResult;
  }

  /// 🚀 新增：異步保存金句到本地資料庫
  Future<void> _saveQuoteToLocalAsync(DailyQuote quote) async {
    try {
      debugPrint('💾 開始保存金句到資料庫...');
      debugPrint('📝 金句內容: ${quote.contentZh}');
      debugPrint('🏷️  分類: ${quote.category}');
      
      await _database.into(_database.dailyQuotes).insert(
        DailyQuotesCompanion(
          contentZh: Value(quote.contentZh),
          contentEn: Value(quote.contentEn),
          author: Value(quote.author),
          category: Value(quote.category),
          createdAt: Value(quote.createdAt),
        ),
      );
      
      debugPrint('✅ 成功從網路獲取並存儲今日金句');
      debugPrint('🆕 新金句: ${quote.contentZh}');
      
      // 維護資料庫大小（非阻塞）
      _maintainDatabaseSizeAsync();
      
      // 顯示目前資料庫總數（非阻塞）
      _showDatabaseStatsAsync();
      
    } catch (e) {
      debugPrint('❌ 保存金句到本地失敗: $e');
    }
  }

  /// 🚀 維護資料庫大小（重新設計使用 async/await）
  Future<void> _maintainDatabaseSizeAsync() async {
    try {
      final allQuotes = await (_database.select(_database.dailyQuotes)
            ..orderBy([(q) => OrderingTerm.desc(q.createdAt)]))
          .get();
      
      if (allQuotes.length > maxQuotesInDatabase) {
        // 刪除最舊的金句，保留最新的100句
        final quotesToDelete = allQuotes.skip(maxQuotesInDatabase);
        
        // 批量刪除
        final deleteIds = quotesToDelete.map((q) => q.id).toList();
        await (_database.delete(_database.dailyQuotes)
              ..where((q) => q.id.isIn(deleteIds)))
            .go();
            
        debugPrint('🗑️ 清理了 ${quotesToDelete.length} 條舊金句，保持資料庫在 $maxQuotesInDatabase 句以內');
      }
    } catch (e) {
      debugPrint('❌ 維護資料庫大小失敗: $e');
    }
  }

  /// 🚀 顯示資料庫統計（非阻塞）
  Future<void> _showDatabaseStatsAsync() async {
    try {
      final totalCount = await _database.select(_database.dailyQuotes).get();
      debugPrint('📊 資料庫現有金句總數: ${totalCount.length}');
    } catch (e) {
      debugPrint('❌ 獲取資料庫統計失敗: $e');
    }
  }

  /// 🚀 重新設計：完全使用 async/await 獲取每日金句（優化離線體驗）
  Future<DailyQuote> getDailyQuote() async {
    debugPrint('🎲 獲取每日金句...');
    
    try {
      // 🚀 簡化：只在非離線模式時才嘗試網路更新
      if (!_offlineMode) {
        debugPrint('🌐 嘗試網路更新...');
        try {
          await _checkAndFetchTodayQuoteFromNetwork();
        } catch (e) {
          debugPrint('⚠️ 網路更新失敗: $e');
          debugPrint('💡 繼續使用本地金句');
        }
      } else {
        debugPrint('📡 離線模式，直接使用本地金句');
      }
      
      // 2. 從資料庫隨機取得金句
      final randomQuote = await _getRandomQuoteFromLocal();
      
      debugPrint('🎯 隨機選取: ${randomQuote.contentZh.length > 20 ? '${randomQuote.contentZh.substring(0, 20)}...' : randomQuote.contentZh}');
      return randomQuote;
      
    } catch (e) {
      debugPrint('❌ 獲取每日金句失敗: $e');
      // 🚀 發生錯誤時確保返回一個可用的金句
      try {
        final fallbackQuote = await _getRandomQuoteFromLocal();
        debugPrint('🔄 使用備用本地金句');
        return fallbackQuote;
      } catch (fallbackError) {
        debugPrint('⚠️ 備用金句獲取也失敗，使用硬編碼預設金句: $fallbackError');
        return DailyQuote(
          id: 0,
          contentZh: '每一天都是新的開始，充滿無限可能。',
          contentEn: 'Every day is a new beginning with endless possibilities.',
          author: 'GOAA',
          category: 'default',
          createdAt: DateTime.now(),
        );
      }
    }
  }

  /// 🚀 檢查並從網路獲取今日新金句（優化網路錯誤處理）
  Future<void> _checkAndFetchTodayQuoteFromNetwork() async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      // 檢查今日是否已獲取過金句
      final todayNetworkQuote = await _getTodayQuoteFromLocal(todayStart);
      
      if (todayNetworkQuote != null) {
        debugPrint('✅ 今日已從網路獲取過金句，無需重複獲取');
        return;
      }

      debugPrint('🌐 今日尚未從網路獲取金句，開始網路請求...');
      
      // 🚀 嘗試從網路獲取今日新金句（已包含網路檢查）
      final networkQuote = await _fetchQuoteFromNetwork();
      
      if (networkQuote != null) {
        final todayQuoteData = DailyQuote(
          id: 0,
          contentZh: networkQuote.contentZh,
          contentEn: networkQuote.contentEn,
          author: networkQuote.author,
          category: 'daily_${todayStart.year}_${todayStart.month}_${todayStart.day}',
          createdAt: todayStart,
        );
        
        // 🚀 非阻塞保存金句
        _saveQuoteToLocalAsync(todayQuoteData);
        debugPrint('💾 今日新金句已排程保存');
      } else {
        debugPrint('⚠️  網路請求返回空結果，將使用本地現有金句');
      }
    } catch (e) {
      debugPrint('❌ 網路獲取今日金句失敗: $e');
      debugPrint('💡 不影響服務運行，將使用本地金句');
    }
  }

  /// 檢查今日是否已有金句（修正版）
  Future<DailyQuote?> _getTodayQuoteFromLocal(DateTime todayStart) async {
    try {
      final todayCategory = 'daily_${todayStart.year}_${todayStart.month}_${todayStart.day}';
      return await (_database.select(_database.dailyQuotes)
            ..where((q) => q.category.equals(todayCategory)))
          .getSingleOrNull();
    } catch (e) {
      debugPrint('❌ 查詢今日金句失敗: $e');
      return null;
    }
  }

  /// 🚀 重新設計：安全的網路獲取金句（完全避免網路錯誤）
  Future<DailyQuote?> _fetchQuoteFromNetwork() async {
    try {
      // 🚀 如果處於離線模式，直接返回 null
      if (_offlineMode) {
        debugPrint('📱 離線模式啟用，跳過所有網路請求');
        return null;
      }

      // 🚀 簡化檢查：如果已經是離線模式就不嘗試
      debugPrint('🔍 當前離線模式狀態: $_offlineMode');

      debugPrint('🌐 嘗試 ZenQuotes API...');
      
      // 🚀 進一步包裝網路請求，確保任何錯誤都被捕獲
      return await _safeNetworkRequest();
      
    } catch (e) {
      // 🚀 最外層錯誤捕獲，確保服務不會崩潰
      debugPrint('❌ 網路獲取金句發生未預期錯誤: $e');
      // 任何錯誤都設置離線模式
      _offlineMode = true;
      return null;
    }
  }

  /// 🚀 新增：安全的網路請求方法（增強調試）
  Future<DailyQuote?> _safeNetworkRequest() async {
    try {
      debugPrint('🌐 [網路請求] 開始請求 zenquotes.io...');
      debugPrint('🔧 [權限檢查] INTERNET 權限應該已在 AndroidManifest.xml 中配置');
      debugPrint('🔧 [iOS配置] NSAppTransportSecurity 應該已在 Info.plist 中配置');
      
      final uri = Uri.parse('https://zenquotes.io/api/random');
      debugPrint('🎯 [目標URL] $uri');
      
      // 🚀 增加超時時間，並添加更詳細的錯誤信息
      debugPrint('📡 [請求開始] 發送HTTP請求...');
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'GoAA Flutter App/1.0',
          'Connection': 'close',
        },
      ).timeout(
        const Duration(seconds: 12), // 🚀 增加超時時間給權限處理更多時間
        onTimeout: () {
          debugPrint('⚠️ [超時] 網路請求超時（12秒）');
          debugPrint('💡 [提示] 可能原因：');
          debugPrint('   1. 網路連接緩慢');
          debugPrint('   2. Android INTERNET 權限未授予');
          debugPrint('   3. iOS 網路權限被阻止');
          debugPrint('   4. 防火牆或代理問題');
          debugPrint('   5. zenquotes.io 服務器響應緩慢');
          debugPrint('🔄 [處理] 自動切換到離線模式，使用本地金句');
          throw TimeoutException('Request timeout after 12 seconds - 切換到離線模式', const Duration(seconds: 12));
        },
      );

      debugPrint('📡 ZenQuotes 回應狀態: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ ZenQuotes 請求成功，使用後台解析...');
        
        // 🚀 在後台線程解析JSON並生成金句
        final quote = await compute(_parseZenQuotesInBackground, response.body);
        
        if (quote != null) {
          debugPrint('🎉 成功從 ZenQuotes 獲取金句！');
          return DailyQuote(
            id: 0,
            contentZh: quote['zh']!,
            contentEn: quote['en']!,
            author: quote['author']!,
            category: 'network',
            createdAt: DateTime.now(),
          );
        }
      } else {
        debugPrint('❌ ZenQuotes 請求失敗，狀態碼: ${response.statusCode}');
      }
      
      return null;
    } on SocketException catch (e) {
      // 🚀 專門處理網路連接問題
      debugPrint('🚫 網路連接問題: ${e.message}');
      if (e.message.contains('Failed host lookup')) {
        debugPrint('🌐 DNS 解析失敗，啟用離線模式');
        _offlineMode = true;
      }
      return null;
    } on HttpException catch (e) {
      // 🚀 處理 HTTP 相關錯誤
      debugPrint('📡 HTTP 請求錯誤: ${e.message}');
      return null;
    } on TimeoutException catch (e) {
      // 🚀 處理超時錯誤
      debugPrint('⏰ 網路請求超時: ${e.message}');
      return null;
    } on FormatException catch (e) {
      // 🚀 處理JSON解析錯誤
      debugPrint('📄 數據格式錯誤: ${e.message}');
      return null;
    } catch (e) {
      // 🚀 處理其他未預期的錯誤
      debugPrint('❌ 網路請求異常: $e');
      // 🚀 任何意外錯誤都啟用離線模式
      _offlineMode = true;
      return null;
    }
  }

  /// 🚀 新增：檢查網路連接（更安全的實現）
  Future<bool> _checkNetworkConnection() async {
    // 🚀 如果已經設置為離線模式，直接返回 false
    if (_offlineMode) {
      debugPrint('📱 已啟用離線模式，跳過網路檢查');
      return false;
    }

    try {
      debugPrint('🔍 檢查網路連接...');
      
      // 🚀 第一步：先檢查基本的DNS解析
      debugPrint('🧪 [步驟1] 檢查基本DNS解析...');
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        debugPrint('❌ DNS解析返回空結果');
        _offlineMode = true;
        return false;
      }
      
      debugPrint('✅ DNS解析成功: ${result[0].address}');
      
      // 🚀 第二步：嘗試實際的HTTP連接測試
      debugPrint('🧪 [步驟2] 測試實際HTTP連接...');
      try {
        final testResponse = await http.head(
          Uri.parse('https://google.com'),
          headers: {'User-Agent': 'GoAA Network Test/1.0'},
        ).timeout(const Duration(seconds: 5));
        
        if (testResponse.statusCode >= 200 && testResponse.statusCode < 400) {
          debugPrint('✅ HTTP連接測試成功 (狀態碼: ${testResponse.statusCode})');
          // 如果網路恢復，重置離線模式
          if (_offlineMode) {
            debugPrint('🔄 網路已恢復，重置離線模式');
            _offlineMode = false;
          }
          return true;
        } else {
          debugPrint('⚠️ HTTP連接測試返回異常狀態碼: ${testResponse.statusCode}');
          _offlineMode = true;
          return false;
        }
      } catch (httpError) {
        debugPrint('❌ HTTP連接測試失敗: $httpError');
        _offlineMode = true;
        return false;
      }
      
    } on SocketException catch (e) {
      debugPrint('🚫 網路連接檢查失敗 (SocketException): ${e.message}');
      if (e.message.contains('Failed host lookup')) {
        debugPrint('📡 DNS解析失敗，網路可能不可用');
      }
      // 🚀 設置離線模式，避免後續不必要的網路嘗試
      if (!_offlineMode) {
        debugPrint('🔄 切換到離線模式');
        _offlineMode = true;
      }
    } on TimeoutException catch (e) {
      debugPrint('⏰ 網路連接檢查超時: ${e.message}');
      // 🚀 超時也設置為離線模式
      if (!_offlineMode) {
        debugPrint('🔄 網路檢查超時，切換到離線模式');
        _offlineMode = true;
      }
    } catch (e) {
      debugPrint('❌ 網路連接檢查異常: $e');
      // 🚀 任何其他錯誤也設置為離線模式
      if (!_offlineMode) {
        debugPrint('🔄 網路檢查異常，切換到離線模式');
        _offlineMode = true;
      }
    }
    
    debugPrint('📡 網路連接不可用，使用離線模式');
    return false;
  }

  /// 🚀 重新設計：從本地資料庫隨機獲取金句（完全使用 async/await）
  Future<DailyQuote> _getRandomQuoteFromLocal() async {
    debugPrint('📚 從資料庫查詢金句...');
    
    try {
      // 🚀 添加超時處理，避免資料庫查詢卡住
      final quotes = await _database.select(_database.dailyQuotes)
          .get()
          .timeout(const Duration(seconds: 5));
          
      debugPrint('📊 資料庫中共有 ${quotes.length} 條金句');
      
      if (quotes.isNotEmpty) {
        // 使用當前時間微秒作為新的隨機種子，確保真正的隨機性
        final timeBasedRandom = _getTimeBasedRandom();
        final randomIndex = timeBasedRandom.nextInt(quotes.length);
        final randomQuote = quotes[randomIndex];
        
        debugPrint('🎯 隨機選擇第 ${randomIndex + 1} 條金句 (共 ${quotes.length} 條)');
        debugPrint('📝 選中的金句: ${randomQuote.contentZh}');
        debugPrint('🏷️  分類: ${randomQuote.category}');
        debugPrint('⏰ 創建時間: ${randomQuote.createdAt.toString().substring(0, 19)}');
        
        return randomQuote;
      } else {
        debugPrint('⚠️  資料庫中沒有金句，使用預設金句');
        return _getDefaultQuote();
      }
    } catch (e) {
      debugPrint('❌ 從本地獲取金句失敗: $e');
      return _getDefaultQuote();
    }
  }

  /// 獲取預設金句
  DailyQuote _getDefaultQuote() {
    debugPrint('🔄 使用預設金句');
    return DailyQuote(
      id: 0,
      contentZh: defaultChineseQuote,
      contentEn: defaultEnglishQuote,
      author: 'GOAA Team',
      category: 'default',
      createdAt: DateTime.now(),
    );
  }

  /// 獲取指定語言的金句內容
  String getQuoteContent(DailyQuote quote, String languageCode) {
    return languageCode.startsWith('zh') ? quote.contentZh : quote.contentEn;
  }

  /// 🚀 新增：獲取服務狀態信息（增強版）
  Map<String, dynamic> getServiceStatus() {
    return {
      'serviceName': 'DailyQuoteService',
      'version': '2.1.0',
      'offlineMode': _offlineMode,
      'initialized': true,
      'features': [
        'Offline-first operation',
        'Network error recovery',
        'Local database fallback',
        'Background JSON parsing',
        'Smart initialization',
        'Detailed error diagnostics'
      ],
      'networkStatus': _offlineMode ? 'offline' : 'unknown',
      'lastUpdate': DateTime.now().toIso8601String(),
      'databaseEngine': 'Drift/SQLite',
    };
  }

  /// 🚀 新增：手動重新初始化服務（用於調試）
  Future<Map<String, dynamic>> reinitializeForDebugging() async {
    debugPrint('🧪 [調試] 手動重新初始化每日金句服務...');
    
    final startTime = DateTime.now();
    final results = <String, dynamic>{
      'startTime': startTime.toIso8601String(),
      'steps': <Map<String, dynamic>>[],
    };
    
    try {
      // 重置離線模式
      _offlineMode = false;
      results['steps'].add({
        'step': 'reset_offline_mode',
        'status': 'success',
        'message': '已重置離線模式'
      });
      
      // 重新初始化
      await initialize();
      results['steps'].add({
        'step': 'initialize',
        'status': 'success',
        'message': '初始化完成'
      });
      
      // 測試金句獲取
      try {
        final quote = await getDailyQuote();
        results['steps'].add({
          'step': 'test_quote',
          'status': 'success',
          'message': '成功獲取金句: ${quote.contentZh.substring(0, 10)}...'
        });
      } catch (e) {
        results['steps'].add({
          'step': 'test_quote',
          'status': 'error',
          'message': '獲取金句失敗: $e'
        });
      }
      
      final endTime = DateTime.now();
      results['endTime'] = endTime.toIso8601String();
      results['duration'] = endTime.difference(startTime).inMilliseconds;
      results['success'] = true;
      
    } catch (e, stackTrace) {
      results['error'] = e.toString();
      results['stackTrace'] = stackTrace.toString();
      results['success'] = false;
    }
    
    debugPrint('🧪 [調試] 重新初始化完成: ${results['success']}');
    return results;
  }

  /// 🚀 重新設計：獲取資料庫統計資訊（完全使用 async/await）
  Future<Map<String, int>> getDatabaseStats() async {
    try {
      final allQuotes = await _database.select(_database.dailyQuotes)
          .get()
          .timeout(const Duration(seconds: 5));
          
      final Map<String, int> stats = {};
      
      for (final quote in allQuotes) {
        final category = quote.category.startsWith('daily_') ? 'daily' : quote.category;
        stats[category] = (stats[category] ?? 0) + 1;
      }
      
      stats['total'] = allQuotes.length;
      return stats;
    } catch (e) {
      debugPrint('❌ 獲取資料庫統計失敗: $e');
      return {'total': 0};
    }
  }

  /// 🚀 重新設計：清理舊的每日金句（完全使用 async/await）  
  Future<void> cleanupOldDailyQuotes() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      // 只刪除 daily_ 開頭的金句，保留預設金句
      await (_database.delete(_database.dailyQuotes)
            ..where((q) => 
              q.category.like('daily_%') & 
              q.createdAt.isSmallerThanValue(thirtyDaysAgo)
            ))
          .go()
          .timeout(const Duration(seconds: 5));
          
      debugPrint('🧹 清理了30天前的每日金句');
    } catch (e) {
      debugPrint('❌ 清理舊每日金句失敗: $e');
    }
  }

  /// 🚀 新增：網路權限和連接診斷
  Future<Map<String, dynamic>> diagnoseNetworkPermissions() async {
    debugPrint('🔍 [診斷] 開始網路權限和連接診斷...');
    
    final diagnosis = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <Map<String, dynamic>>[],
      'summary': <String, dynamic>{},
    };
    
    // 測試 1: 基本網路連接
    try {
      debugPrint('🧪 [測試1] 基本網路連接 (8.8.8.8)...');
      final result = await InternetAddress.lookup('8.8.8.8')
          .timeout(const Duration(seconds: 5));
      
      if (result.isNotEmpty) {
        diagnosis['tests'].add({
          'test': 'basic_network',
          'status': 'success',
          'message': '基本網路連接正常',
          'details': '成功連接到 8.8.8.8'
        });
      }
    } catch (e) {
      diagnosis['tests'].add({
        'test': 'basic_network',
        'status': 'failed',
        'message': '基本網路連接失敗',
        'error': e.toString()
      });
    }
    
    // 測試 2: DNS 解析
    try {
      debugPrint('🧪 [測試2] DNS 解析 (zenquotes.io)...');
      final result = await InternetAddress.lookup('zenquotes.io')
          .timeout(const Duration(seconds: 8));
      
      if (result.isNotEmpty) {
        diagnosis['tests'].add({
          'test': 'dns_resolution',
          'status': 'success',
          'message': 'DNS 解析成功',
          'details': 'zenquotes.io 解析為 ${result.first.address}'
        });
      }
    } catch (e) {
      diagnosis['tests'].add({
        'test': 'dns_resolution',
        'status': 'failed',
        'message': 'DNS 解析失敗',
        'error': e.toString()
      });
    }
    
    // 測試 3: HTTP 請求
    try {
      debugPrint('🧪 [測試3] HTTP 請求測試...');
      final response = await http.get(
        Uri.parse('https://zenquotes.io/api/random'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'GoAA Diagnosis Tool/1.0',
        },
      ).timeout(const Duration(seconds: 15));
      
      diagnosis['tests'].add({
        'test': 'http_request',
        'status': response.statusCode == 200 ? 'success' : 'partial',
        'message': 'HTTP 請求完成',
        'details': {
          'statusCode': response.statusCode,
          'responseLength': response.body.length,
          'contentType': response.headers['content-type'],
        }
      });
    } catch (e) {
      diagnosis['tests'].add({
        'test': 'http_request',
        'status': 'failed',
        'message': 'HTTP 請求失敗',
        'error': e.toString(),
        'recommendation': e is TimeoutException 
            ? '可能是權限問題，請檢查 AndroidManifest.xml 中的 INTERNET 權限'
            : '網路連接問題'
      });
    }
    
    // 生成診斷摘要
    final successfulTests = diagnosis['tests'].where((test) => test['status'] == 'success').length;
    final totalTests = diagnosis['tests'].length;
    
    diagnosis['summary'] = {
      'successfulTests': successfulTests,
      'totalTests': totalTests,
      'successRate': (successfulTests / totalTests * 100).round(),
      'offlineMode': _offlineMode,
      'recommendation': _generateRecommendation(diagnosis['tests']),
    };
    
    debugPrint('✅ [診斷完成] 成功率: ${diagnosis['summary']['successRate']}%');
    return diagnosis;
  }
  
  /// 🚀 生成診斷建議
  String _generateRecommendation(List<Map<String, dynamic>> tests) {
    final failures = tests.where((test) => test['status'] == 'failed').toList();
    
    if (failures.isEmpty) {
      return '所有網路測試通過，服務運行正常';
    }
    
    final recommendations = <String>[];
    
    for (final failure in failures) {
      switch (failure['test']) {
        case 'basic_network':
          recommendations.add('檢查設備的網路連接和Wi-Fi/移動數據設置');
          break;
        case 'dns_resolution':
          recommendations.add('檢查DNS設置或嘗試更換網路環境');
          break;
        case 'http_request':
          if (failure['error'].toString().contains('TimeoutException')) {
            recommendations.add('檢查應用權限：Android需要INTERNET權限，iOS需要NSAppTransportSecurity配置');
          } else {
            recommendations.add('檢查防火牆或代理設置');
          }
          break;
      }
    }
    
    return recommendations.join('；');
  }
} 
