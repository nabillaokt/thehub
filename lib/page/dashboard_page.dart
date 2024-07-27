import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thehub/config/app_route.dart';
import '../config/app_asset.dart';
import '../config/app_color.dart';
import '../config/app_format.dart';
import '../controller/c_dashboard.dart';
import '../model/paket_sarana.dart';
import 'package:badges/badges.dart' as Badges;

import '../source/user_source.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final cDashboard = Get.put(CDashboard());

  late Stream<String?> userBalanceStream;

  @override
  void initState() {
    super.initState();
    userBalanceStream = getUserBalanceStream();
  }

  Stream<String?> getUserBalanceStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .snapshots()
        .map((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        return data['balance']?.toString();
      } else {
        return null;
      }
    });
  }

  Stream<Map<String, dynamic>?> getUserDataStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .snapshots()
        .map((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: getUserDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          final userData = snapshot.data!;
          final role = userData['role'];

          if (role == 'admin') {
            return buildAdminDashboard(context);
          } else {
            return buildUserDashboard(context);
          }
        } else {
          return const Center(child: Text('No user data found'));
        }
      },
    );
  }

  Widget buildAdminDashboard(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: StreamBuilder<String?>(
                    stream: _getUserNameStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          ' ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Text(
                          'Hi, Guest!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        );
                      } else {
                        return Text(
                          'Hi, ${snapshot.data}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      _showSignOutAlert(context);
                    },
                    child: const Icon(
                      LineAwesomeIcons.alternate_sign_out,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30)
              ],
            ),
          ),
          Container(
            color: Theme.of(context).primaryColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(200))),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 50,
                children: [
                  itemDashboard(
                    'Daftar\nPengguna',
                    CupertinoIcons.person_2,
                    Colors.deepOrange,
                    AppRoute.pengunjung,
                  ),
                  itemDashboard(
                    'Kelola\nPaket Panahan',
                    CupertinoIcons.square_list,
                    Colors.green,
                    AppRoute.paketpanahan,
                  ),
                  itemDashboard(
                    'Kelola\nReservasi',
                    LineAwesomeIcons.book,
                    Colors.purple,
                    AppRoute.reservasi,
                  ),
                  itemDashboard(
                    'Kelola\nDetail Jadwal',
                    LineAwesomeIcons.calendar_1,
                    Colors.blue,
                    AppRoute.detailjadwal,
                  ),
                  itemDashboard(
                    'Laporan Reservasi',
                    LineAwesomeIcons.book,
                    Colors.red,
                    AppRoute.laporan,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  void _showSignOutAlert(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Log Out",
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
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
          child: const Text(
            "Tidak",
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
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
          child: const Text(
            "Ya, log out",
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        )
      ],
    ).show();
  }

  Widget buildUserDashboard(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoute.updateProfile);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
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
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data == null) {
                              return const Text(
                                'Hi, Guest!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              );
                            } else {
                              return Text(
                                'Hi, ${snapshot.data}!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              );
                            }
                          },
                        ),
                        Row(
                          children: [
                            const Icon(
                              LineAwesomeIcons.wallet,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            StreamBuilder<String?>(
                              stream: userBalanceStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  String? balance = snapshot.data;

                                  return Text(
                                    AppFormat.currency(
                                        double.parse(balance ?? '0')),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              CupertinoIcons.add_circled_solid,
                              size: 10,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .doc(userId)
                      .collection('reservations')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    // Extracting reservations
                    final notifications = snapshot.data!.docs.map((doc) {
                      return {
                        'status': doc['status'],
                        'isRead': doc['isRead'],
                      };
                    }).toList();

                    // Filter pending and berhasil with isRead == 'unread'
                    final pendingAndSuccessfulUnread =
                        notifications.where((notif) {
                      final status = notif['status'];
                      final isRead = notif['isRead'];
                      return (status == 'pending' || status == 'berhasil') &&
                          isRead == 'unread';
                    }).toList();

                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoute.notification);
                      },
                      child: Badges.Badge(
                        showBadge: pendingAndSuccessfulUnread.isNotEmpty,
                        ignorePointer: true,
                        badgeContent:
                            Text(pendingAndSuccessfulUnread.length.toString()),
                        position: Badges.BadgePosition.topEnd(top: -8, end: -8),
                        child: const Icon(
                          CupertinoIcons.bell_solid,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(50),
                  topLeft: Radius.circular(50),
                ),
                color: Colors.white,
              ),
              child: _buildPaketSaranaGrid(),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildPaketSaranaGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('PaketSaran').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        List<Paketsarana>? list =
            snapshot.data?.docs.map((DocumentSnapshot doc) {
          return Paketsarana(
            id: doc['id'],
            name: doc['name'],
            description: doc['description'],
            cover: doc['cover'],
            price: doc['price'],
          );
        }).toList();

        if (list!.isEmpty) return const Center(child: Text('Tidak Ada Data'));
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 25,
            crossAxisSpacing: 10,
            childAspectRatio: 0.60,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            Paketsarana paket = list[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoute.detailreservation,
                    arguments: paket);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          paket.cover,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      paket.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paket.description,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          AppFormat.currency(paket.price.toDouble()),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget itemDashboard(
      String title, IconData iconData, Color background, String routeName) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
              color: Theme.of(context).primaryColor.withOpacity(.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
