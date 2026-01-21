import 'package:flutter/material.dart';
import '../data/car_store.dart';

class AuthLoginScreen extends StatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  State<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthLoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    CarStore.instance.loginAsUser(emailCtrl.text.trim());
    Navigator.pop(context, true); // true -> login uspeo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prijava')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) => (v == null || !v.contains('@')) ? 'Unesi validan email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Lozinka', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.length < 4) ? 'Min 4 karaktera' : null,
              ),
              const Spacer(),
              FilledButton(onPressed: submit, child: const Text('Prijavi se')),
            ],
          ),
        ),
      ),
    );
  }
}