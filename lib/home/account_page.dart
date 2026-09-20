import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_project_test/app_theme.dart';
import 'package:new_project_test/pages/login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _locationLinkController = TextEditingController();
  final _locationDescriptionController = TextEditingController();
  bool _isSaving = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>>? get _profileDoc {
    final user = _user;
    if (user == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _locationLinkController.dispose();
    _locationDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profileDoc = _profileDoc;
    if (profileDoc == null) return;

    final snapshot = await profileDoc.get();
    final data = snapshot.data();
    if (data == null || !mounted) return;

    setState(() {
      _nameController.text = (data['name'] ?? '').toString();
      _mobileController.text = (data['mobile'] ?? '').toString();
      _locationLinkController.text = (data['locationLink'] ?? '').toString();
      _locationDescriptionController.text =
          (data['locationDescription'] ?? '').toString();
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileDoc = _profileDoc;
    if (profileDoc == null) return;

    setState(() => _isSaving = true);

    try {
      await profileDoc.set({
        'email': _user?.email ?? '',
        'name': _nameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'locationLink': _locationLinkController.text.trim(),
        'locationDescription': _locationDescriptionController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      _showMessage('Account saved');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not save account: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: Text('Please login first'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.leaf, AppColors.pomegranate],
            ),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      _user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: softPanelDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field(_nameController, 'Name', icon: Icons.badge_outlined),
                const SizedBox(height: 12),
                _field(
                  _mobileController,
                  'Mobile number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _field(
                  _locationLinkController,
                  'Delivery location link',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                _field(
                  _locationDescriptionController,
                  'Description about the location',
                  icon: Icons.place_outlined,
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveProfile,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Save account'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
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
      validator: _requiredText,
    );
  }
}
