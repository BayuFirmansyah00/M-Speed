import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/chat/model/chat_buyer_model.dart';
import 'package:mspeed/src/buyer/chat/provider/chat_provider.dart';
import 'package:mspeed/src/buyer/chat/view/chat_person_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── PALET : Ultra-Modern Clean ───────────────────────────
class _C {
  static const primary = Color(0xFFE50012);
  static const primaryLight = Color(0xFFFFEBEE);
  static const bg = Color(0xFFF9FAFB);
  static const card = Color(0xFFFFFFFF);
  static const txt1 = Color(0xFF0F172A);
  static const txt2 = Color(0xFF64748B);
  static const txt3 = Color(0xFF94A3B8);
  
  static const shadowSoft = BoxShadow(
    color: Color(0x08000000),
    blurRadius: 15,
    offset: Offset(0, 5),
  );
}

class ChatListView extends StatefulWidget {
  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends BaseState<ChatListView> {
  String userId = "";
  List<ChatBuyerModelDataSeller?> chatModel = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  String getFullname(ChatBuyerModelDataSeller data) {
    return (data.firstname ?? "") + " " + (data.lastname ?? "");
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(Constant.kSetPrefId) ?? "";

    if (mounted) {
      await context
          .read<ChatProvider>()
          .fetchListChat(context, withLoading: true, idBuyer: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (chatModel.isEmpty && searchController.text.isEmpty) {
      chatModel = context.watch<ChatProvider>().chatBuyerModel.data?.seller ?? [];
    }

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Chat',
          style: TextStyle(color: _C.txt1, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _C.txt1, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _C.txt3.withValues(alpha: 0.1), height: 1),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              initData();
            });
          },
          color: _C.primary,
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: chatModel.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: chatModel.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final chat = chatModel[index];
                          if (chat == null) return const SizedBox.shrink();
                          
                          return ChatListItem(
                            name: getFullname(chat),
                            userId: chat.PenerimaID ?? "-",
                            message: chat.isichat ?? "-",
                            date: chat.Buat ?? "-",
                            imageUrl: Assets.iconsIcSellerProfile,
                            isRead: true, // Assuming default logic
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [_C.shadowSoft],
        ),
        child: TextField(
          controller: searchController,
          onChanged: (String value) {
            setState(() {
              final originalList = context.read<ChatProvider>().chatBuyerModel.data?.seller ?? [];
              chatModel = originalList.where((e) {
                if (e == null) return false;
                return getFullname(e).toLowerCase().contains(value.toLowerCase());
              }).toList();
            });
          },
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari pesan...',
            hintStyle: const TextStyle(color: _C.txt3, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: _C.txt3),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: _C.primary, size: 48),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada pesan', style: TextStyle(color: _C.txt1, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Pesan dengan penjual akan muncul di sini', style: TextStyle(color: _C.txt2, fontSize: 14)),
        ],
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final String userId;
  final String name;
  final String message;
  final String date;
  final String? imageUrl;
  final bool isRead;

  const ChatListItem({
    Key? key,
    this.isRead = true,
    required this.userId,
    required this.name,
    required this.message,
    required this.date,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPersonView(
              id: userId,
              sellerName: name,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? _C.card : _C.primaryLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [_C.shadowSoft],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _C.bg,
                shape: BoxShape.circle,
                border: Border.all(color: _C.txt3.withValues(alpha: 0.2), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: imageUrl != null
                    ? Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.person_rounded, color: _C.txt3))
                    : const Icon(Icons.person_rounded, color: _C.txt3),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.w700 : FontWeight.w800,
                            fontSize: 15,
                            color: _C.txt1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: TextStyle(
                          color: isRead ? _C.txt3 : _C.primary,
                          fontSize: 11,
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: TextStyle(
                      color: isRead ? _C.txt2 : _C.txt1,
                      fontSize: 13,
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Unread Indicator
            if (!isRead) ...[
              const SizedBox(width: 12),
              Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: _C.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
