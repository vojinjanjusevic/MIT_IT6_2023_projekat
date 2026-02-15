class Car {
  final String id;
  final String ownerId;
  final String ownerName;
  final String title;
  final int year;
  final int km;
  final int priceEur;
  final String city;
  final String fuel;
  final String gearbox;
  final String description;
  final List<String> imagePaths;
  final bool reserved;
  final String? reservedById;
  final String? reservedByName;
  final String reservationStatus;
  final String? reservationMessage;
  final String? reservationContactPhone;
  final String? reservationPreferredTime;

  const Car({
    //u kontruktoru this.id je isto sto i this.id=id u javi npr
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.title,
    required this.year,
    required this.km,
    required this.priceEur,
    required this.city,
    required this.fuel,
    required this.gearbox,
    required this.description,
    required this.imagePaths,
    this.reserved = false,
    this.reservedById,
    this.reservedByName,
    this.reservationStatus = 'none',
    this.reservationMessage,
    this.reservationContactPhone,
    this.reservationPreferredTime,
  });

  Car copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? title,
    int? year,
    int? km,
    int? priceEur,
    String? city,
    String? fuel,
    String? gearbox,
    String? description,
    List<String>? imagePaths,
    bool? reserved,
    String? reservedById,
    String? reservedByName,
    String? reservationStatus,
    String? reservationMessage,
    String? reservationContactPhone,
    String? reservationPreferredTime,
  }) {
    return Car(
      //Ako je prosleđena nova cena, koristi nju
      //Ako nije, koristi staru cenu
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      title: title ?? this.title,
      year: year ?? this.year,
      km: km ?? this.km,
      priceEur: priceEur ?? this.priceEur,
      city: city ?? this.city,
      fuel: fuel ?? this.fuel,
      gearbox: gearbox ?? this.gearbox,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      reserved: reserved ?? this.reserved,
      reservedById: reservedById ?? this.reservedById,
      reservedByName: reservedByName ?? this.reservedByName,
      reservationStatus: reservationStatus ?? this.reservationStatus,
      reservationMessage: reservationMessage ?? this.reservationMessage,
      reservationContactPhone: reservationContactPhone ?? this.reservationContactPhone,
      reservationPreferredTime:
          reservationPreferredTime ?? this.reservationPreferredTime,
    );
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'];
    final reservedBy = json['reservedBy'];
    final reservationNote = json['reservationNote'];

    String ownerId = '';
    String ownerName = '';
    if (owner is Map<String, dynamic>) {
      ownerId = (owner['_id'] ?? owner['id'] ?? '').toString();
      ownerName = (owner['name'] ?? '').toString();
    } else {
      ownerId = (json['ownerId'] ?? json['owner'] ?? '').toString();
    }

    String? reservedById;
    String? reservedByName;
    String? reservationMessage;
    String? reservationContactPhone;
    String? reservationPreferredTime;
    if (reservedBy is Map<String, dynamic>) {
      reservedById = (reservedBy['_id'] ?? reservedBy['id'] ?? '').toString();
      reservedByName = (reservedBy['name'] ?? '').toString();
    } else if (reservedBy != null) {
      reservedById = reservedBy.toString();
    }

    if (reservationNote is Map<String, dynamic>) {
      reservationMessage = (reservationNote['message'] ?? '').toString();
      reservationContactPhone = (reservationNote['contactPhone'] ?? '').toString();
      reservationPreferredTime = (reservationNote['preferredTime'] ?? '').toString();
    }

    return Car(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      ownerId: ownerId,
      ownerName: ownerName,
      title: (json['title'] ?? '').toString(),
      year: (json['year'] as num?)?.toInt() ?? 0,
      km: (json['km'] as num?)?.toInt() ?? 0,
      priceEur: (json['priceEur'] as num?)?.toInt() ?? 0,
      city: (json['city'] ?? '').toString(),
      fuel: (json['fuel'] ?? '').toString(),
      gearbox: (json['gearbox'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imagePaths: ((json['imagePaths'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      reserved: json['reserved'] == true,
      reservedById: reservedById,
      reservedByName: reservedByName,
      reservationStatus: (json['reservationStatus'] ?? 'none').toString(),
      reservationMessage: reservationMessage,
      reservationContactPhone: reservationContactPhone,
      reservationPreferredTime: reservationPreferredTime,
    );
  }

  Map<String, dynamic> toApiPayload() {
    return {
      'title': title,
      'year': year,
      'km': km,
      'priceEur': priceEur,
      'city': city,
      'fuel': fuel,
      'gearbox': gearbox,
      'description': description,
      'imagePaths': imagePaths,
    };
  }
}
