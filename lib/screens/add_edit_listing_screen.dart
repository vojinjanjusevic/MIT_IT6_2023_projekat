import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/car_store.dart';
import '../models/car.dart';

class AddEditListingScreen extends StatefulWidget {
  final String? existingCarId;

  const AddEditListingScreen({super.key, this.existingCarId});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  static const List<String> fuelOptions = [
    'Dizel',
    'Benzin',
    'Elektricni pogon',
    'Hibridni pogon',
    'Benzin + gas (TNG)',
  ];

  static const List<String> gearboxOptions = [
    'Manuelni',
    'Automatski/poluautomatski',
  ];

  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final kmCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final ImagePicker picker = ImagePicker();

  Car? existing;
  bool loading = false;
  bool saving = false;
  List<String> imagePaths = [];
  String selectedFuel = fuelOptions.first;
  String selectedGearbox = gearboxOptions.first;

  @override
  void initState() {
    super.initState();
    if (widget.existingCarId != null) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    setState(() => loading = true);
    try {
      final car = await CarStore.instance.fetchCarById(widget.existingCarId!);
      existing = car;
      titleCtrl.text = car.title;
      yearCtrl.text = car.year.toString();
      kmCtrl.text = car.km.toString();
      priceCtrl.text = car.priceEur.toString();
      cityCtrl.text = car.city;
      selectedFuel = fuelOptions.contains(car.fuel) ? car.fuel : fuelOptions.first;
      selectedGearbox = gearboxOptions.contains(car.gearbox)
          ? car.gearbox
          : gearboxOptions.first;
      descCtrl.text = car.description;
      imagePaths = List<String>.from(car.imagePaths);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    yearCtrl.dispose();
    kmCtrl.dispose();
    priceCtrl.dispose();
    cityCtrl.dispose();
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

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    final store = CarStore.instance;
    final user = store.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Moras biti prijavljen.')));
      return;
    }

    setState(() => saving = true);

    final car = Car(
      id: existing?.id ?? '',
      ownerId: existing?.ownerId ?? user.id,
      ownerName: existing?.ownerName ?? user.name,
      title: titleCtrl.text.trim(),
      year: int.parse(yearCtrl.text.trim()),
      km: int.parse(kmCtrl.text.trim()),
      priceEur: int.parse(priceCtrl.text.trim()),
      city: cityCtrl.text.trim(),
      fuel: selectedFuel,
      gearbox: selectedGearbox,
      description: descCtrl.text.trim(),
      imagePaths: imagePaths,
      reserved: existing?.reserved ?? false,
      reservedById: existing?.reservedById,
      reservedByName: existing?.reservedByName,
    );

    try {
      if (existing == null) {
        await store.createCar(car);
      } else {
        await store.updateCar(car);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingCarId != null;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                        labelText: 'Godiste',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Broj' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: kmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kilometraza',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Broj' : null,
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
                        labelText: 'Cena (EUR)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Broj' : null,
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
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedFuel,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Gorivo',
                        border: OutlineInputBorder(),
                      ),
                      items: fuelOptions
                          .map(
                            (fuel) => DropdownMenuItem<String>(
                              value: fuel,
                              child: Text(
                                fuel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      selectedItemBuilder: (context) => fuelOptions
                          .map(
                            (fuel) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                fuel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedFuel = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedGearbox,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Menjac',
                        border: OutlineInputBorder(),
                      ),
                      items: gearboxOptions
                          .map(
                            (gearbox) => DropdownMenuItem<String>(
                              value: gearbox,
                              child: Text(
                                gearbox,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      selectedItemBuilder: (context) => gearboxOptions
                          .map(
                            (gearbox) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                gearbox,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selectedGearbox = value);
                      },
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
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
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
                              onPressed: () => setState(() => imagePaths.removeAt(i)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: saving ? null : save,
                icon: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isEdit ? 'Sacuvaj' : 'Objavi oglas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
