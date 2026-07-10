import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _registerMode = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthStore>();
    final ok = _registerMode
        ? await auth.register(_emailCtrl.text.trim(), _passwordCtrl.text)
        : await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Authentication failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    return Scaffold(
      appBar: AppBar(title: Text(_registerMode ? 'Register' : 'Sign in')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'JWT auth for write endpoints (POST, PATCH, DELETE). Read endpoints work without signing in.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || v.trim().length < 5) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 8) ? 'Minimum 8 characters' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: auth.loading ? null : _submit,
            child: auth.loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_registerMode ? 'Create account' : 'Sign in'),
          ),
          TextButton(
            onPressed: auth.loading ? null : () => setState(() => _registerMode = !_registerMode),
            child: Text(_registerMode ? 'Already have an account? Sign in' : 'Need an account? Register'),
          ),
        ],
      ),
    );
  }
}
