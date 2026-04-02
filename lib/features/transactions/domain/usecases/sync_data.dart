import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class SyncData implements UseCase<void, String> {
  final TransactionRepository repository;

  SyncData(this.repository);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    return await repository.syncData(userId);
  }
}
