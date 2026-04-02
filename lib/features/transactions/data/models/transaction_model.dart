import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';
import 'category_model.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
enum TransactionTypeModel {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 2)
class TransactionModel extends TransactionEntity {
  @HiveField(0)
  final String hiveId;
  @HiveField(1)
  final double hiveAmount;
  @HiveField(2)
  final DateTime hiveDate;
  @HiveField(3)
  final TransactionTypeModel hiveType;
  @HiveField(4)
  final CategoryModel hiveCategory;
  @HiveField(5)
  final String? hiveNote;
  @HiveField(6)
  final bool hiveIsRecurring;

  const TransactionModel({
    required this.hiveId,
    required this.hiveAmount,
    required this.hiveDate,
    required this.hiveType,
    required this.hiveCategory,
    this.hiveNote,
    this.hiveIsRecurring = false,
  }) : super(
          id: hiveId,
          amount: hiveAmount,
          date: hiveDate,
          type: hiveType == TransactionTypeModel.income
              ? TransactionType.income
              : TransactionType.expense,
          category: hiveCategory,
          note: hiveNote,
          isRecurring: hiveIsRecurring,
        );

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      hiveId: entity.id,
      hiveAmount: entity.amount,
      hiveDate: entity.date,
      hiveType: entity.type == TransactionType.income
          ? TransactionTypeModel.income
          : TransactionTypeModel.expense,
      hiveCategory: CategoryModel.fromEntity(entity.category),
      hiveNote: entity.note,
      hiveIsRecurring: entity.isRecurring,
    );
  }
}
