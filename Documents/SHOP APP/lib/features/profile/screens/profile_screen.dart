import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../address/screens/address_list_screen.dart';
import '../../admin/providers/store_settings_provider.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../admin/screens/admin_pin_screen.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/providers/auth_provider.dart';
import '../../orders/screens/my_orders_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar & Name Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        (profile?.name.isNotEmpty == true ? profile!.name[0] : 'U').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  profile?.name ?? 'Customer',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: profile?.isAdmin == true ? AppColors.primary : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  (profile?.role ?? 'customer').toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?.email ?? 'No email',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          if (profile?.phone.isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              profile!.phone,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      tooltip: 'Edit Profile',
                      onPressed: () => _showEditProfileSheet(context, ref, profile),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Navigation Links
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                    title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Track, view details, and download invoices'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                    title: const Text('Delivery Addresses', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Manage saved shipping addresses'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddressListScreen()),
                      );
                    },
                  ),
                    if (profile?.isAdmin == true) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
                        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Store orders, towel inventory & settings'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          final isPinVerified = ref.read(storeSettingsProvider).isAdminPinVerified;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => isPinVerified
                                  ? const AdminDashboardScreen()
                                  : const AdminPinScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Support & About Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.watch(storeSettingsProvider).settings.shopName.isNotEmpty
                          ? ref.watch(storeSettingsProvider).settings.shopName
                          : 'Store & Support',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          ref.watch(storeSettingsProvider).settings.adminPhone.isNotEmpty
                              ? ref.watch(storeSettingsProvider).settings.adminPhone
                              : '+91 98765 43210',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.email_outlined, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Text('support@softtouchtowels.com', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.storefront_outlined, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '12, Handloom Street, Textile City, India',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Logout Button
            CustomButton(
              text: 'Log Out',
              icon: Icons.logout_rounded,
              isOutlined: true,
              textColor: AppColors.error,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Log Out'),
                    content: const Text('Are you sure you want to log out of your account?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref.read(authProvider.notifier).signOut();
                        },
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref, UserProfile? profile) {
    final nameController = TextEditingController(text: profile?.name ?? '');
    final phoneController = TextEditingController(text: profile?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Profile Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your phone number' : null,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          profile?.email ?? 'No email',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      const Text(
                        '(Cannot change)',
                        style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Save Changes',
                  icon: Icons.check_rounded,
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.of(ctx).pop();
                      final success = await ref.read(authProvider.notifier).updateCustomerProfile(
                            name: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Profile updated and saved to Supabase!'
                                  : 'Failed to update profile',
                            ),
                            duration: const Duration(milliseconds: 1800),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: success ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
