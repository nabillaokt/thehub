import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:thehub/config/app_color.dart';
import 'package:thehub/controller/c_home.dart';
import 'package:thehub/page/home_page.dart';

import '../model/paket_sarana.dart';

class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Paketsarana paket =
        ModalRoute.of(context)!.settings.arguments as Paketsarana;
    final cHome = Get.put(CHome());
    return Scaffold(
      backgroundColor: AppColor.backgroundCheckout,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 6, color: Colors.white),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  paket.cover,
                  width: 190,
                  height: 190,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Selamat! Reservasi ${paket.name} panahan Anda berhasil! ',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
            const Text(
              'Waktunya membidik ke target kesuksesan! 🏹 ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 30),
            Material(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  cHome.indexPage = 1;
                  Get.offAll(() => const HomePage());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 50,
                  ),
                  child: const Text(
                    'Check Reservasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
