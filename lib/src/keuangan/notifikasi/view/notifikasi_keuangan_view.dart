import 'package:mspeed/common/base/base_state.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/keuangan/notifikasi/provider/notifikasi_keuangan_provider.dart';
import 'package:mspeed/src/keuangan/notifikasi/widget/notifikasi_item.dart';
import 'package:provider/provider.dart';

import '../../../../common/component/custom_appbar.dart';
import '../../../../common/helper/constant.dart';

class NotifikasiKeuanganView extends StatefulWidget {
  const NotifikasiKeuanganView({super.key});

  @override
  State<NotifikasiKeuanganView> createState() => _NotifikasiKeuanganViewState();
}

class _NotifikasiKeuanganViewState extends BaseState<NotifikasiKeuanganView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    final notifP = context.read<NotifikasiKeuanganProvider>();
    notifP.fetchNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: CustomAppBar.appBar(
        context,
        "Notifikasi",
        isCenter: true,
        color: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xff100629),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 22,
            color: Color(0xff100629),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<NotifikasiKeuanganProvider>(
        builder: (context, notifikasiKeuanganProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              notifikasiKeuanganProvider.fetchNotification(withLoading: true);
            },
            child: Column(children: [
              // Header Status Pesanan & Tandai Dibaca
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xffE2E4E9), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Constant.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.notifications_active_outlined,
                            size: 16,
                            color: Constant.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Status Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xff100629),
                          ),
                        ),
                      ],
                    ),
                    if (notifikasiKeuanganProvider.unreadCount > 0)
                      InkWell(
                        onTap: () async {
                          await notifikasiKeuanganProvider.postMarkAllReadNotif(
                            context,
                            withLoading: true,
                          );
                          await notifikasiKeuanganProvider.fetchNotification(
                            withLoading: true,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            'Tandai Semua Dibaca (${notifikasiKeuanganProvider.unreadCount})',
                            style: TextStyle(
                              color: Constant.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final displayData = notifikasiKeuanganProvider.notificationsToDisplay;
                    final showButton = !notifikasiKeuanganProvider.showOneWeek &&
                        notifikasiKeuanganProvider.hasMoreNotifications;
                    final itemCount = displayData.length + (showButton ? 1 : 0);

                    if (itemCount == 0) {
                      return const Center(
                        child: Text(
                          'Tidak ada notifikasi',
                          style: TextStyle(
                            color: Color(0xff8A93A3),
                            fontSize: 13,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 24),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (showButton && index == displayData.length) {
                          return _buildLoadMoreButton(notifikasiKeuanganProvider);
                        }

                        final item = displayData[index];
                        return NotifikasiItem(
                          isRead: item.isRead ?? '-',
                          image: item.foto ?? '-',
                          title: item.judul ?? '-',
                          subtitle: item.pesan ?? '-',
                          datetime: item.activityAt ?? '-',
                          onClick: () async {
                            await notifikasiKeuanganProvider.postMarkReadNotif(
                              context,
                              parentOrderId: item.parentOrderId,
                              withLoading: true,
                            );
                            await notifikasiKeuanganProvider.fetchNotification(
                              withLoading: true,
                            );
                          },
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

  Widget _buildLoadMoreButton(NotifikasiKeuanganProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Constant.primaryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              provider.showOneWeek = true;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: Constant.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lihat Notifikasi 1 Minggu Terakhir',
                    style: TextStyle(
                      color: Constant.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

