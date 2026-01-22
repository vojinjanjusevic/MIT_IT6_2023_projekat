import 'package:flutter/material.dart';
import 'screens/root_screen.dart';
import 'theme/theme_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;

    return AnimatedBuilder(
      animation: theme,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CarDealer',

          themeMode: theme.mode, // ✅ sluša dark/light

          theme: ThemeData(
            textTheme: const TextTheme(
              titleLarge: TextStyle(fontWeight: FontWeight.w700),
              titleMedium: TextStyle(fontWeight: FontWeight.w600),
              titleSmall: TextStyle(fontWeight: FontWeight.w600),

              bodyLarge: TextStyle(height: 1.4),
              bodyMedium: TextStyle(height: 1.4),

              labelLarge: TextStyle(letterSpacing: 0.3),
            ),
            useMaterial3: true,
            colorSchemeSeed: Colors.blueGrey,

            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),

            cardTheme: CardThemeData(
              elevation: 0.8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.blueGrey.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),

            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          darkTheme: ThemeData(
            textTheme: const TextTheme(
              titleLarge: TextStyle(fontWeight: FontWeight.w700),
              titleMedium: TextStyle(fontWeight: FontWeight.w600),
              titleSmall: TextStyle(fontWeight: FontWeight.w600),

              bodyLarge: TextStyle(height: 1.4),
              bodyMedium: TextStyle(height: 1.4),

              labelLarge: TextStyle(letterSpacing: 0.3),
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blueGrey,

            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),

            cardTheme: CardThemeData(
              elevation: 0.8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),

            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          home: const RootScreen(),
        );
      },
    );
  }
}
