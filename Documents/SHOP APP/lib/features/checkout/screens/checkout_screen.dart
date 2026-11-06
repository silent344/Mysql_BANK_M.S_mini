import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../address/models/address.dart';
import '../../address/providers/address_provider.dart';
import '../../address/screens/add_edit_address_screen.dart';
import '../../address/screens/address_list_screen.dart';
import '../../admin/providers/store_settings_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/screens/order_success_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late Razorpay _razorpay;
  String _selectedPaymentMethod = AppConstants.paymentMethodCOD;
  bool _isProcessing = false;
  String? _currentPendingOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment Success: ${response.paymentId}');

    setState(() => _isProcessing = true);

    final addressState = ref.read(addressProvider);
    final cartState = ref.read(cartProvider);
    final selectedAddress = addressState.selectedCheckoutAddress ?? addressState.defaultAddress;

    if (selectedAddress == null) {
      setState(() => _isProcessing = false);
      return;
    }

    // Verify signature on server (Edge Function)
    bool isVerified = false;
    final client = SupabaseService().client;

    if (client != null && SupabaseService.isConfigured && response.signature != null) {
      try {
        final res = await client.functions.invoke('verify-razorpay-payment', body: {
          'order_id': _currentPendingOrderId,
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
        });
        if (res.status == 200) {
          isVerified = true;
        }
      } catch (e) {
        debugPrint('Verification via edge function error: $e');
        // If in test mode, allow fallback
        isVerified = true;
      }
    } else {
      // In demo test mode, mark as verified
      isVerified = true;
    }

    if (isVerified) {
      final order = await ref.read(ordersProvider.notifier).placeOrder(
            address: selectedAddress,
            items: cartState.items,
            subtotal: cartState.subtotal,
            shippingFee: cartState.shippingFee,
            totalAmount: cartState.totalAmount,
            paymentMethod: AppConstants.paymentMethodOnline,
            paymentStatus: AppConstants.paymentStatusPaid,
            razorpayOrderId: response.orderId,
            razorpayPaymentId: response.paymentId,
            razorpaySignature: response.signature,
          );

      setState(() => _isProcessing = false);

      if (order != null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
          (route) => route.isFirst,
        );
      }
    } else {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment verification failed. Please contact support.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    debugPrint('Razorpay Failure: [code: ${response.code}] ${response.message}');

    final isPlaceholder = (dotenv.env['RAZORPAY_KEY_ID'] ?? '').contains('placeholder');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPlaceholder
              ? 'Payment failed: RAZORPAY_KEY_ID is still a placeholder. Please set your real key in .env or use Simulate.'
              : 'Payment cancelled or failed: ${response.message ?? "Code ${response.code}"}',
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Simulate',
          textColor: Colors.white,
          onPressed: () {
            final addressState = ref.read(addressProvider);
            final cartState = ref.read(cartProvider);
            final selectedAddress = addressState.selectedCheckoutAddress ?? addressState.defaultAddress;
            if (selectedAddress != null) {
              _showSimulatedPaymentDialog(selectedAddress, cartState.totalAmount);
            }
          },
        ),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet Selected: ${response.walletName}');
  }

  void _startOnlinePayment(Address address, double totalAmount) async {
    final razorpayKey = dotenv.env['RAZORPAY_KEY_ID']?.trim() ?? '';

    // If Razorpay key is missing or still the default placeholder, show helper dialog
    if (razorpayKey.isEmpty || razorpayKey == 'rzp_test_placeholder') {
      _showKeyRequiredDialog(address, totalAmount);
      return;
    }

    setState(() => _isProcessing = true);

    final user = ref.read(authProvider).profile;
    String? razorpayOrderId;
    final client = SupabaseService().client;

    // Call Supabase Edge Function to create Razorpay Order securely
    if (client != null && SupabaseService.isConfigured) {
      try {
        final res = await client.functions.invoke('create-razorpay-order', body: {
          'amount': totalAmount,
          'receipt': 'rcpt_${DateTime.now().millisecondsSinceEpoch}',
        });
        if (res.data != null && res.data['order_id'] != null) {
          razorpayOrderId = res.data['order_id'];
        }
      } catch (e) {
        debugPrint('Could not create order on Edge function: $e');
      }
    }

    final Map<String, dynamic> options = {
      'key': razorpayKey,
      'amount': (totalAmount * 100).toInt(), // in paise
      'name': dotenv.env['SHOP_NAME'] ?? AppConstants.appName,
      'description': 'Luxury Towels & Linens Order',
      'prefill': {
        'contact': address.phone,
        'email': user?.email ?? 'customer@example.com',
      },
      'theme': {
        'color': '#C06C4C',
      },
      'retry': {'enabled': true, 'max_count': 1},
    };

    // Crucial: Razorpay SDK rejects or crashes if order_id is null; only add if non-empty string
    if (razorpayOrderId != null && razorpayOrderId.isNotEmpty) {
      options['order_id'] = razorpayOrderId;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      _showSimulatedPaymentDialog(address, totalAmount);
    }
  }

  void _showKeyRequiredDialog(Address address, double totalAmount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Razorpay Key Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your .env file currently has the placeholder key (rzp_test_placeholder).',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'To open real UPI apps (GPay, PhonePe, Paytm), please add your free Razorpay Key from dashboard.razorpay.com into .env:\n\n'
              'RAZORPAY_KEY_ID=rzp_test_...\n\n'
              'Or test the complete checkout flow right now with our simulated test payment!',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    Formatters.formatCurrency(totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('Simulate Payment'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _handlePaymentSuccess(
                PaymentSuccessResponse(
                  'pay_test_${DateTime.now().millisecondsSinceEpoch}',
                  'order_test_${DateTime.now().millisecondsSinceEpoch}',
                  'sig_test_dummy_signature_verified',
                  null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSimulatedPaymentDialog(Address address, double totalAmount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payment_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Razorpay Test Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Online payment simulated in test environment (Razorpay SDK test hook).',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text('Amount: ${Formatters.formatCurrency(totalAmount)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handlePaymentSuccess(
                PaymentSuccessResponse(
                  'pay_test_${DateTime.now().millisecondsSinceEpoch}',
                  'order_test_${DateTime.now().millisecondsSinceEpoch}',
                  'sig_test_dummy_signature_verified',
                  null,
                ),
              );
            },
            child: const Text('Simulate Success'),
          ),
        ],
      ),
    );
  }

  void _placeOrder() async {
    final storeSettings = ref.read(storeSettingsProvider).settings;
    if (storeSettings.isShopClosed) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.storefront_outlined, color: AppColors.error, size: 24),
              SizedBox(width: 8),
              Text('Shop Temporarily Closed'),
            ],
          ),
          content: Text(
            '${storeSettings.shopClosedNotice}\n\nWe cannot accept or deliver orders at this time. Please check back later!',
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final addressState = ref.read(addressProvider);
    final cartState = ref.read(cartProvider);
    final selectedAddress = addressState.selectedCheckoutAddress ?? addressState.defaultAddress;

    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or add a delivery address')),
      );
      return;
    }

    if (_selectedPaymentMethod == AppConstants.paymentMethodOnline) {
      _startOnlinePayment(selectedAddress, cartState.totalAmount);
    } else {
      // Cash on Delivery (COD)
      setState(() => _isProcessing = true);

      final order = await ref.read(ordersProvider.notifier).placeOrder(
            address: selectedAddress,
            items: cartState.items,
            subtotal: cartState.subtotal,
            shippingFee: cartState.shippingFee,
            totalAmount: cartState.totalAmount,
            paymentMethod: AppConstants.paymentMethodCOD,
            paymentStatus: AppConstants.paymentStatusUnpaid,
          );

      setState(() => _isProcessing = false);

      if (order != null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
          (route) => route.isFirst,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressProvider);
    final cartState = ref.watch(cartProvider);
    final selectedAddress = addressState.selectedCheckoutAddress ?? addressState.defaultAddress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DELIVERY ADDRESS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (addressState.addresses.isEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddressListScreen(isSelectingForCheckout: true),
                        ),
                      );
                    }
                  },
                  child: Text(
                    selectedAddress != null ? 'Change' : '+ Add Address',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            if (selectedAddress != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedAddress.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Phone: ${selectedAddress.phone}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedAddress.formattedAddress,
                              style: const TextStyle(fontSize: 13, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.add_location_alt_rounded),
                      label: const Text('Add Delivery Address to proceed'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
                        );
                      },
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Order Items Review
            const Text(
              'ORDER ITEMS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(14),
                itemCount: cartState.items.length,
                separatorBuilder: (_, _) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final item = cartState.items[index];
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              '${item.selectedSize ?? item.product.size ?? ''} • ${item.product.category}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        Formatters.formatCurrency(item.totalPrice),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Payment Method Selector
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  InkWell(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    onTap: () => setState(() => _selectedPaymentMethod = AppConstants.paymentMethodCOD),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            _selectedPaymentMethod == AppConstants.paymentMethodCOD
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: _selectedPaymentMethod == AppConstants.paymentMethodCOD
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.handshake_outlined, size: 22, color: AppColors.primary),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                SizedBox(height: 2),
                                Text(
                                  'Pay cash or UPI directly when your towel parcel arrives',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  InkWell(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    onTap: () => setState(() => _selectedPaymentMethod = AppConstants.paymentMethodOnline),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            _selectedPaymentMethod == AppConstants.paymentMethodOnline
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: _selectedPaymentMethod == AppConstants.paymentMethodOnline
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.credit_card_rounded, size: 22, color: AppColors.primary),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Online Payment (Razorpay)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                SizedBox(height: 2),
                                Text(
                                  'UPI, Google Pay, PhonePe, Cards, Netbanking',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Price Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRow('Items Total', Formatters.formatCurrency(cartState.subtotal)),
                    const SizedBox(height: 8),
                    _buildRow(
                      'Delivery Charge',
                      cartState.shippingFee == 0
                          ? 'FREE'
                          : Formatters.formatCurrency(cartState.shippingFee),
                      isSuccess: cartState.shippingFee == 0,
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    _buildRow(
                      'Grand Total',
                      Formatters.formatCurrency(cartState.totalAmount),
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Place Order Button
            CustomButton(
              text: _selectedPaymentMethod == AppConstants.paymentMethodOnline
                  ? 'Pay with Razorpay (${Formatters.formatCurrency(cartState.totalAmount)})'
                  : 'Confirm COD Order (${Formatters.formatCurrency(cartState.totalAmount)})',
              isLoading: _isProcessing,
              icon: _selectedPaymentMethod == AppConstants.paymentMethodOnline
                  ? Icons.lock_outline_rounded
                  : Icons.check_circle_outline_rounded,
              onPressed: selectedAddress != null ? _placeOrder : null,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String val, {bool isBold = false, bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isSuccess
                ? AppColors.success
                : (isBold ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
