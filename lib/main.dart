import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/screens/dashboard_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dnd_combat_tracker/l10n/app_localizations.dart';
import 'presentation/providers/theme_provider.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/combat.dart';
import 'data/models/combatant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(CombatAdapter());
  Hive.registerAdapter(CombatantAdapter());
  Hive.registerAdapter(CombatStatusAdapter());
  
  // Open Boxes
  await Hive.openBox<Combat>('combats');
  await Hive.openBox<Combatant>('combatants');

  runApp(const ProviderScope(child: MyApp()));
}

class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _InstantPageTransitionsBuilder(),
      TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
      TargetPlatform.windows: _InstantPageTransitionsBuilder(),
      TargetPlatform.macOS: _InstantPageTransitionsBuilder(),
      TargetPlatform.linux: _InstantPageTransitionsBuilder(),
      TargetPlatform.fuchsia: _InstantPageTransitionsBuilder(),
    },
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'D&D Combat Tracker',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
      ),
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        pageTransitionsTheme: _pageTransitionsTheme,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3F51B5), // Indigo 500
          secondary: Color(0xFFFFC107), // Amber 500
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3F51B5),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        scrollbarTheme: ScrollbarThemeData(
          interactive: true,
          thickness: WidgetStateProperty.all(3.5),
          radius: const Radius.circular(8),
          thumbColor: WidgetStateProperty.all(
            const Color(0xFF3F51B5).withValues(alpha: 0.4),
          ),
          trackColor: WidgetStateProperty.all(
            const Color(0xFF3F51B5).withValues(alpha: 0.06),
          ),
          trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        pageTransitionsTheme: _pageTransitionsTheme,
        scaffoldBackgroundColor: const Color(0xFF1E1E2C), // Dark Blue-Grey
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7986CB), // Indigo 300
          secondary: Color(0xFFFFD54F), // Amber 300
          surface: Color(0xFF2D2D44), // Lighter Blue-Grey
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2D2D44),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        scrollbarTheme: ScrollbarThemeData(
          interactive: true,
          thickness: WidgetStateProperty.all(3.5),
          radius: const Radius.circular(8),
          thumbColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.25),
          ),
          trackColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.04),
          ),
          trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', ''),
      ],
      home: const DashboardScreen(),
    );
  }
}
