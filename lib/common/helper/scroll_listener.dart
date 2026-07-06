import 'package:flutter/material.dart';

class ScrollListener extends ChangeNotifier {
  double bottom = 0;
  double _last = 0;
  late ScrollController _scrollController;
  get scrollController => this._scrollController;

  set scrollController(value) => this._scrollController = value;

  bool isScrollingDown = false;
  bool _showAppbar = false;
  bool get getIsScrollingDown => this.isScrollingDown;

  set setIsScrollingDown(bool isScrollingDown) =>
      this.isScrollingDown = isScrollingDown;

  get showAppbar => this._showAppbar;

  set showAppbar(value) => this._showAppbar = value;

  ScrollListener.initialise(ScrollController controller, [double height = 53]) {
    _scrollController = controller;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 53) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = true;
          notifyListeners();
        }
      }
      if (_scrollController.position.pixels < 53) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = false;
          notifyListeners();
        }
      }
    });
  }
}
