import 'package:flutter/material.dart';
import '../../data/models/receipt_model.dart';
import '../../data/models/summary_data.dart';
import '../../data/services/receipt_service.dart';
import '../../helpers/service_locator.dart';
import 'package:intl/intl.dart';

enum DateFilter { week, month, sixMonths, year, all }

class FinansesViewModel extends ChangeNotifier {
  final ReceiptService _receiptService = getIt<ReceiptService>();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  DateFilter _selectedFilter = DateFilter.month;
  DateFilter get selectedFilter => _selectedFilter;

  List<SummaryData> _summaryData = [];
  List<ReceiptModel> _receipts = [];
  List<SummaryData> get summaryData => _summaryData;
  List<ReceiptModel> get receipts => _receipts;

  List<ReceiptModel> _recentReceipts = [];
  List<ReceiptModel> get recentReceipts => _recentReceipts;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 100;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  FinansesViewModel() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    _hasError = false;
    _currentPage = 1;
    _receipts = [];
    _summaryData = [];
    _hasMore = true;
    notifyListeners();

    try {
      final (startDate, endDate) = _getDatesFromFilter();

      final results = await Future.wait([
        _fetchSummary(startDate: startDate, endDate: endDate),
        _fetchReceiptsPage(page: 1, startDate: startDate, endDate: endDate),
      ]);

      _summaryData = results[0] as List<SummaryData>;
      final newReceipts = results[1] as List<ReceiptModel>;

      _receipts = newReceipts;
      _hasMore = newReceipts.length == _pageSize;
      _currentPage = 1;
    } catch (e) {
      debugPrint('Error fetching finanses data: $e');
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecentReceipts() async {
    try {
      _recentReceipts = await _receiptService.getReceipts(
        page: 1,
        pageSize: 5,
        startDate: null,
        endDate: null,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching recent receipts: $e');
    }
  }

  Future<void> setFilter(DateFilter filter) async {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    await fetchData();
  }

  Future<void> loadMoreReceipts() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final (startDate, endDate) = _getDatesFromFilter();
      final newReceipts = await _fetchReceiptsPage(
        page: _currentPage + 1,
        startDate: startDate,
        endDate: endDate,
      );

      _receipts.addAll(newReceipts);
      _hasMore = newReceipts.length == _pageSize;
      _currentPage++;
    } catch (e) {
      debugPrint('Error loading more receipts: $e');
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<List<ReceiptModel>> _fetchReceiptsPage(
      {required int page, DateTime? startDate, DateTime? endDate}) {
    return _receiptService.getReceipts(
      page: page,
      pageSize: _pageSize,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<SummaryData>> _fetchSummary(
      {DateTime? startDate, DateTime? endDate}) {
    return _receiptService.getSummary(
        startDate: startDate,
        endDate: endDate,
        filterType: _selectedFilter.name);
  }

  (DateTime?, DateTime?) _getDatesFromFilter() {
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate = now;

    switch (_selectedFilter) {
      case DateFilter.week:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case DateFilter.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case DateFilter.sixMonths:
        startDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case DateFilter.year:
        startDate = DateTime(now.year, 1, 1);
        break;
      case DateFilter.all:
        startDate = null;
        endDate = null;
        break;
    }
    return (startDate, endDate);
  }

  String getFormattedDate(String label) {
    final currentLocale = Intl.getCurrentLocale();

    switch (_selectedFilter) {
      case DateFilter.week:
        try {
          final dayIndex = int.parse(label);
          final tempDate =
              DateTime(2024, 1, 1).add(Duration(days: dayIndex - 1));
          return DateFormat.E(currentLocale).format(tempDate);
        } catch (e) {
          return label;
        }
      case DateFilter.month:
        return label;
      case DateFilter.sixMonths:
      case DateFilter.year:
        try {
          final date = DateTime.parse('$label-01');
          return DateFormat.MMM(currentLocale).format(date);
        } catch (e) {
          return label;
        }
      case DateFilter.all:
        return label;
    }
  }
}
