import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../features/home/presentation/screens/home_screen.dart';
import 'di/app_dependencies.dart';
import 'theme/app_theme.dart';

class SudokuApp extends StatelessWidget {
  SudokuApp({super.key, AppDependencies? dependencies})
      : _dependencies = dependencies ?? AppDependencies();

  final AppDependencies _dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
        Locale('it'),
        Locale('fr'),
      ],
      theme: const AppTheme().theme(),
      home: HomeScreen(dependencies: _dependencies),
    );
  }
}
