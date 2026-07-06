import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/admin/master/provider/master_provider.dart';
import 'package:provider/provider.dart';

class DataSubditAdminView extends StatefulWidget {
  const DataSubditAdminView({super.key});

  @override
  State<DataSubditAdminView> createState() => _DataSubditAdminViewState();
}

class _DataSubditAdminViewState extends BaseState<DataSubditAdminView> {

  @override
  void initState() {
    super.initState();
    refresh();
  }

  // SubditAdminModel data = SubditAdminModel();

  void refresh({String q = ''}) {
    context.read<MasterProvider>().fetchSubditAdmin(withLoading: true, search: q);
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MasterProvider>().getSubditAdminModel;

    PreferredSizeWidget appBar() {
      return CustomAppBar.appBar(
        context,
        'Data Subdit',
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

    final searchC = context.read<MasterProvider>().searchSubditC;
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
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
            SizedBox(
              height: 12,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: data.data?.length ?? 0,
                itemBuilder: (context, index) {
                  final model = data.data?[index];

                  return InkWell(
                    onTap: () {
                      // CusNav.nPush(
                      //     context,
                      //     KeuanganPesananDetailView(
                      //       transaction_id: transactions[index]?.ID ?? '0',
                      //     ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 8),
                      color: index % 2 == 0 ? Color(0xFFF6F6F6) : Colors.white,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kode',
                                    style: TextStyle(
                                        color: Constant.grayColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    model?.subditCode ?? '-',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 32,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name',
                                        style: TextStyle(
                                            color: Constant.grayColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        model?.subditName ?? '-',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
