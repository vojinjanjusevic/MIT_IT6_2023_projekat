import 'dart:math';
import '../models/app_user.dart';
import '../models/car.dart';

class CarStore {
  //privatni konstruktor ._
  CarStore._();
  static final CarStore instance = CarStore._();

  AppUser? currentUser;
  //referenca na listu se ne menja zbog final, ali se mogu dodavati i brisasti elementi liste
  final List<Car> _cars = [
    //dummy oglasi
    const Car(
      id: '1',
      ownerId: 'u1',
      title: 'Peugeot 308 1.6 HDi',
      year: 2008,
      km: 218000,
      priceEur: 4200,
      city: 'Novi Sad',
      fuel: 'Dizel',
      gearbox: 'Manuelni',
      description: 'Redovno servisiran. Mali potrošač. Dobra limarija.',
    ),
    const Car(
      id: '2',
      ownerId: 'u2',
      title: 'Golf 7 2.0 TDI',
      year: 2014,
      km: 176000,
      priceEur: 10500,
      city: 'Beograd',
      fuel: 'Dizel',
      gearbox: 'Manuelni',
      description: 'Uvoz. Kao nov. Bez ulaganja.',
    ),
  ];
  //list.unmodifiable -- read-only
  List<Car> get allCars => List.unmodifiable(_cars);

  List<Car> myCars() {
    final u = currentUser;
    if (u == null) return const [];
    return _cars.where((c) => c.ownerId == u.id).toList();
  }

  // Fake auth
  void loginAsUser(String email) {
    currentUser = AppUser(id: 'u1', name: 'Korisnik', email: email, role: UserRole.user);
  }

  void loginAsAdmin(String email) {
    currentUser = AppUser(id: 'a1', name: 'Admin', email: email, role: UserRole.admin);
  }

  void register(String name, String email) {
    currentUser = AppUser(
      id: 'u${Random().nextInt(9999)}',
      name: name,
      email: email,
      role: UserRole.user,
    );
  }

  void logout() => currentUser = null;

  // CRUD
  void addCar(Car car) => _cars.insert(0, car);

  void updateCar(Car updated) {
    final i = _cars.indexWhere((c) => c.id == updated.id);
    if (i != -1) _cars[i] = updated;
  }

  void deleteCar(String id) => _cars.removeWhere((c) => c.id == id);
}