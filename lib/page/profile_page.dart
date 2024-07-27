import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thehub/config/app_asset.dart';
import 'package:thehub/config/app_color.dart';

import '../config/app_route.dart';
import '../source/user_source.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          '',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoute.profile);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: StreamBuilder<String?>(
                              stream: _getUserAvatarUrlStream(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    snapshot.data == null) {
                                  return Image.asset(
                                    AppAsset.avatar,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  );
                                }

                                return Image.network(
                                  snapshot.data!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Column(
                  children: [
                    StreamBuilder<String?>(
                      stream: _getUserNameStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            ' ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return const Text(
                            'Hi, Guest',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          );
                        } else {
                          return Text(
                            '${snapshot.data}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          );
                        }
                      },
                    ),
                    StreamBuilder<String?>(
                      stream: _getUserEmailStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            ' ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return const Text(
                            'Hi, Guest',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          );
                        } else {
                          return Text(
                            '${snapshot.data}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),
              MenuProfileWidget(
                title: 'Edit Profil',
                icon: LineAwesomeIcons.cog,
                onPressed: () {
                  Get.toNamed(AppRoute.updateProfile);
                },
              ),
              const SizedBox(height: 15),
              MenuProfileWidget(
                title: 'HUBPay',
                icon: LineAwesomeIcons.wallet,
                onPressed: () {
                  Get.toNamed(AppRoute.wallet);
                },
              ),
              const SizedBox(height: 15),
              MenuProfileWidget(
                title: 'Ubah Password',
                icon: LineAwesomeIcons.lock,
                onPressed: () {
                  Get.toNamed(AppRoute.editpassword);
                },
              ),
              const SizedBox(height: 15),
              MenuProfileWidget(
                title: 'FAQ',
                icon: LineAwesomeIcons.question_circle,
                onPressed: () {
                  Get.toNamed(AppRoute.faq);
                },
              ),
              const Divider(),
              const SizedBox(height: 15),
              MenuProfileWidget(
                title: 'Log Out',
                icon: LineAwesomeIcons.alternate_sign_out,
                textColor: Colors.red,
                endIcon: false,
                onPressed: () {
                  Alert(
                    context: context,
                    title: "Konfirmasi",
                    desc: "Anda yakin ingin log out?",
                    style: const AlertStyle(
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      descStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    buttons: [
                      DialogButton(
                        onPressed: () {
                          UserSource.logout().then((_) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to logout: $error'),
                            ));
                          });
                          Navigator.pop(context);
                        },
                        color: Colors.red,
                        child: Text(
                          "Ya, log out",
                          style: TextStyle(color: Colors.red[50], fontSize: 16),
                        ),
                      ),
                      DialogButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.green,
                        child: Text(
                          "Tidak",
                          style:
                              TextStyle(color: Colors.green[50], fontSize: 16),
                        ),
                      )
                    ],
                  ).show();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Stream<String?> _getUserNameStream() {
  final currentUser = FirebaseAuth.instance.currentUser;
  final userId = currentUser?.uid;
  return FirebaseFirestore.instance
      .collection('user')
      .doc(userId)
      .snapshots()
      .map((DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      return data['name']?.toString();
    } else {
      return null;
    }
  });
}

Stream<String?> _getUserEmailStream() {
  final currentUser = FirebaseAuth.instance.currentUser;
  final userId = currentUser?.uid;
  return FirebaseFirestore.instance
      .collection('user')
      .doc(userId)
      .snapshots()
      .map((DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      return data['email']?.toString();
    } else {
      return null;
    }
  });
}

Stream<String?> _getUserAvatarUrlStream() {
  final currentUser = FirebaseAuth.instance.currentUser;
  final userId = currentUser?.uid;
  return FirebaseFirestore.instance
      .collection('user')
      .doc(userId)
      .snapshots()
      .map((DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      return data['avatarUrl']?.toString();
    } else {
      return null;
    }
  });
}

class MenuProfileWidget extends StatelessWidget {
  const MenuProfileWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColor.primary.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: AppColor.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppColor.secondary.withOpacity(0.1),
              ),
              child: const Icon(
                LineAwesomeIcons.angle_right,
                size: 18,
                color: AppColor.secondary,
              ),
            )
          : null,
    );
  }
}
