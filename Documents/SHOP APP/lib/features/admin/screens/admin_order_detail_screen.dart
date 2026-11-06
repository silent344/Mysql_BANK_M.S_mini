import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../orders/models/order_model.dart';
import '../providers/admin_provider.dart';

class AdminOrderDetailScreen extends ConsumerStatefulWidget {
  final OrderModel order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends ConsumerState<AdminOrderDetailScreen> {
  late OrderModel _order;
  bool _isUpdating = false;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  void _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    final success = await ref
        .read(adminProvider.notifier)
        .updateOrderStatus(_order.id, newStatus);

    setState(() => _isUpdating = false);

    if (success && mounted) {
      setState(() => _order = _order.copyWith(orderStatus: newStatus));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
    }
  }

  void _markCodPaid() async {
    setState(() => _isUpdating = true);

    final success = await ref.read(adminProvider.notifier).markCodOrderPaid(_order.id);

    setState(() => _isUpdating = false);

    if (success && mounted) {
      setState(() => _order = _order.copyWith(paymentStatus: AppConstants.paymentStatusPaid));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('COD marked as Paid')),
      );
    }
  }

  void _downloadInvoice() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final itemsData = _order.items.map((i) => {
            'product_name': i.productName,
            'quantity': i.quantity,
            'unit_price': i.unitPrice,
            'total_price': i.totalPrice,
            'size': i.size,
            'color': i.color,
          }).toList();

      final pdfBytes = await PdfReceiptService.generateOrderReceipt(
        orderNumber: _order.orderNumber,
        orderDate: _order.createdAt,
        customerName: _order.customerName,
        customerPhone: _order.customerPhone,
        address: _order.addressSnapshot,
        items: itemsData,
        subtotal: _order.subtotal,
        shippingFee: _order.shippingFee,
        totalAmount: _order.totalAmount,
        paymentMethod: _order.paymentMethod,
        paymentStatus: _order.paymentStatus,
      );

      await PdfReceiptService.printOrShareReceipt(
        pdfBytes: pdfBytes,
        orderNumber: _order.orderNumber,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order: ${_order.orderNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Print Invoice',
            onPressed: _isGeneratingPdf ? null : _downloadInvoice,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order & Status Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${_order.orderNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        StatusBadge(status: _order.orderStatus),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Received: ${Formatters.formatDate(_order.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Update Fulfillment Status:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),

                    // Status Transition Buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppConstants.statusConfirmed,
                        AppConstants.statusShipped,
                        AppConstants.statusDelivered,
                        AppConstants.statusCancelled,
                      ].map((status) {
                        final isCurrent = _order.orderStatus == status;
                        return ElevatedButton(
                          onPressed: isCurrent || _isUpdating ? null : () => _updateStatus(status),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrent ? AppColors.primary : AppColors.surfaceVariant,
                            foregroundColor: isCurrent ? Colors.white : AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          child: Text(status),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Card & COD Collection Action
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment Details',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        StatusBadge(status: _order.paymentStatus, isPaymentStatus: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Method:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text(_order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text(
                          Formatters.formatCurrency(_order.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary),
                        ),
                      ],
                    ),

                    // Mark COD Paid action button
                    if (_order.paymentMethod == AppConstants.paymentMethodCOD &&
                        _order.paymentStatus != AppConstants.paymentStatusPaid) ...[
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                      CustomButton(
                        text: 'Mark COD as Collected / Paid',
                        icon: Icons.check_circle_outline_rounded,
                        backgroundColor: AppColors.success,
                        isLoading: _isUpdating,
                        onPressed: _markCodPaid,
                      ),
                    ],

                    if (_order.refundStatus == 'refund_pending') ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.warning),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Refund Pending: Customer cancelled after online payment. Please issue refund on Razorpay Dashboard.',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer & Delivery Address Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer & Delivery Address',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Text(_order.customerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('Phone: ${_order.customerPhone}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '${_order.addressSnapshot['line1'] ?? ''}, ${_order.addressSnapshot['line2'] ?? ''}, ${_order.addressSnapshot['city'] ?? ''}, ${_order.addressSnapshot['state'] ?? ''} - ${_order.addressSnapshot['pincode'] ?? ''}',
                      style: const TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Ordered Items Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Items',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _order.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final item = _order.items[index];
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

            const SizedBox(height: 24),
            CustomButton(
              text: 'Print / Share Invoice (PDF)',
              icon: Icons.print_rounded,
              isLoading: _isGeneratingPdf,
              backgroundColor: AppColors.secondary,
              onPressed: _downloadInvoice,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
