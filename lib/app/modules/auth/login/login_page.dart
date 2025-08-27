import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_controller.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/controllers/theme_controller.dart';

/// Login page with responsive design
class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final layoutInfo = themeController.getLayoutInfo(context);
    
    return Scaffold(
      body: SafeArea(
        child: layoutInfo.useWideLayout ? _buildWideLayout(context) : _buildNarrowLayout(context),
      ),
    );
  }
  
  /// Build layout for screens >= 900px (2-column layout)
  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Brand/Info
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: _buildBrandSection(context),
          ),
        ),
        
        // Right side - Login form
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingXLarge),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildLoginForm(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build layout for screens < 900px (1-column layout)
  Widget _buildNarrowLayout(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            const SizedBox(height: AppConstants.paddingXLarge),
            
            // Compact brand section
            _buildCompactBrandSection(context),
            
            const SizedBox(height: AppConstants.paddingXLarge),
            
            // Login form
            _buildLoginForm(context),
          ],
        ),
      ),
    );
  }
  
  /// Build brand section for wide layout
  Widget _buildBrandSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.flutter_dash,
            size: 80,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          Text(
            'Welcome to',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          Text(
            'A comprehensive Flutter template with GetX, Forme, Firebase, and RBAC for enterprise applications.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build compact brand section for narrow layout
  Widget _buildCompactBrandSection(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.flutter_dash,
          size: 60,
          color: Theme.of(context).colorScheme.primary,
        ),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  /// Build login form
  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign In',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Email field
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: controller.validateEmailField,
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Password field
          Obx(() => TextFormField(
                controller: controller.passwordController,
                obscureText: !controller.isPasswordVisible,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
                validator: controller.validatePasswordField,
                onFieldSubmitted: (_) => controller.signInWithEmail(),
              ),
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Remember me and forgot password row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Row(
                    children: [
                      Checkbox(
                        value: controller.rememberMe,
                        onChanged: (_) => controller.toggleRememberMe(),
                      ),
                      const Text('Remember me'),
                    ],
                  ),
              ),
              
              TextButton(
                onPressed: controller.goToForgotPassword,
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Sign in button
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading ? null : controller.signInWithEmail,
                child: controller.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign In'),
              ),
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                child: Text(
                  'OR',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Social login buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.isLoading ? null : controller.signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Google'),
                ),
              ),
              
              const SizedBox(width: AppConstants.paddingMedium),
              
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.isLoading ? null : controller.signInWithApple,
                  icon: const Icon(Icons.apple, size: 24),
                  label: const Text('Apple'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Sign up link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              TextButton(
                onPressed: controller.goToRegister,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}