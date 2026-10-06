import 'package:flutter/widgets.dart';

import 'app.dart';
import 'init_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();
  runApp(const App());
}
