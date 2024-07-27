import 'package:get/get.dart';

class WalletController extends GetxController {
  RxInt balance = 0.obs;

  void topUp(int amount) {
    balance += amount;
  }
}
