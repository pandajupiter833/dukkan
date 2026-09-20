import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_project_test/app_theme.dart';

import '../home/product_categories.dart';

class AdminAddProductPage extends StatefulWidget {
  const AdminAddProductPage({super.key});

  @override
  State<AdminAddProductPage> createState() => _AdminAddProductPageState();
}

class _AdminAddProductPageState extends State<AdminAddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isSaving = false;
  String _selectedCategory = productCategories.first;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'category': _selectedCategory,
        'soldOut': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _formKey.currentState!.reset();
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
      setState(() => _selectedCategory = productCategories.first);

      if (!mounted) return;
      _showMessage('Product added');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not add product: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _priceValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final price = double.tryParse(value.trim());
    if (price == null || price < 0) return 'Enter a valid price';
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: softPanelDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.add_box_outlined, color: AppColors.pomegranate),
                      SizedBox(width: 8),
                      Text(
                        'Add product',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _nameController,
                    'Name',
                    icon: Icons.sell_outlined,
                    validator: _requiredText,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _priceController,
                    'Price',
                    icon: Icons.attach_money,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _priceValidator,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _imageUrlController,
                    'Picture link',
                    icon: Icons.link,
                    keyboardType: TextInputType.url,
                    validator: _requiredText,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  ...productCategories.map(
                    (category) => RadioListTile<String>(
                      title: Text(category),
                      value: category,
                      groupValue: _selectedCategory,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedCategory = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _descriptionController,
                    'Description',
                    icon: Icons.description_outlined,
                    minLines: 3,
                    maxLines: 5,
                    validator: _requiredText,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _addProduct,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: const Text('Add product'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    required IconData icon,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}
