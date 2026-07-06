import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../../common/base/base_state.dart';
import '../../../common/component/custom_alert.dart';
import '../../../common/component/custom_button.dart';
import '../../../common/component/custom_textfield.dart';
import '../../../common/helper/constant.dart';
import '../model/forgot_arguments.dart';
import '../provider/auth_provider.dart';

class ConfirmationView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ConfirmationViewState();
  }
}

class ConfirmationViewState extends BaseState<ConfirmationView> {
  bool _obscureText = true;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget mainLogo() {
    return Align(
      alignment: Alignment.center,
      child: Image(
        image: AssetImage(
          'assets/icons/LOGO CHATOUR ot.png',
        ),
        width: 120,
        height: 120,
      ),
    );
  }

  Widget remindPass() {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 3);
        },
        child: Text(
          "Ingat akun anda? Masuk Disini",
          style: TextStyle(
            color: Constant.primaryColor,
            fontSize: Constant.fontSizeRegular,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ForgotArguments forgotArgs =
        ModalRoute.of(context)?.settings.arguments as ForgotArguments;
    auth.tokenC.text = forgotArgs.token;
    auth.emailForgotC.text = forgotArgs.email;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: InkWell(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              reverse: true,
              child: Container(
                margin: EdgeInsets.all(Constant.paddingSize + 24),
                child: Form(
                  key: auth.confirmKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      mainLogo(),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        "Masukkan kata sandi baru anda untuk mengatur ulang kata sandi",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Constant.fontSizeBig,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: Constant.paddingSize + 8,
                      ),
                      CustomTextField.normalTextField(
                        controller: auth.passForgotC,
                        hintText: "Kata Sandi",
                        obscureText: _obscureText,
                        padding: EdgeInsets.zero,
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              _toggle();
                            });
                          },
                          child: Icon(
                              (_obscureText)
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Constant.primaryColor),
                        ),
                      ),
                      SizedBox(
                        height: Constant.paddingSize,
                      ),
                      CustomTextField.normalTextField(
                        controller: auth.confirmPassForgotC,
                        hintText: "Konfirmasi Kata Sandi",
                        obscureText: _obscureText,
                        padding: EdgeInsets.zero,
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              _toggle();
                            });
                          },
                          child: Icon(
                              (_obscureText)
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Constant.primaryColor),
                        ),
                      ),
                      SizedBox(
                        height: Constant.paddingSize + 12,
                      ),
                      CustomButton.mainButton("Atur Ulang", () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (auth.confirmKey.currentState!.validate()) {
                          if (auth.passForgotC.text.length < 6) {
                            CustomAlert.showSnackBar(
                              context,
                              "Minimal kata sandi 6 karakter",
                              true,
                            );
                            return;
                          }

                          if (auth.passForgotC.text !=
                              auth.confirmPassForgotC.text) {
                            CustomAlert.showSnackBar(
                              context,
                              "Kata sandi baru dan Konfirmasi kata sandi tidak sama",
                              true,
                            );
                            return;
                          }

                          FocusManager.instance.primaryFocus?.unfocus();

                          context
                              .read<AuthProvider>()
                              .postPassword()
                              .then((value) {
                            CustomAlert.showSnackBar(
                              context,
                              value,
                              false,
                            );
                            Future.delayed(Duration(seconds: 2), () {
                              int count = 0;
                              Navigator.of(context)
                                  .popUntil((_) => count++ >= 3);
                            });
                          }).onError((error, stackTrace) {
                            FirebaseCrashlytics.instance.log(
                                "Reset Password Error : " + error.toString());
                            CustomAlert.showSnackBar(
                              context,
                              error.toString().toLowerCase().contains("doctype")
                                  ? "Maaf, Terjadi Galat!"
                                  : error.toString(),
                              true,
                            );
                          });
                        }
                      }),
                      SizedBox(
                        height: Constant.paddingSize + 12,
                      ),
                      remindPass(),
                      Flexible(
                          child: SizedBox(
                              height: MediaQuery.of(context).viewInsets.bottom))
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
}
