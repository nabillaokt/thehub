import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/app_color.dart';
import 'home_page.dart';

class DetailJadwalPage extends StatelessWidget {
  const DetailJadwalPage({Key? key}) : super(key: key);

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
          '',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.offAll(() => const HomePage());
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
            .orderBy('tanggal_reservasi', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Belum ada reservasi'),
            );
          } else {
            List<DocumentSnapshot> docs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var jadwalReservasi = docs[index];
                List<dynamic> targets = jadwalReservasi['target'];
                bool isTargetRed =
                    targets.contains('nilai target yang ingin diwarnai merah');

                bool showDateHeader = _shouldShowDateHeader(docs, index);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDateHeader)
                      _buildDateHeader(
                          jadwalReservasi['tanggal_reservasi'], docs),
                    _buildListTile(jadwalReservasi, targets, isTargetRed),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  bool _shouldShowDateHeader(List<DocumentSnapshot> docs, int index) {
    if (index == 0) return true;
    var previousDate = _formatDatestamp(docs[index - 1]['tanggal_reservasi']);
    var currentDate = _formatDatestamp(docs[index]['tanggal_reservasi']);
    return previousDate != currentDate;
  }

  Padding _buildDateHeader(Timestamp timestamp, List<DocumentSnapshot> docs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDatestamp(timestamp),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.primary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: () => _deleteReservationsByDate(timestamp, docs),
          ),
        ],
      ),
    );
  }

  Padding _buildListTile(DocumentSnapshot jadwalReservasi,
      List<dynamic> targets, bool isTargetRed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Container(
        decoration: BoxDecoration(
          color: isTargetRed
              ? Colors.red.withOpacity(0.2)
              : AppColor.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          title: const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal : ${_formatDatestamp(jadwalReservasi['tanggal_reservasi'])}',
                  ),
                  Text(
                    'Jam : ${jadwalReservasi['jam_reservasi']}',
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: targets.map((target) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColor.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$target',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDatestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMMM yyyy').format(dateTime);
  }

  void _deleteReservationsByDate(
      Timestamp timestamp, List<DocumentSnapshot> docs) {
    DateTime targetDate = timestamp.toDate();
    FirebaseFirestore.instance
        .collection('JadwalReservasi')
        .where('tanggal_reservasi',
            isGreaterThanOrEqualTo: Timestamp.fromDate(targetDate))
        .where('tanggal_reservasi',
            isLessThan:
                Timestamp.fromDate(targetDate.add(const Duration(days: 1))))
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}
