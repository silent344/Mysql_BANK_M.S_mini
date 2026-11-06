import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/empty_view.dart';
import '../../admin/providers/store_settings_provider.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final storeSettings = ref.watch(storeSettingsProvider).settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (cartState.items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Are you sure you want to remove all items from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref.read(cartProvider.notifier).clearCart();
                        },
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: cartState.items.isEmpty
          ? EmptyView(
              icon: Icons.shopping_bag_outlined,
              title: 'Your Cart is Empty',
              message: 'Discover our ultra-soft Turkish cotton towels and bath sheets to pamper yourself.',
              buttonText: 'Shop Towels Now',
              onButtonPressed: () => Navigator.of(context).pop(),
            )
          : Column(
              children: [
                // Shop Closed Alert Banner
                if (storeSettings.isShopClosed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: AppColors.errorLight,
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 22, color: AppColors.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Store is Currently Closed',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                storeSettings.shopClosedNotice,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Free Delivery Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: cartState.qualifiesForFreeShipping
                      ? AppColors.successLight
                      : AppColors.primaryLight,
                  child: Row(
                    children: [
                      Icon(
                        cartState.qualifiesForFreeShipping
                            ? Icons.check_circle_rounded
                            : Icons.local_shipping_outlined,
                        size: 20,
                        color: cartState.qualifiesForFreeShipping
                            ? AppColors.success
                            : AppColors.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cartState.qualifiesForFreeShipping
                              ? '🎉 All items in your cart have FREE Delivery!'
                              : 'Delivery Charges: ${Formatters.formatCurrency(cartState.shippingFee)} applied across items',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cartState.qualifiesForFreeShipping
                                ? AppColors.success
                                : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart Items List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Product Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: CachedNetworkImage(
                                    imageUrl: item.product.imageUrl,
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

                              // Item Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${item.product.category} • ${item.selectedSize ?? item.product.size ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          Formatters.formatCurrency(item.product.price),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: item.product.hasFreeDelivery
                                                ? AppColors.successLight
                                                : AppColors.surfaceVariant,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.product.hasFreeDelivery
                                                ? 'Free Delivery'
                                                : '+ ₹${item.product.deliveryCharge.toInt()} delivery',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: item.product.hasFreeDelivery
                                                ? AppColors.success
                                                : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Controls
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      item.quantity == 1 ? Icons.delete_outline_rounded : Icons.remove,
                                      size: 18,
                                      color: item.quantity == 1 ? AppColors.error : AppColors.textPrimary,
                                    ),
                                    onPressed: () {
                                      ref.read(cartProvider.notifier).decrementQuantity(item.productId);
                                    },
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: item.quantity < item.product.stock
                                        ? () {
                                            ref
                                                .read(cartProvider.notifier)
                                                .incrementQuantity(item.productId);
                                          }
                                        : null,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bill Breakdown Bottom Container
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                    border: const Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Column(
                    children: [
                      _buildPriceRow('Items Subtotal', Formatters.formatCurrency(cartState.subtotal)),
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        'Delivery Fee',
                        cartState.shippingFee == 0
                            ? 'FREE'
                            : Formatters.formatCurrency(cartState.shippingFee),
                        valueColor: cartState.shippingFee == 0 ? AppColors.success : null,
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      _buildPriceRow(
                        'Total Payable',
                        Formatters.formatCurrency(cartState.totalAmount),
                        isTotal: true,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: storeSettings.isShopClosed
                            ? 'Shop Closed (Ordering Paused)'
                            : 'Proceed to Checkout',
                        icon: storeSettings.isShopClosed
                            ? Icons.storefront_outlined
                            : Icons.lock_outline_rounded,
                        backgroundColor: storeSettings.isShopClosed
                            ? AppColors.textSecondary
                            : null,
                        onPressed: () {
                          if (storeSettings.isShopClosed) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Row(
                                  children: [
                                    Icon(
                                      Icons.storefront_outlined,
                                      color: AppColors.error,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Shop Temporarily Closed',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.errorLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        storeSettings.shopClosedNotice,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.error,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'We are unable to deliver products or accept orders at this time. Please check back soon once our store re-opens.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (isTotal ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
