import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../datasources/transaction_remote_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;
  final FirebaseAuth _firebaseAuth;

  TransactionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await localDataSource.cacheTransaction(model);
      if (_currentUserId != null) {
        await remoteDataSource.addTransaction(_currentUserId!, model);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);
      if (_currentUserId != null) {
        await remoteDataSource.deleteTransaction(_currentUserId!, id);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addCategory(TransactionCategory category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await localDataSource.addCategory(model);
      if (_currentUserId != null) {
        await remoteDataSource.addCategory(_currentUserId!, model);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await localDataSource.deleteCategory(id);
      if (_currentUserId != null) {
        await remoteDataSource.deleteCategory(_currentUserId!, id);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionCategory>>> getCategories() async {
    try {
      final models = await localDataSource.getCategories();
      return Right(models); // Model extends Entity so this is fine
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    try {
      final models = await localDataSource.getTransactions();
      // Sort by date descending
      models.sort((a, b) => b.date.compareTo(a.date));
      return Right(models);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncData(String userId) async {
    try {
      // 1. Fetch remote data
      final remoteTransactions = await remoteDataSource.fetchTransactions(userId);
      final remoteCategories = await remoteDataSource.fetchCategories(userId);

      // 2. Cache remote to local
      for (var tx in remoteTransactions) {
        await localDataSource.cacheTransaction(tx);
      }
      for (var cat in remoteCategories) {
        await localDataSource.addCategory(cat);
      }

      // 3. If remote is empty, push local to remote (initial sync)
      if (remoteTransactions.isEmpty) {
        final localTransactions = await localDataSource.getTransactions();
        if (localTransactions.isNotEmpty) {
          await remoteDataSource.syncTransactions(userId, localTransactions.cast<TransactionModel>());
        }
      }
      if (remoteCategories.isEmpty) {
        final localCategories = await localDataSource.getCategories();
        if (localCategories.isNotEmpty) {
          await remoteDataSource.syncCategories(userId, localCategories.cast<CategoryModel>());
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
