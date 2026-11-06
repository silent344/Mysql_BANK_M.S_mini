import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../admin/providers/admin_provider.dart';
import '../../admin/providers/store_settings_provider.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../admin/screens/admin_order_detail_screen.dart';
import '../../admin/screens/admin_pin_screen.dart';
import '../../customer_main_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();

    // Listen to notification taps to navigate admin directly to order
    NotificationService().onOrderNotificationTapped.listen((orderId) {
      final adminState = ref.read(adminProvider);
      final order = adminState.orders.where((o) => o.id == orderId).firstOrNull;
      if (order != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdminOrderDetailScreen(order: order),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!authState.isInitialized) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading SoftTouch Towels...'),
      );
    }

    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }

    // Role-based routing: Admin requires two-factor Master PIN before Admin Console
    if (authState.isAdmin) {
      final storeSettingsState = ref.watch(storeSettingsProvider);
      if (!storeSettingsState.isAdminPinVerified) {
        return const AdminPinScreen();
      }
      return const AdminDashboardScreen();
    }

    return const CustomerMainScreen();
  }
}
