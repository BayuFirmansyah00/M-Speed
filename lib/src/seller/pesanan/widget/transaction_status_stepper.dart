import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/utils/utils.dart';

class TransactionStatusStepper extends StatelessWidget {
  final bool isLast;
  final String? note;
  final String title;
  final String date;

  TransactionStatusStepper({
    Key? key,
    this.isLast = false,
    this.note,
    required this.title,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfffff9f4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Constant.redColor,
                ),
                width: 10,
                height: 10,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                Utils.convertDateddMMMMyyyyCommaHHmm(date),
                style: TextStyle(fontSize: 12, color: Constant.textColor2),
              ),
            ],
          ),
          if (!isLast || note != null)
            Padding(
              padding: EdgeInsets.fromLTRB(9, 0, 16, 0),
              child: Container(
                constraints: BoxConstraints(minHeight: 20),
                decoration:
                    isLast
                        ? null
                        : BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Constant.textColor2),
                          ),
                        ),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note != null) ...[
                      SizedBox(height: 8),
                      Text(
                        'Keterangan',
                        style: TextStyle(
                          color: Constant.textColor2,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffB9B9B9)),
                        ),
                        child: Text(
                          note ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
