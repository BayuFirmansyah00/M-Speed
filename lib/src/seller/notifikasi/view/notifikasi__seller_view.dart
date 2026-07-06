import 'package:mspeed/common/base/base_state.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/seller/notifikasi/widget/notifikasi_item.dart';
import 'package:mspeed/src/seller/notifikasi/provider/notifikasi_seller_provider.dart';
import 'package:provider/provider.dart';

import '../../../../common/component/custom_appbar.dart';
import '../../../../common/helper/constant.dart';

class NotificationSellerView extends StatefulWidget {
  const NotificationSellerView({super.key});

  @override
  State<NotificationSellerView> createState() => _NotificationSellerViewState();
}

class _NotificationSellerViewState extends BaseState<NotificationSellerView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    final notifP = context.read<NotifikasiSellerProvider>();
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
      body: Consumer<NotifikasiSellerProvider>(
        builder: (context, notifikasiProvider, child) {
          final data = notifikasiProvider.notifikasiModel.data;
          return RefreshIndicator(
            onRefresh: () async {
              notifikasiProvider.fetchNotification(withLoading: true);
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
                        await notifikasiProvider.postMarkAllReadNotif(
                          context,
                          withLoading: true,
                        );
                        await notifikasiProvider.fetchNotification(
                          withLoading: true,
                        );
                      },
                      child: Text(
                        'Tandai Sudah Dibaca (${notifikasiProvider.unreadCount})',
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
                        await notifikasiProvider.postMarkReadNotif(
                          context,
                          parentOrderId: data?[index]?.parentOrderId,
                          withLoading: true,
                        );
                        await notifikasiProvider.fetchNotification(
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
