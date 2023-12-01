import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class ItemCategory {
  final int id;
  final String name;
  final String itemClass;

  ItemCategory({
    required this.id,
    required this.name,
    required this.itemClass,
  });

  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    return ItemCategory(
      id: json['id'],
      name: json['name'],
      itemClass: json['itemClass'],
    );
  }

  static List<String> getAllItemCategory(Map<String, dynamic> json) {
    List<String> allitemCategoryList = [];
    for (Map<String,dynamic> itemCategory in json['data']) {
      String oneitemCategory = ItemCategory.fromJson(itemCategory).name;
      allitemCategoryList.add(oneitemCategory);
    }
    return allitemCategoryList;
  }

}