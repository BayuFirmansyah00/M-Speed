/// Manager Dashboard Model
/// Source of truth: ManagerDashboardResource.php
/// Returns: banners, categories, parent_orders, products

class ManagerDashboardModel {
  List<ManagerBannerItem>? banners;
  List<ManagerCategoryItem>? categories;
  List<ManagerDashboardParentOrder>? parentOrders;
  List<ManagerProductItem>? products;

  ManagerDashboardModel({
    this.banners,
    this.categories,
    this.parentOrders,
    this.products,
  });

  factory ManagerDashboardModel.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'] ?? json;

    return ManagerDashboardModel(
      banners: rawData['banners'] != null
          ? (rawData['banners'] as List)
              .map((i) => ManagerBannerItem.fromJson(i))
              .toList()
          : null,
      categories: rawData['categories'] != null
          ? (rawData['categories'] as List)
              .map((i) => ManagerCategoryItem.fromJson(i))
              .toList()
          : null,
      parentOrders: rawData['parent_orders'] != null
          ? (rawData['parent_orders'] as List)
              .map((i) => ManagerDashboardParentOrder.fromJson(i))
              .toList()
          : null,
      products: rawData['products'] != null
          ? (rawData['products'] as List)
              .map((i) => ManagerProductItem.fromJson(i))
              .toList()
          : null,
    );
  }
}

class ManagerBannerItem {
  int? id;
  String? caption;
  String? imgUrl;

  ManagerBannerItem({this.id, this.caption, this.imgUrl});

  factory ManagerBannerItem.fromJson(Map<String, dynamic> json) {
    return ManagerBannerItem(
      id: json['id'],
      caption: json['caption']?.toString(),
      imgUrl: json['img_url']?.toString(),
    );
  }
}

class ManagerCategoryItem {
  int? id;
  String? name;
  int? status;

  ManagerCategoryItem({this.id, this.name, this.status});

  factory ManagerCategoryItem.fromJson(Map<String, dynamic> json) {
    return ManagerCategoryItem(
      id: json['id'],
      name: json['name']?.toString(),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '1'),
    );
  }
}

class ManagerDashboardParentOrder {
  int? id;
  String? orderNum;
  String? buyerName;
  String? paymentStatus;
  ManagerDashboardOrderLog? latestLog;

  ManagerDashboardParentOrder({
    this.id,
    this.orderNum,
    this.buyerName,
    this.paymentStatus,
    this.latestLog,
  });

  factory ManagerDashboardParentOrder.fromJson(Map<String, dynamic> json) {
    return ManagerDashboardParentOrder(
      id: json['id'],
      orderNum: json['order_num']?.toString(),
      buyerName: json['buyer_name']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      latestLog: json['latest_log'] != null
          ? ManagerDashboardOrderLog.fromJson(json['latest_log'])
          : null,
    );
  }

  /// Categorization helper matching ManagerDashboard.blade.php logic
  String get statusCategory {
    final s = (latestLog?.status ?? paymentStatus ?? '').toLowerCase().trim();

    if (s.contains('not approve') || s.contains('ditolak') || s.contains('cancel') || s.contains('reject')) {
      return 'pesanan_ditolak';
    }
    if (s == 'pesanan baru') {
      return 'pesanan_baru';
    }
    if (s.contains('approve pesanan')) {
      return 'pesanan_diterima';
    }
    if (s.contains('dikirim') || s == 'pesanan dikirm') {
      return 'pesanan_dikirim';
    }
    if (s.contains('diterima penerima') || s.contains('barang diterima')) {
      return 'barang_diterima';
    }
    if (s == 'tagihan') {
      return 'tagihan';
    }
    if (s.contains('siap tagih')) {
      return 'siap_tagih';
    }
    if (s.contains('penerimaan & verifikasi') || s.contains('verifikasi')) {
      return 'proses_pembayaran';
    }
    if (s.contains('dibayar') || s.contains('lunas')) {
      return 'telah_dibayar';
    }
    return 'lainnya';
  }
}

class ManagerDashboardOrderLog {
  String? status;
  String? note;
  String? createdAt;

  ManagerDashboardOrderLog({this.status, this.note, this.createdAt});

  factory ManagerDashboardOrderLog.fromJson(Map<String, dynamic> json) {
    return ManagerDashboardOrderLog(
      status: json['status']?.toString(),
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class ManagerProductItem {
  int? id;
  String? name;
  String? productCode;
  int? qty;
  double? price;
  ManagerProductCategory? category;
  ManagerProductSeller? seller;
  List<ManagerProductImage>? images;

  ManagerProductItem({
    this.id,
    this.name,
    this.productCode,
    this.qty,
    this.price,
    this.category,
    this.seller,
    this.images,
  });

  factory ManagerProductItem.fromJson(Map<String, dynamic> json) {
    return ManagerProductItem(
      id: json['id'],
      name: json['name']?.toString(),
      productCode: json['product_code']?.toString(),
      qty: json['qty'] is int ? json['qty'] : int.tryParse(json['qty']?.toString() ?? '0'),
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      category: json['category'] != null
          ? ManagerProductCategory.fromJson(json['category'])
          : null,
      seller: json['seller'] != null
          ? ManagerProductSeller.fromJson(json['seller'])
          : null,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((i) => ManagerProductImage.fromJson(i))
              .toList()
          : null,
    );
  }

  String? get primaryImageUrl {
    if (images != null && images!.isNotEmpty) {
      return images!.first.imgUrl;
    }
    return null;
  }
}

class ManagerProductCategory {
  int? id;
  String? name;

  ManagerProductCategory({this.id, this.name});

  factory ManagerProductCategory.fromJson(Map<String, dynamic> json) {
    return ManagerProductCategory(
      id: json['id'],
      name: json['name']?.toString(),
    );
  }
}

class ManagerProductSeller {
  int? id;
  String? companyName;
  String? phone;
  String? addressDetail;
  String? cityName;

  ManagerProductSeller({
    this.id,
    this.companyName,
    this.phone,
    this.addressDetail,
    this.cityName,
  });

  factory ManagerProductSeller.fromJson(Map<String, dynamic> json) {
    return ManagerProductSeller(
      id: json['id'],
      companyName: json['company_name']?.toString(),
      phone: json['phone']?.toString(),
      addressDetail: json['address_detail']?.toString(),
      cityName: json['city_name']?.toString(),
    );
  }
}

class ManagerProductImage {
  int? id;
  String? imgUrl;

  ManagerProductImage({this.id, this.imgUrl});

  factory ManagerProductImage.fromJson(Map<String, dynamic> json) {
    return ManagerProductImage(
      id: json['id'],
      imgUrl: json['img_url']?.toString(),
    );
  }
}
