import 'package:get_it/get_it.dart';
import 'notification_service.dart';
import '../data/services/api_client.dart';
import '../data/services/receipt_service.dart';
import '../data/services/store_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => ApiClient());
  getIt.registerLazySingleton(() => NotificationService());

  getIt.registerLazySingleton(() => ReceiptService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => StoreService(getIt<ApiClient>()));
}
