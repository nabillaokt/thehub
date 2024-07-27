import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:thehub/config/app_asset.dart';
import 'package:thehub/config/app_color.dart';
import 'package:thehub/config/app_route.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../controller/c_singup.dart';
import '../source/user_source.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final controller = Get.put(SingUpController());
  String selectedGender = 'Pilih Jenis Kelamin';
  final formkey = GlobalKey<FormState>();
  bool isObscurePassword = true;
  String? _emailErrorMessage;

  @override
  void initState() {
    super.initState();
    controller.name.clear();
    controller.email.clear();
    controller.calender.clear();
    controller.password.clear();
    setState(() {
      selectedGender = 'Pilih Jenis Kelamin';
    });
  }

  void _register() async {
    if (formkey.currentState!.validate()) {
      String name = controller.name.text;
      String email = controller.email.text;
      String dateOfBirth = controller.calender.text;
      String password = controller.password.text;
      String gender = selectedGender;

      bool emailExists = await UserSource.checkIfEmailExists(email);
      if (emailExists) {
        setState(() {
          _emailErrorMessage =
              'Maaf, email ini sudah terdaftar. Silakan gunakan email lain untuk mendaftar akun baru';
        });
        return;
      }

      try {
        await UserSource.registerUser(
            email, password, name, dateOfBirth, '', gender, '0');
        Get.offAndToNamed(AppRoute.login);
      } catch (e) {
        Alert(
          context: context,
          type: AlertType.error,
          title: 'Pendaftaran Gagal',
          desc: 'Maaf, pendaftaran akun gagal. Mohon coba lagi nanti.',
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
              onPressed: () => Navigator.pop(context),
              color: Colors.red,
              child: const Text(
                'Ok',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ).show();
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mohon masukkan nama lengkap Anda';
    } else if (value.contains(RegExp(r'[0-9]'))) {
      return 'Nama lengkap tidak boleh mengandung angka';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mohon masukkan alamat email Anda';
    } else if (!GetUtils.isEmail(value)) {
      return 'Format alamat email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mohon masukkan password Anda';
    } else if (value.length < 8) {
      return 'Password harus terdiri dari minimal 8 karakter';
    } else if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])').hasMatch(value)) {
      return 'Password harus diawali dengan huruf kapital dan\nmemiliki minimal 1 angka';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoute.intro);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColor.secondary,
              size: 20,
            )),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Form(
                key: formkey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    children: [
                      Image.asset(
                        AppAsset.logo,
                        width: 120,
                        fit: BoxFit.fitWidth,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Daftar Akun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Isi formulir di bawah untuk mendaftar akun Anda',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Nama Lengkap',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: TextFormField(
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          controller: controller.name,
                          validator: _validateName,
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
                              borderSide:
                                  const BorderSide(color: AppColor.secondary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Alamat Email',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: TextFormField(
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          controller: controller.email,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(CupertinoIcons.mail_solid),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            hintText: 'alamat email',
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
                      if (_emailErrorMessage != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 2, 18, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _emailErrorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tanggal Lahir',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: TextFormField(
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          readOnly: true,
                          controller: controller.calender,
                          validator: (value) =>
                              value == '' ? 'Pilih tanggal lahir Anda' : null,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () async {
                                final DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1945),
                                  lastDate: DateTime(DateTime.now().year + 10),
                                );
                                final formattedDate =
                                    DateFormat("dd-MM-yyy").format(date!);
                                setState(() {
                                  controller.calender.text =
                                      formattedDate.toString();
                                });
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
                              borderSide:
                                  const BorderSide(color: AppColor.secondary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Jenis Kelamin',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: DropdownButtonFormField<String>(
                          value: selectedGender,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedGender = newValue!;
                            });
                          },
                          validator: (value) => value == 'Pilih Jenis Kelamin'
                              ? "Pilih jenis kelamin Anda"
                              : null,
                          items: <String>[
                            'Pilih Jenis Kelamin',
                            'Laki-laki',
                            'Perempuan',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Text(
                                    value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Icon(null),
                                ],
                              ),
                            );
                          }).toList(),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColor.secondary.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: AppColor.secondary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: TextFormField(
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          controller: controller.password,
                          obscureText: isObscurePassword,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isObscurePassword = !isObscurePassword;
                                });
                              },
                              icon: Icon(
                                isObscurePassword
                                    ? CupertinoIcons.eye_slash_fill
                                    : CupertinoIcons.eye_fill,
                                size: 20,
                              ),
                            ),
                            prefixIcon: const Icon(CupertinoIcons.lock_fill),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            hintText: 'Password',
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
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Material(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(8),
                          child: ElevatedButton(
                            onPressed: _register,
                            child: SizedBox(
                              width: double.infinity,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 18,
                                ),
                                child: const Text(
                                  'Daftar',
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
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sudah punya akun? ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 1),
                          InkWell(
                            onTap: () {},
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColor.primary,
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
        }),
      ),
    );
  }
}
