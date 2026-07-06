import 'package:mspeed/common/base/base_state.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/penerima/notifikasi/provider/notifikasi_penerima_provider.dart';
import 'package:mspeed/src/penerima/notifikasi/widget/notifikasi_item.dart';
import 'package:provider/provider.dart';

import '../../../../common/component/custom_appbar.dart';
import '../../../../common/helper/constant.dart';

class NotificationPenerimaView extends StatefulWidget {
  const NotificationPenerimaView({super.key});

  @override
  State<NotificationPenerimaView> createState() =>
      _NotificationPenerimaViewState();
}

class _NotificationPenerimaViewState extends BaseState<NotificationPenerimaView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    final notifP = context.read<NotifikasiPenerimaProvider>();
    notifP.fetchNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "Notifikasi",
        isCenter: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        color: Colors.white,
      ),
      body: Consumer<NotifikasiPenerimaProvider>(
        builder: (context, notifikasiPenerimaProvider, child) {
          final data = notifikasiPenerimaProvider.notifikasiModel.data;
          return RefreshIndicator(
            onRefresh: () async {
              notifikasiPenerimaProvider.fetchNotification(withLoading: true);
            },
            child: Column(children: [
              Container(
                padding: EdgeInsets.all(16),
                color: Color(0xFFF6F6F6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status Pesanan',
                      style: Constant.grayRegular12
                          .copyWith(color: Color(0xFF6D7588)),
                    ),
                    InkWell(
                      onTap: () async {
                        await notifikasiPenerimaProvider.postMarkAllReadNotif(
                          context,
                          withLoading: true,
                        );
                        await notifikasiPenerimaProvider.fetchNotification(
                          withLoading: true,
                        );
                      },
                      child: Text(
                        'Tandai Sudah Dibaca (${notifikasiPenerimaProvider.unreadCount})',
                        style: Constant.grayRegular12
                            .copyWith(color: Constant.primaryColor),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data?.length,
                  itemBuilder: (context, index) {
                    return NotifikasiItem(
                      isRead: data?[index]?.isRead ?? '-',
                      image: data?[index]?.foto ?? '-',
                      title: data?[index]?.judul ?? '-',
                      subtitle: data?[index]?.pesan ?? '-',
                      datetime: data?[index]?.activityAt ?? '-',
                      onClick: () async {
                        await notifikasiPenerimaProvider.postMarkReadNotif(
                          context,
                          parentOrderId: data?[index]?.parentOrderId,
                          withLoading: true,
                        );
                        await notifikasiPenerimaProvider.fetchNotification(
                          withLoading: true,
                        );
                      },
                    );
                  },
                ),
              )
            ]),
          );
        },
      ),
    );
  }
}
