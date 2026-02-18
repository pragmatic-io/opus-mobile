import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Placeholder home page — replace with real feature pages as they are built.
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const _PlaceholderPage(title: 'OPUS Mobile'),
    ),
  ],
);
