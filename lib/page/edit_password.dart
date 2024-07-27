import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../config/app_asset.dart';
import '../config/app_color.dart';
import '../controller/c_home.dart';
import 'home_page.dart';

class EditPasswordPage extends StatefulWidget {
  const EditPasswordPage({super.key});

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  final TextEditingController _passwordlamaController = TextEditingController();
  final TextEditingController _passwordbaruController = TextEditingController();
  final TextEditingController _passwordbaruulangController =
      TextEditingController();

  bool isOldPasswordObscure = true;
  bool isNewPasswordObscure = true;
  bool isConfirmNewPasswordObscure = true;

  final _formKey = GlobalKey<FormState>();
  String? _currentPasswordError;
  String? _newPasswordError;

  Future<void> _validateCurrentPassword() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String email = user!.email!;

      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: _passwordlamaController.text,
      );

      await user.reauthenticateWithCredential(credential);
      setState(() {
        _currentPasswordError = null;
      });
    } catch (e) {
      setState(() {
        _currentPasswordError = "Password lama anda masukan salah";
      });
    }
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate() && _currentPasswordError == null) {
      // Check if the new password is the same as the current password
      if (_passwordlamaController.text == _passwordbaruController.text) {
        setState(() {
          _newPasswordError =
              "Password baru tidak boleh sama dengan password saat ini";
        });
        return;
      } else {
        setState(() {
          _newPasswordError = null;
        });
      }

      try {
        User? user = FirebaseAuth.instance.currentUser;
        await user!.updatePassword(_passwordbaruController.text);

        await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .update({
          'password': _passwordbaruController.text,
        });

        _passwordlamaController.clear();
        _passwordbaruController.clear();
        _passwordbaruulangController.clear();
        _formKey.currentState?.reset();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diperbarui')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan, silakan coba lagi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cHome = Get.put(CHome());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        scrollDirection: Axis.vertical,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.fromLTRB(25, 50, 15, 0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    AppAsset.forgetpassword,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ubah Password",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Password Anda harus memiliki minimal 8 karakter dan\nharus menyertakan kombinasi angka dan huruf",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
                      child: TextFormField(
                        controller: _passwordlamaController,
                        obscureText: isOldPasswordObscure,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isOldPasswordObscure = !isOldPasswordObscure;
                              });
                            },
                            icon: Icon(
                              isOldPasswordObscure
                                  ? CupertinoIcons.eye_slash_fill
                                  : CupertinoIcons.eye_fill,
                              size: 20,
                            ),
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          hintText: 'Password Saat Ini',
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
                            borderSide:
                                const BorderSide(color: AppColor.secondary),
                          ),
                          errorText: _currentPasswordError,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
                      child: TextFormField(
                        controller: _passwordbaruController,
                        obscureText: isNewPasswordObscure,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Silakan masukan password baru anda";
                          } else if (value.length < 8) {
                            return "Password harus terdiri dari minimal 8 karakter";
                          } else if (value == _passwordlamaController.text) {
                            return "Password baru tidak boleh sama dengan password\nAnda saat ini";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isNewPasswordObscure = !isNewPasswordObscure;
                              });
                            },
                            icon: Icon(
                              isNewPasswordObscure
                                  ? CupertinoIcons.eye_slash_fill
                                  : CupertinoIcons.eye_fill,
                              size: 20,
                            ),
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          hintText: 'Password Baru',
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
                            borderSide:
                                const BorderSide(color: AppColor.secondary),
                          ),
                          errorText: _newPasswordError,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
                      child: TextFormField(
                        controller: _passwordbaruulangController,
                        obscureText: isConfirmNewPasswordObscure,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Silakan masukan konfirmasi password baru Anda";
                          } else if (value != _passwordbaruController.text) {
                            return "Password yang anda masukan tidak cocok";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isConfirmNewPasswordObscure =
                                    !isConfirmNewPasswordObscure;
                              });
                            },
                            icon: Icon(
                              isConfirmNewPasswordObscure
                                  ? CupertinoIcons.eye_slash_fill
                                  : CupertinoIcons.eye_fill,
                              size: 20,
                            ),
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          hintText: 'Tulis Ulang Password Baru',
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
                            borderSide:
                                const BorderSide(color: AppColor.secondary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
                      child: Material(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await _validateCurrentPassword();
                            await _updatePassword();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 100,
                            ),
                            child: const Text(
                              'Ubah Password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
