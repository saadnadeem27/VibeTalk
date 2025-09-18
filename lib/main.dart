import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flash_chat/app/theme/app_theme.dart';
import 'package:flash_chat/app/services/auth_service.dart';
import 'package:flash_chat/app/services/group_service.dart';
import 'package:flash_chat/app/controllers/auth_controller.dart';
import 'package:flash_chat/app/controllers/group_controller.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services
  Get.put(AuthService());
  Get.put(GroupService());
  Get.put(AuthController());
  Get.put(GroupController());

  runApp(const VibeTalk());
}

class VibeTalk extends StatelessWidget {
  const VibeTalk({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VibeTalk',
      debugShowCheckedModeBanner: false,
      theme: VibeTalkTheme.darkTheme,
      home: const AuthWrapper(),
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
