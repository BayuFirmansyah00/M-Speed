import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mspeed/src/buyer/product/provider/product_provider.dart';
import 'package:provider/provider.dart';

class ProductViewer extends StatefulWidget {
  @override
  _ProductViewerState createState() => _ProductViewerState();
}

class _ProductViewerState extends State<ProductViewer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = [
      context.watch<ProductProvider>().productModel.data?.first?.foto ?? ''
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light, // For Android (dark icons)
          statusBarBrightness: Brightness.dark, // For iOS (dark icons)
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.network(
              images[_currentIndex],
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(
            height: 48,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFEEF0F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0XFF6D7588)),
              ),
              child: Text('${_currentIndex + 1}/${images.length}'),
            ),
          ),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    width: 80,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            _currentIndex == index ? Colors.red : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}
