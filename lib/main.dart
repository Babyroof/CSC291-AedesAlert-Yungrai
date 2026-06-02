import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/routes/app_router.dart';
import 'core/themes/app_theme.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM when a user is already signed in at startup
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    await FcmService().initialize(currentUser.uid);
  }

  // Also initialize FCM whenever a new sign-in occurs
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      FcmService().initialize(user.uid);
    }
  });
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Yungrai',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
