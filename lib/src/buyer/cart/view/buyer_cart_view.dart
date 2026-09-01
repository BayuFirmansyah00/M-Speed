import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mspeed/src/buyer/cart/provider/buyer_cart_provider.dart';
import 'package:mspeed/src/buyer/cart/provider/buyer_nego_provider.dart';
import 'package:mspeed/src/buyer/cart/model/buyer_cart_model.dart';
import 'package:mspeed/src/buyer/cart/view/buyer_nego_bottom_sheet.dart';
import 'package:mspeed/src/buyer/checkout/view/buyer_checkout_view.dart';
import 'package:mspeed/common/component/custom_alert.dart';
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

  double _calculateTotalCart(List<BuyerTempOrder> tempOrders) {
    double total = 0;
    for (var temp in tempOrders) {
      for (var cart in temp.carts) {
        total += (cart.effectiveUnitPrice * (cart.qty ?? 1));
      }
    }
    return total;
  }

  bool _hasPendingNego(List<BuyerTempOrder> tempOrders) {
    for (var temp in tempOrders) {
      for (var cart in temp.carts) {
        final status = cart.negoStatus?.toUpperCase();
        if (status == 'SUBMITTED_BY_BUYER' ||
            status == 'COUNTER_BY_SELLER' ||
            status == 'SELLER_AGREED') {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cartP = context.watch<BuyerCartProvider>();
    final negoP = context.watch<BuyerNegoProvider>();
    final tempOrders = cartP.cartResponse?.data?.tempOrders ?? [];

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
              : tempOrders.isEmpty
                  ? const Center(
                      child: Text('Keranjang belanja Anda kosong'),
                    )
                  : RefreshIndicator(
                      onRefresh: () => cartP.fetchCart(withLoading: false),
                      child: ListView.builder(
                        itemCount: tempOrders.length,
                        itemBuilder: (context, index) {
                          final tempOrder = tempOrders[index];
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
                                  final status = cartItem.negoStatus?.toUpperCase();
                                  final isDeal = status == 'DEAL';
                                  final isCounterBySeller = status == 'COUNTER_BY_SELLER';
                                  final isSubmittedByBuyer = status == 'SUBMITTED_BY_BUYER';
                                  final isSellerAgreed = status == 'SELLER_AGREED';

                                  final normalPrice = double.tryParse(product?.price?.toString() ?? '0') ?? 0;
                                  final effectivePrice = cartItem.effectiveUnitPrice;
                                  final counterPrice = cartItem.latestNegoValue ?? effectivePrice;

                                  return Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
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
                                                  // Price Display
                                                  if (isDeal)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Rp ${Utils.thousandSeparator(effectivePrice.toInt())}',
                                                          style: const TextStyle(
                                                              fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          'Rp ${Utils.thousandSeparator(normalPrice.toInt())}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.grey.shade500,
                                                            decoration: TextDecoration.lineThrough,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  else
                                                    Text(
                                                      'Rp ${Utils.thousandSeparator(normalPrice.toInt())}',
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
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 10),

                                        // Nego Action / Status UI Block
                                        if (isDeal)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.green.shade200),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Sepakat (Deal) — Rp ${Utils.thousandSeparator(effectivePrice.toInt())} / item',
                                                    style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else if (isCounterBySeller)
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.orange.shade300),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.local_offer_rounded, size: 16, color: Colors.orange),
                                                    const SizedBox(width: 6),
                                                    const Text(
                                                      'Penjual Menawar Balik:',
                                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Rp ${Utils.thousandSeparator(counterPrice.toInt())}',
                                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                                    ),
                                                  ],
                                                ),
                                                if (cartItem.sellerNote != null && cartItem.sellerNote!.isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Catatan Penjual: "${cartItem.sellerNote}"',
                                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                                                  ),
                                                ],
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 32,
                                                        child: ElevatedButton.icon(
                                                          onPressed: negoP.isCartProcessing(cartItem.id ?? -1)
                                                              ? null
                                                              : () async {
                                                                  if (cartItem.id == null) return;
                                                                  await negoP.approveNego(
                                                                    cartId: cartItem.id!,
                                                                    onSuccess: (msg) {
                                                                      Utils.showSuccess(msg: msg);
                                                                      cartP.fetchCart(withLoading: false);
                                                                    },
                                                                    onError: (msg) {
                                                                      CustomAlert.showSnackBar(context, msg, true);
                                                                    },
                                                                  );
                                                                },
                                                          icon: negoP.isCartProcessing(cartItem.id ?? -1)
                                                              ? const SizedBox(
                                                                  width: 14,
                                                                  height: 14,
                                                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                                )
                                                              : const Icon(Icons.check, size: 16, color: Colors.white),
                                                          label: const Text('Terima Tawaran', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.green.shade600,
                                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    SizedBox(
                                                      height: 32,
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
                                                          side: const BorderSide(color: Colors.blue),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                                        ),
                                                        child: const Text('Tawar Ulang', style: TextStyle(fontSize: 12, color: Colors.blue)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        else if (isSubmittedByBuyer)
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.blue.shade200),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.access_time_rounded, size: 16, color: Colors.blue),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        'Menunggu respons penjual',
                                                        style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                                                      ),
                                                      Text(
                                                        'Tawaran Anda: Rp ${Utils.thousandSeparator(counterPrice.toInt())}',
                                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                                      ),
                                                    ],
                                                  ),
                                                ),
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
                                                      side: const BorderSide(color: Colors.blue),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    ),
                                                    child: const Text('Ubah Tawaran', style: TextStyle(fontSize: 11, color: Colors.blue)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else if (isSellerAgreed)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.thumb_up_rounded, size: 16, color: Colors.blue),
                                                SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Penjual menyetujui tawaran Anda',
                                                    style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          // DEFAULT — Belum pernah nego
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
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
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                  ),
                                                  child: const Text('Nego', style: TextStyle(fontSize: 12, color: Colors.blue)),
                                                ),
                                              ),
                                            ],
                                          ),
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
      bottomNavigationBar: tempOrders.isNotEmpty
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hasPendingNego(tempOrders))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.orange),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Selesaikan/tunggu nego sebelum checkout.',
                                style: TextStyle(color: Colors.orange, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        Text(
                          'Rp ${Utils.thousandSeparator(_calculateTotalCart(tempOrders).toInt())}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return BuyerCheckoutView(tempOrders: tempOrders);
                          })).then((didCheckout) {
                            // Jika checkout berhasil (pop(true)), refresh cart untuk memastikan state terbaru
                            if (didCheckout == true && context.mounted) {
                              context.read<BuyerCartProvider>().fetchCart(withLoading: true);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
