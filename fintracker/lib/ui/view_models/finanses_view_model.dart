import 'package:flutter/material.dart';
import '../../data/models/receipt_model.dart';
import '../../data/models/summary_data.dart';
import '../../data/services/receipt_service.dart';
import '../../helpers/service_locator.dart';
import 'package:intl/intl.dart';
import '../../data/services/preferences_service.dart';
import '../../data/services/export_service.dart';

class FinansesViewModel extends ChangeNotifier {
  final ReceiptService _receiptService = getIt<ReceiptService>();
  final PreferencesService _prefsService = getIt<PreferencesService>();
  final ExportService _exportService = getIt<ExportService>();

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _hasError = false;
  bool get hasError => _hasError;

  String _currentCurrency = 'PLN';
  String get currentCurrency => _currentCurrency;

  DateTime _currentDate = DateTime.now();
  DateTime get currentDate => _currentDate;

  double _monthlyBudgetLimit = 3000.0;
  double get monthlyBudgetLimit => _monthlyBudgetLimit;

  double _currentMonthTotal = 0.0;
  double get currentMonthTotal => _currentMonthTotal;

  List<ReceiptModel> _receipts = [];
  List<ReceiptModel> get receipts => _receipts;

  List<SummaryData> _summaryData = [];
  List<SummaryData> get summaryData => _summaryData;

  final Map<String, double> _categoryStats = {};
  Map<String, double> get categoryStats => _categoryStats;

  double get totalSpent =>
      _receipts.fold(0, (sum, item) => sum + item.totalAmount);

  List<ReceiptModel> _recentReceipts = [];
  List<ReceiptModel> get recentReceipts => _recentReceipts;

  FinansesViewModel() {
    _loadBudget();
    fetchData();
  }

  Future<void> _loadBudget() async {
    _monthlyBudgetLimit = await _prefsService.getBudgetLimit();
    _currentCurrency = await _prefsService.getDefaultCurrency();
    notifyListeners();
  }

  Future<void> updateBudgetLimit(double newLimit) async {
    _monthlyBudgetLimit = newLimit;
    await _prefsService.setBudgetLimit(newLimit);
    notifyListeners();
  }

  Future<void> changeMonth(int monthsToAdd) async {
    _currentDate =
        DateTime(_currentDate.year, _currentDate.month + monthsToAdd, 1);
    await fetchData();
  }

Future<void> _fetchCurrentMonthTotal() async {
    final now = DateTime.now();
    
    if (_currentDate.year == now.year && _currentDate.month == now.month) {
      _currentMonthTotal = _summaryData.fold(0, (sum, item) => sum + item.total);
      return;
    }

    try {
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      final summary = await _receiptService.getSummary(
        startDate: startDate,
        endDate: endDate,
        filterType: 'month',
        currencyCode: _currentCurrency,
      );

      _currentMonthTotal = summary.fold(0, (sum, item) => sum + item.total);
    } catch (e) {
      debugPrint('Error fetching current month total: $e');
    }
  }

  Future<void> fetchData() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final startDate = DateTime(_currentDate.year, _currentDate.month, 1);
      final endDate = DateTime(_currentDate.year, _currentDate.month + 1, 0);

      _currentCurrency = await _prefsService.getDefaultCurrency();

      _receipts = await _receiptService.getReceipts(
        page: 1,
        pageSize: 1000,
        startDate: startDate,
        endDate: endDate,
        currencyCode: _currentCurrency,
      );

      _summaryData = await _receiptService.getSummary(
        startDate: startDate,
        endDate: endDate,
        filterType: 'month',
        currencyCode: _currentCurrency,
      );

      _calculateCategoryStats();
      await _fetchCurrentMonthTotal();
    } catch (e) {
      debugPrint('Error fetching finanses data: $e');
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecentReceipts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentCurrency = await _prefsService.getDefaultCurrency();

      _recentReceipts = await _receiptService.getReceipts(
        page: 1,
        pageSize: 5,
        startDate: null,
        endDate: null,
        currencyCode: _currentCurrency,
      );
      _hasError = false;
    } catch (e) {
      debugPrint('Error fetching recent receipts: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportData(DateTime start, DateTime end, bool isPdf) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allReceipts = await _receiptService.getReceipts(
        page: 1,
        pageSize: 10000,
        startDate: start,
        endDate: end,
        currencyCode: _currentCurrency,
      );

      if (allReceipts.isEmpty) {
        debugPrint("Brak danych do eksportu");
      } else {
        if (isPdf) {
          await _exportService.exportToPdf(
              allReceipts, start, end, currentCurrency);
        } else {
          await _exportService.exportToCsv(
              allReceipts, start, end, currentCurrency);
        }
      }
    } catch (e) {
      debugPrint("Błąd eksportu: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateCategoryStats() {
    _categoryStats.clear();
    for (var receipt in _receipts) {
      final category = receipt.categoryName?.isNotEmpty == true
          ? receipt.categoryName!
          : 'Inne';

      _categoryStats.update(category, (value) => value + receipt.totalAmount,
          ifAbsent: () => receipt.totalAmount);
    }
  }

  Map<String, List<ReceiptModel>> get groupedReceipts {
    Map<String, List<ReceiptModel>> grouped = {};
    for (var receipt in _receipts) {
      final dateKey = DateFormat('yyyy-MM-dd').format(receipt.dateShopping);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(receipt);
    }
    return grouped;
  }
}
