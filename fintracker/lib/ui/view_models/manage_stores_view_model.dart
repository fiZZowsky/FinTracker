import 'package:flutter/material.dart';
import '../../data/models/store_model.dart';
import '../../data/services/store_service.dart';
import '../../helpers/service_locator.dart';

class ManageStoresViewModel extends ChangeNotifier {
  final StoreService _storeService = getIt<StoreService>();

  List<StoreModel> _stores = [];
  List<StoreModel> get stores => _stores;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchStores() async {
    _isLoading = true;
    notifyListeners();
    try {
      _stores = await _storeService.getStores();
      _stores.sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? 1 : -1;
        }
        return a.name.compareTo(b.name);
      });
    } catch (e) {
      debugPrint('Error fetching stores: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStore(String name) async {
    final success = await _storeService.createUserStore(name);
    if (success) await fetchStores();
    return success;
  }

  Future<bool> editStore(int id, String name) async {
    final success = await _storeService.updateUserStore(id, name);
    if (success) await fetchStores();
    return success;
  }

  Future<bool> deleteStore(int id) async {
    final success = await _storeService.deleteStore(id);
    if (success) await fetchStores();
    return success;
  }
}
