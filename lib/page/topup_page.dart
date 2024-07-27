import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// Import shared_preferences

import '../config/app_asset.dart';
import '../config/app_color.dart';
import '../config/app_format.dart';
import '../config/app_route.dart';
import '../model/wallet.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({Key? key}) : super(key: key);

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController amountController =
      TextEditingController(text: '0');

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

  void topUpBalance(int amount) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    // Get current balance
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('user').doc(userId).get();
    // Convert balance to double
    double currentBalance = double.parse(userSnapshot['balance']);

    // Update balance
    double newBalance = currentBalance + amount;
    await FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .update({'balance': newBalance.toString()});

    // Add transaction record
    TransactionModel transaction = TransactionModel(
      id: FirebaseFirestore.instance.collection('user').doc().id,
      type: 'Top Up',
      amount: amount,
      timestamp: DateTime.now(),
    );

    FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundCheckout,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Top Up',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.offAndToNamed(AppRoute.wallet);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.secondary,
            size: 15,
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wallet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SvgPicture.asset(
                          AppAsset.cardwallet,
                          fit: BoxFit.cover,
                          height: 60,
                          width: 90,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                );
                              }
                            },
                          ),
                          StreamBuilder<String?>(
                            stream: _getUserNameStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text(
                                  ' ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data == null) {
                                return const Text(
                                  '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                );
                              } else {
                                return Text(
                                  '${snapshot.data}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (text) {
                      String temp = '';

                      for (int i = 0; i < text.length; i++) {
                        temp += RegExp(r'\d').hasMatch(text[i]) ? text[i] : '';
                      }

                      amountController.text = NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'IDR ',
                        decimalDigits: 0,
                      ).format(int.tryParse(temp) ?? 0);

                      amountController.selection = TextSelection.fromPosition(
                        TextPosition(offset: amountController.text.length),
                      );
                    },
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: "Amount",
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 40,
                    runSpacing: 30,
                    children: <Widget>[
                      makeMoneyCard(amount: 50000, width: 120, height: 60),
                      makeMoneyCard(amount: 100000, width: 120, height: 60),
                      makeMoneyCard(amount: 150000, width: 120, height: 60),
                      makeMoneyCard(amount: 200000, width: 120, height: 60),
                      makeMoneyCard(amount: 250000, width: 120, height: 60),
                      makeMoneyCard(amount: 500000, width: 120, height: 60),
                      makeMoneyCard(amount: 1000000, width: 120, height: 60),
                      makeMoneyCard(amount: 2500000, width: 120, height: 60),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Material(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        int amount = int.parse(amountController.text
                            .replaceAll(RegExp(r'\D'), ''));
                        if (amount > 0) {
                          topUpBalance(amount);
                          Get.toNamed(AppRoute.wallet);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 117,
                        ),
                        child: const Text(
                          'Top Up',
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  MoneyCard makeMoneyCard({
    required int amount,
    required double width,
    required double height,
  }) {
    return MoneyCard(
      amount: amount,
      width: width,
      height: height,
      isSelected: amount ==
          int.parse(amountController.text.replaceAll(RegExp(r'\D'), '')),
      onTap: () {
        final selectedAmountValue =
            int.parse(amountController.text.replaceAll(RegExp(r'\D'), ''));
        if (selectedAmountValue != amount) {
          amountController.text = NumberFormat.currency(
            locale: 'id_ID',
            decimalDigits: 0,
            symbol: 'IDR ',
          ).format(amount);
        } else {
          amountController.text = '0';
        }
      },
    );
  }
}

class MoneyCard extends StatelessWidget {
  final int amount;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback onTap;

  const MoneyCard({
    Key? key,
    required this.amount,
    required this.width,
    required this.height,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColor.primary
                : AppColor.primary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Rp $amount',
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColor.primary,
            ),
            textAlign: TextAlign.center,
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
