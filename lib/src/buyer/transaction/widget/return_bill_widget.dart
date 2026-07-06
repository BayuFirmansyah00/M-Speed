
import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_provider.dart';
import 'package:provider/provider.dart';

class ReturnBillWidget extends StatefulWidget {
  const ReturnBillWidget({
    Key? key,
    required this.onSave,
  }) : super(key: key);
  final Function() onSave;

  @override
  State<ReturnBillWidget> createState() => _ReturnBillWidgetState();
}

class _ReturnBillWidgetState extends State<ReturnBillWidget> {
  int? resetDate;
  TextEditingController reasonC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                    onTap: () => CusNav.nPop(context),
                    child: Icon(Icons.keyboard_arrow_left)),
                Expanded(
                  child: Text(
                    'Kembalikan Tagihan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: Constant.semibold,
                      color: Colors.black,
                      fontSize: 17,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 24),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Reset Tanggal')),
                    Radio(
                      value: 1,
                      groupValue: resetDate,
                      visualDensity:
                          VisualDensity(vertical: -4, horizontal: -4),
                      onChanged: (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          resetDate = 1;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Text('Tanpa Reset Tanggal')),
                    Radio(
                      value: 0,
                      groupValue: resetDate,
                      visualDensity:
                          VisualDensity(vertical: -4, horizontal: -4),
                      onChanged: (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          resetDate = 0;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 24),
            CustomTextField.borderTextArea(
              labelText: 'Alasan',
              labelFontWeight: FontWeight.w600,
              controller: reasonC,
              required: true,
              hintText: 'Masukkan alasan',
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () async {
                final provider = context.read<TransactionProvider>();
                provider.resetDate = resetDate;
                provider.reason = reasonC.text;
                widget.onSave();
              },
              child: Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
