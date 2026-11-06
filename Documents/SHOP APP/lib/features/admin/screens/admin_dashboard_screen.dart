import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/store_settings_provider.dart';
import 'admin_add_edit_product_screen.dart';
import 'admin_order_detail_screen.dart';
import '../../../core/services/notification_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 12,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings_rounded, size: 24, color: AppColors.primary),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    Icon(Icons.circle, size: 7, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Live Sync',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            tooltip: 'Add Towel',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminAddEditProductScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Test Order Notification',
            onPressed: () async {
              await NotificationService().showNewOrderAlert(
                orderNumber: 'TEST-9999',
                customerName: 'Rahul Sharma',
                totalAmount: 1299.0,
                paymentMethod: 'COD',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔔 Admin order alert sent! Check your phone notification bar.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log Out',
            onPressed: () {
              ref.read(storeSettingsProvider.notifier).clearAdminPinVerification();
              ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              icon: const Icon(Icons.receipt_long_rounded),
              text: 'Orders (${adminState.orders.length})',
            ),
            Tab(
              icon: const Icon(Icons.inventory_2_outlined),
              text: 'Towel Catalog (${adminState.products.length})',
            ),
            const Tab(
              icon: Icon(Icons.storefront_rounded),
              text: 'Store Settings',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Orders Management
          _buildOrdersTab(context, adminState),

          // Tab 2: Products Management
          _buildProductsTab(context, adminState),

          // Tab 3: Store Status & Settings
          const _StoreSettingsTabView(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              heroTag: 'admin_add_towel_fab',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminAddEditProductScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Add New Item',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            )
          : null,
    );
  }

  Widget _buildOrdersTab(BuildContext context, AdminState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(adminProvider.notifier).loadAllOrders(),
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          // KPI Metric Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildKpiCard('Total Orders', '${state.totalOrdersCount}', Icons.shopping_bag_outlined, AppColors.primary),
                  const SizedBox(width: 10),
                  _buildKpiCard('Pending', '${state.pendingOrdersCount}', Icons.hourglass_top_rounded, AppColors.warning),
                  const SizedBox(width: 10),
                  _buildKpiCard('Revenue', Formatters.formatCurrency(state.totalRevenue), Icons.currency_rupee_rounded, AppColors.success),
                ],
              ),
            ),
          ),

          // Status Filter Bar
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  'All',
                  AppConstants.statusPlaced,
                  AppConstants.statusConfirmed,
                  AppConstants.statusShipped,
                  AppConstants.statusDelivered,
                  AppConstants.statusCancelled,
                ].map((status) {
                  final isSelected = state.statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (_) => ref.read(adminProvider.notifier).setStatusFilter(status),
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Payment Type Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const Text('Payment:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 6,
                    children: ['All', 'COD', 'ONLINE'].map((p) {
                      final isSel = state.paymentFilter == p;
                      return ChoiceChip(
                        label: Text(p, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppColors.textPrimary)),
                        selected: isSel,
                        selectedColor: AppColors.secondary,
                        onSelected: (_) => ref.read(adminProvider.notifier).setPaymentFilter(p),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          if (state.isLoading)
            const SliverFillRemaining(child: LoadingIndicator(message: 'Loading orders...'))
          else if (state.filteredOrders.isEmpty)
            const SliverFillRemaining(
              child: EmptyView(
                icon: Icons.receipt_long_outlined,
                title: 'No Orders Found',
                message: 'No orders match the current filter selection.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = state.filteredOrders[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdminOrderDetailScreen(order: order),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    order.orderNumber,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  StatusBadge(status: order.orderStatus),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.customerName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '• ${order.customerPhone}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${order.items.length} item(s): ${order.items.map((i) => "${i.quantity}x ${i.productName}").join(", ")}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${order.paymentMethod} ',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      StatusBadge(status: order.paymentStatus, isPaymentStatus: true),
                                    ],
                                  ),
                                  Text(
                                    Formatters.formatCurrency(order.totalAmount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: state.filteredOrders.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(BuildContext context, AdminState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(adminProvider.notifier).loadAllProducts(),
      color: AppColors.primary,
      child: state.products.isEmpty
          ? EmptyView(
              icon: Icons.inventory_2_outlined,
              title: 'No Products in Catalog',
              message: 'Add towels to your shop catalog to start receiving customer orders.',
              buttonText: 'Add First Towel',
              onButtonPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminAddEditProductScreen()),
                );
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: state.products.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Prominent Top Action Banner
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Towel Catalog (${state.products.length} Items)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const Text(
                                'Manage pricing, sizes, colors and stock',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AdminAddEditProductScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                final product = state.products[index - 1];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(color: AppColors.surfaceVariant),
                              errorWidget: (_, _, _) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.dry_cleaning, size: 24),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title, Price, Stock
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${product.category} • ${product.gsm} GSM',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    Formatters.formatCurrency(product.price),
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: product.stock > 0 ? AppColors.surfaceVariant : AppColors.errorLight,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Stock: ${product.stock}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: product.stock > 0 ? AppColors.textPrimary : AppColors.error,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: product.hasFreeDelivery ? AppColors.successLight : AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      product.deliveryText,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: product.hasFreeDelivery ? AppColors.success : AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),

                        // Active Toggle & Edit/Delete
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 32,
                              child: Transform.scale(
                                scale: 0.82,
                                child: Switch(
                                  value: product.isActive,
                                  activeThumbColor: AppColors.primary,
                                  onChanged: (val) {
                                    ref.read(adminProvider.notifier).toggleProductActive(product.id, val);
                                  },
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  padding: const EdgeInsets.all(4),
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AdminAddEditProductScreen(existingProduct: product),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  padding: const EdgeInsets.all(4),
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Product'),
                                        content: Text('Permanently remove "${product.name}" from catalog?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                            onPressed: () async {
                                              Navigator.of(ctx).pop();
                                              final success = await ref.read(adminProvider.notifier).deleteProduct(product.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(success ? 'Product deleted from shop' : 'Failed to delete product'),
                                                    backgroundColor: success ? AppColors.success : AppColors.error,
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreSettingsTabView extends ConsumerStatefulWidget {
  const _StoreSettingsTabView();

  @override
  ConsumerState<_StoreSettingsTabView> createState() => _StoreSettingsTabViewState();
}

class _StoreSettingsTabViewState extends ConsumerState<_StoreSettingsTabView> {
  late TextEditingController _noticeController;
  late TextEditingController _phoneController;
  late TextEditingController _shopNameController;
  late TextEditingController _newPasswordController;
  late TextEditingController _newPinController;

  bool _isShopClosed = false;
  bool _broadcastNotification = true;
  bool _obscurePassword = true;
  bool _obscurePin = true;

  bool _isSavingStatus = false;
  bool _isSavingProfile = false;
  bool _isSavingPin = false;
  bool _isSavingShopName = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(storeSettingsProvider).settings;
    _isShopClosed = settings.isShopClosed;
    _noticeController = TextEditingController(text: settings.shopClosedNotice);
    _phoneController = TextEditingController(text: settings.adminPhone);
    _shopNameController = TextEditingController(text: settings.shopName);
    _newPasswordController = TextEditingController();
    _newPinController = TextEditingController();
  }

  @override
  void dispose() {
    _noticeController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _newPasswordController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  void _saveShopStatus() async {
    setState(() => _isSavingStatus = true);
    final success = await ref.read(storeSettingsProvider.notifier).setShopStatus(
          isClosed: _isShopClosed,
          notice: _noticeController.text.trim().isNotEmpty
              ? _noticeController.text.trim()
              : 'Shop is closed for some days so we cannot deliver your product right now.',
          broadcastNotification: _broadcastNotification,
        );
    setState(() => _isSavingStatus = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? (_isShopClosed
                  ? '⚠️ Shop is now CLOSED. Customer orders paused.'
                  : '✅ Shop is now OPEN for customer orders!')
              : 'Failed to update shop status'),
          backgroundColor: success
              ? (_isShopClosed ? AppColors.warning : AppColors.success)
              : AppColors.error,
        ),
      );
    }
  }

  void _saveProfile() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() => _isSavingProfile = true);
    final success = await ref.read(storeSettingsProvider.notifier).updateAdminDetails(
          phone: phone,
          newPassword: _newPasswordController.text.trim().isNotEmpty
              ? _newPasswordController.text.trim()
              : null,
        );
    setState(() => _isSavingProfile = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Admin phone & password updated' : 'Failed to update admin details'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
      if (success) {
        _newPasswordController.clear();
      }
    }
  }

  void _savePin() async {
    final pin = _newPinController.text.trim();
    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Master Security PIN must be at least 4 characters/digits'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSavingPin = true);
    final success = await ref.read(storeSettingsProvider.notifier).updateAdminSecurityPin(pin);
    setState(() => _isSavingPin = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Master Security PIN updated successfully!' : 'Failed to update PIN'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
      if (success) _newPinController.clear();
    }
  }

  void _saveShopName() async {
    final name = _shopNameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSavingShopName = true);
    final success = await ref.read(storeSettingsProvider.notifier).updateShopName(name);
    setState(() => _isSavingShopName = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Store name updated across all devices!' : 'Failed to update store name'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(storeSettingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (settingsState.isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(color: AppColors.primary),
            ),
          // 1. SHOP OPEN / CLOSED CONTROL CARD
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _isShopClosed ? AppColors.error : AppColors.success,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isShopClosed ? AppColors.errorLight : AppColors.successLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isShopClosed ? Icons.storefront_outlined : Icons.storefront_rounded,
                          color: _isShopClosed ? AppColors.error : AppColors.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Store Operating Status',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              _isShopClosed ? 'DELIVERIES CURRENTLY PAUSED' : 'ONLINE & ACCEPTING ORDERS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _isShopClosed ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _isShopClosed ? 'Shop is CLOSED' : 'Shop is OPEN',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text(
                      _isShopClosed
                          ? 'Customer checkouts will be blocked on the cart page and a popup notice will be shown.'
                          : 'Customers can place orders and have products delivered normally.',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _isShopClosed,
                    activeThumbColor: AppColors.error,
                    inactiveThumbColor: AppColors.success,
                    onChanged: (val) {
                      setState(() => _isShopClosed = val);
                    },
                  ),

                  if (_isShopClosed) ...[
                    const Divider(height: 24),
                    const Text(
                      'Customer Notice Message (Popup on App & Cart):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _noticeController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Shop is closed for some days so we cannot deliver your product...',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Quick Preset Templates:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          label: const Text('Shop closed for some days'),
                          onPressed: () => setState(() => _noticeController.text =
                              'Shop is closed for some days so we cannot deliver your product right now.'),
                        ),
                        ActionChip(
                          label: const Text('Personal emergency break'),
                          onPressed: () => setState(() => _noticeController.text =
                              'Shop is temporarily closed due to an emergency. We cannot serve you right now.'),
                        ),
                        ActionChip(
                          label: const Text('Inventory maintenance'),
                          onPressed: () => setState(() => _noticeController.text =
                              'Store is undergoing annual maintenance. Deliveries will resume in 3 days.'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Broadcast notification alert to all customer phones',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      value: _broadcastNotification,
                      onChanged: (val) => setState(() => _broadcastNotification = val ?? true),
                    ),
                  ],

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isShopClosed ? AppColors.error : AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: _isSavingStatus
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_outline_rounded),
                      label: Text(
                        _isShopClosed ? 'Save & Close Shop (Pause Orders)' : 'Save & Open Shop (Accept Orders)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isSavingStatus ? null : _saveShopStatus,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. ADMIN DETAILS & LOGIN PASSWORD
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text('Admin Profile & Login Password',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Exclusive Owner Account: kritikkhodiyar45@gmail.com',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Admin Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _newPasswordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Change Account Password (Optional)',
                      hintText: 'Leave empty to keep existing password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isSavingProfile ? null : _saveProfile,
                      child: _isSavingProfile
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Admin Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. MASTER SECURITY KEY (SECOND-FACTOR PIN)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text('Master Security Key (2nd Password)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Extra private security layer. Required to open Admin Console. Current PIN is set.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _newPinController,
                    obscureText: _obscurePin,
                    decoration: InputDecoration(
                      labelText: 'New Master Security Key / PIN',
                      hintText: 'e.g. 8845 or secret passkey',
                      prefixIcon: const Icon(Icons.key_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePin = !_obscurePin),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isSavingPin ? null : _savePin,
                      child: _isSavingPin
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save New Master PIN'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 4. STORE NAME
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.badge_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text('Shop Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Update the name displayed throughout the app and on invoices.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _shopNameController,
                    decoration: const InputDecoration(
                      labelText: 'Shop Name',
                      hintText: 'Towel Town',
                      prefixIcon: Icon(Icons.store_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isSavingShopName ? null : _saveShopName,
                      child: _isSavingShopName
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Shop Name'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

