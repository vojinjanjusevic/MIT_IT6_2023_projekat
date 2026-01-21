import 'package:flutter/material.dart';
import '../data/car_store.dart';
import '../widgets/spec_chip.dart';

class CarDetailsScreen extends StatelessWidget {
  final String carId;

  const CarDetailsScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
     final store = CarStore.instance;
    final car = store.allCars.firstWhere((c) => c.id == carId);
    final isLoggedIn = store.currentUser != null;

    return Scaffold(
      appBar: AppBar(title: Text(car.title)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child:ListView(
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: const Center(child: Icon(Icons.directions_car,size: 72)),
            ),
            const SizedBox(height: 12),
        Text(
              '${car.priceEur} €',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SpecChip(icon: Icons.calendar_month, text: car.year.toString()),
                SpecChip(icon: Icons.speed, text: '${car.km} km'),
                SpecChip(icon: Icons.local_gas_station, text: car.fuel),
                SpecChip(icon: Icons.settings, text: car.gearbox),
                SpecChip(icon: Icons.location_on_outlined, text: car.city),
              ],
            ),
            const SizedBox(height: 14),
            Text('Opis', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(car.description),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isLoggedIn ? 'Rezervacija (demo)' : 'Prijavi se da rezervišeš (demo)',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bookmark_add_outlined),
              label: Text(isLoggedIn ? 'Rezerviši' : 'Prijavi se za rezervaciju'),
            ),
          ],
        ),
      ),
    );
  }
}