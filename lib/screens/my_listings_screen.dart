  import 'package:flutter/material.dart';
  import '../data/car_store.dart';
  import '../widgets/car_card.dart';
  import 'car_details_screen.dart';
  import 'add_edit_listing_screen.dart';

  class MyListingsScreen extends StatefulWidget {
    const MyListingsScreen({super.key});

    @override
    State<MyListingsScreen> createState() => _MyListingsScreenState();
  }

  class _MyListingsScreenState extends State<MyListingsScreen> {
    void refresh() => setState(() {});

    @override
    Widget build(BuildContext context) {
      final store = CarStore.instance;
      final user = store.currentUser;

      if (user == null) {
        return const Scaffold(
          body: Center(
            child: Text('Prijavite se kako biste videli svoje oglase'),
          ),
        );
      }
      final cars = store.myCars();
      return Scaffold(
        appBar: AppBar(
          title: const Text('Moji oglasi'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditListingScreen()),
                );
                if (ok == true) refresh();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: cars.isEmpty
              ? const Center(child: Text('Nemaš oglase još.'))
              : ListView.separated(
                  itemCount: cars.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final car = cars[i];
                    //dismissible je widget koji omogucava da se kartica prevuce prstom u levo i da se izbrise oglas, kao na yt...
                    return Dismissible(
                      key: ValueKey(car.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Colors.red.withOpacity(0.8),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        store.deleteCar(car.id);
                        refresh();
                      },
                      child: Stack(
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
                            right: 10,
                            top: 10,
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final ok = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditListingScreen(
                                      existingCarId: car.id,
                                    ),
                                  ),
                                );
                                if (ok == true) refresh();
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      );
    }
  }
