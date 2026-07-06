import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/helper/download.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebViewPage extends StatefulWidget {
  final String title;
  final String url;
  bool downloadButton = false;

  WebViewPage(this.title, this.url, this.downloadButton);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;
  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: CustomAppBar.appBar(context, widget.title,
      //     isCenter: true, isLeading: true, color: Colors.black),
      appBar: (widget.title != "Panduan Pengguna")
          ? CustomAppBar.appBar(context, widget.title,
              color: Colors.white,
              action: [
                  InkWell(
                      onTap: () {
                        downloadFile(context, widget.url,
                            filename: widget.title,
                            typeFile:
                                '${widget.url[widget.url.length - 1]}${widget.url[widget.url.length - 2]}${widget.url[widget.url.length - 3]}');
                      },
                      child: Image.asset(Assets.iconsIcDownload))
                ])
          : null,
      body: InkWell(
        onDoubleTap: () {
          ////
        },
        onLongPress: () {
          /////
        },
        child: (widget.title != "Panduan Pengguna")
            ? WebViewWidget(controller: controller)
            : Container(
                color: Colors.white,
                child: SafeArea(
                  left: false,
                  right: false,
                  bottom: false,
                  child: WebViewWidget(controller: controller),
                ),
              ),
      ),
    );
  }
}
