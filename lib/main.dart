import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:thehub/config/app_color.dart';
import 'package:thehub/config/app_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thehub/firebase_options.dart';
import 'package:thehub/page/checkoutSucces_page.dart';
import 'package:thehub/page/checkout_page.dart';
import 'package:thehub/page/dashboard_page.dart';
import 'package:thehub/page/detailjadwal.dart';
import 'package:thehub/page/detailreservasi_page.dart';
import 'package:thehub/page/edit_password.dart';
import 'package:thehub/page/faq_page.dart';
import 'package:thehub/page/forget_password.dart';
import 'package:thehub/page/forgetpass_success.dart';
import 'package:thehub/page/history_page.dart';
import 'package:thehub/page/home_page.dart';
import 'package:thehub/page/intro_page.dart';
import 'package:thehub/page/laporan_page.dart';
import 'package:thehub/page/login_page.dart';
import 'package:thehub/page/notification_page.dart';
import 'package:thehub/page/paketpanahan_page.dart';
import 'package:thehub/page/pengunjung_page.dart';
import 'package:thehub/page/profile_page.dart';
import 'package:thehub/page/reservasi_page.dart';
import 'package:thehub/page/signup.dart';
import 'package:thehub/page/topup_page.dart';
import 'package:thehub/page/topup_success.dart';
import 'package:thehub/page/update_profile.dart';
import 'package:thehub/page/wallet_page.dart';

import 'controller/c_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(CUser());
  initializeDateFormatting('en_US');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: AppColor.backgroundScaffold,
        primaryColor: AppColor.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColor.primary,
          secondary: AppColor.secondary,
        ),
      ),
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? AppRoute.home
          : AppRoute.intro,
      routes: {
        AppRoute.intro: (context) => const IntroPage(),
        AppRoute.home: (context) => const HomePage(),
        AppRoute.login: (context) => const LoginPage(),
        AppRoute.history: (context) => const HistoryPage(),
        AppRoute.dashboard: (context) => const DashboardPage(),
        AppRoute.notification: (context) => const NotificationPage(),
        AppRoute.signup: (context) => const SignUpPage(),
        AppRoute.detailreservation: (context) => const DetailReservationPage(),
        AppRoute.checkout: (context) => const CheckoutPage(),
        AppRoute.profile: (context) => const ProfilePage(),
        AppRoute.updateProfile: (context) => const UpdateProfilePage(),
        AppRoute.checkoutsuccess: (context) => const CheckoutSuccessPage(),
        AppRoute.wallet: (context) => const WalletPage(),
        AppRoute.topup: (context) => const TopUpPage(),
        AppRoute.editpassword: (context) => const EditPasswordPage(),
        AppRoute.forgetpassword: (context) => const ForgetPasswordPage(),
        AppRoute.topupSuccess: (context) => const TopUpSuccessPage(),
        AppRoute.faq: (context) => const FAQPage(),
        AppRoute.forgetpassSuccess: (context) => const ForgetPassSuccesPage(),
        AppRoute.pengunjung: (context) => const PengunjungPage(),
        AppRoute.paketpanahan: (context) => const PaketPanahanPage(),
        AppRoute.reservasi: (context) => const ReservasiPage(),
        AppRoute.detailjadwal: (context) => const DetailJadwalPage(),
        AppRoute.laporan: (context) => const ReservationReport(),
      },
    );
  }
}
