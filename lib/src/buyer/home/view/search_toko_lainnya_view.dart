import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/src/buyer/home/model/buyer_product_model.dart';
import 'package:mspeed/src/buyer/home/provider/home_provider.dart';
import 'package:mspeed/src/buyer/seller/view/seller_home_product_view.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class SearchTokoLainnyaView extends StatefulWidget {
  @override
  State<SearchTokoLainnyaView> createState() => _SearchTokoLainnyaViewState();
}

class _SearchTokoLainnyaViewState extends State<SearchTokoLainnyaView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    Utils.showLoading();
    await context.read<HomeProvider>().searchProduct();
    await context.read<HomeProvider>().fetchKategori();
    Utils.dismissLoading();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HomeProvider>();
    final products = (p.buyerProductModel.data ?? []).toSet().toList();
    final searchController = context.watch<HomeProvider>().searchController;
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
      body: ListView.separated(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildSearchResult(products[index]);
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 16);
        },
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

  Widget _buildSearchResult(BuyerProductModelData? data) {
    return InkWell(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SellerHomeProductView(id: "123")));
      },
      child: Container(
        height: 80,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: SafeNetworkImage(
              url: data?.foto ?? '',
              height: 48,
              width: 48,
            ),
          ),
          title: Text(
            data?.SellerNama ?? '',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: Text(
            data?.deskripsi ?? '',
            style: TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 12,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
