import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isPaymentStatus;

  const StatusBadge({
    super.key,
    required this.status,
    this.isPaymentStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    if (isPaymentStatus) {
      switch (status.toLowerCase()) {
        case AppConstants.paymentStatusPaid:
          bg = AppColors.successLight;
          fg = AppColors.success;
          icon = Icons.check_circle_rounded;
          break;
        case AppConstants.paymentStatusUnpaid:
          bg = AppColors.warningLight;
          fg = AppColors.warning;
          icon = Icons.pending_rounded;
          break;
        case AppConstants.paymentStatusRefunded:
          bg = AppColors.infoLight;
          fg = AppColors.info;
          icon = Icons.replay_rounded;
          break;
        default:
          bg = AppColors.errorLight;
          fg = AppColors.error;
          icon = Icons.cancel_rounded;
      }
    } else {
      switch (status) {
        case AppConstants.statusPlaced:
          bg = AppColors.infoLight;
          fg = AppColors.info;
          icon = Icons.schedule_rounded;
          break;
        case AppConstants.statusConfirmed:
          bg = AppColors.primaryLight;
          fg = AppColors.primaryDark;
          icon = Icons.thumb_up_alt_rounded;
          break;
        case AppConstants.statusShipped:
          bg = AppColors.warningLight;
          fg = AppColors.warning;
          icon = Icons.local_shipping_rounded;
          break;
        case AppConstants.statusDelivered:
          bg = AppColors.successLight;
          fg = AppColors.success;
          icon = Icons.check_circle_rounded;
          break;
        case AppConstants.statusCancelled:
          bg = AppColors.errorLight;
          fg = AppColors.error;
          icon = Icons.cancel_rounded;
          break;
        default:
          bg = AppColors.surfaceVariant;
          fg = AppColors.textSecondary;
          icon = Icons.info_outline_rounded;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
