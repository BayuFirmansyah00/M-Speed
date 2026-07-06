import 'package:mspeed/common/base/base_state.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/buyer/notifikasi/provider/notifikasi_buyer_provider.dart';
import 'package:mspeed/src/buyer/notifikasi/widget/notifikasi_item.dart';
import 'package:provider/provider.dart';

import '../../../../common/component/custom_appbar.dart';
import '../../../../common/helper/constant.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends BaseState<NotificationView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    final notifP = context.read<NotifikasiBuyerProvider>();
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
        leading: SizedBox(),
        color: Colors.white,
      ),
      body: Consumer<NotifikasiBuyerProvider>(
        builder: (context, NotifikasiBuyerProvider, child) {
          final data = NotifikasiBuyerProvider.notifikasiModel.data;
          return RefreshIndicator(
            onRefresh: () async {
              NotifikasiBuyerProvider.fetchNotification(withLoading: true);
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
                        await NotifikasiBuyerProvider.postMarkAllReadNotif(
                          context,
                          withLoading: true,
                        );
                        await NotifikasiBuyerProvider.fetchNotification(
                          withLoading: true,
                        );
                      },
                      child: Text(
                        'Tandai Sudah Dibaca (${NotifikasiBuyerProvider.unreadCount})',
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
                        await NotifikasiBuyerProvider.postMarkReadNotif(
                          context,
                          parentOrderId: data?[index]?.parentOrderId,
                          withLoading: true,
                        );
                        await NotifikasiBuyerProvider.fetchNotification(
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
