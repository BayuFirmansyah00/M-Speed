import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/chat/model/chat_buyer_model.dart';
import 'package:mspeed/src/buyer/chat/provider/chat_provider.dart';
import 'package:mspeed/src/buyer/chat/view/chat_person_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListChatPesananView extends StatefulWidget {
  const ListChatPesananView({super.key});

  @override
  State<ListChatPesananView> createState() => _ListChatPesananViewState();
}

class _ListChatPesananViewState extends State<ListChatPesananView> {
  String userId = "";
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  String getFullname(ChatBuyerModelDataSeller? data) {
    if (data == null) return "-";
    return "${data.firstname ?? ""} ${data.lastname ?? ""}".trim();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(Constant.kSetPrefId) ?? "";

    if (userId.isEmpty || !mounted) return;

    // Jangan tampilkan loading global saat inisialisasi tab Chat karena
    // IndexedStack membangun semua tab sekaligus. Loading global dari tab
    // yang belum terlihat bisa menyebabkan race condition / ANR.
    context
        .read<ChatProvider>()
        .fetchListChat(context, withLoading: false, idBuyer: userId);
  }

  List<ChatBuyerModelDataSeller?> _filterChats(
    List<ChatBuyerModelDataSeller?>? source,
    String query,
  ) {
    if (source == null) return [];
    if (query.trim().isEmpty) return source;
    final lower = query.toLowerCase();
    return source
        .where((e) => getFullname(e).toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final chatP = context.watch<ChatProvider>();
    final source = chatP.chatBuyerModel.data?.seller ?? [];
    final chatModel = _filterChats(source, searchController.text);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: CustomAppBar.appBar(
        context,
        'Chat',
        color: Colors.white,
        isCenter: true,
        leading: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: Constant.primaryColor,
          backgroundColor: Colors.white,
          onRefresh: () async {
            if (userId.isEmpty) return;
            await context
                .read<ChatProvider>()
                .fetchListChat(context, idBuyer: userId, withLoading: true);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pesan Masuk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Komunikasi dengan seller terkait pesanan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: 18),
                // SEARCH BAR
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Cari nama seller...',
                      hintStyle: TextStyle(
                          color: Colors.black38,
                          fontWeight: FontWeight.w400),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.black38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: chatModel.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: chatModel.length,
                          itemBuilder: (context, index) {
                            final item = chatModel[index];
                            return ChatListItem(
                              key: ValueKey(item?.PenerimaID ?? index),
                              name: getFullname(item),
                              userId: item?.PenerimaID ?? "-",
                              message: item?.isichat ?? "-",
                              date: item?.Buat ?? "-",
                              imageUrl: "",
                              isRead: item?.dibaca == "1",
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 42,
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Belum ada percakapan',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Chat dari seller akan muncul\ndi sini',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.45),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
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
    super.key,
    this.isRead = true,
    required this.userId,
    required this.name,
    required this.message,
    required this.date,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Constant.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
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
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    imageUrl: imageUrl ?? "",
                    placeholder: (context, url) => Image.asset(
                      Assets.imagesImgAvatar,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      Assets.imagesImgAvatar,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: Constant.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          color: isRead
                              ? Colors.black.withValues(alpha: 0.45)
                              : Colors.black.withValues(alpha: 0.65),
                          fontSize: 13,
                          fontWeight: isRead
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.35),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
