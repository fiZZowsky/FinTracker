import 'package:flutter/material.dart';
import '../models/category_model.dart';
import 'api_client.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final dynamic data = await _apiClient.get('/api/Categories');

      if (data is List) {
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Invalid data format received for categories.');
      }
    } catch (e) {
      debugPrint('CategoryService getCategories error: $e');
      rethrow;
    }
  }

  Future<bool> createCategory(String name) async {
    try {
      await _apiClient.post('/api/Categories', data: {'name': name});
      return true;
    } catch (e) {
      debugPrint('Create category error: $e');
      return false;
    }
  }

  Future<bool> updateCategory(int id, String name) async {
    try {
      await _apiClient
          .put('/api/Categories/$id', data: {'id': id, 'name': name});
      return true;
    } catch (e) {
      debugPrint('Update category error: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _apiClient.delete('/api/Categories/$id');
      return true;
    } catch (e) {
      debugPrint('Delete category error: $e');
      return false;
    }
  }
}
