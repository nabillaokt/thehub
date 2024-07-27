import 'package:get/get.dart';
import 'package:thehub/model/user.dart';
// Import Cloud Firestore

class CUser extends GetxController {
  final _data = User().obs;
  User get data => _data.value;
  setData(User user) => _data.value = user;
}
