import 'package:flutter/material.dart';

class CusNav {
  static nPush(BuildContext context, Widget page) => Navigator.push(
      context,
      PageRouteBuilder(
          pageBuilder: ((context, animation, secondaryAnimation) => page),
          transitionDuration: const Duration(seconds: 0),
          reverseTransitionDuration: Duration.zero));

  static nPushAndRemoveUntil(BuildContext context, Widget page,
          {Object? arguments,
          bool Function(Route<dynamic> predicate)? predicate}) =>
      Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
              settings: arguments == null
                  ? null
                  : RouteSettings(arguments: arguments),
              pageBuilder: ((context, animation, secondaryAnimation) => page),
              transitionDuration: const Duration(seconds: 0),
              reverseTransitionDuration: Duration.zero),
          predicate ?? (route) => false);
  static nPopUntil(BuildContext context,
          {Object? arguments,
          bool Function(Route<dynamic> predicate)? predicate}) =>
      Navigator.popUntil(context, predicate ?? (route) => false);

  static nPushReplace(BuildContext context, Widget page) =>
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              pageBuilder: ((context, animation, secondaryAnimation) => page),
              transitionDuration: const Duration(seconds: 0),
              reverseTransitionDuration: Duration.zero));
  static nPop(BuildContext context, [Object? result]) =>
      Navigator.pop(context, result);
}
