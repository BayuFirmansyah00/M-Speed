import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_appbar.dart';
import 'package:mspeed/common/component/image_network_widget.dart';
import 'package:mspeed/common/helper/Constant.dart';
import 'package:mspeed/common/helper/download.dart';
import 'package:mspeed/generated/assets.dart';
import 'package:mspeed/src/seller/chat/model/riwayat_komplain_seller_model.dart';
import 'package:mspeed/src/seller/chat/provider/chat_seller_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ChatPesananKomplainView extends StatefulWidget {
  final String penerimaId, orderId;

  ChatPesananKomplainView(
      {Key? key, required this.orderId, required this.penerimaId})
      : super(key: key);

  @override
  State<ChatPesananKomplainView> createState() => _ChatPersonViewState();
}

class _ChatPersonViewState extends State<ChatPesananKomplainView> {
  String userId = "";

  @override
  void initState() {
    context.read<ChatSellerProvider>().riwayat = RiwayatKomplainSellerModel();
    initData();
    super.initState();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = await prefs.getString(Constant.kSetPrefId) ?? "";

    await refresh();
  }

  Future<void> refresh() async {
    context
        .read<ChatSellerProvider>()
        .fetchRiwayat(withLoading: true, order_id: widget.orderId);
  }

  String getTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    DateFormat timeFormat = DateFormat('HH:mm');
    return timeFormat.format(dateTime);
  }

  Widget fileToggle() {
    return InkWell(
      onTap: () {
        setState(() {
          isChoosingFile = !isChoosingFile;
        });
      },
      child: Icon(
        !isChoosingFile ? Icons.add_circle_outline : Icons.cancel_outlined,
        color: Color(0xFF6D7588),
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final riwayat = context.watch<ChatSellerProvider>().riwayat;
    final groupedChats = riwayat.groupDataByCreatedDate();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        'Komplain',
        color: Colors.white,
        isCenter: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context
              .read<ChatSellerProvider>()
              .fetchRiwayat(order_id: widget.orderId);
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: groupedChats.keys.toList().length ?? 0,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _buildDateLabel(groupedChats.keys.toList()[index]),
                        ...groupedChats.values.toList()[index].map((e) {
                          return _buildChatBubble(
                              message: e.pesan ?? "-",
                              time: getTime(e.Created ?? ""),
                              isSender: e.PengirimID != userId,
                              isRead: e.dibaca == "1",
                              file: e.attachment);
                        }).toList()
                      ],
                    );
                  }),
            ),
            _buildMessageInput(),
            _chooseFile()
          ],
        ),
      ),
    );
  }

  ChosenFile? chosenFile;

  Widget _chooseFile() {
    if (!isChoosingFile) return SizedBox();

    final ImagePicker _picker = ImagePicker();

    Future<void> _pickImage(ImageSource source) async {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          chosenFile =
              ChosenFile(true, image.path, image.name, File(image.path));
        });
      }
    }

    Future<void> _pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          chosenFile = ChosenFile(false, result.files.single.path!,
              result.files.single.name, File(result.files.single.path!));
        });
      }
    }

    return Container(
      color: Color(0xFFF5F5F5),
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: (chosenFile != null)
            ? [
                Container(
                  child: (chosenFile!.isImage)
                      ? Image.file(
                          File(chosenFile!.path),
                          width: 32,
                          height: 32,
                        )
                      : Icon(
                          Icons.file_copy_outlined,
                          color: Color(0xFFB9B9B9),
                        ),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(child: AutoSizeText(chosenFile!.name)),
              ]
            : [
                InkWell(
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                  },
                  child: Column(
                    children: [
                      Container(
                        child: Icon(
                          Icons.image_outlined,
                          color: Color(0xFFB9B9B9),
                        ),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text("Gallery")
                    ],
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                InkWell(
                  onTap: () {
                    _pickImage(ImageSource.camera);
                  },
                  child: Column(
                    children: [
                      Container(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFFB9B9B9),
                        ),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text("Kamera")
                    ],
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                InkWell(
                  onTap: () {
                    _pickFile();
                  },
                  child: Column(
                    children: [
                      Container(
                        child: Icon(
                          Icons.file_copy_outlined,
                          color: Color(0xFFB9B9B9),
                        ),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text("Dokumen")
                    ],
                  ),
                ),
              ],
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
      required bool isRead,
      String? file}) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (file != null)
              Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSender
                      ? Color(0xFFF58B2B).withOpacity(.2)
                      : Colors.white,
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
                child: (isImageFile(file))
                    ? ImageNetworkWidget(
                        imageUrl: file,
                        radius: 16,
                        width: 160,
                        height: 160,
                      )
                    : InkWell(
                        onTap: () {
                          final filename = file.split('/').last;
                          downloadFile(
                            context,
                            file,
                            filename: filename,
                            typeFile: file.split('.').last,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.download, color: Constant.primaryColor),
                            SizedBox(
                              width: 8,
                            ),
                            Text('Download')
                          ],
                        ),
                      ),
              ),
            if (message.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSender
                      ? Color(0xFFF58B2B).withOpacity(.2)
                      : Colors.white,
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

  bool isChoosingFile = false;

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          fileToggle(),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: TextField(
              controller: msgController,
              decoration: InputDecoration(
                hintText: 'Type message...',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFEEF0F8),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFEEF0F8),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            radius: 25,
            backgroundColor: Constant.primaryColor,
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: () {
                final riwayat = context.read<ChatSellerProvider>().riwayat;
                // Send message
                if (msgController.text.trim().isEmpty && chosenFile == null)
                  return;

                context.read<ChatSellerProvider>().sendComplain(
                    withLoading: true,
                    nomor_order: widget.orderId,
                    keterangan: msgController.text,
                    file: chosenFile?.file,
                    penerima_id: widget.penerimaId);

                msgController.clear();
                chosenFile = null;
                isChoosingFile = false;
              },
            ),
          ),
        ],
      ),
    );
  }

  bool isImageFile(String fileName) {
    // Define a set of valid image file extensions
    final imageExtensions = {
      '.png',
      '.jpg',
      '.jpeg',
      '.gif',
      '.bmp',
      '.webp',
      '.tiff'
    };

    // Convert the filename to lowercase to make the check case-insensitive
    String lowerCaseFileName = fileName.toLowerCase();

    // Check if the file extension is one of the valid image extensions
    for (var extension in imageExtensions) {
      if (lowerCaseFileName.endsWith(extension)) {
        return true;
      }
    }

    // Return false if no matching extension is found
    return false;
  }
}

class ChosenFile {
  final bool isImage;
  final String path, name;
  final File file;

  ChosenFile(this.isImage, this.path, this.name, this.file);
}
