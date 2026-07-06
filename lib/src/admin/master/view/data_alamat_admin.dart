import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/admin/master/model/alamat_admin_model.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:mspeed/src/admin/master/view/add_addres_admin_view.dart';
import 'package:provider/provider.dart';

class DataAlamatAdminView extends StatefulWidget {
  const DataAlamatAdminView({super.key});

  @override
  State<DataAlamatAdminView> createState() => _DataAlamatAdminViewState();
}

class _DataAlamatAdminViewState extends BaseState<DataAlamatAdminView> {
  @override
  void initState() {
    super.initState();
    refresh();
  }

  // SubditAdminModel data = SubditAdminModel();

  void refresh({String q = ''}) {
    context
        .read<MasterProvider>()
        .fetchAlamatAdmin(withLoading: true, search: q);
  }

  @override
  Widget build(BuildContext context) {
    final masterP = context.watch<MasterProvider>();
    final data = context.watch<MasterProvider>().getAlamatAdminModel;
    final model = context.watch<MasterProvider>().getAlamatAdminModel.data;

    void _showButtonBottomSheet(BuildContext context, int i) {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150,
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){
                      CusNav.nPop(context);
                    },
                      child: Icon(
                    Icons.close,
                    color: Colors.black,
                  )),
                  Constant.xSizedBox16,
                  Container(
                    padding: EdgeInsets.only(left: 5),
                    child: InkWell(
                      onTap: (){
                        CusNav.nPush(
                            context,
                            AddAddressAdminView(
                                alamat: model![i]));
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(Assets.svgsIcAdminEdit),
                          Constant.xSizedBox12,
                          Text(
                            "Ubah",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Constant.xSizedBox16,
                  Container(
                    child: InkWell(
                      onTap: (){
                        CusNav.nPop(context);
                        masterP.deleteAlamat(alamatId: model![i]?.id);
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(Assets.svgsIcAdminDelete),
                          Constant.xSizedBox12,
                          Text(
                            "Hapus",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ));
        },
      );
    }

    TableRow alamatItem({required int index, required AlamatAdminModel? data}) {
      return TableRow(
        decoration: BoxDecoration(color: Colors.transparent),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              data?.data?[index]?.prov ?? '',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              data?.data?[index]?.kota ?? '',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 4),
            child: Text(
              data?.data?[index]?.nama ?? '',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color(0xff100629),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 8, right: 4),
              child: InkWell(
                  onTap: () {
                    _showButtonBottomSheet(context, index);
                  },
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.black54,
                  ))),
        ],
      );
    }

    List<TableRow> tableAlamatMaster() {
      return List.generate(model?.length ?? 0, (i) {
        return alamatItem(index: i, data: data);
      });
    }

    Widget alamatMaster() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            border: TableBorder.all(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5)),
            columnWidths: const <int, TableColumnWidth>{
              0: IntrinsicColumnWidth(flex: 0.4),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
              4: IntrinsicColumnWidth(flex: 0.3),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              // title
              TableRow(
                decoration: BoxDecoration(color: Color(0xffDEEDFF)),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                    child: Text(
                      'No',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color(0xff100629),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      'Provinsi',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color(0xff100629),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      'Kab/Kota',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color(0xff100629),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      'Alamat',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color(0xff100629),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8, right: 4),
                    child: Text(
                      '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff100629),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              // content
              ...tableAlamatMaster(),
            ],
          ),
        ],
      );
    }

    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(
        context,
        'Data Alamat Penerima',
        action: [
          InkWell(
            onTap: (){
              CusNav.nPush(context, AddAddressAdminView());
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: SvgPicture.asset(Assets.svgsIcPlusAdmin),
            ),
          )
        ],
        color: Colors.white,
        isCenter: true,
        titleSpacing: 24,
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    }

    final searchC = context.read<MasterProvider>().searchAlamatC;
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchC,
              onSubmitted: (_) {
                refresh(q: searchC.text);
              },
              textInputAction: TextInputAction.search, // This
              decoration: InputDecoration(
                hintText: 'Cari',
                hintStyle: TextStyle(color: Color(0xFF6D7588)),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF6D7588),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFEEF0F8)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          alamatMaster(),
        ],
      ),
    );
  }
}
