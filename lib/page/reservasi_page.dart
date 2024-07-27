import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../config/app_color.dart';
import 'home_page.dart';

class ReservasiPage extends StatelessWidget {
  const ReservasiPage({Key? key}) : super(key: key);

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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          final filteredDocuments = documents
              .where((doc) => doc.id != 'NYfIlRg91aQ7fryTW9KhG6KLVJF3')
              .toList();

          return ListView(
            children: filteredDocuments.map((document) {
              final Map<String, dynamic> userData =
                  document.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: InkWell(
                  onTap: () {
                    Get.to(() => ReservationDetailsPage(userId: document.id));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(userData['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userData['email']),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Lihat Reservasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class ReservationDetailsPage extends StatefulWidget {
  final String userId;

  const ReservationDetailsPage({Key? key, required this.userId})
      : super(key: key);

  @override
  _ReservationDetailsPageState createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends State<ReservationDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Semua Reservasi', 'Reservasi Selesai'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
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
        centerTitle: true,
        title: const Text(
          'Detail Reservasi ',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReservationList(false),
          _buildReservationList(true),
        ],
      ),
    );
  }

  Widget _buildReservationList(bool showCompleted) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .collection('reservations')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<DocumentSnapshot> reservationDocs = snapshot.data!.docs;

        final filteredReservations = reservationDocs.where((doc) {
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (showCompleted) {
            return data['status'] == 'selesai';
          } else {
            return data['status'] != 'selesai';
          }
        }).toList();

        return ListView(
          children: filteredReservations.map((reservationDoc) {
            final Map<String, dynamic> reservationData =
                reservationDoc.data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                _showStatusChangeDialog(context, reservationDoc.id);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID Reservasi : ${reservationData['id']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _buildStatusBadge(reservationData['status']),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nama Paket : ${reservationData['name']}'),
                          Text(
                              'Harga Paket : Rp ${NumberFormat('#,##0').format(reservationData['paketPrice'])}'),
                          Text('Nomor Target : ${reservationData['noTarget']}'),
                          Text(
                              'Tanggal Reservasi : ${_formatDatestamp(reservationData['date'])}'),
                          Text(
                              'Waktu Reservasi : ${_formatTimestamp(reservationData['time'].toDate())}'),
                          Text(
                              'Total Pembayaran : Rp ${NumberFormat('#,##0').format(reservationData['totalPayment'])}'),
                          Text(
                              'Metode Pembayaran : ${reservationData['paymentMethod']}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String badgeText;

    switch (status) {
      case 'berhasil':
        badgeColor = Colors.green;
        badgeText = 'berhasil';
        break;
      case 'pending':
        badgeColor = Colors.orange;
        badgeText = 'pending';
        break;
      case 'selesai':
        badgeColor = Colors.grey;
        badgeText = 'selesai';
        break;
      default:
        badgeColor = Colors.blue;
        badgeText = status;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        badgeText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showStatusChangeDialog(BuildContext context, String reservationId) {
    String selectedStatus = 'berhasil';

    Alert(
      context: context,
      type: AlertType.none,
      title: "Ubah Status Reservasi",
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: <Widget>[
              DropdownButton<String>(
                value: selectedStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus = newValue!;
                  });
                },
                items: <String>['berhasil', 'pending', 'batal', 'selesai']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          value == 'berhasil'
                              ? Icons.check_circle
                              : value == 'pending'
                                  ? Icons.hourglass_empty
                                  : value == 'batal'
                                      ? Icons.cancel
                                      : Icons.check_circle_outline,
                          color: value == 'berhasil'
                              ? Colors.green
                              : value == 'pending'
                                  ? Colors.orange
                                  : value == 'batal'
                                      ? Colors.red
                                      : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            _updateReservationStatus(reservationId, selectedStatus);
            Navigator.of(context).pop();
          },
          color: Colors.green,
          child: const Text(
            "Simpan",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        DialogButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.grey,
          child: const Text(
            "Batal",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
      ],
    ).show();
  }

  void _updateReservationStatus(String reservationId, String newStatus) {
    DocumentReference reservationRef = FirebaseFirestore.instance
        .collection('user')
        .doc(widget.userId)
        .collection('reservations')
        .doc(reservationId);

    bool isStatusChangedToSuccess = newStatus == 'berhasil';

    reservationRef.update({
      'status': newStatus,
      if (isStatusChangedToSuccess)
        'isRead': 'unread', // Update isRead if status changed to 'berhasil'
    }).then((value) {
      print('Status reservasi berhasil diperbarui!');
    }).catchError((error) {
      print('Terjadi kesalahan saat memperbarui status reservasi: $error');
    });
  }

  String _formatDatestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    return formattedDate;
  }

  String _formatTimestamp(DateTime dateTime) {
    String formattedDate = DateFormat('HH:mm').format(dateTime);
    return formattedDate;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
