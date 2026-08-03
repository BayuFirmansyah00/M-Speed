/// Model daftar kontak chat untuk buyer — disesuaikan dengan Laravel `ChatResource`.
///
/// Laravel `GET /api/chats?user_id={id}` response (ResourceCollection):
/// ```json
/// {
///   "data": [
///     {
///       "id": 1,
///       "message": "halo",
///       "is_seller": false,
///       "is_read": false,
///       "user": { "id": 148, "name": "Budi Santoso" },
///       "seller": { "id": 196, "name": "Atria Seller" },
///       "created_at": "2024-07-16T13:51:35+00:00",
///       "updated_at": "2024-07-16T13:51:35+00:00"
///     }
///   ]
/// }
/// ```

class ChatBuyerModelDataSeller {
  String? id;
  String? message;
  String? isRead;
  String? isSeller;
  String? createdAt;

  /// Info user (buyer) dari ChatResource
  String? userId;
  String? userName;

  /// Info seller dari ChatResource
  String? sellerId;
  String? sellerName;

  ChatBuyerModelDataSeller({
    this.id,
    this.message,
    this.isRead,
    this.isSeller,
    this.createdAt,
    this.userId,
    this.userName,
    this.sellerId,
    this.sellerName,
  });

  ChatBuyerModelDataSeller.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? json['ID']?.toString();
    message = json['message']?.toString() ?? json['isichat']?.toString();
    createdAt = json['created_at']?.toString() ?? json['Buat']?.toString();

    // is_read: bisa bool atau string
    final rawIsRead = json['is_read'];
    if (rawIsRead is bool) {
      isRead = rawIsRead ? '1' : '0';
    } else {
      isRead = json['dibaca']?.toString() ?? rawIsRead?.toString() ?? '0';
    }

    // is_seller: bisa bool atau int
    final rawIsSeller = json['is_seller'];
    if (rawIsSeller is bool) {
      isSeller = rawIsSeller ? '1' : '0';
    } else {
      isSeller = rawIsSeller?.toString() ?? '0';
    }

    // Format baru: user object dan seller object
    final user = json['user'];
    if (user != null) {
      userId = user['id']?.toString();
      userName = user['name']?.toString();
    } else {
      // Fallback format lama
      userId = json['PengirimID']?.toString();
      userName = (json['firstname']?.toString() ?? '') +
          ' ' +
          (json['lastname']?.toString() ?? '');
    }

    final seller = json['seller'];
    if (seller != null) {
      sellerId = seller['id']?.toString();
      sellerName = seller['name']?.toString();
    } else {
      // Fallback format lama
      sellerId = json['PenerimaID']?.toString() ?? json['ID']?.toString();
      sellerName = json['nama_perusahaan']?.toString() ?? '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'is_read': isRead,
      'is_seller': isSeller,
      'created_at': createdAt,
      'user': {'id': userId, 'name': userName},
      'seller': {'id': sellerId, 'name': sellerName},
    };
  }

  // ─── Backward compatibility getters ───
  // Digunakan oleh view yang masih merujuk field lama

  String? get Buat => createdAt;
  String? get isichat => message;
  String? get dibaca => isRead;
  String? get PengirimID => userId;
  String? get PenerimaID => sellerId;
  String? get ID => sellerId;
  String? get firstname => sellerName; // Menampilkan nama seller di list buyer
  String? get lastname => null;
  String? get email => null;
  String? get foto => null;
}

class ChatBuyerModelData {
  List<ChatBuyerModelDataSeller?>? seller;

  ChatBuyerModelData({this.seller});

  ChatBuyerModelData.fromJson(Map<String, dynamic> json) {
    // Provider list chat mengembalikan json yang mungkin dibungkus 'seller' (jika diakali di provider) 
    // atau 'data'
    if (json['seller'] != null) {
      final v = json['seller'];
      final arr0 = <ChatBuyerModelDataSeller>[];
      v.forEach((v) {
        arr0.add(ChatBuyerModelDataSeller.fromJson(v));
      });
      seller = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (seller != null) {
      data['seller'] = seller!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}

class ChatBuyerModel {
  String? result;
  ChatBuyerModelData? data;

  ChatBuyerModel({this.result, this.data});

  ChatBuyerModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString() ?? 'success';
    data = json['data'] != null
        ? ChatBuyerModelData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['result'] = result;
    if (this.data != null) data['data'] = this.data!.toJson();
    return data;
  }
}
