import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../config/app_color.dart';
import '../controller/c_notif.dart';
import '../model/notification.dart' as custom;
import '../controller/c_home.dart';
import 'home_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final cNotif = Get.put(CNotification());

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;
    final cHome = Get.put(CHome());
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            await markAllNotificationsAsRead();
            cHome.indexPage = 0;
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
          'Notifikasi',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<custom.Notification>>(
        stream: cNotif.notificationStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<custom.Notification> pendingNotifications = snapshot
                .data!
                .where((notification) => notification.status == 'pending')
                .toList();

            final List<custom.Notification> successfulNotifications = snapshot
                .data!
                .where((notification) => notification.status == 'berhasil')
                .toList();

            final DateTime now = DateTime.now();
            final DateTime twoDaysAhead = now.add(const Duration(days: 2));

            final List<custom.Notification> approachingNotifications =
                snapshot.data!.where((notification) {
              final DateTime notificationDate = (notification.date).toDate();
              final difference = notificationDate.difference(now).inDays;
              return difference > 0 && difference <= 2;
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pendingNotifications.isNotEmpty) ...[
                      _buildNotificationsList(pendingNotifications, 'pending'),
                    ],
                    if (successfulNotifications.isNotEmpty) ...[
                      _buildNotificationsList(
                          successfulNotifications, 'berhasil'),
                    ],
                    if (approachingNotifications.isNotEmpty) ...[
                      _buildNotificationsList(
                          approachingNotifications, 'approaching'),
                    ],
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> markAllNotificationsAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;
    try {
      CollectionReference notifikasiRef = FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('reservations');

      QuerySnapshot querySnapshot = await notifikasiRef.get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.update({'isRead': 'read'});
      }

      print('Semua notifikasi telah ditandai sebagai sudah dibaca.');
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _buildNotificationsList(
      List<custom.Notification> notifications, String type) {
    // Sort notifications: unread first, then read
    notifications.sort((a, b) {
      if (a.isRead == 'unread' && b.isRead != 'unread') {
        return -1;
      } else if (a.isRead != 'unread' && b.isRead == 'unread') {
        return 1;
      }
      return 0;
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(context, notification, index, type);
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context,
      custom.Notification notification, int index, String type) {
    String title;
    String message;
    Color containerColor;

    // Determine title and message based on type
    if (type == 'pending') {
      title = '📢 Pengingat: Perlu Pembayaran!';
      message =
          'Bayar reservasi ${notification.id}, harap lakukan pembayaran ${notification.paymentMethod} Anda dalam 1 jam ke depan untuk menghindari pembatalan.\n\nTerima kasih atas perhatian Anda.';
    } else if (type == 'berhasil') {
      title = '✅ Pembayaran Berhasil';
      message =
          'Pembayaran ${notification.paymentMethod} Anda telah berhasil. Terima kasih atas kepercayaan Anda.\n\nSelamat berlatih!';
    } else {
      title = '📅 Latihan Panahan Dalam 2 Hari! 🎯';
      message =
          'Jangan lupa, anda memiliki jadwal latihan pada tanggal ${DateFormat('dd MMMM yyyy').format(DateTime.now().add(Duration(days: index)))}. Siapkan diri dan peralatanmu agar bisa berlatih dengan maksimal.\n\nTetap semangat dan terus berlatih untuk mencapai targetmu! 💪🏹';
    }

    // Determine container color based on isRead status
    if (notification.isRead == 'read') {
      containerColor =
          AppColor.primary.withOpacity(0.1); // Yellow for read notifications
    } else {
      containerColor =
          AppColor.primary.withOpacity(0.5); // Yellow for unread notifications
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.fromLTRB(240, 0, 0, 0),
              child: Text(
                DateFormat('dd-MM-yyyy').format((notification.time)
                    .toDate()), // Display the notification date
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
