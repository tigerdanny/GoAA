import 'package:drift/drift.dart';
import '../database/database.dart';

/// 每日金句模型
class DailyQuoteModel {
  final int id;
  final String contentZh;
  final String contentEn;
  final String author;
  final String category;
  final DateTime createdAt;

  DailyQuoteModel({
    required this.id,
    required this.contentZh,
    required this.contentEn,
    required this.author,
    required this.category,
    required this.createdAt,
  });

  /// 從 drift 資料庫行創建模型
  factory DailyQuoteModel.fromRow(DailyQuote row) {
    return DailyQuoteModel(
      id: row.id,
      contentZh: row.contentZh,
      contentEn: row.contentEn,
      author: row.author ?? '',
      category: row.category,
      createdAt: row.createdAt,
    );
  }

  /// 轉換為 drift 資料庫行
  DailyQuotesCompanion toCompanion() {
    return DailyQuotesCompanion(
      id: id == 0 ? const Value.absent() : Value(id),
      contentZh: Value(contentZh),
      contentEn: Value(contentEn),
      author: Value(author),
      category: Value(category),
      createdAt: Value(createdAt),
    );
  }

  /// 複製並修改
  DailyQuoteModel copyWith({
    int? id,
    String? contentZh,
    String? contentEn,
    String? author,
    String? category,
    DateTime? createdAt,
  }) {
    return DailyQuoteModel(
      id: id ?? this.id,
      contentZh: contentZh ?? this.contentZh,
      contentEn: contentEn ?? this.contentEn,
      author: author ?? this.author,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 
