import 'package:mspeed/common/base/base_state.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/src/buyer/notifikasi/provider/notifikasi_buyer_provider.dart';
import 'package:mspeed/src/buyer/notifikasi/widget/notifikasi_item.dart';
import 'package:provider/provider.dart';
import 'package:mspeed/common/helper/constant.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends BaseState<NotificationView> {
  @override
  void initState() {
    super.initState();
    final notifP = context.read<NotifikasiBuyerProvider>();
    notifP.fetchNotification();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Constant.dsPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_rounded, size: 36, color: Constant.dsPrimary),
          ),
          const SizedBox(height: Constant.space16),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontFamily: Constant.primaryTextStyle.fontFamily,
              color: Constant.dsTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Constant.space8),
          Text(
            'Semua update pesanan\nakan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Constant.primaryTextStyle.fontFamily,
              color: Constant.dsTextSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.dsBackground,
      appBar: AppBar(
        backgroundColor: Constant.dsSurface,
        elevation: 0,
        titleSpacing: Constant.space16,
        centerTitle: false,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Constant.dsTextPrimary,
          ),
        ),
      ),
      body: Consumer<NotifikasiBuyerProvider>(
        builder: (context, notifP, child) {
          final data = notifP.notifikasiModel.data ?? [];
          final unread = notifP.unreadCount;

          return Column(
            children: [
              // Sub-header: Label + tombol tandai dibaca
              Container(
                color: Constant.dsSurface,
                padding: const EdgeInsets.fromLTRB(Constant.space16, Constant.space12, Constant.space16, Constant.space12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Status Pesanan',
                          style: TextStyle(
                            fontFamily: Constant.primaryTextStyle.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Constant.dsTextPrimary,
                          ),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(width: Constant.space8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Constant.dsPrimary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$unread belum dibaca',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        await notifP.postMarkAllReadNotif(context, withLoading: true);
                        await notifP.fetchNotification(withLoading: true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Constant.dsPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.done_all_rounded, size: 14, color: Constant.dsPrimary),
                            SizedBox(width: 4),
                            Text(
                              'Tandai Dibaca',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Constant.dsPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Constant.space8),
              Expanded(
                child: RefreshIndicator(
                  color: Constant.dsPrimary,
                  backgroundColor: Constant.dsSurface,
                  onRefresh: () async {
                    await notifP.fetchNotification(withLoading: true);
                  },
                  child: data.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                          itemCount: data.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final item = data[index];
                            return NotifikasiItem(
                              isRead: item?.isRead ?? '-',
                              image: item?.foto ?? '-',
                              title: item?.judul ?? '-',
                              subtitle: item?.pesan ?? '-',
                              datetime: item?.activityAt ?? '-',
                              onClick: () async {
                                await notifP.postMarkReadNotif(context,
                                    parentOrderId: item?.parentOrderId, withLoading: true);
                                await notifP.fetchNotification(withLoading: true);
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
