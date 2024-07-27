import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../config/app_color.dart';

class ReservationReport extends StatefulWidget {
  const ReservationReport({super.key});

  @override
  _ReservationReportState createState() => _ReservationReportState();
}

class _ReservationReportState extends State<ReservationReport> {
  DateTime selectedDate = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      setState(() {});
    });
  }

  void _stopAutoRefresh() {
    _timer?.cancel();
  }

  Stream<int> _fetchReservationsCount(DateTime date) async* {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    yield* FirebaseFirestore.instance
        .collection('user')
        .snapshots()
        .asyncMap((userSnapshot) async {
      int totalReservations = 0;

      for (var userDoc in userSnapshot.docs) {
        String userId = userDoc.id;

        final reservationSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .collection('reservations')
            .where('time',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('time', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .get();

        totalReservations += reservationSnapshot.docs.length;
      }

      return totalReservations;
    });
  }

  Stream<int> _fetchAllReservationsCount() async* {
    yield* FirebaseFirestore.instance
        .collection('user')
        .snapshots()
        .asyncMap((userSnapshot) async {
      int totalReservations = 0;

      for (var userDoc in userSnapshot.docs) {
        String userId = userDoc.id;

        final reservationSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .collection('reservations')
            .get();

        totalReservations += reservationSnapshot.docs.length;
      }

      return totalReservations;
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date); // Adjust format as needed
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
          'Laporan Reservasi',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Navigate back when pressed
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.secondary,
            size: 15,
          ),
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<int>(
            stream: _fetchAllReservationsCount(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data != 0) {
                int allReservationCount = snapshot.data!;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.people,
                            color: Colors.black54, // Warna ikon
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Total Reservasi',
                            style: TextStyle(
                              fontSize: 14, // Ubah font size sesuai kebutuhan
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$allReservationCount',
                            style: const TextStyle(
                              fontSize: 30, // Ubah font size sesuai kebutuhan
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 15.0),
                    margin: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      '0',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDate(selectedDate),
                        style: const TextStyle(
                            color: Colors.black54), // Text color
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black54, // Dropdown icon color
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<int>(
              stream: _fetchReservationsCount(selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data != 0) {
                  int reservationCount = snapshot.data!;
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 30),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Jumlah Reservasi pada ${_formatDate(selectedDate)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                              height: 10), // Add some space between texts
                          StreamBuilder<int>(
                              stream: null,
                              builder: (context, snapshot) {
                                return Text(
                                  '$reservationCount',
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      'Tidak ada reservasi pada tanggal ini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
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
