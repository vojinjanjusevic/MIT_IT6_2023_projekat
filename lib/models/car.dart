class Car {
  final String id;
  final String ownerId;
  final String title;
  final int year;
  final int km;
  final int priceEur;
  final String city;
  final String fuel;
  final String gearbox;
  final String description;

  const Car({
    //u kontruktoru this.id je isto sto i this.id=id u javi npr
    required this.id,
    required this.ownerId,
    required this.title,
    required this.year,
    required this.km,
    required this.priceEur,
    required this.city,
    required this.fuel,
    required this.gearbox,
    required this.description,
  });

  Car copyWith({
    String? id,
    String? ownerId,
    String? title,
    int? year,
    int? km,
    int? priceEur,
    String? city,
    String? fuel,
    String? gearbox,
    String? description,
  }) {
    return Car(
      //Ako je prosleđena nova cena, koristi nju
      //Ako nije, koristi staru cenu
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      year: year ?? this.year,
      km: km ?? this.km,
      priceEur: priceEur ?? this.priceEur,
      city: city ?? this.city,
      fuel: fuel ?? this.fuel,
      gearbox: gearbox ?? this.gearbox,
      description: description ?? this.description,
    );
  }
}