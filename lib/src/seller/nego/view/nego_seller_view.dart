import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_button.dart';
import 'package:mspeed/common/component/custom_dialog.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/component/custom_textfield.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/common/helper/text_editing_formatter.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/seller/nego/model/nego_seller_model.dart';
import 'package:mspeed/src/seller/nego/provider/nego_seller_provider.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:provider/provider.dart';

class NegoSellerView extends StatefulWidget {
  const NegoSellerView({super.key});

  @override
  State<NegoSellerView> createState() => _NegoSellerViewState();
}

class _NegoSellerViewState extends State<NegoSellerView> {
  @override
  void initState() {
    refresh();
    super.initState();
  }

  List<NegoSellerModelData?> negoData = [];
  final searchController = TextEditingController();

  refresh() async {
    final p = context.read<NegoSellerProvider>();
    await p.fetchNego(withLoading: true);
    negoData = p.negoSellerModel.data ?? [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NegoSellerProvider>();
    if (negoData.isEmpty && searchController.text.isEmpty) {
      negoData = p.negoSellerModel.data ?? [];
    }

    // final negoData =
    //     context.watch<NegoSellerProvider>().negoSellerModel.data ?? [];
    Widget search() => Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 8, bottom: 16),
      child: CustomTextField.borderTextField(
        controller: searchController,
        required: false,
        hintText: "Cari",
        hintColor: Color(0xff6D7588),
        borderColor: Color(0xffDBDFE9),
        prefix: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/icons/ic-search.png',
            width: 5,
            height: 5,
            color: Color(0xff6D7588),
          ),
        ),
        suffixIcon:
            p.searchNegoC.text.isEmpty
                ? SizedBox()
                : InkWell(
                  onTap: () {
                    p.searchNegoC.clear();
                    FocusManager.instance.primaryFocus?.unfocus();
                    context.read<NegoSellerProvider>().fetchNego(
                      withLoading: true,
                    );
                    setState(() {});
                  },
                  child: Icon(Icons.close),
                ),
        onChanged: (val) {
          // if (p.searchOnStoppedTyping != null) {
          //   p.searchOnStoppedTyping!.cancel();
          // }
          // p.searchOnStoppedTyping = Timer(p.duration, () async {
          //   context.read<NegoSellerProvider>().fetchNego(withLoading: true);
          // });
          setState(() {
            negoData =
                p.negoSellerModel.data
                    ?.where(
                      (element) =>
                          element?.nama?.toLowerCase().contains(
                            searchController.text.toLowerCase(),
                          ) ??
                          false,
                    )
                    .toList() ??
                [];
          });
        },
      ),
    );
    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(
        context,
        'Permintaan Nego',
        color: Colors.white,
        isCenter: true,
        titleSpacing: 24,
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        isLeading: false,
      );
    }

    negoHarga(BuildContext context, String negoId, int hargaAkhir) {
      CustomDialog.mainDialog(
        context: context,
        title: "",
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.black, size: 24),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                CustomTextField.borderTextField(
                  controller: p.negoHargaC,
                  required: false,
                  labelText: "Masukan nego Harga",
                  hintText: "Masukkan Harga",
                  textInputType: TextInputType.number,
                  textCapitalization: TextCapitalization.words,
                  focusNode: p.negoHargaN,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),
                SizedBox(height: 20),
                CustomButton.mainButton(
                  "Nego Harga",
                  borderRadius: BorderRadius.circular(10),
                  () async {
                    final price = int.parse(
                      (p.negoHargaC.text).replaceAll('.', ''),
                    );
                    if (price > hargaAkhir) {
                      await Utils.showFailed(
                        msg: 'Tidak boleh melebihi harga produk',
                      );
                    } else {
                      setState(() {
                        p.requestNegoUlang(negoId: negoId);
                      });
                      CusNav.nPop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget negoItem(NegoSellerModelData data) {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SafeNetworkImage(
                      width: 70,
                      height: 70,
                      url: data.foto ?? '',
                      errorBuilder: Image.asset(Assets.imagesImgHeadphone),
                    ),
                  ),
                ),
                Constant.xSizedBox16,
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Constant.xSizedBox4,
                      Text(data.nama ?? ''),
                      Constant.xSizedBox4,
                      Text(
                        Utils.thousandSeparator(
                          int.parse(data.hargaAkhir ?? '0'),
                        ),
                        style: TextStyle(color: Constant.textColor2),
                      ),
                      Constant.xSizedBox4,
                      Text(
                        '${data.qty ?? '0'} pcs',
                        style: TextStyle(color: Constant.textColor2),
                      ),
                    ],
                  ),
                ),
                Constant.xSizedBox8,
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Constant.xSizedBox8,
                      Text('Harga Nego'),
                      Constant.xSizedBox8,
                      if (data.nego != null && data.nego3 == null)
                        Text(
                          Utils.thousandSeparator(int.parse(data.nego ?? '0')),
                          style: TextStyle(color: Constant.redColor),
                        ),
                      if (data.nego != null && data.nego3 != null)
                        Text(
                          Utils.thousandSeparator(int.parse(data.nego3 ?? '0')),
                          style: TextStyle(color: Constant.redColor),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Constant.xSizedBox12,
            Row(
              children: [
                Expanded(
                  child: CustomButton.secondaryButtonWithicon(
                    Expanded(
                      flex: 5,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.close,
                            weight: 10,
                            color: Constant.redColor,
                          ),
                        ),
                      ),
                    ),
                    'Tolak',
                    () async {
                      await Utils.showYesNoDialog(
                        context: context,
                        title: 'Konfirmasi Tolak Nego',
                        desc: 'Apakah Anda yakin ingin tolak nego ini?',
                        yesCallback: () async {
                          CusNav.nPop(context);
                          await context
                              .read<NegoSellerProvider>()
                              .acceptOrRejectNego(
                                negoId: data.ID ?? '0',
                                isAccept: false,
                              );
                          context.read<NegoSellerProvider>().fetchNego(
                            withLoading: true,
                          );
                        },
                        noCallback: () async {
                          CusNav.nPop(context);
                        },
                      );
                    },
                    flexText: 6,
                    stretched: true,
                    mainAxisAlignment: MainAxisAlignment.start,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    color: Color(0xffED1C24),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Constant.xSizedBox12,
                Expanded(
                  child: CustomButton.secondaryButtonWithicon(
                    Expanded(
                      flex: 5,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: RotatedBox(
                            quarterTurns: 45,
                            child: Icon(
                              Icons.discount_rounded,
                              weight: 10,
                              color:
                                  data.nego2 == null
                                      ? Color(0xffF47003)
                                      : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    'Nego',
                    () async {
                      if (data.nego2 == null) {
                        await negoHarga(
                          context,
                          data.ID ?? '0',
                          int.parse(
                            (data.hargaAkhir ?? '0').replaceAll('.', ''),
                          ),
                        );
                        context.read<NegoSellerProvider>().fetchNego(
                          withLoading: true,
                        );
                      }
                    },
                    flexText: 6,
                    stretched: true,
                    mainAxisAlignment: MainAxisAlignment.start,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    color: data.nego2 == null ? Color(0xffF47003) : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Constant.xSizedBox12,
                Expanded(
                  child: CustomButton.secondaryButtonWithicon(
                    Expanded(
                      flex: 4,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.check,
                            weight: 10,
                            color: Constant.greenColor,
                          ),
                        ),
                      ),
                    ),
                    'Terima',
                    () async {
                      await Utils.showYesNoDialog(
                        context: context,
                        title: 'Konfirmasi Terima Nego',
                        desc: 'Apakah Anda yakin ingin Terima nego ini?',
                        yesCallback: () async {
                          CusNav.nPop(context);
                          await context
                              .read<NegoSellerProvider>()
                              .acceptOrRejectNego(negoId: data.ID ?? '0');
                          context.read<NegoSellerProvider>().fetchNego(
                            withLoading: true,
                          );
                        },
                        noCallback: () async {
                          CusNav.nPop(context);
                        },
                      );
                    },
                    flexText: 7,
                    stretched: true,
                    mainAxisAlignment: MainAxisAlignment.start,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 5,
                    ),
                    color: Color(0xff1ABC62),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: SafeArea(
        child: Container(
          color: Color(0xffF6F6F6),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: search(),
              ),
              Constant.xSizedBox8,
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    refresh();
                  },
                  child:
                      negoData.isEmpty
                          ? Center(child: Text('Data tidak ditemukan'))
                          : ListView.separated(
                            itemCount: negoData.length,
                            itemBuilder: (c, i) {
                              if (negoData[i] != null)
                                return negoItem(negoData[i]!);
                              return SizedBox();
                            },
                            separatorBuilder: (_, __) => Constant.xSizedBox8,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
