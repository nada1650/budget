import 'package:hive/hive.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends TransactionCategory {
  @HiveField(0)
  final String hiveId;
  @HiveField(1)
  final String hiveName;
  @HiveField(2)
  final String hiveIconFolder;
  @HiveField(3)
  final int hiveColorValue;

  const CategoryModel({
    required this.hiveId,
    required this.hiveName,
    required this.hiveIconFolder,
    required this.hiveColorValue,
  }) : super(
          id: hiveId,
          name: hiveName,
          iconFolder: hiveIconFolder,
          colorValue: hiveColorValue,
        );

  factory CategoryModel.fromEntity(TransactionCategory entity) {
    return CategoryModel(
      hiveId: entity.id,
      hiveName: entity.name,
      hiveIconFolder: entity.iconFolder,
      hiveColorValue: entity.colorValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': hiveId,
      'name': hiveName,
      'iconFolder': hiveIconFolder,
      'colorValue': hiveColorValue,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      hiveId: json['id'],
      hiveName: json['name'],
      hiveIconFolder: json['iconFolder'],
      hiveColorValue: json['colorValue'],
    );
  }
}
