import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../admin/providers/store_settings_provider.dart';
import '../providers/auth_provider.dart';

enum AuthRoleMode { customer, admin }
enum CustomerFormMode { login, register }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  AuthRoleMode _selectedRole = AuthRoleMode.customer;
  CustomerFormMode _customerMode = CustomerFormMode.login;

  // Keys
  final _customerLoginFormKey = GlobalKey<FormState>();
  final _customerRegFormKey = GlobalKey<FormState>();
  final _adminLoginFormKey = GlobalKey<FormState>();

  // Customer Login Controllers
  final _customerEmailController = TextEditingController();
  final _customerPasswordController = TextEditingController();
  bool _obscureCustomerPassword = true;

  // Customer Register Controllers
  final _regNameController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  bool _obscureRegPassword = true;

  // Admin Login Controllers
  final _adminEmailController = TextEditingController(text: 'kritikkhodiyar45@gmail.com');
  final _adminPasswordController = TextEditingController();
  final _adminPinController = TextEditingController();
  bool _obscureAdminPassword = true;
  bool _obscureAdminPin = true;

  @override
  void dispose() {
    _customerEmailController.dispose();
    _customerPasswordController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    _adminPinController.dispose();
    super.dispose();
  }

  void _submitCustomerLogin() async {
    if (!_customerLoginFormKey.currentState!.validate()) return;

    final email = _customerEmailController.text.trim();
    final password = _customerPasswordController.text;

    final success = await ref.read(authProvider.notifier).signInWithEmail(
          email: email,
          password: password,
        );

    if (!success && mounted) {
      final err = ref.read(authProvider).errorMessage ?? 'Login failed. Please check your credentials.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _submitCustomerRegister() async {
    if (!_customerRegFormKey.currentState!.validate()) return;

    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;
    final name = _regNameController.text.trim();
    final phone = _regPhoneController.text.trim();

    if (email.toLowerCase() == 'kritikkhodiyar45@gmail.com') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This email is reserved for the store administrator. Please use your personal email.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).signUpWithEmail(
          email: email,
          password: password,
          name: name,
          phone: phone,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer account created! Welcome to Towel Town.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      final err = ref.read(authProvider).errorMessage ?? 'Registration failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _submitAdminLogin() async {
    if (!_adminLoginFormKey.currentState!.validate()) return;

    final email = _adminEmailController.text.trim();
    final password = _adminPasswordController.text;
    final pin = _adminPinController.text.trim();

    // 1. Strict single-admin check
    if (email.toLowerCase() != 'kritikkhodiyar45@gmail.com') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Access Denied: This portal is exclusively for the store owner (kritikkhodiyar45@gmail.com). Customers, please switch to the Customer tab.',
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // 2. Validate Master Security PIN (Password 2)
    final isPinValid = ref.read(storeSettingsProvider.notifier).verifyAdminPin(pin);
    if (!isPinValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect Master Security PIN. Please verify your 2nd security password.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 3. Authenticate with email & password (Password 1)
    final success = await ref.read(authProvider.notifier).signInWithEmail(
          email: email,
          password: password,
        );

    if (!success && mounted) {
      ref.read(storeSettingsProvider.notifier).clearAdminPinVerification();
      final err = ref.read(authProvider).errorMessage ?? 'Admin login failed. Please check your password.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final storeSettings = ref.watch(storeSettingsProvider).settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branding Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                  ),
                  child: const Icon(
                    Icons.dry_cleaning_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  storeSettings.shopName.isNotEmpty ? storeSettings.shopName : AppConstants.appName,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 26,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appTagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 24),

                // TOP 2-OPTION SWITCHER: Customer vs Store Admin
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // Option 1: Customer (Login & Register)
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            setState(() => _selectedRole = AuthRoleMode.customer);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == AuthRoleMode.customer
                                  ? AppColors.surface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _selectedRole == AuthRoleMode.customer
                                  ? const [
                                      BoxShadow(
                                        color: AppColors.shadow,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 18,
                                  color: _selectedRole == AuthRoleMode.customer
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Customer Portal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _selectedRole == AuthRoleMode.customer
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: _selectedRole == AuthRoleMode.customer
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Option 2: Store Admin (Login Only)
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            setState(() => _selectedRole = AuthRoleMode.admin);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == AuthRoleMode.admin
                                  ? AppColors.surface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _selectedRole == AuthRoleMode.admin
                                  ? const [
                                      BoxShadow(
                                        color: AppColors.shadow,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.admin_panel_settings_outlined,
                                  size: 18,
                                  color: _selectedRole == AuthRoleMode.admin
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Admin Login',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _selectedRole == AuthRoleMode.admin
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: _selectedRole == AuthRoleMode.admin
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Card Containing either Customer Forms (Login/Register) or Admin Form (Login Only)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _selectedRole == AuthRoleMode.customer
                        ? _buildCustomerView(authState)
                        : _buildAdminView(authState),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. CUSTOMER VIEW (Login & Register Switcher)
  // ==========================================
  Widget _buildCustomerView(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-switcher for Customer: Login vs Register
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _customerMode == CustomerFormMode.login
                        ? AppColors.primaryLight
                        : Colors.transparent,
                    foregroundColor: _customerMode == CustomerFormMode.login
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    setState(() => _customerMode = CustomerFormMode.login);
                  },
                  child: const Text('Customer Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _customerMode == CustomerFormMode.register
                        ? AppColors.primaryLight
                        : Colors.transparent,
                    foregroundColor: _customerMode == CustomerFormMode.register
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    setState(() => _customerMode = CustomerFormMode.register);
                  },
                  child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        if (_customerMode == CustomerFormMode.login) ...[
          // CUSTOMER LOGIN FORM
          Form(
            key: _customerLoginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sign in to access your cart, orders & addresses',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  label: 'Customer Email',
                  hint: 'name@example.com',
                  controller: _customerEmailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password
                CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _customerPasswordController,
                  obscureText: _obscureCustomerPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCustomerPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscureCustomerPassword = !_obscureCustomerPassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your password';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomButton(
                  text: 'Sign In as Customer',
                  isLoading: authState.isLoading,
                  onPressed: _submitCustomerLogin,
                ),
                const SizedBox(height: 16),

                // Switch to Register option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _customerMode = CustomerFormMode.register);
                        },
                        child: const Text(
                          'Register Here',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // CUSTOMER REGISTRATION FORM
          Form(
            key: _customerRegFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join Towel Town',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Create your customer account to start shopping',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Full Name
                CustomTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _regNameController,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Phone
                CustomTextField(
                  label: 'Phone Number',
                  hint: '9876543210',
                  controller: _regPhoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your phone number';
                    if (v.trim().length < 10) return 'Enter a valid 10-digit phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Email
                CustomTextField(
                  label: 'Email Address',
                  hint: 'name@example.com',
                  controller: _regEmailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password
                CustomTextField(
                  label: 'Create Password',
                  hint: '••••••••',
                  controller: _regPasswordController,
                  obscureText: _obscureRegPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRegPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please create a password';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomButton(
                  text: 'Create Customer Account',
                  isLoading: authState.isLoading,
                  onPressed: _submitCustomerRegister,
                ),
                const SizedBox(height: 16),

                // Switch to Login option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _customerMode = CustomerFormMode.login);
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================
  // 2. STORE ADMIN VIEW (Login Only - No Register)
  // ==========================================
  Widget _buildAdminView(AuthState authState) {
    return Form(
      key: _adminLoginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.security_rounded, size: 20, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store Admin Portal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Login only • Private & restricted',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Security banner informing that registration is strictly disabled
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_rounded, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Admin account registration is disabled. Only the verified store owner can log in.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Admin Email
          CustomTextField(
            label: 'Admin Email',
            hint: 'kritikkhodiyar45@gmail.com',
            controller: _adminEmailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter admin email';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Password 1: Account Login Password
          CustomTextField(
            label: 'Account Password (Password 1)',
            hint: '••••••••',
            controller: _adminPasswordController,
            obscureText: _obscureAdminPassword,
            prefixIcon: const Icon(Icons.password_rounded, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureAdminPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textTertiary,
              ),
              onPressed: () => setState(() => _obscureAdminPassword = !_obscureAdminPassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your login password';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Password 2: Master Security PIN
          CustomTextField(
            label: 'Master Security PIN (Password 2)',
            hint: 'Enter 4-digit PIN (Default: 8845)',
            controller: _adminPinController,
            keyboardType: TextInputType.number,
            obscureText: _obscureAdminPin,
            prefixIcon: const Icon(Icons.pin_rounded, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureAdminPin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textTertiary,
              ),
              onPressed: () => setState(() => _obscureAdminPin = !_obscureAdminPin),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your Master Security PIN';
              if (v.trim().length < 4) return 'PIN must be at least 4 digits';
              return null;
            },
          ),
          const SizedBox(height: 20),

          CustomButton(
            text: 'Admin Sign In',
            icon: Icons.lock_open_rounded,
            isLoading: authState.isLoading,
            onPressed: _submitAdminLogin,
          ),
          const SizedBox(height: 14),

          // Clarification text
          const Center(
            child: Text(
              'Looking to buy towels? Switch to the "Customer Portal" tab above.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
