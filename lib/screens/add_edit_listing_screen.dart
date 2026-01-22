import 'dart:math';
import 'package:flutter/material.dart';
import '../data/car_store.dart';
import '../models/car.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddEditListingScreen extends StatefulWidget {
  final String? existingCarId;

  const AddEditListingScreen({super.key, this.existingCarId});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final kmCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final fuelCtrl = TextEditingController();
  final gearboxCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  Car? existing;
  final ImagePicker picker = ImagePicker();
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    final store = CarStore.instance;

    if (widget.existingCarId != null) {
      existing = store.allCars.firstWhere((c) => c.id == widget.existingCarId);
      final c = existing!;
      titleCtrl.text = c.title;
      yearCtrl.text = c.year.toString();
      kmCtrl.text = c.km.toString();
      priceCtrl.text = c.priceEur.toString();
      cityCtrl.text = c.city;
      fuelCtrl.text = c.fuel;
      gearboxCtrl.text = c.gearbox;
      descCtrl.text = c.description;
      imagePaths = List<String>.from(c.imagePaths);
    } else {
      fuelCtrl.text = 'Dizel';
      gearboxCtrl.text = 'Manuelni';
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    yearCtrl.dispose();
    kmCtrl.dispose();
    priceCtrl.dispose();
    cityCtrl.dispose();
    fuelCtrl.dispose();
    gearboxCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;

    setState(() {
      imagePaths.addAll(files.map((f) => f.path));
    });
  }

  void save() {
    if (!formKey.currentState!.validate()) return;

    final store = CarStore.instance;
    final user = store.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Moraš biti prijavljen.')));
      return;
    }

    final car = Car(
      id: existing?.id ?? 'c${Random().nextInt(999999)}',
      ownerId: existing?.ownerId ?? user.id,
      title: titleCtrl.text.trim(),
      year: int.parse(yearCtrl.text.trim()),
      km: int.parse(kmCtrl.text.trim()),
      priceEur: int.parse(priceCtrl.text.trim()),
      city: cityCtrl.text.trim(),
      fuel: fuelCtrl.text.trim(),
      gearbox: gearboxCtrl.text.trim(),
      description: descCtrl.text.trim(),
      imagePaths: imagePaths,
    );

    if (existing == null) {
      store.addCar(car);
    } else {
      store.updateCar(car);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Izmeni oglas' : 'Dodaj oglas')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Naslov',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().length < 3) ? 'Unesi naslov' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: yearCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Godište',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          int.tryParse(v ?? '') == null ? 'Broj' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: kmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kilometraža',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          int.tryParse(v ?? '') == null ? 'Broj' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cena (€)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          int.tryParse(v ?? '') == null ? 'Broj' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: cityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Grad',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Unesi grad' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: fuelCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Gorivo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: gearboxCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Menjač',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Opis',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: pickImages,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Dodaj slike'),
              ),

              const SizedBox(height: 10),

              if (imagePaths.isNotEmpty)
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: imagePaths.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final p = imagePaths[i];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(p),
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => imagePaths.removeAt(i)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Sačuvaj' : 'Objavi oglas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
