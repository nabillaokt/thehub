// signout_page.dart
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'login_page.dart'; // Sesuaikan dengan path halaman login Anda

class SignOutPage extends StatelessWidget {
  const SignOutPage({Key? key}) : super(key: key);

  void signOut(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Konfirmasi Keluar",
      desc: "Apakah Anda yakin ingin keluar?",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
          child: const Text(
            "Batal",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        DialogButton(
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Get.offAll(() => const LoginPage()); // Navigate to login page
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal keluar: $e')),
              );
            }
          },
          color: Colors.red,
          child: const Text(
            "Keluar",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Out Page"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => signOut(context),
          child: const Text("Sign Out"),
        ),
      ),
    );
  }
}
