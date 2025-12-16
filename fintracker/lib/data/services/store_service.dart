import 'package:flutter/material.dart';
import '../models/store_model.dart';
import 'api_client.dart';

class StoreService {
  final ApiClient _apiClient;

  StoreService(this._apiClient);

  Future<List<StoreModel>> getStores() async {
    try {
      final dynamic data = await _apiClient.get('/api/Store');

      if (data is List) {
        return data.map((json) => StoreModel.fromJson(json)).toList();
      } else {
        throw Exception('Invalid data format received for stores.');
      }
    } catch (e) {
      debugPrint('StoreService getStores error: $e');
      rethrow;
    }
  }
}
