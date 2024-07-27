import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:thehub/config/app_color.dart';
import 'package:thehub/config/app_format.dart';
import 'package:thehub/config/app_route.dart';
import 'package:thehub/controller/c_user.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../model/paket_sarana.dart';
import '../model/wallet.dart';
import '../source/reservation_source.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final cUser = Get.put(CUser());
  String selectedPaymentMethod = '';
  final reservationSource = ReservationSource();

  Stream<String?>? userBalanceStream;

  @override
  void initState() {
    super.initState();

    userBalanceStream = getUserBalanceStream();
  }

  void updateWalletBalanceAndSaveTransaction(double totalPayment) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    if (selectedPaymentMethod == 'HUBPay') {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      double currentBalance = double.parse(userSnapshot['balance']);

      double newBalance = currentBalance - totalPayment;

      await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .update({'balance': newBalance.toString()});
    }

    // Only save transaction if selectedPaymentMethod is 'HUBPay'
    if (selectedPaymentMethod == 'HUBPay') {
      String status = 'berhasil';
      TransactionModel transaction = TransactionModel(
        id: FirebaseFirestore.instance.collection('user').doc().id,
        type: 'Pembayaran',
        amount: -(totalPayment.toInt()),
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    DateTime selectedDate = args['selectedDate'] as DateTime;
    String selectedTime = args['selectedTime'] as String;
    Paketsarana paket = args['paket'] as Paketsarana;
    List<String> selectedTargets = args['selectedTargets'] as List<String>;

    return Scaffold(
      backgroundColor: AppColor.backgroundCheckout,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Check Out',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          header(paket),
          const SizedBox(height: 15),
          detailReservasi(
              context, selectedDate, selectedTime, selectedTargets, paket),
          const SizedBox(height: 15),
          metodepembayaran(
            selectedDate,
            selectedTime,
            selectedTargets,
            paket,
          ),
          const SizedBox(height: 30),
          Material(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                if (selectedPaymentMethod.isEmpty) {
                  Alert(
                    context: context,
                    type: AlertType.error,
                    title: "Metode Pembayaran",
                    desc:
                        "Silakan pilih metode pembayaran\nanda terlebih dahulu",
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
                        width: 120,
                        color: AppColor.primary,
                        child: const Text(
                          "Ok",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    ],
                  ).show();
                  return;
                }

                double totalPayment =
                    selectedTargets.length * paket.price.toDouble();
                updateWalletBalanceAndSaveTransaction(totalPayment);

                String status = selectedPaymentMethod == 'Transfer Bank'
                    ? 'pending'
                    : 'berhasil';

                DateTime currentDate = DateTime.now();

// Gabungkan tanggal saat ini dengan waktu yang diparse dari selectedTime
                DateTime reservationDateTime = DateTime(
                  currentDate.year,
                  currentDate.month,
                  currentDate.day,
                  DateFormat('HH:mm').parse(selectedTime).hour,
                  DateFormat('HH:mm').parse(selectedTime).minute,
                );

                reservationSource.saveReservationData(
                  selectedDate,
                  reservationDateTime,
                  selectedTargets,
                  paket.name,
                  paket.cover,
                  paket.price.toDouble(),
                  totalPayment,
                  status,
                  selectedPaymentMethod,
                  'unread',
                );
                Navigator.pushReplacementNamed(
                    context, AppRoute.checkoutsuccess,
                    arguments: paket);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: const Text(
                  'Proses Reservasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  Container metodepembayaran(DateTime selectedDate, String selectedTime,
      List<String> selectedTargets, Paketsarana paket) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<String?>(
            stream: userBalanceStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                String? balance = snapshot.data;
                double totalPayment =
                    (selectedTargets.length * paket.price).toDouble();
                bool isBalanceSufficient =
                    double.parse(balance ?? '0') >= totalPayment;

                if (!isBalanceSufficient && selectedPaymentMethod == 'HUBPay') {
                  return Column(
                    children: [
                      const Text(
                        'Silakan top up saldo HUBPay anda terlebih dahulu atau gunakan metode pembayaran lainnya',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      paymentOption(
                        'HUBPay',
                        'Balance ${AppFormat.currency(double.parse(balance ?? '0'))}',
                        isBalanceSufficient ? Colors.black : Colors.red,
                      ),
                      const SizedBox(height: 10),
                      paymentOption(
                        'Transfer Bank',
                        'Bayar melalui rekening bank berikut',
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      paymentOption(
                        'HUBPay',
                        'Balance ${AppFormat.currency(double.parse(balance ?? '0'))}',
                        isBalanceSufficient ? Colors.black : Colors.red,
                      ),
                      const SizedBox(height: 10),
                      paymentOption(
                        'Transfer Bank',
                        'Bayar melalui rekening bank berikut : 083797657 a/n The HUB Cibubur',
                      ),
                    ],
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget paymentOption(String method, String description, [Color? textColor]) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedPaymentMethod == method
                ? Colors.greenAccent
                : Colors.grey[300]!,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(height: 16, width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: textColor ?? Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedPaymentMethod == method)
              const Icon(Icons.check_circle, color: Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  Container detailReservasi(BuildContext context, DateTime selectedDate,
      String selectedTime, List<String> selectedTargets, Paketsarana paket) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Reservasi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          itemdetailreserv(
              context, 'ID Reservasi', AppFormat.generateReservationId()),
          const SizedBox(height: 15),
          itemdetailreserv(
            context,
            'Tanggal',
            DateFormat('yyyy-MM-dd').format(selectedDate),
          ),
          const SizedBox(height: 15),
          itemdetailreserv(
            context,
            'Waktu',
            selectedTime,
          ),
          const SizedBox(height: 15),
          itemdetailreserv(
            context,
            'Nomor Bantalan',
            selectedTargets.join(' '),
          ),
          const SizedBox(height: 15),
          itemdetailreserv(
            context,
            'Biaya',
            AppFormat.currency(paket.price.toDouble()),
          ),
          const SizedBox(height: 15),
          itemdetailreserv(
            context,
            'Total Pembayaran',
            AppFormat.currency(
                (selectedTargets.length * paket.price).toDouble()),
          ),
        ],
      ),
    );
  }

  Row itemdetailreserv(BuildContext context, String title, String data) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        data,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      )
    ]);
  }

  Container header(Paketsarana paket) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              paket.cover,
              fit: BoxFit.cover,
              height: 70,
              width: 90,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paket.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${AppFormat.currency(paket.price.toDouble())} / Jam',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
