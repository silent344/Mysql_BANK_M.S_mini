import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/order_model.dart';
import 'order_detail_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  bool _isGeneratingPdf = false;

  void _downloadOrSharePdf() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final itemsData = widget.order.items.map((i) => {
            'product_name': i.productName,
            'quantity': i.quantity,
            'unit_price': i.unitPrice,
            'total_price': i.totalPrice,
            'size': i.size,
            'color': i.color,
          }).toList();

      final pdfBytes = await PdfReceiptService.generateOrderReceipt(
        orderNumber: widget.order.orderNumber,
        orderDate: widget.order.createdAt,
        customerName: widget.order.customerName,
        customerPhone: widget.order.customerPhone,
        address: widget.order.addressSnapshot,
        items: itemsData,
        subtotal: widget.order.subtotal,
        shippingFee: widget.order.shippingFee,
        totalAmount: widget.order.totalAmount,
        paymentMethod: widget.order.paymentMethod,
        paymentStatus: widget.order.paymentStatus,
      );

      await PdfReceiptService.printOrShareReceipt(
        pdfBytes: pdfBytes,
        orderNumber: widget.order.orderNumber,
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
    final order = widget.order;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Celebration Icon
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 64,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Order Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'We have received your order and are packing your plush towels with care.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Order Meta Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Order Number',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            Text(
                              order.orderNumber,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            Text(
                              Formatters.formatCurrency(order.totalAmount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Payment Method',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            Text(
                              order.paymentMethod,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Payment Status',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            StatusBadge(status: order.paymentStatus, isPaymentStatus: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Action Buttons
                CustomButton(
                  text: 'Download / Share Invoice (PDF)',
                  icon: Icons.picture_as_pdf_rounded,
                  isLoading: _isGeneratingPdf,
                  backgroundColor: AppColors.secondary,
                  onPressed: _downloadOrSharePdf,
                ),
                const SizedBox(height: 12),

                CustomButton(
                  text: 'View Order Details',
                  isOutlined: true,
                  icon: Icons.receipt_long_rounded,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
                    );
                  },
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Back to Home / Continue Shopping'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
