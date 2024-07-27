import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/app_asset.dart';
import '../config/app_color.dart';
import '../config/app_format.dart';
import '../config/app_route.dart';
import '../controller/c_home.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final cHome = Get.put(CHome());

  late Stream<String?> userBalanceStream;

  @override
  void initState() {
    super.initState();
    userBalanceStream = _getUserBalanceStream();
  }

  Stream<String?> _getUserBalanceStream() {
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

  Stream<List<DocumentSnapshot>> _getTransactionStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'HUBPay',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            cHome.indexPage = 2;
            Get.offAndToNamed(AppRoute.home);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.secondary,
            size: 15,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 10, 20),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.offAndToNamed(AppRoute.topup);
                  },
                  child: SvgPicture.asset(
                    AppAsset.cardwallet,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 0, 10),
                      child: Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: StreamBuilder<String?>(
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
                              AppFormat.currency(double.parse(balance ?? '0')),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                      child: StreamBuilder<String?>(
                        stream: _getUserNameStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              ' ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return const Text(
                              '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            );
                          } else {
                            return Text(
                              '${snapshot.data}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text(
              "Transaksi Terakhir",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _getTransactionStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<DocumentSnapshot> transactions = snapshot.data ?? [];

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      var transactionData =
                          transactions[index].data() as Map<String, dynamic>;

                      Color amountColor = transactionData['type'] == 'Top Up'
                          ? Colors.green
                          : Colors.red;

                      String formattedDateTime = DateFormat('dd-MM-yyyy')
                          .add_Hms() // Optionally add hours, minutes, seconds if needed
                          .format((transactionData['timestamp'] as Timestamp)
                              .toDate());

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Icon(
                                transactionData['type'] == 'Top Up'
                                    ? Icons.arrow_circle_up
                                    : Icons.arrow_circle_down,
                                color: amountColor,
                              ),
                            ),
                            title: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Text(
                                transactionData['type'] == 'Top Up'
                                    ? 'Top Up E-wallet'
                                    : 'Pembayaran',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: Text(
                                    AppFormat.currency(double.parse(
                                        transactionData['amount'].toString())),
                                    style: TextStyle(
                                      color: amountColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  formattedDateTime,
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.5)),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
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
