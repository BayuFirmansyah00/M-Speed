import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/src/buyer/address/provider/address_provider.dart';
import 'package:mspeed/src/buyer/address/view/address_penerima_view.dart';
import 'package:provider/provider.dart';

class AkunPenerimaView extends StatefulWidget {
  const AkunPenerimaView({super.key});

  @override
  State<AkunPenerimaView> createState() => _AkunPenerimaViewState();
}

class _AkunPenerimaViewState extends BaseState<AkunPenerimaView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    await context.read<AddressProvider>().fetchAkunPenerima(withLoading: true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final penerimaP = context.watch<AddressProvider>().akunPenerimaModel;
    return Scaffold(
        appBar: CustomAppBar.appBar(
          context,
          "Pilih Akun Penerima",
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(10),
              child: Divider(
                color: Colors.blue.shade100.withOpacity(0.2),
                thickness: 7,
              )),
        ),
        body: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: penerimaP?.data?.length ?? 0,
          separatorBuilder: (c, i) => SizedBox(
            height: 16,
          ),
          itemBuilder: (c, i) {
            final item = penerimaP?.data?[i];
            return Container(
              padding: EdgeInsets.all(10),
              child: InkWell(
                onTap: () async {
                  context.read<AddressProvider>().selectedPenerima = item;
                  context.read<AddressProvider>().selectedPenerimaID = item?.ID;
                  setState(() {});
                  await CusNav.nPush(context, AddressPenerimaView());
                  CusNav.nPop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade400,
                          // foregroundColor: Colors.grey,
                          child: Text("ehe")),
                    ),
                    Expanded(
                        flex: 7,
                        child: Text(penerimaP?.data?[i]?.firstname ?? "")),
                    Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 20,
                        weight: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
