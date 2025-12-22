import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _budgetKey = 'monthly_budget_limit';

  Future<void> setBudgetLimit(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, amount);
  }

  Future<double> getBudgetLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_budgetKey) ?? 3000.0;
  }
}
