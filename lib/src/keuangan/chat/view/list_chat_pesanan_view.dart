import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/Constant.dart';
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

  @override
  void initState() {
    initData();
    super.initState();
  }

  String getFullname(ChatBuyerModelDataSeller data) {
    return (data.firstname ?? "") + " " + (data.lastname ?? "");
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";

    context
        .read<ChatProvider>()
        .fetchListChat(context, withLoading: true, idBuyer: userId);
  }

  List<ChatBuyerModelDataSeller?> chatModel = [];
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (chatModel.isEmpty && searchController.text.isEmpty) {
      chatModel =
          context.watch<ChatProvider>().chatBuyerModel.data?.seller ?? [];
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff100629),
        title: const Text(
          'Pesan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xffE2E4E9),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context
                .read<ChatProvider>()
                .fetchListChat(context, idBuyer: userId, withLoading: true);
          },
          color: const Color(0xffF59E0B),
          child: Column(
            children: [
              // Standardized Modern Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F6FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffE2E4E9)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search_rounded, color: Constant.grayColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          style: const TextStyle(fontSize: 13),
                          onChanged: (String value) {
                            setState(() {
                              chatModel = context
                                      .read<ChatProvider>()
                                      .chatBuyerModel
                                      .data
                                      ?.seller
                                      ?.where((e) {
                                    return getFullname(e!).toLowerCase().contains(value.toLowerCase());
                                  }).toList() ??
                                  [];
                            });
                          },
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Cari nama seller...',
                            hintStyle: TextStyle(color: Constant.grayColor, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            searchController.clear();
                            setState(() {
                              chatModel = context.read<ChatProvider>().chatBuyerModel.data?.seller ?? [];
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.close_rounded, color: Constant.grayColor, size: 18),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Chat List
              Expanded(
                child: chatModel.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada percakapan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: chatModel.length,
                        itemBuilder: (context, index) {
                          final item = chatModel[index];
                          if (item == null) return const SizedBox();
                          return ChatListItem(
                            name: getFullname(item),
                            userId: item.PenerimaID ?? "-",
                            message: item.isichat ?? "-",
                            date: item.Buat ?? "-",
                            isRead: true, // Assuming default or mapping if available
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

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xffEBEBF0), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatPersonView(
                          id: userId,
                          sellerName: name,
                        )),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffF59E0B), Color(0xffD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xffF59E0B).withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Message Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff100629),
                              ),
                            ),
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xff8A93A3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff6D7588),
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
      ),
    );
  }
}
