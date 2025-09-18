import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flash_chat/app/controllers/auth_controller.dart';
import 'package:flash_chat/app/theme/app_theme.dart';
import 'package:flash_chat/screens/login_screen.dart';

class RegistrationScreen extends StatelessWidget {
  static const String id = 'registration_screen';

  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: VibeTalkColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(VibeTalkSpacing.lg),
            child: Column(
              children: [
                // Header with back button and logo
                _buildHeader(),

                const SizedBox(height: VibeTalkSpacing.xl),

                // Welcome text
                _buildWelcomeText(),

                const SizedBox(height: VibeTalkSpacing.xl),

                // Registration form
                _buildRegistrationForm(authController),

                const SizedBox(height: VibeTalkSpacing.lg),

                // Sign in link
                _buildSignInLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: VibeTalkColors.textPrimary,
          ),
        ).animate().fadeIn().slideX(begin: -0.3, end: 0),

        const Spacer(),

        // Mini logo
        Hero(
          tag: 'logo',
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: VibeTalkColors.primaryGradient,
              borderRadius: BorderRadius.circular(VibeTalkRadius.md),
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              size: 25,
              color: VibeTalkColors.onPrimary,
            ),
          ),
        ).animate().scale(delay: const Duration(milliseconds: 200)),

        const Spacer(),

        const SizedBox(width: 48), // Balance the back button
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Create Account',
          style: Theme.of(Get.context!).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 300))
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: VibeTalkSpacing.sm),
        Text(
          'Join VibeTalk and start connecting',
          style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                color: VibeTalkColors.textSecondary,
              ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 400))
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildRegistrationForm(AuthController authController) {
    return Form(
      key: authController.signUpFormKey,
      child: Column(
        children: [
          // Name field
          TextFormField(
            controller: authController.displayNameController,
            validator: authController.validateDisplayName,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(
                Icons.person_outlined,
                color: VibeTalkColors.primaryColor,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 500))
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: VibeTalkSpacing.lg),

          // Email field
          TextFormField(
            controller: authController.emailController,
            validator: authController.validateEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: VibeTalkColors.primaryColor,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 600))
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: VibeTalkSpacing.lg),

          // Password field
          Obx(() => TextFormField(
                    controller: authController.passwordController,
                    validator: authController.validatePassword,
                    obscureText: !authController.isPasswordVisible.value,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(
                        Icons.lock_outlined,
                        color: VibeTalkColors.primaryColor,
                      ),
                      suffixIcon: IconButton(
                        onPressed: authController.togglePasswordVisibility,
                        icon: Icon(
                          authController.isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: VibeTalkColors.textSecondary,
                        ),
                      ),
                    ),
                  ))
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 700))
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: VibeTalkSpacing.lg),

          // Confirm Password field
          Obx(() => TextFormField(
                    controller: authController.confirmPasswordController,
                    validator: authController.validateConfirmPassword,
                    obscureText: !authController.isConfirmPasswordVisible.value,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(
                        Icons.lock_outlined,
                        color: VibeTalkColors.primaryColor,
                      ),
                      suffixIcon: IconButton(
                        onPressed:
                            authController.toggleConfirmPasswordVisibility,
                        icon: Icon(
                          authController.isConfirmPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: VibeTalkColors.textSecondary,
                        ),
                      ),
                    ),
                  ))
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 800))
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: VibeTalkSpacing.xl),

          // Terms and conditions
          Container(
            padding: const EdgeInsets.all(VibeTalkSpacing.md),
            decoration: BoxDecoration(
              color: VibeTalkColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(VibeTalkRadius.md),
            ),
            child: Text(
              'By creating an account, you agree to our Terms of Service and Privacy Policy.',
              style: Theme.of(Get.context!).textTheme.bodySmall!.copyWith(
                    color: VibeTalkColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 900)),

          const SizedBox(height: VibeTalkSpacing.lg),

          // Register button
          Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authController.isSignUpLoading.value
                          ? null
                          : authController.signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VibeTalkColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(VibeTalkRadius.lg),
                        ),
                        elevation: 8,
                        shadowColor:
                            VibeTalkColors.primaryColor.withOpacity(0.3),
                      ),
                      child: authController.isSignUpLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: VibeTalkColors.onPrimary,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ))
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 1000))
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
              .shimmer(
                delay: const Duration(milliseconds: 1500),
                duration: const Duration(milliseconds: 1000),
              ),
        ],
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: Theme.of(Get.context!).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => Get.to(() => LoginScreen()),
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: VibeTalkColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: const Duration(milliseconds: 1100));
  }
}
