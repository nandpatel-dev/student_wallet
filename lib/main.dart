import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/auth/presentation/pages/login_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:student_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── System UI Overlay ──────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:            Colors.transparent,
      statusBarIconBrightness:   Brightness.dark,
      systemNavigationBarColor:  Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Portrait Mode Only ─────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  void initDeepLinks() async {
    _appLinks = AppLinks();
    
    // Check initial link if app was closed
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }

    // Listen for incoming links while app is open
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) async {
    // Example: justifai://wallet/open?token=<appToken>
    if (uri.scheme == 'justifai' && uri.path.contains('wallet/open')) {
      final token = uri.queryParameters['token'];
      if (token != null) {
        final walletProvider = Provider.of<WalletProvider>(context, listen: false);
        final success = await walletProvider.handleDeepLink(token);
        if (success) {
          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardWrapper()),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark        = themeProvider.isDarkMode;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      // ── App Info ──────────────────────────────
      title:                    'Student Portfolio',
      debugShowCheckedModeBanner: false,

      // ── Material 3 Themes ─────────────────────
      theme:     AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // ── Entry Point ───────────────────────────
      home: const LoginPage(),

      // ── Page Transitions — M3 style ───────────
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
    );
  }
}
