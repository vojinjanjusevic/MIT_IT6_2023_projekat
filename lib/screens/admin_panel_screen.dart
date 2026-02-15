import 'package:flutter/material.dart';
import '../data/car_store.dart';
import '../models/app_user.dart';
import '../widgets/car_card.dart';
import 'car_details_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await CarStore.instance.fetchCars();
      await CarStore.instance.fetchUsers();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Potvrda brisanja'),
            content: Text('Obrisati: "$title"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Otkaži'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Obriši'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final store = CarStore.instance;
    final me = store.currentUser;

    if (me == null || me.role != UserRole.admin) {
      return const Scaffold(
        body: Center(child: Text('Nemaš pristup admin panelu.')),
      );
    }

    final cars = store.allCars;
    final users = store.allUsers;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin panel'),
          actions: [
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car), text: 'Oglasi'),
              Tab(icon: Icon(Icons.people_alt_outlined), text: 'Korisnici'),
            ],
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : TabBarView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: cars.isEmpty
                            ? const Center(child: Text('Nema oglasa.'))
                            : ListView.separated(
                                itemCount: cars.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 8),
                                itemBuilder: (context, i) {
                                  final car = cars[i];
                                  return Stack(
                                    children: [
                                      CarCard(
                                        car: car,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CarDetailsScreen(carId: car.id),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: IconButton(
                                          tooltip: 'Obriši oglas',
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () async {
                                            final ok = await _confirmDelete(context, car.title);
                                            if (!ok) return;
                                            try {
                                              await store.deleteCar(car.id);
                                              if (mounted) setState(() {});
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(this.context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    e
                                                        .toString()
                                                        .replaceFirst('Exception: ', ''),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: users.isEmpty
                            ? const Center(child: Text('Nema korisnika.'))
                            : ListView.separated(
                                itemCount: users.length,
                                separatorBuilder: (_, _) => const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final u = users[i];
                                  final isMe = me.id == u.id;

                                  IconData roleIcon = Icons.person_outline;
                                  String roleText = 'User';
                                  if (u.role == UserRole.admin) {
                                    roleText = 'Admin';
                                    roleIcon = Icons.admin_panel_settings_outlined;
                                  } else if (u.role == UserRole.guest) {
                                    roleText = 'Guest';
                                  } else {
                                    roleIcon = Icons.person;
                                  }

                                  return ListTile(
                                    leading: Icon(roleIcon),
                                    title: Text(u.name),
                                    subtitle: Text('${u.email} • $roleText'),
                                    trailing: IconButton(
                                      tooltip: isMe
                                          ? 'Ne možeš obrisati sebe'
                                          : 'Obriši korisnika',
                                      onPressed: isMe
                                          ? null
                                          : () async {
                                              final ok = await _confirmDelete(context, u.email);
                                              if (!ok) return;
                                              try {
                                                await store.deleteUser(u.id);
                                                if (mounted) setState(() {});
                                              } catch (e) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(this.context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      e
                                                          .toString()
                                                          .replaceFirst('Exception: ', ''),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
