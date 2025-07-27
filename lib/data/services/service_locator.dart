import 'package:chit_chat/data/repositories/auth_repository.dart';
import 'package:chit_chat/data/repositories/chat_repository.dart';
import 'package:chit_chat/data/repositories/contact_repository.dart';
import 'package:chit_chat/logic/cubits/auth/auth_cubit.dart';
import 'package:chit_chat/logic/cubits/chat/chat_cubit.dart';
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

  // Register repositories
  getIt.registerLazySingleton(() => AuthRepository());
  getIt.registerLazySingleton(() => ContactRepository());
  getIt.registerLazySingleton(() => ChatRepository());

  // Firebase instances
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // Update AuthCubit to include ChatRepository
  getIt.registerLazySingleton(
    () => AuthCubit(
      authRepository: getIt<AuthRepository>(),
      chatRepository: getIt<ChatRepository>(),
    ),
  );

  // ChatCubit (safe with factory because of user-dependent state)
  getIt.registerFactory(
    () => ChatCubit(
      chatRepository: getIt<ChatRepository>(),
      currentUserId: getIt<FirebaseAuth>().currentUser!.uid,
    ),
  );
}
