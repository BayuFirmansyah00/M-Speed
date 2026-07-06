
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mspeed/utils/utils.dart';


class PDFScreen extends StatefulWidget {
  final String path;

  PDFScreen({required this.path});

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  late PDFViewController _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed: () {
              setState(() {
                if (_currentPage > 0) {
                  _currentPage--;
                  _pdfViewController.setPage(_currentPage);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: () {
              setState(() {
                if (_currentPage < _totalPages - 1) {
                  _currentPage++;
                  _pdfViewController.setPage(_currentPage);
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            autoSpacing: true,
            enableSwipe: true,
            pageSnap: true,
            swipeHorizontal: false,
            onRender: (pages) {
              setState(() {
                _totalPages = pages!;
                pdfReady = true;
              });
            },
            onViewCreated: (PDFViewController vc) {
              _pdfViewController = vc;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
          ),
          !pdfReady
              ? Center(child: CircularProgressIndicator())
              : Offstage(),
        ],
      ),
    );
  }
}


class PDFScreen1 extends StatefulWidget {
  final String path;
  final String? title;

  PDFScreen1({required this.path, this.title});

  @override
  State<PDFScreen1> createState() => _PDFScreen1State();
}

class _PDFScreen1State extends State<PDFScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.title != "PDF View")
          ? Utils.appBar(widget.title ?? "PDF View", backgroundColor: Colors.white)
          : null,
      body: PDFView(
        filePath: widget.path,
      ),
    );
  }
}
