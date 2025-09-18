import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flash_chat/app/controllers/auth_controller.dart';
import 'package:flash_chat/app/theme/app_theme.dart';
import 'package:flash_chat/app/routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  static const String id = 'login_screen';

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: VibeTalkColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(VibeTalkSpacing.lg),
            child: Column(
              children: [
                // Header with back button and logo
                _buildHeader(),
                
                SizedBox(height: VibeTalkSpacing.xxl),
                
                // Welcome back text
                _buildWelcomeText(),
                
                SizedBox(height: VibeTalkSpacing.xxl),
                
                // Login form
                _buildLoginForm(authController),
                
                SizedBox(height: VibeTalkSpacing.lg),
                
                // Sign up link
                _buildSignUpLink(),
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: VibeTalkColors.textPrimary,
          ),
        )
            .animate()
            .fadeIn()
            .slideX(begin: -0.3, end: 0),
        
        Spacer(),
        
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
            child: Icon(
              Icons.chat_bubble_rounded,
              size: 25,
              color: VibeTalkColors.onPrimary,
            ),
          ),
        )
            .animate()
            .scale(delay: Duration(milliseconds: 200)),
        
        Spacer(),
        
        SizedBox(width: 48), // Balance the back button
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome Back!',
          style: Theme.of(Get.context!).textTheme.displayMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 300))
            .slideY(begin: 0.3, end: 0),
        
        SizedBox(height: VibeTalkSpacing.sm),
        
        Text(
          'Sign in to continue to VibeTalk',
          style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
            color: VibeTalkColors.textSecondary,
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 400))
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildLoginForm(AuthController authController) {
    return Form(
      key: authController.signInFormKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: authController.emailController,
            validator: authController.validateEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: VibeTalkColors.primaryColor,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 500))
              .slideX(begin: -0.3, end: 0),
          
          SizedBox(height: VibeTalkSpacing.lg),
          
          // Password field
          Obx(() => TextFormField(
            controller: authController.passwordController,
            validator: authController.validatePassword,
            obscureText: !authController.isPasswordVisible.value,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(
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
              .fadeIn(delay: Duration(milliseconds: 600))
              .slideX(begin: -0.3, end: 0),
          
          SizedBox(height: VibeTalkSpacing.lg),
          
          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: VibeTalkColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 700)),
          
          SizedBox(height: VibeTalkSpacing.lg),
          
          // Login button
          Obx(() => SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authController.isSignInLoading.value 
                  ? null 
                  : authController.signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: VibeTalkColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(VibeTalkRadius.lg),
                ),
                elevation: 8,
                shadowColor: VibeTalkColors.primaryColor.withOpacity(0.3),
              ),
              child: authController.isSignInLoading.value
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: VibeTalkColors.onPrimary,
                      ),
                    )
                  : Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ))
              .animate()
              .fadeIn(delay: Duration(milliseconds: 800))
              .scale(begin: Offset(0.8, 0.8), end: Offset(1, 1))
              .shimmer(
                delay: Duration(milliseconds: 1500),
                duration: Duration(milliseconds: 1000),
              ),
        ],
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: Theme.of(Get.context!).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.register),
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: VibeTalkColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 900));
  }
}