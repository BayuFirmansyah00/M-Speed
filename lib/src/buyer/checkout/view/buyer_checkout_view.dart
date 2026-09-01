import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/src/buyer/cart/model/buyer_cart_model.dart';
import 'package:mspeed/src/buyer/cart/provider/buyer_cart_provider.dart';
import 'package:mspeed/src/buyer/checkout/provider/buyer_checkout_provider.dart';
import 'package:mspeed/src/buyer/address/provider/address_provider.dart';
import 'package:mspeed/src/buyer/home/provider/home_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:mspeed/common/component/custom_alert.dart';

class BuyerCheckoutView extends StatefulWidget {
  final List<BuyerTempOrder> tempOrders;
  const BuyerCheckoutView({Key? key, required this.tempOrders}) : super(key: key);

  @override
  State<BuyerCheckoutView> createState() => _BuyerCheckoutViewState();
}

class _BuyerCheckoutViewState extends State<BuyerCheckoutView> {
  int? _selectedAddressId;
  DateTime? _estDeliveryStart;
  DateTime? _estDeliveryEnd;
  
  // Untuk simulasi testing input ongkir
  final TextEditingController _shippingCostC = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressP = context.read<AddressProvider>();
      addressP.fetchAddressShippingList();
    });
  }

  @override
  void dispose() {
    _shippingCostC.dispose();
    super.dispose();
  }

  void _selectDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _estDeliveryStart = picked.start;
        _estDeliveryEnd = picked.end;
      });
    }
  }

  double _calculateSubtotal() {
    double total = 0;
    for (var temp in widget.tempOrders) {
      for (var cart in temp.carts) {
        double price = cart.effectiveUnitPrice;
        int qty = cart.qty ?? 1;
        total += (price * qty);
      }
    }
    return total;
  }

  bool _hasPendingNego() {
    for (var temp in widget.tempOrders) {
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

  void _doCheckout() async {
    if (_hasPendingNego()) {
      CustomAlert.showSnackBar(context, 'Masih terdapat penawaran harga yang belum selesai (DEAL).', true);
      return;
    }
    
    if (_selectedAddressId == null) {
      CustomAlert.showSnackBar(context, 'Pilih alamat pengiriman terlebih dahulu', true);
      return;
    }

    if (_estDeliveryStart == null || _estDeliveryEnd == null) {
      CustomAlert.showSnackBar(context, 'Pilih estimasi tanggal pengiriman terlebih dahulu', true);
      return;
    }

    final checkoutP = context.read<BuyerCheckoutProvider>();
    List<int> tempOrderIds = widget.tempOrders.map((e) => e.id!).toList();

    // Opsional: simpan shipping cost jika diisi
    if (_shippingCostC.text.isNotEmpty) {
      double cost = double.tryParse(_shippingCostC.text) ?? 0;
      // Pada V1 API kita harus set shipping untuk masing-masing tempOrder
      for (var id in tempOrderIds) {
        bool shipSuccess = await checkoutP.updateShipping(context, id, cost);
        if (!shipSuccess) return; // Jika gagal update shipping, stop checkout
      }
    }

    // Checkout utama
    bool success = await checkoutP.checkout(
      context, 
      tempOrderIds: tempOrderIds, 
      addressId: _selectedAddressId!, 
      estDeliveryStart: _estDeliveryStart!, 
      estDeliveryEnd: _estDeliveryEnd!
    );

    if (success && mounted) {
      Utils.showSuccess(msg: 'Checkout Berhasil!');
      // Refresh cart state & dashboard state di background agar item dan stok langsung terupdate
      // ignore: use_build_context_synchronously
      context.read<BuyerCartProvider>().fetchCart(withLoading: false);
      // ignore: use_build_context_synchronously
      context.read<HomeProvider>().fetchBuyerDashboard(withLoading: false);
      Navigator.of(context).pop(true); // pop(true) memberi sinyal ke BuyerCartView
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressP = context.watch<AddressProvider>();
    final checkoutP = context.watch<BuyerCheckoutProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Pesanan (V1)', style: TextStyle(color: Colors.black87, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: checkoutP.isLoading || checkoutP.isUpdatingShipping
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nego Warning
                  if (_hasPendingNego())
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange)),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(child: Text('Terdapat item dengan Nego yang belum selesai. Checkout akan ditolak oleh sistem.', style: TextStyle(color: Colors.orange, fontSize: 12))),
                        ],
                      ),
                    ),

                  // Alamat
                  const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('Pilih Alamat'),
                    value: _selectedAddressId,
                    items: addressP.getAddressShippingList.data?.map((e) {
                      return DropdownMenuItem<int>(
                        value: e?.id,
                        child: Text(e?.address ?? 'Alamat', overflow: TextOverflow.ellipsis),
                      );
                    }).toList() ?? [],
                    onChanged: (val) => setState(() => _selectedAddressId = val),
                  ),
                  const SizedBox(height: 16),

                  // Estimasi Tanggal
                  const Text('Estimasi Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            _estDeliveryStart != null 
                            ? '${_estDeliveryStart!.day}/${_estDeliveryStart!.month}/${_estDeliveryStart!.year} - ${_estDeliveryEnd!.day}/${_estDeliveryEnd!.month}/${_estDeliveryEnd!.year}'
                            : 'Pilih Tanggal Pengiriman',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Daftar Pesanan
                  const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  ...widget.tempOrders.map((temp) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.storefront, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(temp.seller?.companyName ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(),
                          ...temp.carts.map((cart) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(child: Text('${cart.product?.name ?? '-'} (x${cart.qty})', style: const TextStyle(fontSize: 13))),
                                        if (cart.negoStatus?.toUpperCase() == 'DEAL')
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            margin: const EdgeInsets.only(right: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.green.shade300),
                                            ),
                                            child: const Text('DEAL', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    Utils.thousandSeparator((cart.effectiveUnitPrice * (cart.qty ?? 1)).toInt()),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),

                  // Input Ongkir Khusus Testing API V1
                  const SizedBox(height: 8),
                  TextField(
                    controller: _shippingCostC,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Biaya Pengiriman (Opsional / Testing)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal Produk', style: TextStyle(fontSize: 14)),
                      Text(Utils.thousandSeparator(_calculateSubtotal().toInt()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 48), // Padding bawah
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
          child: ElevatedButton(
            onPressed: checkoutP.isLoading ? null : _doCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: checkoutP.isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Buat Pesanan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
