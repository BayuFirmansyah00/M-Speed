import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textfield.dart';

// import 'package:mspeed/src/auth/view/sign_up_view.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/auth/view/forgot_view.dart';
import 'package:mspeed/src/auth/view/seller_register_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../common/helper/constant.dart';
import '../provider/auth_provider.dart';

class LoginView extends StatefulWidget {
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends BaseState<LoginView> {
  @override
  void initState() {
    context.read<AuthProvider>().loginKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    Widget form() {
      return Padding(
        padding: EdgeInsets.only(top: 13),
        child: Form(
          key: auth.loginKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 45),
                child: Center(
                    child: Image.asset(
                  'assets/icons/ic-mspeed-rectangle2.png',
                  scale: 7,
                )),
              ),
              SizedBox(height: 15),
              Center(
                child: Text(
                  "Selamat Datang di M-Speed",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.only(left: 35),
                child: Text(
                  "Email",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              CustomTextField.borderTextField(
                padding: EdgeInsets.symmetric(horizontal: 30),
                controller: auth.usernameC,
                fillColor: Colors.white,
                hintColor: Constant.grayColor,
                hintText: "Email",
                labelFontSize: 20,
                labelFontWeight: FontWeight.bold,
                labelColor: Constant.grayColor,
                borderColor: Constant.grayColor,
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.only(left: 35),
                child: Text(
                  "Password",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              CustomTextField.borderTextField(
                padding: EdgeInsets.symmetric(horizontal: 30),
                controller: auth.passC,
                fillColor: Colors.white,
                hintColor: Constant.grayColor,
                hintText: "Password",
                labelFontSize: 20,
                labelFontWeight: FontWeight.bold,
                labelColor: Constant.grayColor,
                borderColor: Constant.grayColor,
                obscureText: auth.obscurePass,
                onEditingComplete: () async {
                  await context.read<AuthProvider>().login(context);
                },
                suffixIcon: InkWell(
                  onTap: () => auth.toggleObscurePass(),
                  child: Icon(
                    auth.obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: Constant.grayColor,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(right: 27),
                width: 100.w,
                child: InkWell(
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordView()));
                  },
                  child: Text(
                    "Lupa Password?",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 14,
                        color: Constant.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 10),
              CustomButton.mainButton(
                "Sign In",
                () async {
                  await context.read<AuthProvider>().login(context);
                },
                textStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
                contentPadding: EdgeInsets.all(10),
                borderRadius: BorderRadius.circular(10),
                margin: EdgeInsets.symmetric(horizontal: 30),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => SplashView()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum Punya Akun Vendor? ",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),InkWell(
                      onTap: () {
                        CusNav.nPush(context, SellerRegisterView());
                      },
                      child: Text(
                        " Daftar",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 14,
                            color: Constant.primaryColor,
                            fontWeight: FontWeight.w600),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 100.h,
              width: 100.w,
              padding: EdgeInsets.only(bottom: 6.h),
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
                top: 72.h,
                left: 0,
                right: 0,
                child: Center(
                    child: Image.asset(
                  'assets/images/img-under-login.png',
                  scale: 2.8,
                ))),
            form(),
          ],
        ),
      ),
    );
  }
}
