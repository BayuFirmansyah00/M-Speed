import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_alert.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_textField.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {

  Widget remindPass() {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Text(
          "Ingat akun anda? Masuk Disini",
          style: TextStyle(
            color: Constant.primaryColor,
            fontSize: Constant.fontSizeRegular,
            // decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
  Widget contentForget() {
    final auth = context.watch<AuthProvider>();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: auth.forgotKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100,),
            Text(
              "Lupa Password",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Text(
              "Masukkan email Anda untuk melakukan pengaturan ulang kata sandi",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: Constant.fontSizeBig, color: Colors.grey),
            ),
            SizedBox(height: Constant.paddingSize + 8),
            CustomTextField.normalTextField(
                padding: EdgeInsets.zero,
                controller: auth.emailForgotC,
                hintText: "Email"),
            SizedBox(height: Constant.paddingSize + 12),
            CustomButton.mainButton("Atur Ulang", () {
              if (auth.forgotKey.currentState!.validate()) {
                FocusManager.instance.primaryFocus?.unfocus();
                context
                    .read<AuthProvider>()
                    .postForgot()
                    .then((value) {
                  CustomAlert.showSnackBar(
                      context, value.message, false);
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.pushNamed(context, '/token',
                        arguments: auth.emailForgotC.text);
                  });
                }).onError((error, stackTrace) {
                  FirebaseCrashlytics.instance.log(
                      "Forgot Password Error : " + error.toString());
                  CustomAlert.showSnackBar(
                      context,
                      error
                          .toString()
                          .toLowerCase()
                          .contains("doctype")
                          ? "Maaf, Terjadi Galat!"
                          : error.toString(),
                      true);
                });
              }
            }),
            SizedBox(height: Constant.paddingSize + 12),
            remindPass(),
            // Flexible(
            //     child: SizedBox(
            //         height: MediaQuery.of(context).viewInsets.bottom)),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body:  SingleChildScrollView(
        child: Center(
          child: Stack(
            children: [
              Container(
                height: 100.h,
                width: 100.w,
                padding: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: Constant.primaryColor,
                  // image: DecorationImage(
                  //   image: AssetImage(
                  //       'assets/images/img-bg-login.png',), // Ganti dengan URL gambar Anda
                  //   fit: BoxFit.fill, // Menyesuaikan ukuran gambar dengan Container
                  // ),
                ),
                child: Image.asset(
                  'assets/images/img-bg-login.png',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                  top: 71.h,
                  left: 0,
                  right: 0,
                  child: Center(
                      child: Image.asset(
                        'assets/images/img-under-forget.png',
                        scale: 2.5,
                      ))),
              contentForget(),
            ],
          ),
        ),
      ),
    );
  }
}
