import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thehub/config/app_color.dart';
import 'package:thehub/page/dashboard_page.dart';
import 'package:thehub/page/history_page.dart';
import 'package:thehub/controller/c_home.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final cHome = Get.put(CHome());
  final List<Map<String, dynamic>> listNav = [
    {'icon': CupertinoIcons.home, 'label': 'Beranda'},
    {'icon': CupertinoIcons.time, 'label': 'Histori'},
    {'icon': CupertinoIcons.person, 'label': 'Profil'},
  ];

  Stream<DocumentSnapshot> _userStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .snapshots();
    } else {
      return const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (cHome.indexPage == 1) {
          return const HistoryPage();
        } else if (cHome.indexPage == 2) {
          return const ProfilePage();
        }
        return const DashboardPage();
      }),
      bottomNavigationBar: StreamBuilder<DocumentSnapshot>(
        stream: _userStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          bool isSpecialUser = false;
          if (snapshot.hasData && snapshot.data!.exists) {
            isSpecialUser = snapshot.data!.id == 'NYfIlRg91aQ7fryTW9KhG6KLVJF3';
          }

          if (isSpecialUser) {
            return const SizedBox.shrink();
          }

          return Material(
            elevation: 5,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Obx(() => BottomNavigationBar(
                    currentIndex: cHome.indexPage,
                    onTap: (value) => cHome.indexPage = value,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    type: BottomNavigationBarType.fixed,
                    unselectedItemColor: Colors.black.withOpacity(0.5),
                    selectedItemColor: AppColor.primary,
                    selectedIconTheme: const IconThemeData(
                      color: AppColor.primary,
                    ),
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    selectedFontSize: 12,
                    items: listNav.map((e) {
                      return BottomNavigationBarItem(
                        icon: Icon(e['icon']),
                        label: e['label'],
                      );
                    }).toList(),
                  )),
            ),
          );
        },
      ),
    );
  }
}
