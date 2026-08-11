import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_alert.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class _ForgotHeaderClipper extends CustomClipper<Path> {
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
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            "Ingat akun anda? Masuk Disini",
            style: TextStyle(
              color: Constant.secondaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    Widget header() {
      return ClipPath(
        clipper: _ForgotHeaderClipper(),
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
          key: auth.forgotKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  "Lupa Password",
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
                  "Masukkan email Anda untuk melakukan pengaturan ulang kata sandi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Constant.grayColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              CustomTextField.borderTextField(
                controller: auth.emailForgotC,
                fillColor: Color(0xffF8FAFC),
                hintColor: Constant.grayColor.withOpacity(0.8),
                hintText: "Masukkan email kamu",
                labelText: "Email",
                labelFontSize: 12,
                labelFontWeight: FontWeight.w700,
                labelColor: Colors.black87,
                borderColor: Color(0xffE2E8F0),
                activeBorderColor: Constant.secondaryColor,
                required: true,
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
              SizedBox(height: 24),
              
              // Tombol Reset
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
                    onTap: () {
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
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Atur Ulang",
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
              remindPass(),
              SizedBox(height: 32),
              
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
                  'assets/images/img-under-forget.png',
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
