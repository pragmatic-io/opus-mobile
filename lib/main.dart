import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/cache/hive_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initialize();
  runApp(const OpusApp());
}

class OpusApp extends StatelessWidget {
  const OpusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: const [],
      child: MaterialApp.router(
        title: 'OPUS Mobile',
        debugShowCheckedModeBanner: false,
        theme: OpusTheme.light(),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
