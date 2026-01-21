import 'package:flutter/material.dart';
import '../data/car_store.dart';

class AuthRegisterScreen extends StatefulWidget {
  const AuthRegisterScreen({super.key});

  @override
  State<AuthRegisterScreen> createState() => _AuthRegisterScreenState();
}

class _AuthRegisterScreenState extends State<AuthRegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    CarStore.instance.register(nameCtrl.text.trim(), emailCtrl.text.trim());
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registracija')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Ime', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().length < 2) ? 'Unesi ime' : null,
              ),
              const SizedBox(height: 12),
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
              FilledButton(onPressed: submit, child: const Text('Napravi nalog')),
            ],
          ),
        ),
      ),
    );
  }
}