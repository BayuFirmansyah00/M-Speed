import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../helper/constant.dart';

class CustomButton {
  static Widget mainButton(
    String text,
    VoidCallback onClick, {
    Color? color,
    EdgeInsetsGeometry? margin,
    bool stretched = true,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    double? fontSize,
    TextAlign? textAlign,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.all(0),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(padding ?? padding),
          backgroundColor: WidgetStateProperty.all<Color>(
            color ?? Constant.primaryColor,
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(25),
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
        ),
        onPressed: onClick,
        child: Container(
          padding: contentPadding ?? EdgeInsets.all(8),
          alignment: stretched ? Alignment.center : null,
          child: Text(
            text,
            style:
                textStyle ??
                TextStyle(
                  fontWeight: Constant.medium,
                  fontSize: fontSize ?? 16,
                  color: Colors.white,
                ),
            textAlign: textAlign ?? TextAlign.center,
          ),
        ),
      ),
    );
  }

  static Widget mainButtonWithIcon(
    Widget icon,
    String text,
    VoidCallback onClick, {
    Color? color,
    EdgeInsetsGeometry? margin,
    bool stretched = true,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    MainAxisAlignment? mainAxisAlignment,
    double? fontSize,
    int? flexText,
    TextAlign? textAlign,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.all(0),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(padding ?? EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.all<Color>(
            color ?? Constant.primaryColor,
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(25),
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
        ),
        onPressed: onClick,
        child: Container(
          padding: contentPadding ?? EdgeInsets.all(8),
          alignment: stretched ? Alignment.center : null,
          child: Row(
            mainAxisAlignment:
                mainAxisAlignment ?? MainAxisAlignment.spaceBetween,
            children: [
              icon,
              SizedBox(width: 4),
              mainAxisAlignment != null &&
                      mainAxisAlignment != MainAxisAlignment.center
                  ? Expanded(
                    flex: flexText ?? 0,
                    child: Text(
                      text,
                      style:
                          textStyle ??
                          TextStyle(
                            fontWeight: Constant.medium,
                            fontSize: fontSize ?? 16,
                            color: Colors.white,
                          ),
                      textAlign: textAlign ?? TextAlign.left,
                    ),
                  )
                  : Text(
                    text,
                    style:
                        textStyle ??
                        TextStyle(
                          fontWeight: Constant.medium,
                          fontSize: fontSize ?? 16,
                          color: Colors.white,
                        ),
                    textAlign: textAlign ?? TextAlign.left,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget mainButtonWithIcon2(
    Widget icon,
    String text,
    VoidCallback onClick, {
    Color? color,
    EdgeInsetsGeometry? margin,
    bool stretched = true,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    MainAxisAlignment? mainAxisAlignment,
    double? fontSize,
    int? flexText,
    TextAlign? textAlign,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.all(0),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(padding ?? EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.all<Color>(
            color ?? Constant.primaryColor,
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(25),
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
        ),
        onPressed: onClick,
        child: Container(
          padding: contentPadding ?? EdgeInsets.all(8),
          alignment: stretched ? Alignment.center : null,
          child: Row(
            children: [
              icon,
              SizedBox(width: 4),
              Expanded(
                child: AutoSizeText(
                  text,
                  maxLines: 1,
                  style:
                      textStyle ??
                      TextStyle(
                        fontWeight: Constant.medium,
                        fontSize: fontSize ?? 16,
                        color: Colors.white,
                      ),
                  minFontSize: 6,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget smallMainButton(
    String text,
    VoidCallback onClick, {
    Color? color,
    EdgeInsetsGeometry? margin,
    bool stretched = true,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? textStyle,
    double? fontSize,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.all(0),
      child: InkWell(
        onTap: onClick,
        child: Container(
          decoration: BoxDecoration(
            color: color ?? Constant.primaryColor,
            borderRadius: borderRadius ?? BorderRadius.circular(15),
          ),
          padding: contentPadding ?? EdgeInsets.all(8),
          alignment: stretched ? Alignment.center : null,
          child: Text(
            text,
            style:
                textStyle ??
                TextStyle(
                  fontWeight: Constant.medium,
                  fontSize: fontSize ?? 16,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  static Widget smallMainButtonWithIcon(
    Widget icon,
    String text,
    VoidCallback onClick, {
    Color? color,
    EdgeInsetsGeometry? margin,
    bool stretched = true,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? textStyle,
    double? fontSize,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.all(0),
      child: InkWell(
        onTap: onClick,
        child: Container(
          decoration: BoxDecoration(
            color: color ?? Constant.primaryColor,
            borderRadius: borderRadius ?? BorderRadius.circular(25),
          ),
          padding: contentPadding ?? EdgeInsets.all(8),
          alignment: stretched ? Alignment.center : null,
          child: Row(
            children: [
              icon,
              SizedBox(width: 2),
              Text(
                text,
                style:
                    textStyle ??
                    TextStyle(
                      fontWeight: Constant.medium,
                      fontSize: fontSize ?? 16,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget secondaryButton(
    String text,
    VoidCallback onClick, {
    EdgeInsetsGeometry? margin,
    bool stretched = true,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? textStyle,
    Color? color,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.all(0),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(25),
              side: BorderSide(color: color ?? Constant.primaryColor, width: 2),
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
        ),
        onPressed: onClick,
        child: Container(
          padding: contentPadding ?? EdgeInsets.all(8),
          alignment: stretched ? Alignment.center : null,
          child: Center(
            child: Text(
              text,
              style:
                  textStyle ??
                  TextStyle(
                    color: color ?? Constant.primaryColor,
                    fontWeight: Constant.medium,
                    fontSize: 16,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  static Widget thirdButton(
    String text,
    VoidCallback onClick, {
    EdgeInsetsGeometry? margin,
    bool stretched = true,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? textStyle,
    Color? color,
    BorderRadiusGeometry? borderRadius,
    BorderSide? side,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.all(0),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(10),
              side:
                  side ??
                  BorderSide(
                    color: color ?? Constant.darkGrayButtonColor,
                    width: 1,
                  ),
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
        ),
        onPressed: onClick,
        child: Container(
          padding: contentPadding ?? EdgeInsets.zero,
          alignment: stretched ? Alignment.center : null,
          child: Center(
            child: Text(
              text,
              style:
                  textStyle ??
                  TextStyle(
                    color: Constant.darkGrayButtonColor,
                    fontWeight: Constant.medium,
                    fontSize: 12,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  static Widget secondaryButtonWithicon(
    Widget icon,
    String text,
    VoidCallback onClick, {
    Color? color,
    EdgeInsetsGeometry? margin,
    bool stretched = true,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    MainAxisAlignment? mainAxisAlignment,
    double? fontSize,
    int? flexText,
    TextAlign? textAlign,
    double? borderWidth,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.all(0),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(padding ?? EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(25),
              side: BorderSide(
                color: color ?? Constant.primaryColor,
                width: borderWidth ?? 2,
              ),
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
        ),
        onPressed: onClick,
        child: Container(
          padding: contentPadding ?? EdgeInsets.all(8),
          alignment: stretched ? Alignment.center : null,
          child: Row(
            mainAxisAlignment:
                mainAxisAlignment ?? MainAxisAlignment.spaceBetween,
            children: [
              icon,
              SizedBox(width: 4),
              mainAxisAlignment != null &&
                      mainAxisAlignment != MainAxisAlignment.center
                  ? Expanded(
                    flex: flexText ?? 0,
                    child: Text(
                      text,
                      style:
                          textStyle ??
                          TextStyle(
                            fontWeight: Constant.medium,
                            fontSize: fontSize ?? 16,
                            color: color,
                          ),
                      textAlign: textAlign ?? TextAlign.left,
                    ),
                  )
                  : Text(
                    text,
                    style:
                        textStyle ??
                        TextStyle(
                          color: color,
                          fontWeight: Constant.medium,
                          fontSize: fontSize ?? 16,
                        ),
                    textAlign: TextAlign.center,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget secondaryButtonBlack(
    String text,
    VoidCallback onClick, {
    EdgeInsetsGeometry? margin,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.all(0),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.black),
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
        ),
        onPressed: onClick,
        child: Container(
          padding: EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontWeight: Constant.medium,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  static Widget logoutButton(
    String text,
    VoidCallback onClick, {
    EdgeInsetsGeometry? margin,
  }) {
    return Padding(
      padding: margin ?? EdgeInsets.all(0),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(color: Colors.red),
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
        ),
        onPressed: onClick,
        child: Container(
          padding: EdgeInsets.all(12),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.red,
              fontWeight: Constant.medium,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  static Widget absentButton(String tag, Color color, VoidCallback callback) {
    return ElevatedButton(
      child: Container(
        width: 80,
        child: Text(
          tag,
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
      onPressed: callback,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(color),
        padding: WidgetStateProperty.all<EdgeInsets>(
          EdgeInsets.only(right: 8, left: 8),
        ),
        elevation: WidgetStateProperty.all(1),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }
}
