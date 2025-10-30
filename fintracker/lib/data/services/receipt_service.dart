import '../models/receipt_model.dart';
import 'api_client.dart';
import 'package:flutter/material.dart';

class ReceiptService {
  final ApiClient _apiClient;

  ReceiptService(this._apiClient);

  Future<List<ReceiptModel>> getReceipts() async {
    final dynamic data = await _apiClient.get('/api/Receipts');

    if (data is List) {
      return data.map((json) => _mapJsonToReceipt(json)).toList();
    } else {
      throw Exception('Invalid data format received from server.');
    }
  }

  ReceiptModel _mapJsonToReceipt(Map<String, dynamic> json) {
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
}
