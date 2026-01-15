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

  Future<bool> createUserStore(String name) async {
    try {
      await _apiClient.post('/api/Store/user', data: {'name': name});
      return true;
    } catch (e) {
      debugPrint('Create user store error: $e');
      return false;
    }
  }

  Future<bool> updateUserStore(int id, String name) async {
    try {
      await _apiClient.put('/api/Store/user/$id', data: {'name': name});
      return true;
    } catch (e) {
      debugPrint('Update user store error: $e');
      return false;
    }
  }

  Future<bool> deleteStore(int id) async {
    try {
      await _apiClient.delete('/api/Store/$id');
      return true;
    } catch (e) {
      debugPrint('Delete store error: $e');
      return false;
    }
  }
}
