import 'package:flutter/material.dart';
import '../models/car.dart';
import 'spec_chip.dart';
import 'dart:io';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;

  const CarCard({super.key, required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 92,
                  height: 92,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: car.imagePaths.isNotEmpty
                      ? Image.file(
                          File(car.imagePaths.first),
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.directions_car, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${car.priceEur} €',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        SpecChip(
                          icon: Icons.calendar_month,
                          text: car.year.toString(),
                        ),
                        SpecChip(icon: Icons.speed, text: '${car.km} km'),
                        SpecChip(
                          icon: Icons.location_on_outlined,
                          text: car.city,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
