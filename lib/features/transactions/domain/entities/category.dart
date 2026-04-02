import 'package:equatable/equatable.dart';

class TransactionCategory extends Equatable {
  final String id;
  final String name;
  final String iconFolder; // To distinguish icon later
  final int colorValue;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.iconFolder,
    required this.colorValue,
  });

  @override
  List<Object?> get props => [id, name, iconFolder, colorValue];
}
