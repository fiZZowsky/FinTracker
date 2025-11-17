import 'package:flutter/foundation.dart';

class ReceiptModel {
  final int id;
  final String storeName;
  final double totalAmount;
  final DateTime dateShopping;

  ReceiptModel({
    required this.id,
    required this.storeName,
    required this.totalAmount,
    required this.dateShopping,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    try {
      return ReceiptModel(
        id: json['id'] as int,
        storeName: json['storeName'] as String,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        dateShopping: DateTime.parse(json['dateShopping'] as String),
      );
    } catch (e) {
      debugPrint('Receipt parsing error: $e. Invalid JSON: $json');
      throw Exception('Failed to parse receipt data.');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'totalAmount': totalAmount,
      'dateShopping': dateShopping.toIso8601String(),
    };
  }
}
