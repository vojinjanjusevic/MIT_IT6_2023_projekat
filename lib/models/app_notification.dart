class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool read;
  final DateTime? createdAt;
  final String? carId;
  final String? carTitle;
  final String? actorName;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    this.createdAt,
    this.carId,
    this.carTitle,
    this.actorName,
  });

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      read: read ?? this.read,
      createdAt: createdAt,
      carId: carId,
      carTitle: carTitle,
      actorName: actorName,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final actor = json["actor"];
    final car = json["car"];
    return AppNotification(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      type: (json["type"] ?? "system").toString(),
      title: (json["title"] ?? "").toString(),
      message: (json["message"] ?? "").toString(),
      read: json["read"] == true,
      createdAt: json["createdAt"] is String
          ? DateTime.tryParse(json["createdAt"].toString())
          : null,
      carId: car is Map<String, dynamic>
          ? (car["_id"] ?? car["id"] ?? "").toString()
          : null,
      carTitle: car is Map<String, dynamic> ? (car["title"] ?? "").toString() : null,
      actorName: actor is Map<String, dynamic> ? (actor["name"] ?? "").toString() : null,
    );
  }
}
