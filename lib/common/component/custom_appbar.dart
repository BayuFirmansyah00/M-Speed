import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/constant.dart';
import '../helper/app_colors.dart';

class CustomAppBar {
  /// custom appbar
  static AppBar appBar(
    BuildContext context,
    String title, {
    List<Widget>? action,
    Color? color,
    Color? foregroundColor,
    PreferredSizeWidget? bottom,
    TextStyle? textStyle,
    ShapeBorder? border,
    IconThemeData? iconThemeData,
    bool isLeading = true,
    bool isCenter = false,
    double? titleSpacing,
    Widget? flexibleSpace,
    Widget? leading,
    Function()? onBack,
  }) {
    return AppBar(
      leading: isLeading
          ? leading ??
              IconButton(
                  onPressed: onBack ?? () => Navigator.pop(context),
                  icon: Icon(Icons.keyboard_arrow_left))
          : null,
      title: Text(
        title,
        style: textStyle ??
            TextStyle(
              fontWeight: Constant.semibold,
              color: AppColors.textPrimary,
              fontSize: 17,
            ),
      ),
      flexibleSpace: flexibleSpace,
      iconTheme: iconThemeData ?? null,
      titleSpacing: titleSpacing ?? 0,
      shape: border ?? null,
      elevation: 0,
      forceMaterialTransparency: true,
      surfaceTintColor: color ?? AppColors.surface,
      backgroundColor: color ?? AppColors.surface,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      bottom: bottom ?? null,
      automaticallyImplyLeading: isLeading,
      centerTitle: isCenter,
      actions: action,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness:
            Brightness.dark, //<-- For Android SEE HERE (dark icons)
        statusBarBrightness:
            Brightness.dark, //<-- For iOS SEE HERE (dark icons)
      ),
    );
  }

  static PreferredSizeWidget searchAppBar(
    BuildContext context,
    Widget title, {
    List<Widget>? action,
    Color? color,
    Color? foregroundColor,
    PreferredSizeWidget? bottom,
    TextStyle? textStyle,
    ShapeBorder? border,
    IconThemeData? iconThemeData,
    bool isLeading = true,
    bool isCenter = false,
    double? titleSpacing,
    Widget? flexibleSpace,
    Widget? leading,
  }) {
    return AppBar(
      leading: isLeading
          ? leading ??
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.keyboard_arrow_left))
          : null,
      title: title,
      flexibleSpace: flexibleSpace,
      iconTheme: iconThemeData ?? null,
      titleSpacing: titleSpacing ?? 0,
      shape: border ?? null,
      elevation: 0,
      backgroundColor: color ?? AppColors.surface,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      bottom: bottom ?? null,
      automaticallyImplyLeading: isLeading,
      centerTitle: isCenter,
      actions: action,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness:
            Brightness.dark, //<-- For Android SEE HERE (dark icons)
        statusBarBrightness:
            Brightness.dark, //<-- For iOS SEE HERE (dark icons)
      ),
    );
  }
}
