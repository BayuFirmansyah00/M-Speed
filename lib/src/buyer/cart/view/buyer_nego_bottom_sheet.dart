import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/component/custom_alert.dart';
import 'package:mspeed/src/buyer/cart/model/buyer_cart_model.dart';
import 'package:mspeed/src/buyer/cart/provider/buyer_nego_provider.dart';
import 'package:mspeed/src/buyer/cart/provider/buyer_cart_provider.dart';
import 'package:mspeed/utils/utils.dart';

import 'package:mspeed/src/seller/nego/provider/nego_seller_provider.dart';

class BuyerNegoBottomSheet extends StatefulWidget {
  final BuyerCartItem cartItem;

  const BuyerNegoBottomSheet({Key? key, required this.cartItem}) : super(key: key);

  @override
  State<BuyerNegoBottomSheet> createState() => _BuyerNegoBottomSheetState();
}

class _BuyerNegoBottomSheetState extends State<BuyerNegoBottomSheet> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.cartItem.latestNegoValue != null && widget.cartItem.latestNegoValue! > 0) {
      _priceController.text = widget.cartItem.latestNegoValue!.toInt().toString();
    } else if (widget.cartItem.initialPrice != null) {
      double price = double.tryParse(widget.cartItem.initialPrice!) ?? 0;
      if (price > 0) {
        _priceController.text = price.toInt().toString();
      }
    } else if (widget.cartItem.product?.price != null) {
      double price = double.tryParse(widget.cartItem.product!.price.toString()) ?? 0;
      if (price > 0) {
        _priceController.text = price.toInt().toString();
      }
    }

    if (widget.cartItem.buyerNote != null) {
      _noteController.text = widget.cartItem.buyerNote!;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitNego() {
    if (_formKey.currentState!.validate()) {
      final negoP = context.read<BuyerNegoProvider>();
      final cartP = context.read<BuyerCartProvider>();
      final cartId = widget.cartItem.id;
      final parsedValue = NegoSellerProvider.parsePriceInput(_priceController.text);

      if (cartId == null || parsedValue == null || parsedValue <= 0) {
        CustomAlert.showSnackBar(context, 'Masukkan nominal harga tawaran yang valid (lebih dari 0)', true);
        return;
      }

      negoP.submitNego(
        cartId: cartId,
        value: parsedValue,
        buyerNote: _noteController.text,
        onSuccess: (msg) {
          Utils.showSuccess(msg: msg);
          Navigator.pop(context, true);
          cartP.fetchCart(withLoading: false);
        },
        onError: (msg) {
          CustomAlert.showSnackBar(context, msg, true);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final negoP = context.watch<BuyerNegoProvider>();
    final productName = widget.cartItem.product?.name ?? '-';
    final normalPrice = double.tryParse(widget.cartItem.product?.price?.toString() ?? '0') ?? 0;
    final displayCurrentPrice = normalPrice > 0
        ? normalPrice
        : (double.tryParse(widget.cartItem.initialPrice ?? '0') ?? 0);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ajukan Nego',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              productName,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Harga normal: ${Utils.thousandSeparator(displayCurrentPrice.toInt())}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            if (widget.cartItem.latestNegoValue != null && widget.cartItem.latestNegoValue! > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Tawaran terakhir: ${Utils.thousandSeparator(widget.cartItem.latestNegoValue!.toInt())}',
                style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Harga Tawaran Anda (Satuan)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomTextField.underlineTextField(
              controller: _priceController,
              hintText: 'Masukkan harga tawaran satuan',
              textInputType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Masukkan harga tawaran satuan';
                }
                final parsed = NegoSellerProvider.parsePriceInput(value);
                if (parsed == null || parsed <= 0) {
                  return 'Nominal harga tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Catatan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomTextField.underlineTextField(
              controller: _noteController,
              hintText: 'Masukkan catatan untuk penjual',
              maxLength: 100,
              validator: (value) => null, // Catatan 100% opsional
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: negoP.isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton.mainButton('Kirim Nego', _submitNego),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
