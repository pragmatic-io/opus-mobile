import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/flavor_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class OpusApp extends ConsumerWidget {
  const OpusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: FlavorConfig.instance.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: !FlavorConfig.instance.isProd,
    );
  }
}
