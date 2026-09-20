import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_project_test/app_theme.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  Future<void> _cancelOrder(String id) async {
    await FirebaseFirestore.instance.collection('orders').doc(id).update({
      'status': 'Cancelled by customer',
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login first'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load orders: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 56),
                  SizedBox(height: 12),
                  Text('No orders yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final order = doc.data();
              final status = (order['status'] ?? 'Pending').toString();
              final items = List<Map<String, dynamic>>.from(
                (order['items'] ?? []).map(
                  (item) => Map<String, dynamic>.from(item),
                ),
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: softPanelDecoration(),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _statusChip(status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            size: 18,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 6),
                          Text('Payment: ${order['paymentMethod'] ?? ''}'),
                        ],
                      ),
                      const Divider(),
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item['name'] ?? ''} x${item['quantity'] ?? 1}',
                                ),
                              ),
                              Text(
                                '\$${_lineTotal(item).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      const Divider(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: \$${order['total'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (status == 'Pending')
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () => _cancelOrder(doc.id),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel order'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
    );
  }

  Widget _statusChip(String status) {
    final isDone = status == 'Done' || status == 'Confirmed';
    final isCancelled = status.contains('Cancelled');
    final color = isDone
        ? AppColors.leaf
        : isCancelled
        ? Colors.red.shade700
        : AppColors.pomegranate;

    return Chip(
      label: Text(status),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
    );
  }

  double _lineTotal(Map<String, dynamic> item) {
    final price = item['price'];
    final quantity = item['quantity'] ?? 1;
    final itemPrice = price is num
        ? price.toDouble()
        : double.tryParse(price.toString()) ?? 0;
    return itemPrice * quantity;
  }
}
