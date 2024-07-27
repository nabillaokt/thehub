import 'package:get/get.dart';
import '../model/notification.dart';
import '../source/reservation_source.dart';

class CNotification extends GetxController {
  final _listNotification = <Notification>[].obs;
  List<Notification> get listNotification => _listNotification;

  Stream<List<Notification>> notificationStream() {
    return ReservationSource.getNotifStream();
  }
}
