import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/phone_registration_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/profile/screens/profile_onboarding_screen.dart';
import '../../features/gombo/screens/gombo_list_screen.dart';
import '../../features/gombo/screens/gombo_detail_screen.dart';
import '../../features/chat/screens/chat_thread_screen.dart';

class AppRouter {
  static const String _tokenKey = 'auth_token';

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: _globalRedirect,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) async {
          final isAuthenticated = await _checkAuthentication();
          return isAuthenticated ? '/gombos' : '/auth/phone';
        },
      ),
      GoRoute(
        path: '/auth/phone',
        name: 'auth-phone',
        builder: (context, state) => const PhoneRegistrationScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        name: 'auth-otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerificationScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/profile/onboarding',
        name: 'profile-onboarding',
        builder: (context, state) => const ProfileOnboardingScreen(),
      ),
      GoRoute(
        path: '/gombos',
        name: 'gombos',
        builder: (context, state) => const GomboListScreen(),
      ),
      GoRoute(
        path: '/gombos/:id',
        name: 'gombo-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GomboDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat-thread',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final recipientName = state.extra as String?;
          return ChatThreadScreen(id: id, recipientName: recipientName);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page introuvable',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Une erreur est survenue.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );

  static Future<String?> _globalRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    return null;
  }

  static Future<bool> _checkAuthentication() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
