import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thehub/page/home_page.dart';

import '../config/app_color.dart';
import 'editpaket_page.dart';

class PaketPanahanPage extends StatelessWidget {
  const PaketPanahanPage({super.key});

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
          'Daftar Paket Panahan',
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
          stream:
              FirebaseFirestore.instance.collection('PaketSaran').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            var paketsaran = snapshot.data!.docs;

            return ListView.builder(
              itemCount: paketsaran.length,
              itemBuilder: (context, index) {
                var paketData =
                    paketsaran[index].data() as Map<String, dynamic>;
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (_) {
                    Alert(
                      context: context,
                      title: 'Konfirmasi',
                      desc: 'Apakah Anda yakin ingin menghapus paket ini?',
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
                          onPressed: () => Navigator.of(context).pop(),
                          color: Colors.grey,
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        DialogButton(
                          onPressed: () {
                            // Hapus item dari Firebase Firestore
                            FirebaseFirestore.instance
                                .collection('PaketSaran')
                                .doc(paketsaran[index].id)
                                .delete();

                            Navigator.of(context).pop(); // Close the dialog
                          },
                          color: Colors.red,
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ).show();
                  },
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: paketData['cover'] != null
                            ? NetworkImage(paketData['cover'])
                            : const AssetImage('asset/avatar.png')
                                as ImageProvider,
                      ),
                      title: Text(
                        paketData['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            'Deskripsi :\n${paketData['description']}',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Harga :\nRp ${paketData['price']}',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return EditPackagePopup(packageData: paketData);
                            },
                          );
                        },
                        child: const Icon(
                          Icons.edit,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30, right: 10),
        child: FloatingActionButton(
          onPressed: () {
            _showAddPackagePopup(context);
          },
          backgroundColor: AppColor.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

void _showAddPackagePopup(BuildContext context) async {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  File? imageFile;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Paket Panahan'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Paket',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing between fields
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing between fields
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10), // Spacing between fields
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          imageFile = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          imageFile == null
                              ? 'Pilih gambar cover'
                              : 'Gambar cover telah dipilih',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing between fields
                  imageFile != null
                      ? Image.file(imageFile!, height: 100, width: 100)
                      : Container(),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Batal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Simpan'),
                onPressed: () async {
                  String name = nameController.text.trim();
                  String description = descriptionController.text.trim();
                  int price = int.tryParse(priceController.text.trim()) ?? 0;

                  if (name.isNotEmpty &&
                      description.isNotEmpty &&
                      price > 0 &&
                      imageFile != null) {
                    String imageURL =
                        await uploadImageToFirebaseStorage(imageFile!);

                    // Simpan data ke Firestore
                    DocumentReference docRef = await FirebaseFirestore.instance
                        .collection('PaketSaran')
                        .add({
                      'name': name,
                      'description': description,
                      'price': price,
                      'cover': imageURL,
                    });

                    // Dapatkan ID dokumen yang baru saja dibuat
                    String idDocument = docRef.id;

                    // Simpan idDocument ke dalam Firestore
                    docRef.update({'id': idDocument});

                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Mohon lengkapi semua input dengan benar dan pilih gambar.'),
                    ));
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}

Future<String> uploadImageToFirebaseStorage(File imageFile) async {
  try {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference =
        storage.ref().child('images/${DateTime.now()}.jpg');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;

    String imageURL = await taskSnapshot.ref.getDownloadURL();
    return imageURL;
  } catch (e) {
    print('Error uploading image to Firebase Storage: $e');
    throw Exception('Error uploading image to Firebase Storage');
  }
}
