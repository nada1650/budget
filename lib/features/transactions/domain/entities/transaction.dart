import 'package:equatable/equatable.dart';
import 'category.dart';

enum TransactionType { income, expense }

class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;
  final String? note;
  final bool isRecurring;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.note,
    this.isRecurring = false,
  });

  @override
  List<Object?> get props => [id, amount, date, type, category, note, isRecurring];
}
