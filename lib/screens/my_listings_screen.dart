import 'package:flutter/material.dart';
import '../data/car_store.dart';
import '../models/car.dart';
import '../widgets/car_card.dart';
import 'car_details_screen.dart';
import 'add_edit_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final store = CarStore.instance;
    if (!store.isLoggedIn) {
      setState(() {
        loading = false;
        error = null;
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await Future.wait([
        store.fetchMyCars(),
        store.fetchReservedCars(),
      ]);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _openCreateScreen() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditListingScreen()),
    );
    if (ok == true) await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final store = CarStore.instance;
    final user = store.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Prijavite se kako biste videli svoje oglase i rezervacije.'),
        ),
      );
    }

    final myCars = store.myCars();
    final reservedCars = store.reservedCars();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Moji oglasi'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openCreateScreen,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Moji oglasi'),
              Tab(text: 'Rezervisani'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(child: Text(error!))
                  : TabBarView(
                      children: [
                        _buildMyCarsList(myCars),
                        _buildReservedCarsList(reservedCars),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildMyCarsList(List<Car> cars) {
    final store = CarStore.instance;

    if (cars.isEmpty) {
      return const Center(child: Text('Nemas oglase jos.'));
    }

    return ListView.separated(
      itemCount: cars.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final car = cars[i];
        return Dismissible(
          key: ValueKey(car.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red.withValues(alpha: 0.8),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) async {
            try {
              await store.deleteCar(car.id);
              if (mounted) setState(() {});
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text(
                    e.toString().replaceFirst('Exception: ', ''),
                  ),
                ),
              );
              _loadData();
            }
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
                    if (ok == true) await _loadData();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReservedCarsList(List<Car> cars) {
    if (cars.isEmpty) {
      return const Center(child: Text('Nemas rezervisanih oglasa.'));
    }

    return ListView.separated(
      itemCount: cars.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final car = cars[i];
        return CarCard(
          car: car,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CarDetailsScreen(carId: car.id),
              ),
            );
            if (mounted) {
              await _loadData();
            }
          },
        );
      },
    );
  }
}
