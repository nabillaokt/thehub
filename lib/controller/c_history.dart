import 'package:get/get.dart';
import 'package:thehub/model/reservation.dart';
import 'package:thehub/source/reservation_source.dart';

class CHistory extends GetxController {
  final _listReservation = <Reservation>[].obs;
  List<Reservation> get listReservation => _listReservation;

  Stream<List<Reservation>> reservationStream() {
    // Return a stream of reservations from ReservationSource
    return ReservationSource.getHistoryStream();
  }
}
