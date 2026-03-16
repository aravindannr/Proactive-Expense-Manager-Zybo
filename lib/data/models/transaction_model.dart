import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final double amount;
  final String note;
  final String type; // 'credit' or 'debit'
  final String categoryId;
  final String? categoryName; // populated via JOIN
  final String timestamp;
  final int isSynced;
  final int isDeleted;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    this.categoryName,
    required this.timestamp,
    this.isSynced = 0,
    this.isDeleted = 0,
  });

  bool get isExpense => type == 'debit';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type,
      'category_id': categoryId,
      'timestamp': timestamp,
      'is_synced': isSynced,
      'is_deleted': isDeleted,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String? ?? '',
      type: map['type'] as String,
      categoryId: map['category_id'] as String? ?? '',
      categoryName: map['category_name'] as String?,
      timestamp: map['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      isSynced: map['is_synced'] as int? ?? 0,
      isDeleted: map['is_deleted'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type,
      'category_id': categoryId,
      'timestamp': timestamp.replaceAll('T', ' ').split('.').first,
    };
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? note,
    String? type,
    String? categoryId,
    String? categoryName,
    String? timestamp,
    int? isSynced,
    int? isDeleted,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [id, amount, note, type, categoryId, categoryName, timestamp, isSynced, isDeleted];
}
