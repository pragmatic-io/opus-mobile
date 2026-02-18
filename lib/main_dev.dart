import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/flavor_config.dart';
import 'core/storage/hive_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig.initialize(
    flavor: Flavor.dev,
    appName: 'OPUS Mobile (Dev)',
    apiBaseUrl: 'https://api-dev.opus-mobile.app',
    enableLogging: true,
  );

  await HiveService.init();

  runApp(const ProviderScope(child: OpusApp()));
}
