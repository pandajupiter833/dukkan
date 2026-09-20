import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_project_test/app_theme.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  Future<void> _updateOrderStatus(String id, String status) async {
    await FirebaseFirestore.instance.collection('orders').doc(id).update({
      'status': status,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _adminHeader(
          icon: Icons.receipt_long_outlined,
          title: 'Orders',
          subtitle: 'Review requests and update fulfillment status.',
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Could not load orders: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = snapshot.data?.docs ?? [];
            if (orders.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No orders yet'),
              );
            }

            return Column(children: orders.map(_orderCard).toList());
          },
        ),
      ],
    );
  }

  Widget _orderCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final order = doc.data();
    final status = (order['status'] ?? 'Pending').toString();
    final customer = Map<String, dynamic>.from(order['customer'] ?? {});
    final items = List<Map<String, dynamic>>.from(
      (order['items'] ?? []).map((item) => Map<String, dynamic>.from(item)),
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
                  'Customer order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${order['total'] ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _statusChip(status),
                Text('Payment: ${order['paymentMethod'] ?? ''}'),
              ],
            ),
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
              subtitle: Text(customer['locationDescription'] ?? ''),
            ),
            const SizedBox(height: 8),
            Text(
              items
                  .map(
                    (item) =>
                        '${item['name']} x${item['quantity'] ?? 1} - \$${item['price'] ?? 0}',
                  )
                  .join('\n'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: status == 'Confirmed'
                      ? null
                      : () => _updateOrderStatus(doc.id, 'Confirmed'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Confirm'),
                ),
                OutlinedButton.icon(
                  onPressed: status == 'Cancelled'
                      ? null
                      : () => _updateOrderStatus(doc.id, 'Cancelled'),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                ),
                OutlinedButton.icon(
                  onPressed: status == 'Done'
                      ? null
                      : () => _updateOrderStatus(doc.id, 'Done'),
                  icon: const Icon(Icons.done_all),
                  label: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.berry, AppColors.ink]),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
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
}
