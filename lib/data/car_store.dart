import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/car.dart';

class CarStore extends ChangeNotifier {
  CarStore._();
  static final CarStore instance = CarStore._();

  static const String _apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/api',
  );
  static const Duration _requestTimeout = Duration(seconds: 12);

  AppUser? currentUser;
  String? _token;

  final List<Car> _cars = [];
  final List<Car> _myCars = [];
  final List<Car> _reservedCars = [];
  final List<AppNotification> _notifications = [];
  final List<AppUser> _users = [];

  List<Car> get allCars => UnmodifiableListView(_cars);
  List<Car> myCars() => UnmodifiableListView(_myCars);
  List<Car> reservedCars() => UnmodifiableListView(_reservedCars);
  List<AppNotification> notifications() => UnmodifiableListView(_notifications);
  List<AppUser> get allUsers => UnmodifiableListView(_users);
  bool get isLoggedIn => _token != null && currentUser != null;

  Map<String, String> _headers({bool auth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (auth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(_apiBase);
    return base.replace(
      path: '${base.path}$path',
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  String _parseError(http.Response response) {
    final fallbackByStatus = switch (response.statusCode) {
      400 => 'Podaci nisu ispravni. Proveri unos i pokusaj ponovo.',
      401 => 'Email ili lozinka nisu tacni.',
      403 => 'Nemas dozvolu za ovu akciju.',
      404 => 'Trazeni podatak nije pronadjen.',
      409 => 'Akcija nije moguca zbog trenutnog stanja podataka.',
      >= 500 => 'Doslo je do greske na serveru. Pokusaj ponovo malo kasnije.',
      _ => 'Doslo je do greske. Pokusaj ponovo.',
    };

    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] != null) {
        final raw = data['message'].toString();
        return _friendlyBackendMessage(raw, fallbackByStatus);
      }
    } catch (_) {}

    return fallbackByStatus;
  }

  String _friendlyBackendMessage(String raw, String fallback) {
    const map = <String, String>{
      'Invalid credentials': 'Email ili lozinka nisu tacni.',
      'Name, email and password are required': 'Unesi ime, email i lozinku.',
      'Email and password are required': 'Unesi email i lozinku.',
      'User with this email already exists':
          'Korisnik sa ovom email adresom vec postoji.',
      'Not authorized, token missing': 'Prijavi se da nastavis.',
      'Not authorized, user not found': 'Sesija je istekla. Prijavi se ponovo.',
      'Access denied: admin only':
          'Ova opcija je dostupna samo administratoru.',
      'Invalid car id': 'Neispravan oglas.',
      'Invalid user id': 'Neispravan korisnik.',
      'Car listing not found': 'Oglas nije pronadjen.',
      'User not found': 'Korisnik nije pronadjen.',
      'Missing required fields: title, year, km, priceEur, city, fuel, gearbox, description':
          'Popuni sva obavezna polja oglasa.',
      'Not allowed to update this listing':
          'Nemas dozvolu da izmenis ovaj oglas.',
      'Not allowed to delete this listing':
          'Nemas dozvolu da obrises ovaj oglas.',
      'Owner cannot reserve own listing': 'Ne mozes rezervisati svoj oglas.',
      'Listing is already reserved': 'Oglas je vec rezervisan.',
      'Listing already has pending reservation request':
          'Za ovaj oglas vec postoji zahtev za rezervaciju.',
      'Listing is not reserved': 'Oglas nije rezervisan.',
      'Listing is not reserved or pending':
          'Za ovaj oglas nema aktivne rezervacije ni zahteva.',
      'Not allowed to approve this reservation':
          'Nemas dozvolu da potvrdis ovu rezervaciju.',
      'Not allowed to reject this reservation':
          'Nemas dozvolu da odbijes ovu rezervaciju.',
      'Listing has no pending reservation request':
          'Ovaj oglas nema zahtev koji ceka potvrdu.',
      'Not allowed to cancel this reservation':
          'Nemas dozvolu da otkazes ovu rezervaciju.',
      'Admin cannot delete own account': 'Ne mozes obrisati svoj nalog.',
      'Invalid notification id': 'Neispravna notifikacija.',
      'Notification not found': 'Notifikacija nije pronadjena.',
      'Not allowed to update this notification':
          'Nemas dozvolu da izmenis ovu notifikaciju.',
      'Not allowed to delete this notification':
          'Nemas dozvolu da obrises ovu notifikaciju.',
    };

    if (map.containsKey(raw)) {
      return map[raw]!;
    }

    if (raw.startsWith('Missing required fields:')) {
      return 'Popuni sva obavezna polja oglasa.';
    }

    return fallback;
  }

  Future<http.Response> _safeRequest(Future<http.Response> request) async {
    try {
      return await request.timeout(_requestTimeout);
    } on TimeoutException {
      throw Exception('Veza traje predugo. Proveri internet i pokusaj ponovo.');
    } on SocketException {
      throw Exception(
        'Trenutno ne mozemo da se povezemo. Pokusaj ponovo za nekoliko sekundi.',
      );
    }
  }

  AppUser _extractUserFromResponse(Map<String, dynamic> data) {
    final userJson = data['user'];
    if (userJson is! Map<String, dynamic>) {
      throw Exception('Doslo je do greske pri ucitavanju korisnika.');
    }
    return AppUser.fromJson(userJson);
  }

  Future<void> _warmupAfterAuth() async {
    try {
      await fetchCars();
    } catch (_) {}
    try {
      await fetchMyCars();
    } catch (_) {}
    try {
      await fetchReservedCars();
    } catch (_) {}
    try {
      await fetchNotifications();
    } catch (_) {}
    if (currentUser?.role == UserRole.admin) {
      try {
        await fetchUsers();
      } catch (_) {}
    }
  }

  Car _extractCarFromResponse(Map<String, dynamic> data) {
    final carJson = data['car'];
    if (carJson is! Map<String, dynamic>) {
      throw Exception('Doslo je do greske pri ucitavanju oglasa.');
    }
    return Car.fromJson(carJson);
  }

  Future<void> refreshAuthUser() async {
    if (_token == null) return;
    final response = await _safeRequest(
      http.get(_uri('/auth/me'), headers: _headers(auth: true)),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    currentUser = _extractUserFromResponse(data);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await _safeRequest(
      http.post(
        _uri('/auth/login'),
        headers: _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _token = (data['token'] ?? '').toString();
    currentUser = _extractUserFromResponse(data);
    notifyListeners();
    await _warmupAfterAuth();
  }

  Future<void> register(String name, String email, String password) async {
    final response = await _safeRequest(
      http.post(
        _uri('/auth/register'),
        headers: _headers(),
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ),
    );

    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _token = (data['token'] ?? '').toString();
    currentUser = _extractUserFromResponse(data);
    notifyListeners();
    await _warmupAfterAuth();
  }

  Future<void> logout() async {
    _token = null;
    currentUser = null;
    _myCars.clear();
    _reservedCars.clear();
    _notifications.clear();
    _users.clear();
    notifyListeners();
  }

  Future<void> fetchCars({
    String? search,
    String? city,
    String? fuel,
    String? gearbox,
    bool? reserved,
    int? minPrice,
    int? maxPrice,
    int? yearFrom,
    int? yearTo,
    String? sort,
  }) async {
    final query = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (city != null && city.trim().isNotEmpty) {
      query['city'] = city.trim();
    }
    if (fuel != null && fuel.trim().isNotEmpty) {
      query['fuel'] = fuel.trim();
    }
    if (gearbox != null && gearbox.trim().isNotEmpty) {
      query['gearbox'] = gearbox.trim();
    }
    if (reserved != null) {
      query['reserved'] = reserved.toString();
    }
    if (minPrice != null) {
      query['minPrice'] = minPrice.toString();
    }
    if (maxPrice != null) {
      query['maxPrice'] = maxPrice.toString();
    }
    if (yearFrom != null) {
      query['yearFrom'] = yearFrom.toString();
    }
    if (yearTo != null) {
      query['yearTo'] = yearTo.toString();
    }
    if (sort != null && sort.trim().isNotEmpty) {
      query['sort'] = sort.trim();
    }
    final response = await _safeRequest(
      http.get(_uri('/cars', query), headers: _headers()),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final carsRaw = (data['cars'] as List?) ?? const [];
    _cars
      ..clear()
      ..addAll(carsRaw.whereType<Map<String, dynamic>>().map(Car.fromJson));
    notifyListeners();
  }

  Future<Car> fetchCarById(String carId) async {
    final response = await _safeRequest(
      http.get(_uri('/cars/$carId'), headers: _headers()),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final car = _extractCarFromResponse(data);

    final index = _cars.indexWhere((c) => c.id == car.id);
    if (index == -1) {
      _cars.insert(0, car);
    } else {
      _cars[index] = car;
    }
    notifyListeners();
    return car;
  }

  Future<void> fetchMyCars() async {
    if (!isLoggedIn) {
      _myCars.clear();
      notifyListeners();
      return;
    }
    final response = await _safeRequest(
      http.get(_uri('/cars/my'), headers: _headers(auth: true)),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final carsRaw = (data['cars'] as List?) ?? const [];
    _myCars
      ..clear()
      ..addAll(carsRaw.whereType<Map<String, dynamic>>().map(Car.fromJson));
    notifyListeners();
  }

  Future<void> fetchReservedCars() async {
    if (!isLoggedIn) {
      _reservedCars.clear();
      notifyListeners();
      return;
    }
    final response = await _safeRequest(
      http.get(_uri('/cars/reserved/mine'), headers: _headers(auth: true)),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final carsRaw = (data['cars'] as List?) ?? const [];
    _reservedCars
      ..clear()
      ..addAll(carsRaw.whereType<Map<String, dynamic>>().map(Car.fromJson));
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    if (!isLoggedIn) {
      _notifications.clear();
      notifyListeners();
      return;
    }
    final response = await _safeRequest(
      http.get(_uri('/notifications'), headers: _headers(auth: true)),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final notificationsRaw = (data['notifications'] as List?) ?? const [];
    _notifications
      ..clear()
      ..addAll(
        notificationsRaw.whereType<Map<String, dynamic>>().map(
          AppNotification.fromJson,
        ),
      );
    notifyListeners();
  }

  Future<void> markNotificationRead(String notificationId) async {
    final response = await _safeRequest(
      http.post(
        _uri('/notifications/$notificationId/read'),
        headers: _headers(auth: true),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final notificationJson = data['notification'];
    if (notificationJson is! Map<String, dynamic>) {
      return;
    }
    final updated = AppNotification.fromJson(notificationJson);
    final index = _notifications.indexWhere((n) => n.id == updated.id);
    if (index != -1) {
      _notifications[index] = updated;
    }
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    final response = await _safeRequest(
      http.delete(
        _uri('/notifications/$notificationId'),
        headers: _headers(auth: true),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  Future<void> clearNotifications() async {
    final response = await _safeRequest(
      http.delete(_uri('/notifications'), headers: _headers(auth: true)),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    _notifications.clear();
    notifyListeners();
  }

  Future<Car> createCar(Car car) async {
    final response = await _safeRequest(
      http.post(
        _uri('/cars'),
        headers: _headers(auth: true),
        body: jsonEncode(car.toApiPayload()),
      ),
    );
    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final created = _extractCarFromResponse(data);

    _cars.insert(0, created);
    await fetchMyCars();
    notifyListeners();
    return created;
  }

  Future<Car> updateCar(Car car) async {
    final response = await _safeRequest(
      http.put(
        _uri('/cars/${car.id}'),
        headers: _headers(auth: true),
        body: jsonEncode(car.toApiPayload()),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final updated = _extractCarFromResponse(data);

    final index = _cars.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _cars[index] = updated;
    }
    await fetchMyCars();
    notifyListeners();
    return updated;
  }

  Future<void> deleteCar(String carId) async {
    final response = await _safeRequest(
      http.delete(_uri('/cars/$carId'), headers: _headers(auth: true)),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    _cars.removeWhere((c) => c.id == carId);
    _myCars.removeWhere((c) => c.id == carId);
    notifyListeners();
  }

  Future<Car> reserveCar(
    String carId, {
    String? message,
    String? contactPhone,
    String? preferredTime,
  }) async {
    final response = await _safeRequest(
      http.post(
        _uri('/cars/$carId/reserve'),
        headers: _headers(auth: true),
        body: jsonEncode({
          'message': (message ?? '').trim(),
          'contactPhone': (contactPhone ?? '').trim(),
          'preferredTime': (preferredTime ?? '').trim(),
        }),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final updated = _extractCarFromResponse(data);
    _upsertCar(updated);
    await fetchReservedCars();
    await fetchMyCars();
    await fetchNotifications();
    notifyListeners();
    return updated;
  }

  Future<Car> unreserveCar(String carId) async {
    final response = await _safeRequest(
      http.post(_uri('/cars/$carId/unreserve'), headers: _headers(auth: true)),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final updated = _extractCarFromResponse(data);
    _upsertCar(updated);
    await fetchReservedCars();
    await fetchMyCars();
    await fetchNotifications();
    notifyListeners();
    return updated;
  }

  Future<Car> approveReservation(String carId) async {
    final response = await _safeRequest(
      http.post(
        _uri('/cars/$carId/reservation-approve'),
        headers: _headers(auth: true),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final updated = _extractCarFromResponse(data);
    _upsertCar(updated);
    await fetchReservedCars();
    await fetchMyCars();
    await fetchNotifications();
    notifyListeners();
    return updated;
  }

  Future<Car> rejectReservation(String carId) async {
    final response = await _safeRequest(
      http.post(
        _uri('/cars/$carId/reservation-reject'),
        headers: _headers(auth: true),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final updated = _extractCarFromResponse(data);
    _upsertCar(updated);
    await fetchReservedCars();
    await fetchMyCars();
    await fetchNotifications();
    notifyListeners();
    return updated;
  }

  Future<void> fetchUsers() async {
    if (currentUser?.role != UserRole.admin) {
      _users.clear();
      notifyListeners();
      return;
    }
    final response = await _safeRequest(
      http.get(_uri('/admin/users'), headers: _headers(auth: true)),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final usersRaw = (data['users'] as List?) ?? const [];
    _users
      ..clear()
      ..addAll(
        usersRaw.whereType<Map<String, dynamic>>().map(AppUser.fromJson),
      );
    notifyListeners();
  }

  Future<void> deleteUser(String userId) async {
    final response = await _safeRequest(
      http.delete(_uri('/admin/users/$userId'), headers: _headers(auth: true)),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
    _users.removeWhere((u) => u.id == userId);
    _cars.removeWhere((c) => c.ownerId == userId);
    notifyListeners();
  }

  void _upsertCar(Car car) {
    final allIndex = _cars.indexWhere((c) => c.id == car.id);
    if (allIndex == -1) {
      _cars.insert(0, car);
    } else {
      _cars[allIndex] = car;
    }

    final myIndex = _myCars.indexWhere((c) => c.id == car.id);
    if (myIndex != -1) {
      _myCars[myIndex] = car;
    }
  }
}
