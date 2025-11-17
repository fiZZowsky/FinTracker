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
      return data.map((json) => ReceiptModel.fromJson(json)).toList();
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

  Future<ReceiptModel?> uploadReceipt(XFile file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final dynamic data =
          await _apiClient.postFormData('/api/Receipts/Upload', formData);
      if (data is Map<String, dynamic>) {
        return ReceiptModel.fromJson(data);
      } else {
        throw Exception('Invalid data format received from parser.');
      }
    } catch (e) {
      debugPrint('ReceiptService upload error: $e');
      return null;
    }
  }

  Future<bool> createReceipt(ReceiptModel receipt) async {
    try {
      await _apiClient.post(
        '/api/Receipts',
        data: receipt.toJson(),
      );
      return true;
    } catch (e) {
      debugPrint('ReceiptService create error: $e');
      return false;
    }
  }

  Future<ReceiptModel?> getReceiptById(int id) async {
    try {
      final dynamic data = await _apiClient.get('/api/Receipts/$id');
      if (data is Map<String, dynamic>) {
        return ReceiptModel.fromJson(data);
      } else {
        throw Exception('Invalid data format received from server.');
      }
    } catch (e) {
      debugPrint('ReceiptService getById error: $e');
      return null;
    }
  }

  Future<bool> updateReceipt(int id, ReceiptModel receipt) async {
    try {
      await _apiClient.put(
        '/api/Receipts/$id',
        data: receipt.toJson(),
      );
      return true;
    } catch (e) {
      debugPrint('ReceiptService update error: $e');
      return false;
    }
  }
}
