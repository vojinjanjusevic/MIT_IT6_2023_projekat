import 'package:flutter/material.dart';
import '../data/car_store.dart';
import '../widgets/car_card.dart';
import 'car_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  _HomeFilters _filters = const _HomeFilters();
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCars() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await CarStore.instance.fetchCars(
        search: _searchCtrl.text.trim().isEmpty
            ? null
            : _searchCtrl.text.trim(),
        city: _filters.city,
        fuel: _filters.fuel,
        gearbox: _filters.gearbox,
        reserved: _filters.reserved,
        minPrice: _filters.minPrice,
        maxPrice: _filters.maxPrice,
        yearFrom: _filters.yearFrom,
        yearTo: _filters.yearTo,
        sort: _filters.sort,
      );
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _openFilters() async {
    final next = await showModalBottomSheet<_HomeFilters>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HomeFiltersSheet(initial: _filters),
    );
    if (next == null) return;
    setState(() => _filters = next);
    await _loadCars();
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() => _filters = const _HomeFilters());
    _loadCars();
  }

  @override
  Widget build(BuildContext context) {
    final store = CarStore.instance;
    final cars = store.allCars;
    final hasFilters = _filters.hasValues || _searchCtrl.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oglasi'),
        actions: [
          IconButton(onPressed: _openFilters, icon: const Icon(Icons.tune)),
          IconButton(onPressed: _loadCars, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Pretraga (marka, model...)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _loadCars,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _loadCars(),
            ),
            const SizedBox(height: 8),
            if (hasFilters)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Aktivni filteri',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Ocisti'),
                  ),
                ],
              ),
            if (hasFilters)
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _filters.toChips(_searchCtrl.text.trim()),
                ),
              ),
            if (hasFilters) const SizedBox(height: 8),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                  ? Center(child: Text(error!))
                  : RefreshIndicator(
                      onRefresh: _loadCars,
                      child: ListView.separated(
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
                                  builder: (_) =>
                                      CarDetailsScreen(carId: car.id),
                                ),
                              );
                              if (mounted) {
                                _loadCars();
                              }
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFilters {
  final String? city;
  final String? fuel;
  final String? gearbox;
  final bool? reserved;
  final int? minPrice;
  final int? maxPrice;
  final int? yearFrom;
  final int? yearTo;
  final String? sort;

  const _HomeFilters({
    this.city,
    this.fuel,
    this.gearbox,
    this.reserved,
    this.minPrice,
    this.maxPrice,
    this.yearFrom,
    this.yearTo,
    this.sort,
  });

  bool get hasValues =>
      city != null ||
      fuel != null ||
      gearbox != null ||
      reserved != null ||
      minPrice != null ||
      maxPrice != null ||
      yearFrom != null ||
      yearTo != null ||
      sort != null;

  List<Widget> toChips(String search) {
    final labels = <String>[];
    if (search.isNotEmpty) labels.add('Pretraga: $search');
    if (city != null) labels.add('Grad: $city');
    if (fuel != null) labels.add('Gorivo: $fuel');
    if (gearbox != null) labels.add('Menjac: $gearbox');
    if (reserved != null) labels.add(reserved! ? 'Rezervisano' : 'Slobodno');
    if (minPrice != null) labels.add('Cena od: $minPrice');
    if (maxPrice != null) labels.add('Cena do: $maxPrice');
    if (yearFrom != null) labels.add('God. od: $yearFrom');
    if (yearTo != null) labels.add('God. do: $yearTo');
    if (sort != null) labels.add(_sortLabel(sort!));
    return labels.map((e) => Chip(label: Text(e))).toList();
  }
}

class _HomeFiltersSheet extends StatefulWidget {
  final _HomeFilters initial;

  const _HomeFiltersSheet({required this.initial});

  @override
  State<_HomeFiltersSheet> createState() => _HomeFiltersSheetState();
}

class _HomeFiltersSheetState extends State<_HomeFiltersSheet> {
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

  final cityCtrl = TextEditingController();
  final minPriceCtrl = TextEditingController();
  final maxPriceCtrl = TextEditingController();
  final yearFromCtrl = TextEditingController();
  final yearToCtrl = TextEditingController();

  String? fuel;
  String? gearbox;
  bool? reserved;
  String? sort;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    cityCtrl.text = initial.city ?? '';
    minPriceCtrl.text = initial.minPrice?.toString() ?? '';
    maxPriceCtrl.text = initial.maxPrice?.toString() ?? '';
    yearFromCtrl.text = initial.yearFrom?.toString() ?? '';
    yearToCtrl.text = initial.yearTo?.toString() ?? '';
    fuel = initial.fuel;
    gearbox = initial.gearbox;
    reserved = initial.reserved;
    sort = initial.sort;
  }

  @override
  void dispose() {
    cityCtrl.dispose();
    minPriceCtrl.dispose();
    maxPriceCtrl.dispose();
    yearFromCtrl.dispose();
    yearToCtrl.dispose();
    super.dispose();
  }

  int? _toInt(String text) {
    final value = text.trim();
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filteri', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Grad',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cena od',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: maxPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cena do',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: yearFromCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Godiste od',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: yearToCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Godiste do',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: fuel,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Gorivo',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Sve'),
                  ),
                  ...fuelOptions.map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  ),
                ],
                onChanged: (value) => setState(() => fuel = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: gearbox,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Menjac',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Sve'),
                  ),
                  ...gearboxOptions.map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  ),
                ],
                onChanged: (value) => setState(() => gearbox = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<bool>(
                initialValue: reserved,
                decoration: const InputDecoration(
                  labelText: 'Status rezervacije',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<bool>(value: null, child: Text('Sve')),
                  DropdownMenuItem<bool>(
                    value: false,
                    child: Text('Samo slobodni'),
                  ),
                  DropdownMenuItem<bool>(
                    value: true,
                    child: Text('Samo rezervisani'),
                  ),
                ],
                onChanged: (value) => setState(() => reserved = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: sort,
                decoration: const InputDecoration(
                  labelText: 'Sortiranje',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('Najnovije'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'price_asc',
                    child: Text('Cena rastuce'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'price_desc',
                    child: Text('Cena opadajuce'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'year_asc',
                    child: Text('Godiste rastuce'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'year_desc',
                    child: Text('Godiste opadajuce'),
                  ),
                ],
                onChanged: (value) => setState(() => sort = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(context, const _HomeFilters()),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          _HomeFilters(
                            city: cityCtrl.text.trim().isEmpty
                                ? null
                                : cityCtrl.text.trim(),
                            fuel: fuel,
                            gearbox: gearbox,
                            reserved: reserved,
                            minPrice: _toInt(minPriceCtrl.text),
                            maxPrice: _toInt(maxPriceCtrl.text),
                            yearFrom: _toInt(yearFromCtrl.text),
                            yearTo: _toInt(yearToCtrl.text),
                            sort: sort,
                          ),
                        );
                      },
                      child: const Text('Primeni'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _sortLabel(String sort) {
  switch (sort) {
    case 'price_asc':
      return 'Sort: Cena rastuce';
    case 'price_desc':
      return 'Sort: Cena opadajuce';
    case 'year_asc':
      return 'Sort: Godiste rastuce';
    case 'year_desc':
      return 'Sort: Godiste opadajuce';
    default:
      return 'Sort: Najnovije';
  }
}
