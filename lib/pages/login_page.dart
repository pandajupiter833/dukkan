import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_project_test/app_theme.dart';
import 'package:new_project_test/admin/admin_page.dart';
import 'package:new_project_test/home/homepage.dart';
import 'package:new_project_test/pages/reset_password_page.dart';
import 'package:new_project_test/pages/sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningIn = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Enter your email and password');
      return;
    }

    setState(() => _isSigningIn = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final token = await credential.user?.getIdTokenResult(true);
      final isAdmin = token?.claims?['admin'] == true;

      if (!mounted) return;
      _replaceWith(isAdmin ? const AdminPage() : const HomePage());
    } on FirebaseAuthException {
      _showMessage('Unable to sign in. Check your credentials and try again.');
    } catch (_) {
      _showMessage('Unable to sign in. Please try again.');
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  void _replaceWith(Widget page) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => page));
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 760;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFBF7), Color(0xFFF7E7E5), Color(0xFFF4F6F8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: DecoratedBox(
                  decoration: softPanelDecoration(),
                  child: isWide
                      ? Row(
                          children: [
                            Expanded(child: _heroPanel(size, isWide: true)),
                            Expanded(child: _formPanel()),
                          ],
                        )
                      : Column(
                          children: [
                            _heroPanel(size, isWide: false),
                            _formPanel(),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroPanel(Size size, {required bool isWide}) {
    return Container(
      height: isWide ? 560 : 290,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.berry, AppColors.pomegranate, AppColors.coral],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: isWide ? -80 : -48,
            bottom: isWide ? -60 : -70,
            child: Image.asset(
              'assets/images/pomagranate2.png',
              width: isWide ? 430 : size.width * 0.78,
              fit: BoxFit.contain,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.22),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.24),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Fresh Store',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Shop fresh picks as a customer or manage orders from the admin dashboard.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sign in',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in with your account email.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 26),
          TextField(
            controller: _usernameController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.alternate_email),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: _hidePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: _hidePassword ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            onSubmitted: (_) => _isSigningIn ? null : _login(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSigningIn ? null : _login,
              icon: _isSigningIn
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.login),
              label: Text(_isSigningIn ? 'Signing in...' : 'Login'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _openPage(const ResetPasswordPage()),
                  child: const Text('Reset password'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _openPage(const SignUpPage()),
                  child: const Text('Create account'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.leaf.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: AppColors.leaf),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Customer and admin areas open from this secure sign in.',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
