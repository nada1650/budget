import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/transaction_repository.dart';

class AddCategory implements UseCase<void, TransactionCategory> {
  final TransactionRepository repository;

  AddCategory(this.repository);

  @override
  Future<Either<Failure, void>> call(TransactionCategory params) async {
    return await repository.addCategory(params);
  }
}
