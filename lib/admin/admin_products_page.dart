import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_project_test/app_theme.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  CollectionReference<Map<String, dynamic>> get _products {
    return FirebaseFirestore.instance.collection('products');
  }

  Future<void> _deleteProduct(String id) async {
    await _products.doc(id).delete();
  }

  Future<void> _toggleSoldOut(String id, bool value) async {
    await _products.doc(id).update({'soldOut': value});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.pomegranate),
            SizedBox(width: 8),
            Text(
              'Manage products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _products.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Could not load products: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No products yet')),
              );
            }

            return Column(children: docs.map(_productCard).toList());
          },
        ),
      ],
    );
  }

  Widget _productCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final product = doc.data();
    final soldOut = product['soldOut'] == true;
    final imageUrl = (product['imageUrl'] ?? '').toString();
    final category = (product['category'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: softPanelDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (product['name'] ?? '').toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (category.isNotEmpty)
                        Chip(
                          label: Text(category),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  Text('\$${product['price'] ?? 0}'),
                  const SizedBox(height: 4),
                  Text(
                    (product['description'] ?? '').toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sold out'),
                    value: soldOut,
                    onChanged: (value) => _toggleSoldOut(doc.id, value),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: () => _deleteProduct(doc.id),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
