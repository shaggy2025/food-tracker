import 'package:hive/hive.dart';

part 'dish.g.dart'; // Generated file

@HiveType(typeId: 0)
class Dish {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double price;

  @HiveField(2)
  final String image;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final List<Map<String, dynamic>> sales; // Store sales with timestamps

  Dish({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    List<Map<String, dynamic>>? sales,
  }) : sales = sales ?? [];
}