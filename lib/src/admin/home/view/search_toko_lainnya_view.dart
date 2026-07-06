import 'package:flutter/material.dart';

import '../../../buyer/seller/view/seller_home_product_view.dart';

class SearchTokoLainnyaView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _buildSearchBar(),
      ),
      body: ListView(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SellerHomeProductView(id: "123",)),
              );
              // Navigator.of(context).pushNamed('/seller_home_product');
            },
            child: _buildSearchResult(
                'Three Band', 'Seller Aam', 'assets/three_band_icon.png'),
          ),
          _buildSearchResult(
              'Three Axe', 'Seller Aam', 'assets/three_axe_icon.png'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.zero,
                    bottomRight: Radius.zero,
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8)),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Three',
                  hintStyle: TextStyle(color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    bottomLeft: Radius.zero,
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
              ),
              child: Icon(Icons.search, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResult(String title, String subtitle, String iconPath) {
    return Container(
      height: 80,
      child: ListTile(
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: Image.network('https://via.placeholder.com/150.jpg')),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 12,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
