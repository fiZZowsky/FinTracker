import '../models/receipt_model.dart';
import '../models/summary_data.dart';
import 'api_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptService {
  final ApiClient _apiClient;

  ReceiptService(this._apiClient);

  Future<List<ReceiptModel>> getReceipts({
    int page = 1,
    int pageSize = 100,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'page': page,
      'pageSize': pageSize,
    };

    if (startDate != null) {
      queryParameters['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParameters['endDate'] = endDate.toIso8601String();
    }

    final dynamic data =
        await _apiClient.get('/api/Receipts', queryParameters: queryParameters);

    if (data is List) {
      return data.map((json) => _mapJsonToReceipt(json)).toList();
    } else {
      throw Exception('Invalid data format received from server.');
    }
  }

  Future<List<SummaryData>> getSummary(
      {DateTime? startDate, DateTime? endDate, String? filterType}) async {
    final Map<String, dynamic> queryParameters = {};

    if (startDate != null) {
      queryParameters['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParameters['endDate'] = endDate.toIso8601String();
    }
    if (filterType != null) {
      queryParameters['filterType'] = filterType;
    }

    final dynamic data = await _apiClient.get('/api/Receipts/summary',
        queryParameters: queryParameters);

    if (data is List) {
      return data.map((json) => SummaryData.fromJson(json)).toList();
    } else {
      throw Exception('Invalid summary data format.');
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

  Future<bool> uploadReceipt(XFile file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      await _apiClient.postFormData('/api/Receipts/Upload', formData);

      return true;
    } catch (e) {
      debugPrint('ReceiptService upload error: $e');
      return false;
    }
  }
}
