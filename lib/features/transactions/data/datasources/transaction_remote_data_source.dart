import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

abstract class TransactionRemoteDataSource {
  Future<void> syncTransactions(String userId, List<TransactionModel> transactions);
  Future<void> syncCategories(String userId, List<CategoryModel> categories);
  Future<List<TransactionModel>> fetchTransactions(String userId);
  Future<List<CategoryModel>> fetchCategories(String userId);
  Future<void> addTransaction(String userId, TransactionModel transaction);
  Future<void> deleteTransaction(String userId, String transactionId);
  Future<void> addCategory(String userId, CategoryModel category);
  Future<void> deleteCategory(String userId, String categoryId);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore _firestore;

  TransactionRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _userTransactions(String userId) =>
      _firestore.collection('users').doc(userId).collection('transactions');

  CollectionReference _userCategories(String userId) =>
      _firestore.collection('users').doc(userId).collection('categories');

  @override
  Future<void> syncTransactions(String userId, List<TransactionModel> transactions) async {
    final batch = _firestore.batch();
    for (var tx in transactions) {
      batch.set(_userTransactions(userId).doc(tx.id), _transactionToMap(tx));
    }
    await batch.commit();
  }

  @override
  Future<void> syncCategories(String userId, List<CategoryModel> categories) async {
    final batch = _firestore.batch();
    for (var cat in categories) {
      batch.set(_userCategories(userId).doc(cat.id), cat.toJson());
    }
    await batch.commit();
  }

  @override
  Future<List<TransactionModel>> fetchTransactions(String userId) async {
    final snapshot = await _userTransactions(userId).get();
    return snapshot.docs
        .map((doc) => _mapToTransaction(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CategoryModel>> fetchCategories(String userId) async {
    final snapshot = await _userCategories(userId).get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addTransaction(String userId, TransactionModel transaction) async {
    await _userTransactions(userId).doc(transaction.id).set(_transactionToMap(transaction));
  }

  @override
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _userTransactions(userId).doc(transactionId).delete();
  }

  @override
  Future<void> addCategory(String userId, CategoryModel category) async {
    await _userCategories(userId).doc(category.id).set(category.toJson());
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    await _userCategories(userId).doc(categoryId).delete();
  }

  Map<String, dynamic> _transactionToMap(TransactionModel tx) {
    return {
      'id': tx.hiveId,
      'amount': tx.hiveAmount,
      'date': Timestamp.fromDate(tx.hiveDate),
      'type': tx.hiveType.name,
      'category': tx.hiveCategory.toJson(),
      'note': tx.hiveNote,
      'isRecurring': tx.hiveIsRecurring,
    };
  }

  TransactionModel _mapToTransaction(Map<String, dynamic> map) {
    return TransactionModel(
      hiveId: map['id'],
      hiveAmount: (map['amount'] as num).toDouble(),
      hiveDate: (map['date'] as Timestamp).toDate(),
      hiveType: TransactionTypeModel.values.firstWhere((e) => e.name == map['type']),
      hiveCategory: CategoryModel.fromJson(map['category']),
      hiveNote: map['note'],
      hiveIsRecurring: map['isRecurring'] ?? false,
    );
  }
}
