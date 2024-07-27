import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../config/app_color.dart';
import 'home_page.dart';

class PengunjungPage extends StatelessWidget {
  const PengunjungPage({Key? key}) : super(key: key);

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
          'Daftar Pengguna',
          style: TextStyle(
            fontSize: 15,
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
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('user').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            var users = snapshot.data!.docs;
            var nonAdminUsers = users.where((doc) {
              var userData = doc.data() as Map<String, dynamic>;
              return userData['role'] != 'admin';
            }).toList();

            return ListView.builder(
              itemCount: nonAdminUsers.length,
              itemBuilder: (context, index) {
                var userData =
                    nonAdminUsers[index].data() as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: userData['avatarUrl'] != null
                          ? NetworkImage(userData['avatarUrl'])
                          : const AssetImage('asset/avatar.png')
                              as ImageProvider,
                    ),
                    title: Text(
                      (userData['name']),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email : ${userData['email']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Jenis Kelamin : ${userData['gender']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Tanggal Lahir : ${userData['dateOfBirth']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
