import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_project_test/app_theme.dart';

class AdminCliqPage extends StatefulWidget {
  const AdminCliqPage({super.key});

  @override
  State<AdminCliqPage> createState() => _AdminCliqPageState();
}

class _AdminCliqPageState extends State<AdminCliqPage> {
  final _cliqAddressController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCliqAddress();
  }

  @override
  void dispose() {
    _cliqAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadCliqAddress() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('settings')
        .doc('payment')
        .get();

    if (!mounted) return;
    _cliqAddressController.text =
        (snapshot.data()?['cliqAddress'] ?? '').toString();
  }

  Future<void> _saveCliqAddress() async {
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('settings').doc('payment').set(
        {
          'cliqAddress': _cliqAddressController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;
      _showMessage('CliQ address saved');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not save CliQ address: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.pomegranate,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'CliQ payment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cliqAddressController,
                  decoration: const InputDecoration(
                    labelText: 'CliQ address',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveCliqAddress,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Save CliQ address'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
