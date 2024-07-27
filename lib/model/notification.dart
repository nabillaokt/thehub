import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  String id;
  String status;
  String cover;
  String name;
  Timestamp date;
  Timestamp time;
  List<dynamic> noTarget;
  String isRead;
  String paymentMethod;

  Notification({
    required this.id,
    required this.status,
    required this.cover,
    required this.name,
    required this.date,
    required this.time,
    required this.noTarget,
    required this.isRead,
    required this.paymentMethod,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json["id"] ?? "",
      status: json["status"] ?? "",
      cover: json["cover"] ?? "",
      name: json["name"] ?? "",
      date: json["date"] ?? Timestamp.now(),
      time: json["time"] ?? Timestamp.now(),
      noTarget: json["noTarget"] ?? [],
      isRead: json['isRead'] ?? 'unread',
      paymentMethod: json['paymentMethod'] ?? '',
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
        "isRead": isRead,
        "paymentMethod": paymentMethod,
      };
}
