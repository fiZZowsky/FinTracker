import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/services/category_service.dart';
import '../../helpers/service_locator.dart';

class CategoriesViewModel extends ChangeNotifier {
  final CategoryService _categoryService = getIt<CategoryService>();

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    if (_categories.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
      _categories.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
