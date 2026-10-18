import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language/language.dart';
import 'package:themes/themes.dart';

import 'config/language/language_change_adapter.dart';
import 'config/themes/colors_palettes.dart';
import 'core/api/refresh_token_helper.dart';
import 'core/services/bloc_observer/bloc_observer.dart';
import 'features/capture/data/datasources/receipt_image_data_source.dart';
import 'core/services/local_storage/impl/language_code_storage.dart';
import 'core/services/local_storage/impl/theme_mode_storage.dart';
import 'core/services/notifications/app_notifications_service.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> initApp() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ServiceLocator.init();
  await clearLeftoverReceiptPhotos();
  await Language.instance.init(
    storage: LanguageCodeStorage(sharedPreferences),
    listener: const LanguageChangeAdapter(),
  );
  await Themes.instance.init(
    config: ColorsPalettes.config,
    storage: ThemeModeStorage(sharedPreferences),
  );
  unawaited(AppNotificationsService.initNotifications());
  RefreshTokenHelper.instance.setOnSessionExpired(() async {
    // AppRouter.router.go(const SplashRoute(sessionExpired: true).location);
  });
  Bloc.observer = AppBlocObserver();
}
