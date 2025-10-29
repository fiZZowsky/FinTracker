import 'package:get_it/get_it.dart';
import 'notification_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => NotificationService());
}
