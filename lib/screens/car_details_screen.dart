import 'package:flutter/material.dart';
import '../data/car_store.dart';

class CarDetailsScreen extends StatelessWidget {
  final String carId;

  const CarDetailsScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    final car = CarStore.instance.allCars.firstWhere((c) => c.id == carId);

    return Scaffold(
      appBar: AppBar(title: Text(car.title)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Detalj (placeholder)\n\nCena: ${car.priceEur} €\nGodište: ${car.year}\nKm: ${car.km}\nGrad: ${car.city}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}