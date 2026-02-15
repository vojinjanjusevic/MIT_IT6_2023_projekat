import 'package:flutter/material.dart';
import '../data/car_store.dart';
import 'auth_login_screen.dart';
import 'auth_register_screen.dart';
import '../theme/theme_controller.dart';
import 'admin_panel_screen.dart';
import '../models/app_user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsLoading = false;
  bool clearAnimation = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final store = CarStore.instance;
    if (!store.isLoggedIn) return;
    setState(() => notificationsLoading = true);
    try {
      await store.fetchNotifications();
    } catch (_) {
    } finally {
      if (mounted) setState(() => notificationsLoading = false);
    }
  }

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final store = CarStore.instance;
    final user = store.currentUser;
    final visibleNotifications = store.notifications();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: user == null
            ? ListView(
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
                      setState(() {});
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
                      if (ok == true) await _loadNotifications();
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
                      if (ok == true) await _loadNotifications();
                    },
                    child: const Text('Registracija'),
                  ),
                ],
              )
            : ListView(
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
                      setState(() {});
                    },
                    title: const Text('Dark theme'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),

                  if (user.role == UserRole.admin) ...[
                    FilledButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminPanelScreen(),
                          ),
                        );
                        refresh();
                      },
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: const Text('Admin panel'),
                    ),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Notifikacije',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (visibleNotifications.isNotEmpty)
                        TextButton(
                          onPressed: notificationsLoading
                              ? null
                              : () async {
                                  setState(() => clearAnimation = true);
                                  await Future<void>.delayed(
                                    const Duration(milliseconds: 180),
                                  );
                                  try {
                                    await store.clearNotifications();
                                  } finally {
                                    if (mounted) {
                                      setState(() => clearAnimation = false);
                                    }
                                  }
                                },
                          child: const Text('Obrisi sve'),
                        ),
                      IconButton(
                        onPressed: notificationsLoading ? null : _loadNotifications,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  if (notificationsLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    )
                  else
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: (visibleNotifications.isEmpty || clearAnimation)
                          ? const Padding(
                              key: ValueKey('empty_notifications'),
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('Nema notifikacija.'),
                            )
                          : Column(
                              key: ValueKey(
                                'notifications_${visibleNotifications.length}',
                              ),
                              children: visibleNotifications.take(10).map(
                                (n) => Dismissible(
                        key: ValueKey('notif_${n.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: Colors.red.withValues(alpha: 0.8),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          await store.deleteNotification(n.id);
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    n.read
                                        ? Icons.notifications_none_outlined
                                        : Icons.notifications_active_outlined,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.message,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!n.read) ...[
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () async {
                                      await store.markNotificationRead(n.id);
                                      refresh();
                                    },
                                    child: const Text('Procitano'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                              ).toList(),
                            ),
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      await store.logout();
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
