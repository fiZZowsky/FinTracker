import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/services/category_service.dart';
import '../../helpers/service_locator.dart';

class ManageCategoriesViewModel extends ChangeNotifier {
  final CategoryService _categoryService = getIt<CategoryService>();

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _categoryService.getCategories();
      _categories.sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? 1 : -1;
        }
        return a.name.compareTo(b.name);
      });
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(String name) async {
    final success = await _categoryService.createCategory(name);
    if (success) await fetchCategories();
    return success;
  }

  Future<bool> editCategory(int id, String name) async {
    final success = await _categoryService.updateCategory(id, name);
    if (success) await fetchCategories();
    return success;
  }

  Future<bool> deleteCategory(int id) async {
    final success = await _categoryService.deleteCategory(id);
    if (success) await fetchCategories();
    return success;
  }
}
