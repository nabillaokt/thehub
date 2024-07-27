import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:thehub/config/app_route.dart';

import '../config/app_asset.dart';
import '../config/app_color.dart';
import '../controller/c_home.dart';

class ForgetPassSuccesPage extends StatelessWidget {
  const ForgetPassSuccesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cHome = Get.put(CHome());
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the children vertically
          children: [
            ClipRect(
              child: SvgPicture.asset(AppAsset.success),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sukses',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                'Silakan periksa email Anda untuk membuat kata sandi baru',
                textAlign: TextAlign.center, // Center the text horizontally
                style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Tidak mendapatkan email? ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 1),
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoute.forgetpassword);
                  },
                  child: const Text(
                    "Kirim Ulang",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColor.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Material(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Get.toNamed(AppRoute.login);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 100,
                  ),
                  child: const Text(
                    'Kembali login',
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
