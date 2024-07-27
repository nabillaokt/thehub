import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/app_color.dart';
import '../config/app_format.dart';
import '../config/app_route.dart';
import '../model/paket_sarana.dart';
import '../service/target_status.dart';

class DetailReservationPage extends StatefulWidget {
  const DetailReservationPage({Key? key}) : super(key: key);

  @override
  State<DetailReservationPage> createState() => _DetailReservationState();
}

class _DetailReservationState extends State<DetailReservationPage> {
  List<String> selectedTargets = [];
  DateTime selectedDate = DateTime.now();
  String selectedTime = '09:00';

  @override
  Widget build(BuildContext context) {
    Paketsarana paket =
        ModalRoute.of(context)!.settings.arguments as Paketsarana;
    return Scaffold(
      backgroundColor: AppColor.backgroundCheckout,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          paket.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoute.home);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.secondary,
            size: 15,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('JadwalReservasi')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> reservationData = snapshot.data!.docs;
          List<String> reservedTargets =
              getReservedTargets(reservationData, selectedDate, selectedTime);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildDateSelection(),
              const SizedBox(height: 30),
              _buildTimeSelection(),
              const SizedBox(height: 30),
              _buildTargetSelection(reservedTargets),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 25, 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    TargetsStatus(
                      color: Colors.white,
                      status: 'Available',
                    ),
                    SizedBox(width: 10),
                    TargetsStatus(
                      color: AppColor.primary,
                      status: 'Your Selection',
                    ),
                    SizedBox(width: 10),
                    TargetsStatus(
                      color: AppColor.colorreserved,
                      status: 'Reserved',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildTotalPriceAndCheckoutSection(context, paket)
            ],
          );
        },
      ),
    );
  }

  List<String> getReservedTargets(
      List<DocumentSnapshot> reservationData, DateTime date, String time) {
    List<String> reservedTargets = [];
    for (var doc in reservationData) {
      DateTime reservationDate =
          (doc['tanggal_reservasi'] as Timestamp).toDate();
      String reservationTime = doc['jam_reservasi'] as String;
      if (isSameDay(reservationDate, date) && reservationTime == time) {
        reservedTargets.addAll(List<String>.from(doc['target']));
      }
    }
    return reservedTargets;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildDateSelection() {
    final items = List<DateTime>.generate(15, (index) {
      return DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).add(Duration(days: index));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Pilih Tanggal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items.map((date) {
              bool isSelected = isSameDay(date, selectedDate);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MMM').format(date),
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black),
                      ),
                      Text(
                        DateFormat('dd').format(date),
                        style: TextStyle(
                            fontSize: 20,
                            color: isSelected ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    final availableTimes = ['09:00', '11:00', '13:00', '15:00'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Pilih waktu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: availableTimes.map((time) {
            bool isAvailable = isTimeAvailable(selectedDate, time);
            bool isSelected = selectedTime == time;

            return GestureDetector(
              onTap: () {
                if (isAvailable) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? (isSelected ? AppColor.primary : Colors.white)
                      : Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 16,
                    color: isAvailable
                        ? (isSelected ? Colors.white : Colors.black)
                        : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool isTimeAvailable(DateTime selectedDate, String time) {
    DateTime currentTime = DateTime.now();
    List<String> splitTime = time.split(':');
    int hour = int.parse(splitTime[0]);
    int minute = int.parse(splitTime[1]);

    if (selectedDate.year == currentTime.year &&
        selectedDate.month == currentTime.month &&
        selectedDate.day == currentTime.day) {
      if (hour > currentTime.hour ||
          (hour == currentTime.hour && minute > currentTime.minute)) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Widget _buildTargetSelection(List<String> reservedTargets) {
    List<String> targetNames = [
      '1A',
      '1B',
      '1C',
      '2A',
      '2B',
      '2C',
      '3A',
      '3B',
      '3C',
      '4A',
      '4B',
      '4C',
      '5A',
      '5B',
      '5C',
      '6A',
      '6B',
      '6C'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Pilih Posisi Target',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: targetNames.map((target) {
              bool isReserved = reservedTargets.contains(target);
              bool isSelected = selectedTargets.contains(target);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isReserved) return;

                    if (isSelected) {
                      selectedTargets.remove(target);
                    } else {
                      selectedTargets.add(target);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isReserved
                        ? Colors.grey
                        : (isSelected ? AppColor.primary : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Text(
                      target,
                      style: TextStyle(
                          color: isReserved || isSelected
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPriceAndCheckoutSection(
    BuildContext context,
    Paketsarana paket,
  ) {
    return selectedTargets.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Harga',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w300),
                      ),
                      Text(
                        AppFormat.currency(
                          ((selectedTargets.length) * paket.price).toDouble(),
                        ),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 0),
                MaterialButton(
                  onPressed: () async {
                    await saveJadwalReservasi(
                        selectedDate, selectedTime, selectedTargets);
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoute.checkout,
                      arguments: {
                        'selectedDate': selectedDate,
                        'selectedTime': selectedTime,
                        'selectedTargets': selectedTargets,
                        'paket': paket,
                      },
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: AppColor.primary,
                  height: 60,
                  minWidth: 200,
                  child: const Center(
                    child: Text(
                      'Proses Jadwal Reservasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}

Future<void> saveJadwalReservasi(
    DateTime date, String time, List<String> targets) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('user').doc(userId).get();

  String username = userDoc['name'];

  await FirebaseFirestore.instance.collection('JadwalReservasi').add({
    'tanggal_reservasi': date,
    'jam_reservasi': time,
    'target': targets,
    'id_user': userId,
    'nama_user': username,
    'status_target': 'reserved',
  });
}
