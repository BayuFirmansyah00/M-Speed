import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/buyer/chat/model/detail_chat_buyer_model.dart';
import 'package:mspeed/src/buyer/chat/provider/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPesananKomplainView extends StatefulWidget {
  final String id;

  ChatPesananKomplainView({Key? key, required this.id}) : super(key: key);

  @override
  State<ChatPesananKomplainView> createState() => _ChatPersonViewState();
}

class _ChatPersonViewState extends State<ChatPesananKomplainView> {
  String userId = "";

  @override
  void initState() {
    context.read<ChatProvider>().detailChatBuyerModel = DetailChatBuyerModel();
    initData();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";

    context.read<ChatProvider>().fetchDetailChat(context,
        withLoading: true, idUser: userId, idSeller: widget.id);
  }

  String getTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    DateFormat timeFormat = DateFormat('HH:mm');
    return timeFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final chatModel = context.watch<ChatProvider>().detailChatBuyerModel;
    final groupedChats = chatModel.groupDataByCreatedDate();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(context, "Komplain", isCenter: true),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ChatProvider>().fetchDetailChat(context,
              idSeller: widget.id, idUser: userId, withLoading: true);
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: groupedChats.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _buildDateLabel(groupedChats.keys.toList()[index]),
                        ...groupedChats.values.toList()[index].map((e) {
                          return _buildChatBubble(
                            message: e.pesan ?? "-",
                            time: getTime(e.Created ?? ""),
                            isSender: e.PengirimID == userId,
                            isRead: e.dibaca == "1",
                          );
                        }).toList()
                      ],
                    );
                  }),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateLabel(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFEEF0F8),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(
            date,
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(
      {required String message,
      required String time,
      required bool isSender,
      required bool isRead}) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isSender ? Color(0xFFF58B2B).withOpacity(.2) : Colors.white,
                borderRadius: isSender
                    ? BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16))
                    : BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16)),
                border: Border.all(
                    color: isSender
                        ? Color(0xFFF58B2B).withOpacity(.2)
                        : Colors.grey[300]!),
              ),
              child: Wrap(
                children: [
                  Text(message),
                  SizedBox(
                    width: 8,
                  ),
                  if (isRead)
                    Image.asset(Assets.iconsIcRead, width: 16, height: 16),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(width: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final msgController = TextEditingController();

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: msgController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            radius: 25,
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                // Send message
                if (msgController.text.trim().isEmpty) return;

                context.read<ChatProvider>().sendChat(context,
                    withLoading: true,
                    idPenerima: widget.id,
                    idPengirim: userId,
                    message: msgController.text);

                msgController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}
