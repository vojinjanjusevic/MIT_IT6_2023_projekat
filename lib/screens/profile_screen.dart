import 'package:flutter/material.dart';
import '../data/car_store.dart';
import 'auth_login_screen.dart';
import 'auth_register_screen.dart';
import '../theme/theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final store = CarStore.instance;
    final user = store.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: user == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('Gost'),
                    subtitle: Text('Prijavi se ili registruj se'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: ThemeController.instance.isDark,
                    onChanged: (v) {
                      ThemeController.instance.setDark(v);
                      setState(() {}); // ✅ osveži ovaj ekran
                    },
                    title: const Text('Dark theme'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),

                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      final ok = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AuthLoginScreen(),
                        ),
                      );
                      if (ok == true) refresh();
                    },
                    child: const Text('Prijava'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      final ok = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AuthRegisterScreen(),
                        ),
                      );
                      if (ok == true) refresh();
                    },
                    child: const Text('Registracija'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                  ),
                  const Divider(),
                  SwitchListTile(
                    value: ThemeController.instance.isDark,
                    onChanged: (v) {
                      ThemeController.instance.setDark(v);
                      setState(() {}); // ✅ osveži ovaj ekran
                    },
                    title: const Text('Dark theme'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),

                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      store.logout();
                      refresh();
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
      ),
    );
  }
}
