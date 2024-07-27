import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thehub/model/reservation.dart';

import '../config/app_format.dart';
import '../model/notification.dart';

class ReservationSource {
  static Future<Reservation?> reserved(String userId, String paketId) async {
    var result = await FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('reservations')
        .where('idPaketSarana', isEqualTo: paketId)
        .where('is_done', isEqualTo: false)
        .get();
    if (result.size > 0) {
      return Reservation.fromJson(result.docs.first.data());
    }
    return null;
  }

  Future<void> saveReservationData(
    DateTime selectedDate,
    DateTime selectedTime,
    List<String> selectedTargets,
    String paketName,
    String paketCover,
    double paketPrice,
    double totalPayment,
    String statusReservasi,
    String paymentMethod,
    String isRead,
  ) async {
    try {
      String reservationId = AppFormat.generateReservationId();

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        WriteBatch batch = FirebaseFirestore.instance.batch();

        DocumentReference reservationDoc = FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .collection('reservations')
            .doc();

        Map<String, dynamic> reservationData = {
          'id': reservationId,
          'cover': paketCover,
          'name': paketName,
          'date': Timestamp.fromDate(selectedDate),
          'time': Timestamp.fromDate(selectedTime),
          'noTarget': selectedTargets,
          'paketPrice': paketPrice,
          'totalPayment': totalPayment,
          'status': statusReservasi, // Use the dynamic status here
          'paymentMethod': paymentMethod,
          'isRead': isRead,
        };

        batch.set(reservationDoc, reservationData);

        await batch.commit();
      } else {
        throw Exception("User not logged in");
      }
    } catch (error) {}
  }

  Future<void> SaveNotification(
    DateTime selectedDate,
    DateTime selectedTime,
    List<String> selectedTargets,
    String paketName,
    String paketCover,
    double paketPrice,
    double totalPayment,
    String statusReservasi,
    String paymentMethod,
    String isRead,
  ) async {
    try {
      String reservationId = AppFormat.generateReservationId();

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        WriteBatch batch = FirebaseFirestore.instance.batch();

        DocumentReference reservationDoc = FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .collection('notifications')
            .doc();

        Map<String, dynamic> reservationData = {
          'id': reservationId,
          'cover': paketCover,
          'name': paketName,
          'date': Timestamp.fromDate(selectedDate),
          'time': Timestamp.fromDate(selectedTime),
          'noTarget': selectedTargets,
          'paketPrice': paketPrice,
          'totalPayment': totalPayment,
          'status': statusReservasi, // Use the dynamic status here
          'paymentMethod': paymentMethod,
          'isRead': isRead,
        };

        batch.set(reservationDoc, reservationData);

        await batch.commit();
      } else {
        throw Exception("User not logged in");
      }
    } catch (error) {
      print("Failed to save reservation data: $error");
    }
  }

  static Stream<List<Reservation>> getHistoryStream() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('reservations')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reservation.fromJson(doc.data()))
            .toList());
  }

  static Stream<List<Notification>> getNotifStream() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('reservations')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notification.fromJson(doc.data()))
            .toList());
  }

  static Future<List<String>> getTargetData() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        var result = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .collection('reservations')
            .get();
        return result.docs.map((doc) => doc['target'] as String).toList();
      }
      throw Exception("User not logged in");
    } catch (error) {
      print("Failed to get target data: $error");
      return [];
    }
  }
}
