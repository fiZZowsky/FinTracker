import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../ui/view_models/theme_view_model.dart';
import '../ui/view_models/loading_view_model.dart';
import '../ui/view_models/locale_view_model.dart';
import '../ui/view_models/finanses_view_model.dart';

List<SingleChildWidget> getGlobalProviders() {
  return [
    ChangeNotifierProvider(create: (context) => ThemeViewModel()),
    ChangeNotifierProvider(create: (context) => LoadingViewModel()),
    ChangeNotifierProvider(create: (context) => LocaleViewModel()),
    ChangeNotifierProvider(create: (context) => FinansesViewModel()),
  ];
}
