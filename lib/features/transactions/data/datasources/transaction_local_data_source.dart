import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> cacheTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<List<CategoryModel>> getCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final Box<TransactionModel> transactionBox;
  final Box<CategoryModel> categoryBox;

  TransactionLocalDataSourceImpl({
    required this.transactionBox,
    required this.categoryBox,
  });

  @override
  Future<List<TransactionModel>> getTransactions() {
    return Future.value(transactionBox.values.toList());
  }

  @override
  Future<void> cacheTransaction(TransactionModel transaction) {
    return transactionBox.put(transaction.hiveId, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) {
    return transactionBox.delete(id);
  }

  @override
  Future<void> addCategory(CategoryModel category) {
    return categoryBox.put(category.hiveId, category);
  }

  @override
  Future<void> deleteCategory(String id) {
    return categoryBox.delete(id);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final settingsBox = Hive.box('settings');
    final hasSeeded = settingsBox.get('seededCategoriesV2', defaultValue: false);

    if (!hasSeeded) {
      // Seed initial categories with pastel colors only once
      final initialCategories = [
        const CategoryModel(hiveId: '1', hiveName: 'Food', hiveIconFolder: 'fastfood', hiveColorValue: 0xFFFFE0B2), 
        const CategoryModel(hiveId: '2', hiveName: 'Transport', hiveIconFolder: 'directions_car', hiveColorValue: 0xFFBBDEFB), 
        const CategoryModel(hiveId: '3', hiveName: 'Entertainment', hiveIconFolder: 'movie', hiveColorValue: 0xFFE1BEE7), 
        const CategoryModel(hiveId: '4', hiveName: 'Shopping', hiveIconFolder: 'shopping_cart', hiveColorValue: 0xFFB2EBF2), 
        const CategoryModel(hiveId: '5', hiveName: 'Salary', hiveIconFolder: 'attach_money', hiveColorValue: 0xFFDCEDC8), 
        const CategoryModel(hiveId: '6', hiveName: 'Rent', hiveIconFolder: 'home', hiveColorValue: 0xFFFFCC80), 
        const CategoryModel(hiveId: '7', hiveName: 'Internet', hiveIconFolder: 'wifi', hiveColorValue: 0xFFB2DFDB), 
      ];
      for (var cat in initialCategories) {
        if (!categoryBox.containsKey(cat.hiveId)) {
          await categoryBox.put(cat.hiveId, cat);
        }
      }
      await settingsBox.put('seededCategoriesV2', true);
    }

    return Future.value(categoryBox.values.toList());
  }
}
