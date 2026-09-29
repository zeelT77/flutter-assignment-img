import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';
import 'providers/saved_photos_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/photo_detail_screen.dart';
import 'models/photo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SavedPhotosProvider()),
      ],
      child: const SnaplyApp(),
    ),
  );
}

class SnaplyApp extends StatelessWidget {
  const SnaplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final themeProvider = context.watch<ThemeProvider>();
    
    final GoRouter router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: authService,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => 
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SignupScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => 
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/photo_detail',
          pageBuilder: (context, state) {
            final photo = state.extra as Photo;
            return CustomTransitionPage(
              key: state.pageKey,
              child: PhotoDetailScreen(photo: photo),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => 
                  FadeTransition(opacity: animation, child: child),
            );
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  builder: (context, state) => const SearchScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/saved',
                  builder: (context, state) => const SavedScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final bool isSplash = state.matchedLocation == '/splash';
        final bool isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
        
        if (isSplash) return null;
        
        if (!authService.isAuthenticated && !isLoggingIn) {
          return '/login';
        }
        
        if (authService.isAuthenticated && isLoggingIn) {
          return '/home';
        }
        
        return null;
      },
    );

    return MaterialApp.router(
      title: 'Snaply',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
