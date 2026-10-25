import 'package:flutter/material.dart';

import 'widgets/reminder_lifecycle.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_theme.dart';
import 'views/startup/app_startup_page.dart';
import 'services/backend_readiness.dart';
import 'widgets/backend_ready_gate.dart';
import 'widgets/biometric_gate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hành Trình An Nhiên',
      theme: AppTheme.light,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('vi'), Locale('en')],
      locale: const Locale('vi'),
      builder: (context, child) => ReminderLifecycle(
        child: BiometricGate(
          child: BackendReadiness.enabled
              ? BackendReadyGate(child: child!)
              : child!,
        ),
      ),
      home: const AppStartupPage(),
    );
  }
}
