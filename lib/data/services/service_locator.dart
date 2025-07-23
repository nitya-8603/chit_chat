import 'package:chit_chat/data/repositories/auth_repository.dart';
import 'package:chit_chat/data/repositories/contact_repository.dart';
import 'package:chit_chat/logic/cubits/auth/auth_cubit.dart';
import 'package:chit_chat/router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton(() => AuthRepository());
  getIt.registerLazySingleton(() => ContactRepository());
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(
    () => AuthCubit(authRepository: AuthRepository()),
  );
}
