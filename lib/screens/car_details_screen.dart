import 'dart:io';
import 'package:flutter/material.dart';
import '../data/car_store.dart';
import '../models/app_user.dart';
import '../models/car.dart';
import '../widgets/spec_chip.dart';

class CarDetailsScreen extends StatefulWidget {
  final String carId;

  const CarDetailsScreen({super.key, required this.carId});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  Car? car;
  bool loading = true;
  bool reservationLoading = false;
  String? error;

  Future<Map<String, String>?> _showReserveRequestDialog() async {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _ReserveRequestDialog(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCar();
  }

  Future<void> _loadCar() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final loaded = await CarStore.instance.fetchCarById(widget.carId);
      car = loaded;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _toggleReservation() async {
    final store = CarStore.instance;
    final user = store.currentUser;
    final currentCar = car;
    if (user == null || currentCar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prijavi se da bi mogao rezervisati.')),
      );
      return;
    }

    setState(() => reservationLoading = true);
    try {
      final hasActiveReservation = currentCar.reserved || currentCar.reservationStatus == 'pending';
      final canUnreserve = hasActiveReservation &&
          (currentCar.reservedById == user.id ||
              currentCar.ownerId == user.id ||
              user.role == UserRole.admin);

      Map<String, String>? reserveRequest;
      if (!canUnreserve) {
        reserveRequest = await _showReserveRequestDialog();
        if (!mounted) return;
        if (reserveRequest == null) {
          return;
        }
      }

      final updated = canUnreserve
          ? await store.unreserveCar(currentCar.id)
          : await store.reserveCar(
              currentCar.id,
              message: reserveRequest?['message'],
              contactPhone: reserveRequest?['contactPhone'],
              preferredTime: reserveRequest?['preferredTime'],
            );
      car = updated;
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            canUnreserve
                ? 'Zahtev ili rezervacija su otkazani.'
                : 'Zahtev za rezervaciju je poslat vlasniku.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => reservationLoading = false);
    }
  }

  Future<void> _approveReservation() async {
    final currentCar = car;
    if (currentCar == null) return;

    setState(() => reservationLoading = true);
    try {
      final updated = await CarStore.instance.approveReservation(currentCar.id);
      car = updated;
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(const SnackBar(content: Text('Rezervacija je potvrdena.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => reservationLoading = false);
    }
  }

  Future<void> _rejectReservation() async {
    final currentCar = car;
    if (currentCar == null) return;

    setState(() => reservationLoading = true);
    try {
      final updated = await CarStore.instance.rejectReservation(currentCar.id);
      car = updated;
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Zahtev je odbijen.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => reservationLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = CarStore.instance;
    final isLoggedIn = store.currentUser != null;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null || car == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalji')),
        body: Center(child: Text(error ?? 'Oglas nije pronadjen')),
      );
    }

    final currentCar = car!;
    final me = store.currentUser;
    final isPending = currentCar.reservationStatus == 'pending';
    final canSeeReservationNote = me != null &&
        (currentCar.reserved || isPending) &&
        (me.role == UserRole.admin || me.id == currentCar.ownerId);
    final canApproveOrReject = me != null &&
        isPending &&
        (me.id == currentCar.ownerId || me.role == UserRole.admin);
    final canUnreserve = me != null &&
        (currentCar.reserved || isPending) &&
        (currentCar.reservedById == me.id ||
            currentCar.ownerId == me.id ||
            me.role == UserRole.admin);

    return Scaffold(
      appBar: AppBar(title: Text(currentCar.title)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            if (currentCar.imagePaths.isEmpty)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: const Center(
                  child: Icon(Icons.directions_car, size: 72),
                ),
              )
            else
              SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: currentCar.imagePaths.length,
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(currentCar.imagePaths[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              '${currentCar.priceEur} EUR',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SpecChip(icon: Icons.calendar_month, text: currentCar.year.toString()),
                SpecChip(icon: Icons.speed, text: '${currentCar.km} km'),
                SpecChip(icon: Icons.local_gas_station, text: currentCar.fuel),
                SpecChip(icon: Icons.settings, text: currentCar.gearbox),
                SpecChip(icon: Icons.location_on_outlined, text: currentCar.city),
                if (isPending)
                  SpecChip(
                    icon: Icons.hourglass_top_rounded,
                    text: currentCar.reservedByName == null
                        ? 'Zahtev na cekanju'
                        : 'Ceka potvrdu: ${currentCar.reservedByName}',
                  ),
                if (currentCar.reserved)
                  SpecChip(
                    icon: Icons.bookmark_added_outlined,
                    text: currentCar.reservedByName == null
                        ? 'Rezervisano'
                        : 'Rezervisao: ${currentCar.reservedByName}',
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Opis', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(currentCar.description),
            if (canSeeReservationNote &&
                ((currentCar.reservationMessage ?? '').isNotEmpty ||
                    (currentCar.reservationContactPhone ?? '').isNotEmpty ||
                    (currentCar.reservationPreferredTime ?? '').isNotEmpty)) ...[
              const SizedBox(height: 14),
              Text(
                'Zahtev rezervacije',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              if ((currentCar.reservationContactPhone ?? '').isNotEmpty)
                Text('Telefon: ${currentCar.reservationContactPhone}'),
              if ((currentCar.reservationPreferredTime ?? '').isNotEmpty)
                Text('Predlog termina: ${currentCar.reservationPreferredTime}'),
              if ((currentCar.reservationMessage ?? '').isNotEmpty)
                Text('Poruka: ${currentCar.reservationMessage}'),
            ],
            const SizedBox(height: 18),
            if (canApproveOrReject) ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: reservationLoading ? null : _approveReservation,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Potvrdi zahtev'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: reservationLoading ? null : _rejectReservation,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Odbij zahtev'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            FilledButton.icon(
              onPressed: reservationLoading ? null : _toggleReservation,
              icon: reservationLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      canUnreserve ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
                    ),
              label: Text(
                !isLoggedIn
                    ? 'Prijavi se za rezervaciju'
                    : canUnreserve
                        ? (isPending ? 'Otkazi zahtev' : 'Otkazi rezervaciju')
                        : 'Posalji zahtev',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReserveRequestDialog extends StatefulWidget {
  const _ReserveRequestDialog();

  @override
  State<_ReserveRequestDialog> createState() => _ReserveRequestDialogState();
}

class _ReserveRequestDialogState extends State<_ReserveRequestDialog> {
  final messageCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final timeCtrl = TextEditingController();

  @override
  void dispose() {
    messageCtrl.dispose();
    phoneCtrl.dispose();
    timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Posalji zahtev'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(
                labelText: 'Predlog termina',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: messageCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Poruka vlasniku',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Odustani'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'contactPhone': phoneCtrl.text.trim(),
              'preferredTime': timeCtrl.text.trim(),
              'message': messageCtrl.text.trim(),
            });
          },
          child: const Text('Posalji zahtev'),
        ),
      ],
    );
  }
}
