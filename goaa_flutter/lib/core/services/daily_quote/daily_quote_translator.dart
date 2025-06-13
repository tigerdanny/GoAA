/// 每日金句翻譯服務
class DailyQuoteTranslator {
  static final DailyQuoteTranslator _instance = DailyQuoteTranslator._internal();
  factory DailyQuoteTranslator() => _instance;
  
  DailyQuoteTranslator._internal();

  /// 獲取中文翻譯
  static String getChineseTranslation(String englishContent) {
    const translations = [
      '成功來自堅持不懈的努力。',
      '相信自己，你能做到。',
      '每一天都是新的機會。',
      '困難會過去，美好會到來。',
      '保持積極，迎接挑戰。',
      '勇敢面對，無所畏懼。',
      '夢想在前，勇敢前行。',
      '堅持努力，成就未來。'
    ];
    
    return translations[englishContent.length % translations.length];
  }

  static String toChinese(String english) {
    const translations = [
      '成功來自堅持不懈的努力。',
      '相信自己，你能做到。',
      '每一天都是新的機會。',
      '困難會過去，美好會到來。',
      '保持積極，迎接挑戰。',
      '勇敢面對，無所畏懼。',
      '夢想在前，勇敢前行。',
      '堅持努力，成就未來。'
    ];
    return translations[english.length % translations.length];
  }
} 
