import 'package:chit_chat/config/theme/app_theme.dart';
import 'package:chit_chat/data/services/service_locator.dart';
import 'package:chit_chat/presentation/screens/auth/login_screen.dart';
import 'package:chit_chat/presentation/screens/auth/signup_screen.dart';
import 'package:chit_chat/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChitChat',
      navigatorKey: getIt<AppRouter>().navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: LoginScreen(),
    );
  }
}
