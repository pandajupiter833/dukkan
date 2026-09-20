import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _paymentMethod = 'Cash';
  bool _isConfirming = false;
  late final Future<List<dynamic>> _checkoutData;

  @override
  void initState() {
    super.initState();
    _checkoutData = Future.wait([_loadCustomer(), _loadCliqAddress()]);
  }

  double get _total {
    return widget.cart.fold(0.0, (sum, item) => sum + _lineTotal(item));
  }

  double _lineTotal(Map<String, dynamic> item) {
    return _itemPrice(item) * (item['quantity'] ?? 1);
  }

  double _itemPrice(Map<String, dynamic> item) {
    final price = item['price'];
    if (price is num) return price.toDouble();
    return double.tryParse(price.toString()) ?? 0;
  }

  Future<Map<String, dynamic>> _loadCustomer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return snapshot.data() ?? {};
  }

  Future<String> _loadCliqAddress() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('settings')
        .doc('payment')
        .get();

    return (snapshot.data()?['cliqAddress'] ?? '').toString();
  }

  Future<void> _confirmOrder(Map<String, dynamic> customer) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isConfirming = true);

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'email': user.email ?? '',
        'customer': {
          'name': customer['name'] ?? '',
          'mobile': customer['mobile'] ?? '',
          'locationLink': customer['locationLink'] ?? '',
          'locationDescription': customer['locationDescription'] ?? '',
        },
        'items': widget.cart
            .map((item) => {
                  'id': item['id'] ?? '',
                  'name': item['name'] ?? '',
                  'price': item['price'] ?? 0,
                  'quantity': item['quantity'] ?? 1,
                  'category': item['category'] ?? '',
                })
            .toList(),
        'total': _total,
        'paymentMethod': _paymentMethod,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      widget.cart.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order confirmed')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not confirm order: $e')),
      );
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  bool _hasRequiredCustomerInfo(Map<String, dynamic> customer) {
    return (customer['name'] ?? '').toString().trim().isNotEmpty &&
        (customer['mobile'] ?? '').toString().trim().isNotEmpty &&
        (customer['locationLink'] ?? '').toString().trim().isNotEmpty &&
        (customer['locationDescription'] ?? '').toString().trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('Checkout')),
      body: FutureBuilder<List<dynamic>>(
        future: _checkoutData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final customer = Map<String, dynamic>.from(
            (snapshot.data?[0] ?? {}) as Map,
          );
          final cliqAddress = (snapshot.data?[1] ?? '').toString();
          final hasInfo = _hasRequiredCustomerInfo(customer);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 185, 34, 34),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.receipt_long, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Are you sure to proceed order?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final item in widget.cart) _orderLine(item),
                      const Divider(),
                      Text(
                        'Total: \$${_total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              RadioListTile<String>(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: const Text('Cash'),
                value: 'Cash',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  if (value != null) setState(() => _paymentMethod = value);
                },
              ),
              RadioListTile<String>(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: const Text('CliQ'),
                subtitle: Text(
                  cliqAddress.isEmpty
                      ? 'CliQ address is not set yet'
                      : cliqAddress,
                ),
                value: 'CliQ',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  if (value != null) setState(() => _paymentMethod = value);
                },
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery info',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person_outline),
                        title: Text(customer['name'] ?? ''),
                        subtitle: Text(customer['mobile'] ?? ''),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(customer['locationLink'] ?? ''),
                        subtitle: Text(
                          customer['locationDescription'] ?? '',
                        ),
                      ),
                      if (!hasInfo)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Please complete your account info before ordering.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: !hasInfo || _isConfirming
                      ? null
                      : () => _confirmOrder(customer),
                  icon: _isConfirming
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Confirm'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _orderLine(Map<String, dynamic> item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${item['name'] ?? ''} x${item['quantity'] ?? 1}'),
      trailing: Text('\$${_lineTotal(item).toStringAsFixed(2)}'),
    );
  }
}
