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

class _LoginHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

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

    Widget header() {
      return ClipPath(
        clipper: _LoginHeaderClipper(),
        child: Container(
          height: 26.h,
          width: 100.w,
          color: Constant.primaryColor,
        ),
      );
    }

    Widget logoBadge() {
      return Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Image.asset(
          'assets/icons/ic-mspeed-rectangle2.png',
          scale: 6,
        ),
      );
    }

    Widget form() {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Form(
          key: auth.loginKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  "Selamat Datang Kembali",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 6),
              Center(
                child: Text(
                  "Masuk ke akun M-Speed kamu untuk melanjutkan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Constant.grayColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(height: 32),
              CustomTextField.borderTextField(
                controller: auth.usernameC,
                fillColor: Color(0xffF5F6FA),
                hintColor: Constant.grayColor,
                hintText: "Masukkan email kamu",
                labelText: "Email",
                labelFontSize: 13,
                labelFontWeight: FontWeight.w600,
                labelColor: Colors.black,
                borderColor: Color(0xffE2E4E9),
                required: false,
                borderRadius: BorderRadius.circular(14),
                prefix: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.mail_outline_rounded,
                    color: Constant.grayColor,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(height: 16),
              CustomTextField.borderTextField(
                controller: auth.passC,
                fillColor: Color(0xffF5F6FA),
                hintColor: Constant.grayColor,
                hintText: "Masukkan password kamu",
                labelText: "Password",
                labelFontSize: 13,
                labelFontWeight: FontWeight.w600,
                labelColor: Colors.black,
                borderColor: Color(0xffE2E4E9),
                required: false,
                borderRadius: BorderRadius.circular(14),
                obscureText: auth.obscurePass,
                onEditingComplete: () async {
                  await context.read<AuthProvider>().login(context);
                },
                prefix: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: Constant.grayColor,
                    size: 20,
                  ),
                ),
                suffixIcon: InkWell(
                  onTap: () => auth.toggleObscurePass(),
                  child: Icon(
                    auth.obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: Constant.grayColor,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordView()));
                  },
                  child: Text(
                    "Lupa Password?",
                    style: TextStyle(
                        fontSize: 13,
                        color: Constant.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 24),
              CustomButton.mainButton(
                "Sign In",
                () async {
                  await context.read<AuthProvider>().login(context);
                },
                textStyle: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
                contentPadding: EdgeInsets.symmetric(vertical: 15),
                borderRadius: BorderRadius.circular(14),
                margin: EdgeInsets.zero,
              ),
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(color: Color(0xffE2E4E9), thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Vendor Baru?",
                      style: TextStyle(
                        fontSize: 12,
                        color: Constant.grayColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Color(0xffE2E4E9), thickness: 1),
                  ),
                ],
              ),
              SizedBox(height: 16),
              CustomButton.secondaryButton(
                "Daftar Sebagai Vendor",
                () {
                  CusNav.nPush(context, SellerRegisterView());
                },
                color: Constant.primaryColor,
                contentPadding: EdgeInsets.symmetric(vertical: 13),
                borderRadius: BorderRadius.circular(14),
                margin: EdgeInsets.zero,
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Constant.primaryColor,
                  fontWeight: FontWeight.w600,
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
        physics: ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                header(),
                Positioned(
                  bottom: -32,
                  child: logoBadge(),
                ),
              ],
            ),
            SizedBox(height: 48),
            form(),
          ],
        ),
      ),
    );
  }
}
