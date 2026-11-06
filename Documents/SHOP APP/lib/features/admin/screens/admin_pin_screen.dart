import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/store_settings_provider.dart';

class AdminPinScreen extends ConsumerStatefulWidget {
  const AdminPinScreen({super.key});

  @override
  ConsumerState<AdminPinScreen> createState() => _AdminPinScreenState();
}

class _AdminPinScreenState extends ConsumerState<AdminPinScreen> {
  final _pinController = TextEditingController();
  bool _obscurePin = true;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verify() {
    final entered = _pinController.text.trim();
    if (entered.isEmpty) {
      setState(() => _errorMessage = 'Please enter your Master Security PIN');
      return;
    }

    final success = ref.read(storeSettingsProvider.notifier).verifyAdminPin(entered);
    if (!success) {
      setState(() {
        _errorMessage = 'Incorrect Master Security PIN. Access denied.';
      });
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(storeSettingsProvider).settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Security Shield Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Admin Security Key',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Two-factor privacy protection enabled for ${settings.shopName}. Please enter your secondary Master PIN to access the Store Console.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // PIN Entry Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Master Security PIN',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 8),

                        TextField(
                          controller: _pinController,
                          obscureText: _obscurePin,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _verify(),
                          decoration: InputDecoration(
                            hintText: 'Enter Admin Security Key',
                            prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.textTertiary,
                              ),
                              onPressed: () => setState(() => _obscurePin = !_obscurePin),
                            ),
                            errorText: _errorMessage,
                          ),
                          onChanged: (_) {
                            if (_errorMessage != null) {
                              setState(() => _errorMessage = null);
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        CustomButton(
                          text: 'Unlock Admin Console',
                          icon: Icons.key_rounded,
                          onPressed: _verify,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Sign Out Option
                TextButton.icon(
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Sign Out of Admin Account'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                  onPressed: () => ref.read(authProvider.notifier).signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
