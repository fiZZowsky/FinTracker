import 'package:fintracker/ui/view_models/navigation_guard_view_model.dart';
import 'package:fintracker/ui/view_models/settings_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../ui/view_models/theme_view_model.dart';
import '../ui/view_models/loading_view_model.dart';
import '../ui/view_models/locale_view_model.dart';
import '../ui/view_models/finanses_view_model.dart';
import '../ui/view_models/scanner_view_model.dart';
import '../ui/view_models/receipt_edit_view_model.dart';
import '../ui/view_models/receipt_details_view_model.dart';
import '../ui/view_models/stores_view_model.dart';
import '../ui/view_models/categories_view_model.dart';

List<SingleChildWidget> getGlobalProviders() {
  return [
    ChangeNotifierProvider(create: (context) => ThemeViewModel()),
    ChangeNotifierProvider(create: (context) => LoadingViewModel()),
    ChangeNotifierProvider(create: (context) => LocaleViewModel()),
    ChangeNotifierProvider(create: (context) => FinansesViewModel()),
    ChangeNotifierProvider(
      create: (context) => ScannerViewModel(
        loadingViewModel: context.read<LoadingViewModel>(),
      ),
    ),
    ChangeNotifierProvider(create: (context) => ReceiptEditViewModel()),
    ChangeNotifierProvider(create: (context) => ReceiptDetailsViewModel()),
    ChangeNotifierProvider(create: (context) => NavigationGuardViewModel()),
    ChangeNotifierProvider(create: (context) => StoresViewModel()),
    ChangeNotifierProvider(create: (context) => CategoriesViewModel()),
    ChangeNotifierProvider(create: (context) => SettingsViewModel()),
  ];
}
