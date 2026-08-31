import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/component/custom_alert.dart';
import 'package:mspeed/src/buyer/cart/model/buyer_cart_model.dart';
import 'package:mspeed/src/buyer/cart/provider/buyer_nego_provider.dart';
import 'package:mspeed/src/buyer/cart/provider/buyer_cart_provider.dart';
import 'package:mspeed/utils/utils.dart';

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
    if (widget.cartItem.finalPrice != null) {
      double price = double.tryParse(widget.cartItem.finalPrice!) ?? 0;
      _priceController.text = price.toInt().toString();
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
      final cartId = widget.cartItem.id;
      final valueStr = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (cartId == null || valueStr.isEmpty) return;
      
      final value = double.tryParse(valueStr) ?? 0;
      
      negoP.submitNego(
        cartId: cartId,
        value: value,
        buyerNote: _noteController.text,
        onSuccess: (msg) {
          CustomAlert.showSnackBar(context, msg, false);
          Navigator.pop(context);
          context.read<BuyerCartProvider>().fetchCart();
        },
        onError: (msg) {
          CustomAlert.showSnackBar(context, msg, true);
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final negoP = context.watch<BuyerNegoProvider>();
    final productName = widget.cartItem.product?.name ?? '-';
    final initialPrice = widget.cartItem.finalPrice ?? '0';

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
              'Harga saat ini: Rp ${Utils.thousandSeparator(double.tryParse(initialPrice)?.toInt() ?? 0)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text('Harga Tawaran', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomTextField.underlineTextField(
              controller: _priceController,
              hintText: 'Masukkan harga tawaran',
              textInputType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('Catatan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomTextField.underlineTextField(
              controller: _noteController,
              hintText: 'Masukkan catatan',
              maxLength: 100,
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
