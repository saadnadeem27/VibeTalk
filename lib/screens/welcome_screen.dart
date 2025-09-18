import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flash_chat/app/theme/app_theme.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const String id = 'welcome_screen';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: VibeTalkColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: VibeTalkSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and App Name
                _buildLogoSection(),

                const SizedBox(height: VibeTalkSpacing.xxl),

                // Animated tagline
                _buildTaglineSection(),

                const SizedBox(height: VibeTalkSpacing.xxl * 2),

                // Action buttons
                _buildActionButtons(),

                const SizedBox(height: VibeTalkSpacing.lg),

                // Footer text
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Animated logo
        Hero(
          tag: 'logo',
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              gradient: VibeTalkColors.primaryGradient,
              borderRadius: BorderRadius.circular(VibeTalkRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: VibeTalkColors.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              size: 60,
              color: VibeTalkColors.onPrimary,
            ),
          ),
        )
            .animate()
            .scale(
              duration: VibeTalkAnimations.slow,
              curve: VibeTalkAnimations.bounceIn,
            )
            .shimmer(
              duration: const Duration(milliseconds: 2000),
              color: VibeTalkColors.secondaryColor.withOpacity(0.3),
            ),

        const SizedBox(height: VibeTalkSpacing.lg),

        // App name with typing animation
        DefaultTextStyle(
          style: Theme.of(Get.context!).textTheme.displayLarge!.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'VibeTalk',
                speed: const Duration(milliseconds: 150),
              ),
            ],
            totalRepeatCount: 1,
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 500))
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildTaglineSection() {
    return Column(
      children: [
        DefaultTextStyle(
          style: Theme.of(Get.context!).textTheme.headlineMedium!.copyWith(
                color: VibeTalkColors.textSecondary,
              ),
          child: AnimatedTextKit(
            animatedTexts: [
              FadeAnimatedText(
                'Connect with friends',
                duration: const Duration(milliseconds: 2000),
              ),
              FadeAnimatedText(
                'Share moments',
                duration: const Duration(milliseconds: 2000),
              ),
              FadeAnimatedText(
                'Stay in touch',
                duration: const Duration(milliseconds: 2000),
              ),
            ],
            repeatForever: true,
          ),
        ),
        const SizedBox(height: VibeTalkSpacing.md),
        Text(
          'Modern messaging with style',
          style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                color: VibeTalkColors.textHint,
              ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 1500))
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Login button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Get.to(() => LoginScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: VibeTalkColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(VibeTalkRadius.lg),
              ),
              elevation: 8,
              shadowColor: VibeTalkColors.primaryColor.withOpacity(0.3),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 2000))
            .slideX(begin: -0.3, end: 0)
            .shimmer(
              delay: const Duration(milliseconds: 3000),
              duration: const Duration(milliseconds: 1500),
            ),

        const SizedBox(height: VibeTalkSpacing.md),

        // Register button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => Get.to(() => RegistrationScreen()),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: VibeTalkColors.primaryColor,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(VibeTalkRadius.lg),
              ),
            ),
            child: const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VibeTalkColors.primaryColor,
                letterSpacing: 1,
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 2200))
            .slideX(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(
      '© 2024 VibeTalk. All rights reserved.',
      style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
            color: VibeTalkColors.textHint,
          ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: const Duration(milliseconds: 2500));
  }
}
