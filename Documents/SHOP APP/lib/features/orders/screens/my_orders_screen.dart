import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../providers/orders_provider.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(ordersProvider.notifier).loadOrders();
        },
        color: AppColors.primary,
        child: ordersState.isLoading
            ? const LoadingIndicator(message: 'Loading your orders...')
            : ordersState.orders.isEmpty
                ? EmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Orders Yet',
                    message: "You haven't placed any towel orders yet. Check out our collection!",
                    buttonText: 'Start Shopping',
                    onButtonPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ordersState.orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = ordersState.orders[index];

                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(order: order),
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
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    StatusBadge(status: order.orderStatus),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Formatters.formatDate(order.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),

                                // Items summary
                                if (order.items.isNotEmpty)
                                  Text(
                                    order.items
                                        .map((i) => '${i.quantity}x ${i.productName}')
                                        .join(', '),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      height: 1.3,
                                    ),
                                  )
                                else
                                  const Text(
                                    '1 or more towel items',
                                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  ),

                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${order.paymentMethod} • ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        StatusBadge(
                                          status: order.paymentStatus,
                                          isPaymentStatus: true,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      Formatters.formatCurrency(order.totalAmount),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
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
                  ),
      ),
    );
  }
}
