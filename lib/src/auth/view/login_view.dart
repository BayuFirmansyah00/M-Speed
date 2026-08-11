import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textfield.dart';

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
    path.cubicTo(
      size.width * 0.3,
      size.height,
      size.width * 0.7,
      size.height - 70,
      size.width,
      size.height - 30,
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
          height: 20.h,
          width: 100.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF051C3F),
                Constant.secondaryColor,
                Color(0xFF1E5C99),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Efek Cahaya Oranye
              Positioned(
                top: -80,
                left: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFF15A24).withOpacity(0.25),
                        Color(0xFFF15A24).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Efek Cahaya Kuning Emas
              Positioned(
                bottom: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFF7931E).withOpacity(0.18),
                        Color(0xFFF7931E).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget logoBadge() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF0B4177).withOpacity(0.14),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo MKP
            Image.asset(
              'assets/icons/ic-mspeed-rectangle2.png',
              height: 34,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 16),
            // Garis Pembatas
            Container(
              width: 1.5,
              height: 26,
              color: Colors.grey.shade300,
            ),
            SizedBox(width: 16),
            // Logo M-Speed
            Image.asset(
              'assets/images/ic-mspeed.png',
              height: 34,
              fit: BoxFit.contain,
            ),
          ],
        ),
      );
    }

    Widget form() {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                    color: Constant.secondaryColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Center(
                child: Text(
                  "Masuk ke akun M-Speed kamu untuk melanjutkan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Constant.grayColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Input Email
              CustomTextField.borderTextField(
                controller: auth.usernameC,
                fillColor: Color(0xffF8FAFC),
                hintColor: Constant.grayColor.withOpacity(0.8),
                hintText: "Masukkan email kamu",
                labelText: "Email",
                labelFontSize: 12,
                labelFontWeight: FontWeight.w700,
                labelColor: Colors.black87,
                borderColor: Color(0xffE2E8F0),
                activeBorderColor: Constant.secondaryColor,
                required: false,
                borderRadius: BorderRadius.circular(14),
                prefix: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.mail_outline_rounded,
                    color: Constant.secondaryColor.withOpacity(0.85),
                    size: 20,
                  ),
                ),
              ),
              SizedBox(height: 12),
              
              // Input Password
              CustomTextField.borderTextField(
                controller: auth.passC,
                fillColor: Color(0xffF8FAFC),
                hintColor: Constant.grayColor.withOpacity(0.8),
                hintText: "Masukkan password kamu",
                labelText: "Password",
                labelFontSize: 12,
                labelFontWeight: FontWeight.w700,
                labelColor: Colors.black87,
                borderColor: Color(0xffE2E8F0),
                activeBorderColor: Constant.secondaryColor,
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
                    color: Constant.secondaryColor.withOpacity(0.85),
                    size: 20,
                  ),
                ),
                suffixIcon: InkWell(
                  onTap: () => auth.toggleObscurePass(),
                  child: Icon(
                    auth.obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: Constant.grayColor.withOpacity(0.8),
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
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      "Lupa Password?",
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF15A24),
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // Tombol Sign In
              Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF15A24),
                      Color(0xFFFF8C00),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFF15A24).withOpacity(0.3),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await context.read<AuthProvider>().login(context);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(color: Color(0xffE2E8F0), thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Vendor Baru?",
                      style: TextStyle(
                        fontSize: 11,
                        color: Constant.grayColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Color(0xffE2E8F0), thickness: 1),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Tombol Daftar Vendor
              OutlinedButton(
                onPressed: () {
                  CusNav.nPush(context, SellerRegisterView());
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Constant.secondaryColor.withOpacity(0.8), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  backgroundColor: Constant.secondaryColor.withOpacity(0.01),
                ),
                child: Text(
                  "Daftar Sebagai Vendor",
                  style: TextStyle(
                    fontSize: 13,
                    color: Constant.secondaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // Kartu Dekorasi Bawah Terintegrasi (Terlihat Premium, Bukan Stiker Tempel)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xFFF8FAFC),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0B4177).withOpacity(0.03),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/img-under-login.png',
                  fit: BoxFit.contain,
                  height: 9.h,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFE),
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
                  bottom: -24,
                  child: logoBadge(),
                ),
              ],
            ),
            SizedBox(height: 38),
            form(),
          ],
        ),
      ),
    );
  }
}