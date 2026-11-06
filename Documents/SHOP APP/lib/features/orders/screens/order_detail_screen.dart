import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/order_model.dart';
import '../providers/orders_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  late OrderModel _currentOrder;
  bool _isDownloadingPdf = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  void _downloadOrSharePdf() async {
    setState(() => _isDownloadingPdf = true);

    try {
      final itemsData = _currentOrder.items.map((i) => {
            'product_name': i.productName,
            'quantity': i.quantity,
            'unit_price': i.unitPrice,
            'total_price': i.totalPrice,
            'size': i.size,
            'color': i.color,
          }).toList();

      final pdfBytes = await PdfReceiptService.generateOrderReceipt(
        orderNumber: _currentOrder.orderNumber,
        orderDate: _currentOrder.createdAt,
        customerName: _currentOrder.customerName,
        customerPhone: _currentOrder.customerPhone,
        address: _currentOrder.addressSnapshot,
        items: itemsData,
        subtotal: _currentOrder.subtotal,
        shippingFee: _currentOrder.shippingFee,
        totalAmount: _currentOrder.totalAmount,
        paymentMethod: _currentOrder.paymentMethod,
        paymentStatus: _currentOrder.paymentStatus,
      );

      await PdfReceiptService.printOrShareReceipt(
        pdfBytes: pdfBytes,
        orderNumber: _currentOrder.orderNumber,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not download PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloadingPdf = false);
    }
  }

  void _showCancelConfirmationDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this order?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_currentOrder.isPaidOnline) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ℹ️ Since this was paid online, your order will be marked as "Refund Pending". The shop owner will process your refund to the original payment source.',
                  style: TextStyle(fontSize: 12, color: AppColors.info),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Reason for cancellation (optional):', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Changed my mind, ordered wrong size',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isCancelling = true);

              final success = await ref.read(ordersProvider.notifier).cancelOrder(
                    orderId: _currentOrder.id,
                    reason: reasonController.text.trim(),
                  );

              setState(() => _isCancelling = false);

              if (success && mounted) {
                setState(() {
                  _currentOrder = _currentOrder.copyWith(
                    orderStatus: AppConstants.statusCancelled,
                    cancelReason: reasonController.text.trim(),
                    refundStatus: _currentOrder.isPaidOnline ? 'refund_pending' : 'none',
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled successfully')),
                );
              }
            },
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to live updates of this order if changed by admin
    final ordersState = ref.watch(ordersProvider);
    final freshOrder = ordersState.orders.where((o) => o.id == _currentOrder.id).firstOrNull;
    if (freshOrder != null) {
      _currentOrder = freshOrder;
    }

    final order = _currentOrder;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(order.orderNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Download Invoice',
            onPressed: _isDownloadingPdf ? null : _downloadOrSharePdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Status',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        StatusBadge(status: order.orderStatus),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Placed on ${Formatters.formatDate(order.createdAt)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),

                    // Refund notice if applicable
                    if (order.refundStatus == 'refund_pending') ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.replay_rounded, size: 20, color: AppColors.info),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Refund Pending: Shop owner will review and initiate the online refund.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (order.cancelReason != null && order.cancelReason!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Cancellation reason: "${order.cancelReason}"',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.error),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Delivery Address Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Delivery Address',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('Phone: ${order.customerPhone}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '${order.addressSnapshot['line1'] ?? ''}, ${order.addressSnapshot['line2'] ?? ''}, ${order.addressSnapshot['city'] ?? ''}, ${order.addressSnapshot['state'] ?? ''} - ${order.addressSnapshot['pincode'] ?? ''}',
                      style: const TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Items Purchased Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items in Order',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final item = order.items[index];
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
                                    item.productName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  if (item.size != null || item.color != null)
                                    Text(
                                      '${item.size ?? ''} • ${item.color ?? ''}',
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment & Bill Summary',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Payment Method', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text(order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Payment Status', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        StatusBadge(status: order.paymentStatus, isPaymentStatus: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    _buildRow('Subtotal', Formatters.formatCurrency(order.subtotal)),
                    const SizedBox(height: 6),
                    _buildRow('Delivery Fee', order.shippingFee == 0 ? 'FREE' : Formatters.formatCurrency(order.shippingFee)),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    _buildRow('Total Paid / Due', Formatters.formatCurrency(order.totalAmount), isBold: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // PDF Invoice Button
            CustomButton(
              text: 'Download / Share Receipt (PDF)',
              icon: Icons.picture_as_pdf_rounded,
              isLoading: _isDownloadingPdf,
              backgroundColor: AppColors.secondary,
              onPressed: _downloadOrSharePdf,
            ),

            // Cancel Order Action (Allowed only when status is Placed or Confirmed)
            if (order.isCancellable) ...[
              const SizedBox(height: 12),
              CustomButton(
                text: 'Cancel Order',
                isOutlined: true,
                textColor: AppColors.error,
                isLoading: _isCancelling,
                onPressed: _showCancelConfirmationDialog,
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
