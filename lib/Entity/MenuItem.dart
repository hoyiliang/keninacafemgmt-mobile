import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'User.dart';

@JsonSerializable()
class MenuItem {
  final int id;
  final String itemClass;
  final String image;
  final String name;
  final double price_standard;
  final double price_large;
  final String description;
  final bool isOutOfStock;
  final bool hasVariant;
  final String variants;
  final bool hasSize;
  final String sizes;
  final String category_name;
  final String user_created_name;
  final String user_updated_name;
  int numOrder; // Cart and Order purpose
  String sizeChosen; // Cart and Order purpose
  String variantChosen; // Cart and Order purpose
  String remarks; // Cart and Order purpose

  MenuItem({
    required this.id,
    required this.itemClass,
    required this.image,
    required this.name,
    required this.price_standard,
    required this.price_large,
    required this.description,
    required this.isOutOfStock,
    required this.hasVariant,
    required this.variants,
    required this.hasSize,
    required this.sizes,
    required this.category_name,
    required this.user_created_name,
    required this.user_updated_name,
    required this.numOrder, // Cart and Order purpose
    // required this.priceNumOrder, // Cart and Order purpose
    required this.sizeChosen, // Cart and Order purpose
    required this.variantChosen, // Cart and Order purpose
    required this.remarks, // Cart and Order purpose
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // if (kDebugMode) {
    //   print('MenuItem.fromJson: $json');
    // }
    return MenuItem(
      id: json['id'],
      itemClass: json['itemClass'],
      image: json['image'] ?? '',
      name: json['name'],
      price_standard: json['price_standard'],
      price_large: json['price_large'] ?? 0,
      description: json['description'] ?? '',
      isOutOfStock: json['isOutOfStock'],
      hasVariant: json['hasVariant'],
      variants: json['variants'] ?? '',
      hasSize: json['hasSize'],
      sizes: json['sizes'] ?? '',
      category_name: json['category_name'],
      user_created_name: json['user_created_name'] ?? '',
      user_updated_name: json['user_updated_name'] ?? '',
      numOrder: 0, // Cart and Order purpose
      // priceNumOrder: 0, // Cart and Order purpose
      sizeChosen: "", // Cart and Order purpose
      variantChosen: "", // Cart and Order purpose
      remarks: "", // Cart and Order purpose
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemClass': itemClass,
      'image': image,
      'name': name,
      'price_standard': price_standard,
      'price_large': price_large,
      'description': description,
      'isOutOfStock': isOutOfStock,
      'hasVariant': hasVariant,
      'variants': variants,
      'hasSize': hasSize,
      'sizes': sizes,
      'category_name': category_name,
      'numOrder': numOrder, // Cart and Order purpose
      'sizeChosen': sizeChosen, // Cart and Order purpose
      'variantChosen': variantChosen, // Cart and Order purpose
      'remarks': remarks, // Cart and Order purpose
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is! MenuItem) return false;
    if (name == other.name && sizeChosen == other.sizeChosen && variantChosen == other.variantChosen && remarks == other.remarks) return true;
    return false;
  }

  @override
  int get hashCode => id.hashCode;

  // @override
  // int get hashCode {
  //   var result = 17;
  //   result = 37 * result + color.hashCode;
  //   result = 37 * result + make.hashCode;
  //   result = 37 * result + year.hashCode;
  //   return result;
  // }

  static List<MenuItem> getMenuItemDataList(Map<String, dynamic> json) {
    List<MenuItem> menuItemDataList = [];
    for (Map<String,dynamic> menuItemData in json['data']) {
      MenuItem oneMenuItemData = MenuItem.fromJson(menuItemData);
      menuItemDataList.add(oneMenuItemData);
    }
    return menuItemDataList;
  }

  static List<String> getMenuItemList(Map<String, dynamic> json) {
    List<String> menuItemList = [];
    for (Map<String,dynamic> menuItem in json['data']) {
      String oneMenuItem = MenuItem.fromJson(menuItem).name;
      menuItemList.add(oneMenuItem);
    }
    return menuItemList;
  }

  static List<MenuItem> getItemCategoryExistMenuItemList(Map<String, dynamic> json) {
    List<MenuItem> itemCategoryExistMenuItemList = [];
    for (Map<String,dynamic> itemCategoryExistMenuItem in json['data']) {
      MenuItem oneitemCategoryExistMenuItem = MenuItem.fromJson(itemCategoryExistMenuItem);
      itemCategoryExistMenuItemList.add(oneitemCategoryExistMenuItem);
    }
    return itemCategoryExistMenuItemList;
  }

}