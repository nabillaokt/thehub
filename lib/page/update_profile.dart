import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../controller/c_singup.dart';
import '../config/app_asset.dart';
import '../config/app_color.dart';
import '../controller/c_home.dart';
import 'home_page.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final controller = Get.put(SingUpController());
  String selectedGender = 'Pilih Jenis Kelamin';
  late User _currentUser;
  late FirebaseFirestore _firestore;
  io.File? _image;
  String? avatarUrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _firestore = FirebaseFirestore.instance;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('user').doc(_currentUser.uid).get();

    setState(() {
      controller.name.text = userDoc['name'];
      controller.email.text = userDoc['email'];
      controller.calender.text = userDoc['dateOfBirth'];
      selectedGender = userDoc['gender'] ?? 'Pilih Jenis Kelamin';
      avatarUrl = userDoc['avatarUrl'];
    });
  }

  Future<void> _updateUserData() async {
    final cHome = Get.put(CHome());
    if (_formKey.currentState!.validate()) {
      try {
        if (_image != null) {
          String imageName = 'profile_image_${_currentUser.uid}.jpg';
          firebase_storage.Reference ref = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child(imageName);

          await ref.putFile(_image!);

          String imageUrl = await ref.getDownloadURL();

          await _firestore.collection('user').doc(_currentUser.uid).update({
            'name': controller.name.text,
            'dateOfBirth': controller.calender.text,
            'gender': selectedGender,
            'avatarUrl': imageUrl,
          });
        } else {
          await _firestore.collection('user').doc(_currentUser.uid).update({
            'name': controller.name.text,
            'dateOfBirth': controller.calender.text,
            'gender': selectedGender,
          });
        }

        Get.snackbar('Berhasil', 'Profil berhasil diperbarui');
      } catch (e) {
        Get.snackbar('Error', 'Terjadi kesalahan saat memperbarui profil: $e');
      }
    }
  }

  Stream<List<String>> getGenderStream() {
    return _firestore.collection('user').snapshots().map((snapshot) {
      List<String> genders = [];
      for (var doc in snapshot.docs) {
        String? gender = doc.data()['gender'];
        if (gender != null && !genders.contains(gender)) {
          genders.add(gender);
        }
      }

      // Add 'Perempuan' if not already included
      if (!genders.contains('Perempuan')) {
        genders.add('Perempuan');
      }

      return genders;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cHome = Get.put(CHome());
    final ImagePicker picker = ImagePicker();

    Future<void> getImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _image = io.File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            cHome.indexPage = 2;
            Get.offAll(() => const HomePage());
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.secondary,
            size: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 60, 30, 20),
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: (_image != null)
                        ? Image.file(
                            _image!,
                            fit: BoxFit.fill,
                          )
                        : (avatarUrl != null)
                            ? Image.network(
                                avatarUrl!,
                                key: UniqueKey(),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                AppAsset.avatar,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      getImage();
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColor.primary,
                      ),
                      child: const Icon(
                        LineAwesomeIcons.camera,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 50),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(CupertinoIcons.person_solid),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      hintText: 'Nama Lengkap',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: AppColor.secondary.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColor.secondary),
                      ),
                    ),
                    controller: controller.name,
                    validator: (value) {
                      final RegExp nameExp = RegExp(r'^[a-zA-Z\s]+$');
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      } else if (!nameExp.hasMatch(value)) {
                        return 'Nama mengandung karakter yang tidak diizinkan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(CupertinoIcons.mail_solid),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      hintText: 'Email',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: AppColor.secondary.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColor.secondary),
                      ),
                    ),
                    controller: controller.email,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    readOnly: true,
                    controller: controller.calender,
                    validator: (value) => value == '' ? "Don't empty" : null,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () async {
                          final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1945),
                              lastDate: DateTime(2024)
                                  .add(const Duration(days: 365)));
                          if (date != null) {
                            final formattedDate =
                                DateFormat("dd-MM-yyyy").format(date);
                            setState(() {
                              controller.calender.text =
                                  formattedDate.toString();
                            });
                          }
                        },
                        icon: const Icon(
                          CupertinoIcons.calendar,
                          size: 20,
                        ),
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      hintText: 'Tanggal Lahir',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColor.secondary.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColor.secondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  StreamBuilder<List<String>>(
                    stream: getGenderStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Tidak ada data jenis kelamin');
                      } else {
                        List<String> genderOptions = snapshot.data!;

                        // Insert 'Pilih Jenis Kelamin' if it's missing
                        if (!genderOptions.contains('Pilih Jenis Kelamin')) {
                          genderOptions.insert(0, 'Pilih Jenis Kelamin');
                        }

                        // Add 'Perempuan' if not already included
                        if (!genderOptions.contains('Perempuan')) {
                          genderOptions.add('Perempuan');
                        }

                        return DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.wc_rounded),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            hintText: 'Pilih Jenis Kelamin',
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppColor.secondary.withOpacity(0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: AppColor.secondary),
                            ),
                          ),
                          items: genderOptions.map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(
                                gender,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == 'Pilih Jenis Kelamin') {
                              return 'Pilih jenis kelamin';
                            }
                            return null;
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _updateUserData,
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
