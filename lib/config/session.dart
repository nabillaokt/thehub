import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thehub/model/user.dart';
import 'package:thehub/controller/c_user.dart';

class Session {
  static Future<bool> saveUser(User user) async {
    try {
      final pref = await SharedPreferences.getInstance();
      final Map<String, dynamic> mapUser = user.toJson();
      final String stringUser = jsonEncode(mapUser);
      final bool success = await pref.setString('user', stringUser);
      if (success) {
        final cUser = Get.find<
            CUser>(); // Menggunakan Get.find untuk mencari instance yang sudah ada
        cUser.setData(user);
      }
      return success;
    } catch (error) {
      return false;
    }
  }

  Stream<User> getUserStream() async* {
    final pref = await SharedPreferences.getInstance();
    String? stringUser = pref.getString('user');
    User user = User(); // default value

    if (stringUser != null) {
      Map<String, dynamic> mapUser = jsonDecode(stringUser);
      user = User.fromJson(mapUser);
    }

    final cUser = Get.put(CUser());
    cUser.setData(user);

    yield user;
  }

  static Future<bool> clearUser() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final bool success = await pref.remove('user');
      final cUser = Get.find<
          CUser>(); // Menggunakan Get.find untuk mencari instance yang sudah ada
      cUser.setData(User());
      return success;
    } catch (error) {
      return false;
    }
  }

  static Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> saveReservations(List<String> reservations) async {
    try {
      final pref = await SharedPreferences.getInstance();
      final String stringReservations = jsonEncode(reservations);
      final bool success =
          await pref.setString('reservations', stringReservations);
      return success;
    } catch (error) {
      return false;
    }
  }

  static Future<List<String>> getReservations() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final String? stringReservations = pref.getString('reservations');
      if (stringReservations != null) {
        final List<dynamic> listReservations = jsonDecode(stringReservations);
        final List<String> reservations = listReservations.cast<String>();
        return reservations;
      }
      return [];
    } catch (error) {
      return [];
    }
  }

  static Future<bool> saveTargets(List<String> targets) async {
    try {
      final pref = await SharedPreferences.getInstance();
      final String stringTargets = jsonEncode(targets);
      final bool success = await pref.setString('targets', stringTargets);
      return success;
    } catch (error) {
      return false;
    }
  }

  static Future<List<String>> getTargets() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final String? stringTargets = pref.getString('targets');
      if (stringTargets != null) {
        final List<dynamic> listTargets = jsonDecode(stringTargets);
        final List<String> targets = listTargets.cast<String>();
        return targets;
      }
      return [];
    } catch (error) {
      return [];
    }
  }
}
