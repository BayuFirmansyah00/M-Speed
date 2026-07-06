import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/src/buyer/seller/provider/seller_provider.dart';
import 'package:provider/provider.dart';

class SellerHomeInfoView extends StatelessWidget {
  final String id;

  SellerHomeInfoView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SellerProvider>().sellerModel.data;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(context, 'Seller Info',
          color: Colors.black,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Colors.black))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ImageNetworkWidget(
                    imageUrl: data?.getSeller?.foto ?? '',
                    radius: 30,
                    width: 48,
                    height: 48,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?.getSeller?.nama ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 8,
              color: Color(0xFFF6F6F6),
              margin: EdgeInsets.symmetric(vertical: 12),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Informasi Utama',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  InfoTile(
                    label: 'Nama',
                    value: data?.getSeller?.nama ?? '',
                  ),
                  InfoTile(
                    label: 'Alamat',
                    value: data?.getSeller?.alamat ?? '',
                  ),
                  InfoTile(
                    label: 'Email',
                    value: data?.getSeller?.email ?? '',
                  ),
                  InfoTile(
                    label: 'Telp',
                    value: data?.getSeller?.telp ?? '',
                  ),
                ],
              ),
            ),
            Container(
              height: 8,
              color: Color(0xFFF6F6F6),
              margin: EdgeInsets.symmetric(vertical: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;

  InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
