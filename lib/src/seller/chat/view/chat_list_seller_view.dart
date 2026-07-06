import 'package:flutter/material.dart';
import 'package:mspeed/common/base/base_state.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/src/seller/chat/model/chat_seller_model.dart';
import 'package:mspeed/src/seller/chat/provider/chat_seller_provider.dart';
import 'package:mspeed/src/seller/chat/view/chat_person_seller_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListSellerView extends StatefulWidget {
  @override
  State<ChatListSellerView> createState() => _ChatListSellerViewState();
}

class _ChatListSellerViewState extends BaseState<ChatListSellerView> {
  String userId = "";

  @override
  void initState() {
    initData();
    super.initState();
  }

  String getFullname(ChatSellerModelDataSeller data) {
    return data.firstname ?? "" + " " + (data.lastname ?? "");
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";

    context
        .read<ChatSellerProvider>()
        .fetchListChat(context, withLoading: true, idSeller: userId);
  }

  List<ChatSellerModelDataSeller?> chatModel = [];
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (chatModel.isEmpty && searchController.text.isEmpty) {
      chatModel =
          context.watch<ChatSellerProvider>().chatSellerModel.data?.seller ??
              [];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        'Chat',
        color: Colors.white,
        isCenter: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context
                .read<ChatSellerProvider>()
                .fetchListChat(context, idSeller: userId, withLoading: true);
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (String value) {
                    setState(() {
                      chatModel = context
                              .read<ChatSellerProvider>()
                              .chatSellerModel
                              .data
                              ?.seller
                              ?.where((e) {
                            return getFullname(e!)
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          }).toList() ??
                          [];
                    });
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
              Expanded(
                child: ListView.builder(
                  itemCount: chatModel.length ?? 0,
                  itemBuilder: (context, index) {
                    return ChatListItem(
                      name: getFullname(chatModel[index]!),
                      userId: chatModel[index]?.PengirimID ?? "-",
                      message: chatModel[index]?.isichat ?? "-",
                      date: chatModel[index]?.Buat ?? "-",
                      imageUrl:
                          chatModel[index]?.foto ?? "-", // BLUM ADA IMG URL
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (userId != '-')
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPersonView(
                      id: userId,
                      sellerName: name,
                    )),
          );
        // Navigator.pushNamed(context, '/chat_person');
      },
      child: Column(
        children: [
          Container(
            color: isRead ? Colors.white : Color(0xFFF58B2B).withOpacity(.05),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Container(
                    width: 52,
                    height: 52,
                    child: imageUrl != null
                        ? Image.network(imageUrl!)
                        : Icon(Icons.person)),
              ),
              title: Text(name,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(color: Color(0xFF6D7588), fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Divider(
                    color: Colors.blueGrey[50],
                  )
                ],
              ),
              trailing: Text(date, style: TextStyle(color: Color(0xFF6D7588))),
            ),
          ),
        ],
      ),
    );
  }
}
