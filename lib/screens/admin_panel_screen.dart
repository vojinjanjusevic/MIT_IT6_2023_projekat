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
  void refresh() => setState(() {});

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

    // zaštita: ako neko nekako uđe bez admin role
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
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car), text: 'Oglasi'),
              Tab(icon: Icon(Icons.people_alt_outlined), text: 'Korisnici'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Oglasi
            Padding(
              padding: const EdgeInsets.all(12),
              child: cars.isEmpty
                  ? const Center(child: Text('Nema oglasa.'))
                  : ListView.separated(
                      itemCount: cars.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
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
                                  store.deleteCar(car.id);
                                  refresh();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // TAB 2: Korisnici
            Padding(
              padding: const EdgeInsets.all(12),
              child: users.isEmpty
                  ? const Center(child: Text('Nema korisnika.'))
                  : ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final u = users[i];

                        final isMe = me.id == u.id;
                        final isAdmin = u.role == UserRole.admin;

                        IconData roleIcon = Icons.person_outline;
                        String roleText = 'User';
                        if (u.role == UserRole.guest) {
                          roleText = 'Guest';
                          roleIcon = Icons.person_outline;
                        } else if (u.role == UserRole.user) {
                          roleText = 'User';
                          roleIcon = Icons.person;
                        } else if (u.role == UserRole.admin) {
                          roleText = 'Admin';
                          roleIcon = Icons.admin_panel_settings_outlined;
                        }

                        return ListTile(
                          leading: Icon(roleIcon),
                          title: Text(u.name),
                          subtitle: Text('${u.email} • $roleText'),
                          trailing: IconButton(
                            tooltip: isMe
                                ? 'Ne možeš obrisati sebe'
                                : (isAdmin ? 'Brisanje admina je zabranjeno' : 'Obriši korisnika'),
                            onPressed: (isMe || isAdmin)
                                ? null
                                : () async {
                                    final ok = await _confirmDelete(context, u.email);
                                    if (!ok) return;
                                    store.deleteUser(u.id);
                                    refresh();
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