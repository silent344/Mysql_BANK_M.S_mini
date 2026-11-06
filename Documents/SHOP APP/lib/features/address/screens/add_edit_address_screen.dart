import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/address.dart';
import '../providers/address_provider.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  final Address? existingAddress;

  const AddEditAddressScreen({super.key, this.existingAddress});

  @override
  ConsumerState<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _line1Controller;
  late TextEditingController _line2Controller;
  late TextEditingController _landmarkController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAddress;
    _nameController = TextEditingController(text: a?.name ?? '');
    _phoneController = TextEditingController(text: a?.phone ?? '');
    _line1Controller = TextEditingController(text: a?.line1 ?? '');
    _line2Controller = TextEditingController(text: a?.line2 ?? '');
    _landmarkController = TextEditingController(text: a?.landmark ?? '');
    _cityController = TextEditingController(text: a?.city ?? '');
    _stateController = TextEditingController(text: a?.state ?? '');
    _pincodeController = TextEditingController(text: a?.pincode ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final address = Address(
      id: widget.existingAddress?.id ?? '',
      userId: widget.existingAddress?.userId ?? '',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      line1: _line1Controller.text.trim(),
      line2: _line2Controller.text.trim(),
      landmark: _landmarkController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      isDefault: _isDefault,
    );

    bool success;
    if (widget.existingAddress != null) {
      success = await ref.read(addressProvider.notifier).updateAddress(address);
    } else {
      success = await ref.read(addressProvider.notifier).addAddress(address);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingAddress != null ? 'Address updated' : 'Address saved'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAddress != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Delivery Address' : 'Add New Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Full Name',
                        hint: 'Receiver full name',
                        controller: _nameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter full name' : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: '10-Digit Mobile Number',
                        hint: '9876543210',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                        validator: (v) => (v == null || v.trim().length != 10) ? 'Enter valid 10-digit number' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Flat / House No. / Building Name',
                        hint: 'e.g. Flat 402, Lotus Residency',
                        controller: _line1Controller,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Street / Colony / Area',
                        hint: 'e.g. Ring Road, Near City Mall',
                        controller: _line2Controller,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Landmark (Optional)',
                        hint: 'e.g. Opposite Central Park',
                        controller: _landmarkController,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'City',
                              hint: 'Surat',
                              controller: _cityController,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'City required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'Pincode',
                              hint: '395007',
                              controller: _pincodeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                              validator: (v) => (v == null || v.trim().length != 6) ? '6-digit pincode' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'State',
                        hint: 'Gujarat',
                        controller: _stateController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'State required' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Default address switch
              Card(
                child: SwitchListTile(
                  title: const Text(
                    'Set as Default Delivery Address',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Use this address automatically for future orders',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  value: _isDefault,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isDefault = val),
                ),
              ),

              const SizedBox(height: 24),
              CustomButton(
                text: isEditing ? 'Update Address' : 'Save Delivery Address',
                isLoading: _isSaving,
                onPressed: _save,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
