import 'package:chit_chat/config/theme/app_theme.dart';
import 'package:chit_chat/data/repositories/chat_repository.dart';
import 'package:chit_chat/data/services/service_locator.dart';
import 'package:chit_chat/logic/cubits/auth/auth_cubit.dart';
import 'package:chit_chat/logic/cubits/auth/auth_state.dart';
import 'package:chit_chat/logic/observer/life_app_cycle_observer.dart';
import 'package:chit_chat/presentation/home/home_screen.dart';
import 'package:chit_chat/presentation/screens/auth/login_screen.dart';
import 'package:chit_chat/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  LifeAppCycleObserver? _lifeCycleObserver;

  @override
  void initState() {
    super.initState();

    // Listen to AuthCubit changes
    getIt<AuthCubit>().stream.listen((state) {
      if (state.status == AuthStatus.authenticated && state.user != null) {
        // If already added, remove the previous observer
        if (_lifeCycleObserver != null) {
          WidgetsBinding.instance.removeObserver(_lifeCycleObserver!);
        }

        _lifeCycleObserver = LifeAppCycleObserver(
          userId: state.user!.uid,
          chatRepository: getIt<ChatRepository>(),
        );
        WidgetsBinding.instance.addObserver(_lifeCycleObserver!);
      }
    });
  }

  @override
  void dispose() {
    if (_lifeCycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifeCycleObserver!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChitChat',
      navigatorKey: getIt<AppRouter>().navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: BlocBuilder<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        builder: (context, state) {
          if (state.status == AuthStatus.initial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.status == AuthStatus.authenticated) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
