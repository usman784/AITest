import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive initialisation
  await Hive.initFlutter();

  // AdMob initialisation
  await MobileAds.instance.initialize();

  // Screen orientations — supports both portrait and landscape for tablet layouts
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Forward Flutter framework errors to the default error handler
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // Build the ProviderScope with SharedPreferences override and run the app.
  final scope = await buildProviderScope();
  runApp(scope);
}
