import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thehub/config/app_asset.dart';
import 'package:thehub/config/app_color.dart';
import 'package:thehub/config/app_route.dart';
import 'package:thehub/source/user_source.dart';

import '../controller/c_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? passwordError;
  String? emailError;
  final cHome = Get.put(CHome());
  bool isObscure = true;

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  Future<bool> checkEmailExists(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  login(BuildContext context) async {
    setState(() {
      passwordError = null;
      emailError = null;
    });

    if (formKey.currentState!.validate()) {
      bool emailExists = await checkEmailExists(controllerEmail.text);

      if (!emailExists) {
        setState(() {
          emailError =
              'Maaf, email tidak ditemukan. Mohon periksa kembali atau daftar akun baru';
        });
        return;
      }

      UserSource.login(controllerEmail.text, controllerPassword.text)
          .then((response) {
        if (response['success']) {
          cHome.indexPage = 0;
          Get.offAndToNamed(AppRoute.home);
        } else {
          setState(() {
            passwordError =
                'Maaf, password yang dimasukkan salah. Mohon coba lagi';
          });
        }
      });
    }
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
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Column(
                    children: [
                      Image.asset(
                        AppAsset.logo,
                        width: 150,
                        fit: BoxFit.fitWidth,
                      ),
                      const SizedBox(height: 60),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email',
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
                          controller: controllerEmail,
                          validator: (value) {
                            if (value == '') {
                              return 'Mohon masukkan alamat email Anda';
                            }
                            if (emailError != null) {
                              return emailError;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(CupertinoIcons.mail_solid),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
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
                              borderSide:
                                  const BorderSide(color: AppColor.secondary),
                            ),
                          ),
                        ),
                      ),
                      if (emailError != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              emailError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
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
                          controller: controllerPassword,
                          obscureText: isObscure,
                          validator: (value) {
                            if (value == '') {
                              return "Mohon masukkan password Anda";
                            }
                            if (passwordError != null) {
                              return passwordError;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isObscure = !isObscure;
                                });
                              },
                              icon: Icon(
                                isObscure
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
                      if (passwordError != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              passwordError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, AppRoute.forgetpassword);
                            },
                            child: const Text(
                              'Lupa password?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Material(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              login(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 142,
                              ),
                              child: const Text(
                                'Login',
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
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum memiliki akun? ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 1),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, AppRoute.signup);
                            },
                            child: const Text(
                              "Daftar di sini",
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
