import 'package:flutter/material.dart';
import '../../data/models/store_model.dart';
import '../../data/services/store_service.dart';
import '../../helpers/service_locator.dart';

class StoresViewModel extends ChangeNotifier {
  final StoreService _storeService = getIt<StoreService>();

  List<StoreModel> _stores = [];
  List<StoreModel> get stores => _stores;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchStores() async {
    if (_stores.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      _stores = await _storeService.getStores();
      _stores.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('Error fetching stores: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  StoreModel? findByName(String name) {
    try {
      return _stores.firstWhere(
        (s) => s.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
