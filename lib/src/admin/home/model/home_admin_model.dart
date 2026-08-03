/// Model untuk response dari endpoint GET /api/v1/admin/dashboard
///
/// JSON Structure dari AdminDashboardResource:
/// ```json
/// {
///   "data": {
///     "user_statistics": {
///       "active_users":  { "buyer": 0, "seller": 0, "receiver": 0 },
///       "inactive_users": { "buyer": 0, "seller": 0, "receiver": 0 }
///     },
///     "purchase_statistics": {
///       "total_items_bought": 0,
///       "total_nominal_bought": 0.0,
///       "total_orders": 0
///     },
///     "order_status_monitoring": {
///       "pesanan_baru": 0, "approve_manager": 0,
///       "pesanan_dikirim": 0, "pesanan_diterima": 0,
///       "tagihan": 0, "siap_tagih_manager": 0,
///       "penerimaan_verifikasi": 0, "pesanan_dibayar": 0
///     },
///     "top_rankings": {
///       "products": [ { "product_name": "", "total_sold": 0, "total_revenue": 0 } ],
///       "buyers":   [ { "buyer_id": 0, "buyer_name": "", "total_transactions": 0, "total_spent": 0 } ],
///       "sellers":  [ { "seller_id": 0, "seller_name": "", "seller_company_name": "", "total_sales_orders": 0, "total_revenue": 0 } ]
///     }
///   }
/// }
/// ```

// ── User Statistics ────────────────────────────────────────────────────────

class UserCountDetail {
  int buyer;
  int seller;
  int receiver;

  UserCountDetail({this.buyer = 0, this.seller = 0, this.receiver = 0});

  factory UserCountDetail.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserCountDetail();
    return UserCountDetail(
      buyer: json['buyer'] ?? 0,
      seller: json['seller'] ?? 0,
      receiver: json['receiver'] ?? 0,
    );
  }

  int get total => buyer + seller + receiver;
}

class UserStatistics {
  UserCountDetail activeUsers;
  UserCountDetail inactiveUsers;

  UserStatistics({
    UserCountDetail? activeUsers,
    UserCountDetail? inactiveUsers,
  })  : activeUsers = activeUsers ?? UserCountDetail(),
        inactiveUsers = inactiveUsers ?? UserCountDetail();

  factory UserStatistics.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserStatistics();
    return UserStatistics(
      activeUsers: UserCountDetail.fromJson(json['active_users']),
      inactiveUsers: UserCountDetail.fromJson(json['inactive_users']),
    );
  }

  int get totalActive => activeUsers.total;
  int get totalInactive => inactiveUsers.total;
}

// ── Purchase Statistics ────────────────────────────────────────────────────

class PurchaseStatistics {
  int totalItemsBought;
  double totalNominalBought;
  int totalOrders;

  PurchaseStatistics({
    this.totalItemsBought = 0,
    this.totalNominalBought = 0.0,
    this.totalOrders = 0,
  });

  factory PurchaseStatistics.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PurchaseStatistics();
    return PurchaseStatistics(
      totalItemsBought: json['total_items_bought'] ?? 0,
      totalNominalBought: (json['total_nominal_bought'] ?? 0).toDouble(),
      totalOrders: json['total_orders'] ?? 0,
    );
  }
}

// ── Order Status Monitoring ────────────────────────────────────────────────

class OrderStatusMonitoring {
  int pesananBaru;
  int approveManager;
  int pesananDikirim;
  int pesananDiterima;
  int tagihan;
  int siapTagihManager;
  int penerimaanVerifikasi;
  int pesananDibayar;

  OrderStatusMonitoring({
    this.pesananBaru = 0,
    this.approveManager = 0,
    this.pesananDikirim = 0,
    this.pesananDiterima = 0,
    this.tagihan = 0,
    this.siapTagihManager = 0,
    this.penerimaanVerifikasi = 0,
    this.pesananDibayar = 0,
  });

  factory OrderStatusMonitoring.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OrderStatusMonitoring();
    return OrderStatusMonitoring(
      pesananBaru: json['pesanan_baru'] ?? 0,
      approveManager: json['approve_manager'] ?? 0,
      pesananDikirim: json['pesanan_dikirim'] ?? 0,
      pesananDiterima: json['pesanan_diterima'] ?? 0,
      tagihan: json['tagihan'] ?? 0,
      siapTagihManager: json['siap_tagih_manager'] ?? 0,
      penerimaanVerifikasi: json['penerimaan_verifikasi'] ?? 0,
      pesananDibayar: json['pesanan_dibayar'] ?? 0,
    );
  }

  int get total =>
      pesananBaru +
      approveManager +
      pesananDikirim +
      pesananDiterima +
      tagihan +
      siapTagihManager +
      penerimaanVerifikasi +
      pesananDibayar;
}

// ── Top Rankings ───────────────────────────────────────────────────────────

class TopProduct {
  String productName;
  int totalSold;
  double totalRevenue;

  TopProduct({
    this.productName = '',
    this.totalSold = 0,
    this.totalRevenue = 0.0,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
        productName: json['product_name']?.toString() ?? '',
        totalSold: json['total_sold'] ?? 0,
        totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      );
}

class TopBuyer {
  int buyerId;
  String buyerName;
  int totalTransactions;
  double totalSpent;

  TopBuyer({
    this.buyerId = 0,
    this.buyerName = '',
    this.totalTransactions = 0,
    this.totalSpent = 0.0,
  });

  factory TopBuyer.fromJson(Map<String, dynamic> json) => TopBuyer(
        buyerId: json['buyer_id'] ?? 0,
        buyerName: json['buyer_name']?.toString() ?? '',
        totalTransactions: json['total_transactions'] ?? 0,
        totalSpent: (json['total_spent'] ?? 0).toDouble(),
      );
}

class TopSeller {
  int sellerId;
  String sellerName;
  String sellerCompanyName;
  int totalSalesOrders;
  double totalRevenue;

  TopSeller({
    this.sellerId = 0,
    this.sellerName = '',
    this.sellerCompanyName = '',
    this.totalSalesOrders = 0,
    this.totalRevenue = 0.0,
  });

  factory TopSeller.fromJson(Map<String, dynamic> json) => TopSeller(
        sellerId: json['seller_id'] ?? 0,
        sellerName: json['seller_name']?.toString() ?? '',
        sellerCompanyName: json['seller_company_name']?.toString() ?? '',
        totalSalesOrders: json['total_sales_orders'] ?? 0,
        totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      );
}

class TopRankings {
  List<TopProduct> products;
  List<TopBuyer> buyers;
  List<TopSeller> sellers;

  TopRankings({
    List<TopProduct>? products,
    List<TopBuyer>? buyers,
    List<TopSeller>? sellers,
  })  : products = products ?? [],
        buyers = buyers ?? [],
        sellers = sellers ?? [];

  factory TopRankings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TopRankings();
    return TopRankings(
      products: (json['products'] as List? ?? [])
          .map((e) => TopProduct.fromJson(e))
          .toList(),
      buyers: (json['buyers'] as List? ?? [])
          .map((e) => TopBuyer.fromJson(e))
          .toList(),
      sellers: (json['sellers'] as List? ?? [])
          .map((e) => TopSeller.fromJson(e))
          .toList(),
    );
  }
}

// ── Root Model ─────────────────────────────────────────────────────────────

class HomeAdminModel {
  UserStatistics userStatistics;
  PurchaseStatistics purchaseStatistics;
  OrderStatusMonitoring orderStatusMonitoring;
  TopRankings topRankings;

  HomeAdminModel({
    UserStatistics? userStatistics,
    PurchaseStatistics? purchaseStatistics,
    OrderStatusMonitoring? orderStatusMonitoring,
    TopRankings? topRankings,
  })  : userStatistics = userStatistics ?? UserStatistics(),
        purchaseStatistics = purchaseStatistics ?? PurchaseStatistics(),
        orderStatusMonitoring =
            orderStatusMonitoring ?? OrderStatusMonitoring(),
        topRankings = topRankings ?? TopRankings();

  factory HomeAdminModel.fromJson(Map<String, dynamic> json) {
    // response dibalut dalam { "data": { ... } }
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return HomeAdminModel(
      userStatistics: UserStatistics.fromJson(data['user_statistics']),
      purchaseStatistics:
          PurchaseStatistics.fromJson(data['purchase_statistics']),
      orderStatusMonitoring:
          OrderStatusMonitoring.fromJson(data['order_status_monitoring']),
      topRankings: TopRankings.fromJson(data['top_rankings']),
    );
  }
}
