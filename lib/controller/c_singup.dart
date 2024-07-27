import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SingUpController extends GetxController {
  static SingUpController get instance => Get.find();

  final email = TextEditingController();
  final calender = TextEditingController();
  final name = TextEditingController();
  final password = TextEditingController();
}
