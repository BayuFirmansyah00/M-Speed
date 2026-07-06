import 'package:flutter/material.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:mspeed/src/buyer/transaction/provider/transaction_status.dart';

class TransactionStepper extends StatelessWidget {
  final listImg = [
    Assets.iconsImgAkunPesananbaru,
    Assets.iconsImgAkunPesananditerima,
    Assets.iconsImgAkunPesanandikirim,
    Assets.iconsImgAkunBarangditerima,
    Assets.iconsImgAkunProsespembayaran,
    Assets.iconsImgAkunTelahdibayar
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: listImg
              .asMap()
              .entries
              .map(
                (entry) => JustTheTooltip(
                  isModal: true,
                  onShow: () {},
                  tailBuilder: (point1, point2, point3) {
                    return Path()
                      ..moveTo(point1.dx, point1.dy)
                      ..close();
                  },
                  content: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      dateStatusTransaction?[entry.key] ?? 'No date available',
                    ),
                  ),
                  child: Image.asset(
                    entry.value,
                    width: 32,
                    height: 32,
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _buildStep(),
        )
      ],
    );
  }

  List<Widget> _buildStep() {
    final List<Widget> listSteps = [];

    for (var i = 0; i < 6; i++) {
      if (i != 0)
        listSteps.add(
          Expanded(
            child: Container(
              color: i <= status.index ? Colors.green : Colors.grey,
              height: 2,
            ),
          ),
        );
      listSteps.add(
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: i <= status.index ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 8,
            color: Colors.white,
          ),
        ),
      );
    }

    return listSteps;
  }

  TransactionStepper(
      {Key? key, required this.status, this.dateStatusTransaction})
      : super(key: key);

  final TransactionStatus status;
  final List<String>? dateStatusTransaction;
}
