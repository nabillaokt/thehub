import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  String id;
  String status;
  String cover;
  String name;
  Timestamp date;
  Timestamp time;
  List<dynamic> noTarget;

  Reservation({
    required this.id,
    required this.status,
    required this.cover,
    required this.name,
    required this.date,
    required this.time,
    required this.noTarget,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json["id"] ?? "",
      status: json["status"] ?? "",
      cover: json["cover"] ?? "",
      name: json["name"] ?? "",
      date: json["date"] ?? Timestamp.now(),
      time: json["time"] ?? Timestamp.now(),
      noTarget: json["noTarget"] ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "cover": cover,
        "name": name,
        "status": status,
        "date": date,
        "time": time,
        "noTarget": noTarget,
      };
}
