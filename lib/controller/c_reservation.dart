import 'package:get/get.dart';

class DeletedItemsController extends GetxController {
  RxList<String> deletedUserIds = <String>[].obs;
  RxList<String> deletedReservationIds = <String>[].obs;

  void addUserToDelete(String userId) {
    deletedUserIds.add(userId);
  }

  void addReservationToDelete(String reservationId) {
    deletedReservationIds.add(reservationId);
  }
}
