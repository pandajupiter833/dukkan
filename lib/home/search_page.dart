import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'product_categories.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  const SearchPage({super.key, required this.cart});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final Set<String> _selectedCategories = {};

  Stream<QuerySnapshot<Map<String, dynamic>>> get _productsStream {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterProducts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final searchText = _searchController.text.trim().toLowerCase();

    return docs
        .where((doc) => doc.data()['soldOut'] != true)
        .map(_productFromDoc)
        .where((product) {
          final name = product['name'].toString().toLowerCase();
          final category = product['category'].toString();
          final matchesName = searchText.isEmpty || name.contains(searchText);
          final matchesCategory =
              _selectedCategories.isEmpty ||
              _selectedCategories.contains(category);

          return matchesName && matchesCategory;
        })
        .toList();
  }

  Map<String, dynamic> _productFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return {
      'id': doc.id,
      'name': data['name'] ?? '',
      'price': data['price'] ?? 0,
      'description': data['description'] ?? '',
      'image': data['imageUrl'] ?? data['image'] ?? '',
      'category': data['category'] ?? '',
    };
  }

  void _toggleCategory(String category, bool selected) {
    setState(() {
      if (selected) {
        _selectedCategories.add(category);
      } else {
        _selectedCategories.remove(category);
      }
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      widget.cart.add({...product, 'quantity': 1});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: productCategories.map(_categoryChip).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Could not load products: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = _filterProducts(snapshot.data?.docs ?? []);

                if (products.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return _productTile(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: _selectedCategories.contains(category),
        onSelected: (selected) => _toggleCategory(category, selected),
      ),
    );
  }

  Widget _productTile(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Image.network(
          product['image'],
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported);
          },
        ),
        title: Text(product['name']),
        subtitle: Text('${product['category']} - \$${product['price']}'),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () => _addToCart(product),
        ),
      ),
    );
  }
}
