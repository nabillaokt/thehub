import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:thehub/controller/c_history.dart';
import 'package:thehub/model/reservation.dart';

import '../config/app_color.dart';
import '../config/app_format.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final cHistory = Get.put(CHistory());
  List<Reservation> allReservations = [];

  @override
  void initState() {
    super.initState();
    cHistory.reservationStream().listen((reservations) {
      setState(() {
        allReservations = reservations;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: allReservations.isEmpty
          ? const Center(child: Text('Belum ada reservasi'))
          : DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  title: const Text(
                    'Histori',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  bottom: const TabBar(
                    tabs: [
                      Tab(
                        child: Text(
                          'Semua',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Selesai',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    buildReservationList(allReservations),
                    buildReservationList(allReservations
                        .where((reservation) => reservation.status == 'selesai')
                        .toList()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildReservationList(List<Reservation> reservations) {
    if (reservations.isEmpty) {
      return const Center(
        child: Text('Belum ada reservasi'),
      );
    }
    return ListView(
      shrinkWrap: true,
      children: [
        GroupedListView<Reservation, String>(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shrinkWrap: true,
          elements: reservations,
          groupBy: (element) {
            DateTime dateTime = element.date.toDate();
            return DateFormat('yyyy-MM-dd').format(dateTime);
          },
          groupSeparatorBuilder: (String groupByValue) {
            String date =
                DateFormat('yyyy-MM-dd').format(DateTime.now()) == groupByValue
                    ? 'Hari ini'
                    : AppFormat.dateMonth(groupByValue);
            return Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          itemBuilder: (context, element) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {},
                child: item(context, element),
              ),
            );
          },
          itemComparator: (item1, item2) => item1.date.compareTo(item2.date),
          order: GroupedListOrder.ASC,
        ),
      ],
    );
  }

  Widget item(BuildContext context, Reservation reservation) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              reservation.cover,
              fit: BoxFit.cover,
              height: 60,
              width: 70,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Reservasi : ${reservation.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Nama Paket : ${reservation.name}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Nomor Target : ${reservation.noTarget.join(', ')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Tanggal & Waktu : ${DateFormat('dd-MM-yyyy').format(reservation.date.toDate())} '
                  '${DateFormat.Hm().format(reservation.time.toDate())}-${DateFormat.Hm().format(reservation.time.toDate().add(const Duration(hours: 1)))}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: reservation.status == 'pending'
                  ? Colors.orange
                  : reservation.status == 'batal'
                      ? Colors.red
                      : reservation.status == 'selesai'
                          ? Colors.grey
                          : Colors.green,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            child: Text(
              reservation.status,
              style: TextStyle(
                color: reservation.status == 'pending'
                    ? Colors.orange[100]
                    : reservation.status == 'batal'
                        ? Colors.red[100]
                        : reservation.status == 'selesai'
                            ? Colors.grey[100]
                            : Colors.green[100],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
