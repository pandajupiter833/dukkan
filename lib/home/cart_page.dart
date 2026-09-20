import 'package:flutter/material.dart';

import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get _total {
    return widget.cart.fold(0.0, (sum, item) => sum + _lineTotal(item));
  }

  void _openCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckoutPage(cart: widget.cart)),
    ).then((_) => setState(() {}));
  }

  double _lineTotal(Map<String, dynamic> item) {
    return _priceOf(item) * (item['quantity'] ?? 1);
  }

  double _priceOf(Map<String, dynamic> item) {
    final price = item['price'];
    if (price is num) return price.toDouble();
    return double.tryParse(price.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('Shopping cart')),
      body: widget.cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 56),
                  SizedBox(height: 12),
                  Text('Your cart is empty'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return _cartItem(item, index);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${_total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _openCheckout,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Proceed with order'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _cartItem(Map<String, dynamic> item, int index) {
    final quantity = item['quantity'] ?? 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            (item['image'] ?? '').toString(),
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 58,
                height: 58,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
        ),
        title: Text(
          (item['name'] ?? '').toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${item['category'] ?? ''}\nQty: $quantity - \$${item['price']} each',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Remove',
          onPressed: () => setState(() => widget.cart.removeAt(index)),
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
}
