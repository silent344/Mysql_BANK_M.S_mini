import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../products/models/product.dart';
import '../providers/admin_provider.dart';

class AdminAddEditProductScreen extends ConsumerStatefulWidget {
  final Product? existingProduct;

  const AdminAddEditProductScreen({super.key, this.existingProduct});

  @override
  ConsumerState<AdminAddEditProductScreen> createState() => _AdminAddEditProductScreenState();
}

class _AdminAddEditProductScreenState extends ConsumerState<AdminAddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _stockController;
  late TextEditingController _colorController;
  late TextEditingController _sizeController;
  late TextEditingController _materialController;
  late TextEditingController _gsmController;
  late TextEditingController _deliveryChargeController;

  String _selectedCategory = 'Bath Towel';
  bool _isActive = true;
  bool _isFreeDelivery = true;
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _originalPriceController = TextEditingController(text: p?.originalPrice?.toString() ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '20');
    _colorController = TextEditingController(text: p?.color ?? 'Natural Linen');
    _sizeController = TextEditingController(text: p?.size ?? '70 x 140 cm');
    _materialController = TextEditingController(text: p?.material ?? '100% Turkish Cotton');
    _gsmController = TextEditingController(text: p?.gsm.toString() ?? '550');

    final double initialCharge = p?.deliveryCharge ?? 0.0;
    _isFreeDelivery = initialCharge <= 0;
    _deliveryChargeController = TextEditingController(
      text: _isFreeDelivery ? '0' : (initialCharge % 1 == 0 ? initialCharge.toInt().toString() : initialCharge.toString()),
    );

    if (p != null) {
      _selectedCategory = p.category;
      _isActive = p.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _materialController.dispose();
    _gsmController.dispose();
    _deliveryChargeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedImageName = file.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final double deliveryCharge = _isFreeDelivery
        ? 0.0
        : (double.tryParse(_deliveryChargeController.text.trim()) ?? 0.0);

    final product = Product(
      id: widget.existingProduct?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      originalPrice: double.tryParse(_originalPriceController.text.trim()),
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      category: _selectedCategory,
      imageUrl: widget.existingProduct?.imageUrl ??
          'https://images.unsplash.com/photo-1616627547584-bf28cee262db?auto=format&fit=crop&w=800&q=80',
      color: _colorController.text.trim(),
      size: _sizeController.text.trim(),
      material: _materialController.text.trim(),
      gsm: int.tryParse(_gsmController.text.trim()) ?? 550,
      isActive: _isActive,
      deliveryCharge: deliveryCharge < 0 ? 0.0 : deliveryCharge,
    );

    bool success;
    if (widget.existingProduct != null) {
      success = await ref.read(adminProvider.notifier).updateProduct(
            product,
            imageBytes: _pickedImageBytes,
            filename: _pickedImageName,
          );
    } else {
      success = await ref.read(adminProvider.notifier).addProduct(
            product,
            imageBytes: _pickedImageBytes,
            filename: _pickedImageName,
          );
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingProduct != null ? 'Product updated' : 'Product added to shop'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      final err = ref.read(adminProvider).error ?? 'Could not save product. Please check connection and permissions.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $err'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProduct != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Towel Product' : 'Add New Towel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          color: AppColors.surfaceVariant,
                          child: _pickedImageBytes != null
                              ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                              : (widget.existingProduct != null
                                  ? CachedNetworkImage(
                                      imageUrl: widget.existingProduct!.imageUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined,
                                            size: 48, color: AppColors.primary),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Tap below to select photo from gallery',
                                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    )),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: Text(_pickedImageBytes != null || widget.existingProduct != null
                            ? 'Change Image'
                            : 'Upload Image to Supabase Storage'),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Basic Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Towel Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 14),

                      CustomTextField(
                        label: 'Product Title',
                        hint: 'e.g. Royal Turkish Plush Bath Towel',
                        controller: _nameController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Product title required' : null,
                      ),
                      const SizedBox(height: 14),

                      // Category Dropdown
                      const Text(
                        'Category',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(),
                        items: AppConstants.categories
                            .where((c) => c != 'All')
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        label: 'Description',
                        hint: 'Yarn quality, absorbency, softness, weaving details...',
                        controller: _descriptionController,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pricing & Stock Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pricing & Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Price (₹)',
                              hint: '799.00',
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'Original Price (₹)',
                              hint: '1299.00',
                              controller: _originalPriceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Stock Quantity',
                        hint: '45',
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) => (v == null || v.isEmpty) ? 'Stock count required' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Textile Specifications Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Textile Specifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'GSM (Weight/Density)',
                              hint: '550',
                              controller: _gsmController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'Dimensions / Size',
                              hint: '70 x 140 cm',
                              controller: _sizeController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Color Shade',
                              hint: 'Linen Sand',
                              controller: _colorController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'Cotton Material',
                              hint: '100% Turkish Cotton',
                              controller: _materialController,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Delivery & Shipping Charge Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Delivery & Shipping Charge',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Choose if this product has Free Delivery or set a specific delivery fee for customers.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Free Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          _isFreeDelivery
                              ? 'Customers will get Free Delivery on this item (₹0.00)'
                              : 'A custom delivery charge is applied to this item',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isFreeDelivery ? AppColors.success : AppColors.textSecondary,
                            fontWeight: _isFreeDelivery ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        value: _isFreeDelivery,
                        activeThumbColor: AppColors.success,
                        onChanged: (val) {
                          setState(() {
                            _isFreeDelivery = val;
                            if (val) {
                              _deliveryChargeController.text = '0';
                            } else if (_deliveryChargeController.text == '0' || _deliveryChargeController.text.isEmpty) {
                              _deliveryChargeController.text = '49';
                            }
                          });
                        },
                      ),

                      if (!_isFreeDelivery) ...[
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Delivery Fee Amount (₹)',
                          hint: '49.00',
                          controller: _deliveryChargeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                          validator: (v) {
                            if (_isFreeDelivery) return null;
                            if (v == null || v.trim().isEmpty) return 'Delivery charge required';
                            final val = double.tryParse(v.trim());
                            if (val == null || val < 0) return 'Invalid delivery charge';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Quick Presets:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('₹49 Standard'),
                              selected: _deliveryChargeController.text == '49',
                              onSelected: (_) => setState(() => _deliveryChargeController.text = '49'),
                            ),
                            ChoiceChip(
                              label: const Text('₹79 Express'),
                              selected: _deliveryChargeController.text == '79',
                              onSelected: (_) => setState(() => _deliveryChargeController.text = '79'),
                            ),
                            ChoiceChip(
                              label: const Text('₹99 Heavy / Bulky'),
                              selected: _deliveryChargeController.text == '99',
                              onSelected: (_) => setState(() => _deliveryChargeController.text = '99'),
                            ),
                            ChoiceChip(
                              label: const Text('Free (₹0)'),
                              selected: false,
                              onSelected: (_) {
                                setState(() {
                                  _isFreeDelivery = true;
                                  _deliveryChargeController.text = '0';
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Visibility Switch
              Card(
                child: SwitchListTile(
                  title: const Text('Show in Customer Shop', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('When disabled, customers will not see this product in the catalog'),
                  value: _isActive,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: isEditing ? 'Save Product Changes' : 'Publish Product to Shop',
                isLoading: _isSaving,
                onPressed: _save,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
