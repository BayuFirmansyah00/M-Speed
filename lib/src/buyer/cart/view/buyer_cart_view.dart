import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mspeed/src/buyer/cart/provider/buyer_cart_provider.dart';
import 'package:mspeed/src/buyer/cart/view/buyer_nego_bottom_sheet.dart';
import 'package:mspeed/utils/utils.dart';

class BuyerCartView extends StatefulWidget {
  const BuyerCartView({Key? key}) : super(key: key);

  @override
  State<BuyerCartView> createState() => _BuyerCartViewState();
}

class _BuyerCartViewState extends State<BuyerCartView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuyerCartProvider>().fetchCart(withLoading: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartP = context.watch<BuyerCartProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Keranjang Belanja', style: TextStyle(color: Colors.black87, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: cartP.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartP.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cartP.errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => cartP.fetchCart(),
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : (cartP.cartResponse?.data?.tempOrders == null || cartP.cartResponse!.data!.tempOrders.isEmpty)
                  ? const Center(
                      child: Text('Keranjang belanja Anda kosong'),
                    )
                  : RefreshIndicator(
                      onRefresh: () => cartP.fetchCart(withLoading: false),
                      child: ListView.builder(
                        itemCount: cartP.cartResponse!.data!.tempOrders.length,
                        itemBuilder: (context, index) {
                          final tempOrder = cartP.cartResponse!.data!.tempOrders[index];
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Toko
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.storefront, size: 20, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        tempOrder.seller?.companyName ?? 'Toko Tidak Diketahui',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, thickness: 1),
                                // List Produk
                                ...tempOrder.carts.map((cartItem) {
                                  final product = cartItem.product;
                                  return Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Product Image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: product?.firstImage ?? '',
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey.shade200,
                                              width: 60,
                                              height: 60,
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: Colors.grey.shade200,
                                              width: 60,
                                              height: 60,
                                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Product Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product?.name ?? '-',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 13),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Rp ${Utils.thousandSeparator(int.tryParse(product?.price?.toString() ?? '0') ?? 0)}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold, color: Colors.red),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Qty: ${cartItem.qty}', style: const TextStyle(fontSize: 12)),
                                                  cartP.isDeletingCart(cartItem.id ?? -1)
                                                      ? const SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child: CircularProgressIndicator(strokeWidth: 2))
                                                      : InkWell(
                                                          onTap: () {
                                                            if (cartItem.id != null) {
                                                              cartP.removeFromCart(context, cartItem.id!);
                                                            }
                                                          },
                                                          child: const Icon(Icons.delete_outline,
                                                              color: Colors.grey, size: 20),
                                                        ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  if (cartItem.negoStatus != null && cartItem.negoStatus != '0' && cartItem.negoStatus != 'false')
                                                    Expanded(
                                                      child: Text(
                                                        'Status Nego: ${cartItem.negoStatus}',
                                                        style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                                                      ),
                                                    )
                                                  else
                                                    const Spacer(),
                                                  if (cartItem.negoStatus != 'DEAL' && cartItem.negoStatus != 'deal' && cartItem.negoStatus != 'SELLER_AGREED')
                                                    SizedBox(
                                                      height: 28,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          showModalBottomSheet(
                                                            context: context,
                                                            isScrollControlled: true,
                                                            shape: const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                                            ),
                                                            builder: (context) => BuyerNegoBottomSheet(cartItem: cartItem),
                                                          );
                                                        },
                                                        style: OutlinedButton.styleFrom(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                                          side: const BorderSide(color: Colors.blue),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                        ),
                                                        child: const Text('Nego', style: TextStyle(fontSize: 12, color: Colors.blue)),
                                                      ),
                                                    ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }).toList()
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
