import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/empty_view.dart';
import '../providers/address_provider.dart';
import 'add_edit_address_screen.dart';

class AddressListScreen extends ConsumerWidget {
  final bool isSelectingForCheckout;

  const AddressListScreen({
    super.key,
    this.isSelectingForCheckout = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isSelectingForCheckout ? 'Select Delivery Address' : 'Saved Addresses'),
      ),
      body: addressState.addresses.isEmpty
          ? EmptyView(
              icon: Icons.location_on_outlined,
              title: 'No Addresses Saved',
              message: 'Add a delivery address to ensure fast and accurate doorstep delivery.',
              buttonText: 'Add New Address',
              onButtonPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
                );
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: addressState.addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = addressState.addresses[index];
                final isSelected =
                    addressState.selectedCheckoutAddress?.id == address.id;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected && isSelectingForCheckout
                          ? AppColors.primary
                          : AppColors.border,
                      width: isSelected && isSelectingForCheckout ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (address.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Phone: ${address.phone}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.formattedAddress,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.3),
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            if (isSelectingForCheckout)
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: Icon(
                                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                    size: 16,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                  label: Text(
                                    isSelected ? 'Selected' : 'Deliver Here',
                                    style: TextStyle(
                                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primary : AppColors.border,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  onPressed: () {
                                    ref.read(addressProvider.notifier).selectCheckoutAddress(address);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              )
                            else if (!address.isDefault)
                              TextButton(
                                onPressed: () {
                                  ref.read(addressProvider.notifier).setDefaultAddress(address.id);
                                },
                                child: const Text('Set as Default', style: TextStyle(fontSize: 12)),
                              ),

                            const Spacer(),

                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddEditAddressScreen(existingAddress: address),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Address'),
                                    content: const Text('Are you sure you want to remove this delivery address?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                          ref.read(addressProvider.notifier).deleteAddress(address.id);
                                        },
                                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: CustomButton(
          text: 'Add New Delivery Address',
          icon: Icons.add_rounded,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
            );
          },
        ),
      ),
    );
  }
}
