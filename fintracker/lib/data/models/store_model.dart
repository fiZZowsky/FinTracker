import 'dart:convert';
import 'dart:typed_data';

class StoreModel {
  final int id;
  final String name;
  final Uint8List? logo;
  final bool isDefault;

  StoreModel({
    required this.id,
    required this.name,
    this.logo,
    this.isDefault = false,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      logo: json['logo'] != null ? base64Decode(json['logo'] as String) : null,
      isDefault: json['isDefault'] ?? false,
    );
  }
}
