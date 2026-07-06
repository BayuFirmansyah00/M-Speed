import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../common/base/base_state.dart';
import '../../../common/component/custom_alert.dart';
import '../../../common/component/custom_button.dart';
import '../../../common/component/custom_textfield.dart';
import '../../../common/helper/constant.dart';
import '../../../utils/utils.dart';
import '../model/forgot_arguments.dart';
import '../provider/auth_provider.dart';

class TokenView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TokenViewState();
  }
}

class TokenViewState extends BaseState<TokenView> {
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
          Navigator.of(context).popUntil((_) => count++ >= 2);
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
    auth.emailForgotC.text =
        ModalRoute.of(context)?.settings.arguments as String;
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
                  key: auth.tokenKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 50),
                      mainLogo(),
                      SizedBox(height: 50),
                      Text(
                        "Masukkan kode Anda untuk melakukan pengaturan ulang kata sandi",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Constant.fontSizeBig,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: Constant.paddingSize + 8),
                      CustomTextField.normalTextField(
                          controller: auth.tokenC,
                          hintText: "Kode",
                          padding: EdgeInsets.zero),
                      SizedBox(height: Constant.paddingSize + 12),
                      CustomButton.mainButton("Kirim Kode", () {
                        if (auth.tokenKey.currentState!.validate()) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          context
                              .read<AuthProvider>()
                              .postToken()
                              .then((value) {
                            CustomAlert.showSnackBar(
                              context,
                              value,
                              false,
                            );
                            Future.delayed(Duration(seconds: 2), () {
                              ForgotArguments args = ForgotArguments(
                                  auth.tokenC.text, auth.emailForgotC.text);
                              Navigator.pushNamed(context, '/confirm',
                                  arguments: args);
                            });
                          }).onError((error, stackTrace) {
                            FirebaseCrashlytics.instance.log(
                                "Kirim Kode Reset Password Error : " +
                                    error.toString());
                            return Utils.showToast(
                              error.toString().toLowerCase().contains("doctype")
                                  ? "Maaf, Terjadi Galat!"
                                  : error.toString(),
                            );
                          });
                        }
                      }),
                      SizedBox(height: Constant.paddingSize + 12),
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
