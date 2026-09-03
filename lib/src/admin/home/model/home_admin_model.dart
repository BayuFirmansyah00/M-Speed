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
  int finance;
  int manager;
  int audit;
  int direksi;

  UserCountDetail({
    this.buyer = 0,
    this.seller = 0,
    this.receiver = 0,
    this.finance = 0,
    this.manager = 0,
    this.audit = 0,
    this.direksi = 0,
  });

  factory UserCountDetail.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserCountDetail();
    return UserCountDetail(
      buyer: int.tryParse(json['buyer']?.toString() ?? json['buyer_count']?.toString() ?? '0') ?? 0,
      seller: int.tryParse(json['seller']?.toString() ?? json['seller_count']?.toString() ?? '0') ?? 0,
      receiver: int.tryParse(json['receiver']?.toString() ?? json['penerima']?.toString() ?? json['receiver_count']?.toString() ?? '0') ?? 0,
      finance: int.tryParse(json['finance']?.toString() ?? json['keuangan']?.toString() ?? json['finance_count']?.toString() ?? '0') ?? 0,
      manager: int.tryParse(json['manager']?.toString() ?? json['manager_count']?.toString() ?? '0') ?? 0,
      audit: int.tryParse(json['audit']?.toString() ?? json['audit_count']?.toString() ?? '0') ?? 0,
      direksi: int.tryParse(json['direksi']?.toString() ?? json['direksi_count']?.toString() ?? '0') ?? 0,
    );
  }

  int get total => buyer + seller + receiver + finance + manager + audit + direksi;
}

class UserStatistics {
  UserCountDetail activeUsers;
  UserCountDetail inactiveUsers;

  UserStatistics({UserCountDetail? activeUsers, UserCountDetail? inactiveUsers})
    : activeUsers = activeUsers ?? UserCountDetail(),
      inactiveUsers = inactiveUsers ?? UserCountDetail();

  factory UserStatistics.fromJson(Map<String, dynamic>? json, [Map<String, dynamic>? listPerType]) {
    final active = UserCountDetail.fromJson(json?['active_users']);
    final inactive = UserCountDetail.fromJson(json?['inactive_users']);

    if (listPerType != null) {
      if (active.buyer == 0 && listPerType['buyer_aktif'] is List) {
        active.buyer = (listPerType['buyer_aktif'] as List).length;
      }
      if (active.seller == 0 && listPerType['seller_aktif'] is List) {
        active.seller = (listPerType['seller_aktif'] as List).length;
      }
      if (active.receiver == 0 && listPerType['penerima_aktif'] is List) {
        active.receiver = (listPerType['penerima_aktif'] as List).length;
      }
      if (inactive.buyer == 0 && listPerType['buyer_nonaktif'] is List) {
        inactive.buyer = (listPerType['buyer_nonaktif'] as List).length;
      }
      if (inactive.seller == 0 && listPerType['seller_nonaktif'] is List) {
        inactive.seller = (listPerType['seller_nonaktif'] as List).length;
      }
      if (inactive.receiver == 0 && listPerType['penerima_nonaktif'] is List) {
        inactive.receiver = (listPerType['penerima_nonaktif'] as List).length;
      }
    }

    return UserStatistics(
      activeUsers: active,
      inactiveUsers: inactive,
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
  double totalShippingCost;

  PurchaseStatistics({
    this.totalItemsBought = 0,
    this.totalNominalBought = 0.0,
    this.totalOrders = 0,
    this.totalShippingCost = 0.0,
  });

  factory PurchaseStatistics.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PurchaseStatistics();
    return PurchaseStatistics(
      totalItemsBought: int.tryParse(json['total_items_bought']?.toString() ?? json['total_items']?.toString() ?? '0') ?? 0,
      totalNominalBought: double.tryParse(json['total_nominal_bought']?.toString() ?? json['total_nominal']?.toString() ?? '0') ?? 0.0,
      totalOrders: int.tryParse(json['total_orders']?.toString() ?? json['orders']?.toString() ?? '0') ?? 0,
      totalShippingCost: double.tryParse(json['total_shipping_cost']?.toString() ?? json['shipping_cost']?.toString() ?? '0') ?? 0.0,
    );
  }
}

// ── Order Status Monitoring ────────────────────────────────────────────────

class OrderStatusMonitoring {
  int pesananBaru;
  int approveManager;
  int notApproveManager;
  int pesananDikirim;
  int pesananDiterima;
  int tagihan;
  int siapTagihManager;
  int penerimaanVerifikasi;
  int pesananDibayar;

  OrderStatusMonitoring({
    this.pesananBaru = 0,
    this.approveManager = 0,
    this.notApproveManager = 0,
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
      pesananBaru: int.tryParse(json['pesanan_baru']?.toString() ?? '0') ?? 0,
      approveManager: int.tryParse(json['approve_manager']?.toString() ?? '0') ?? 0,
      notApproveManager: int.tryParse(json['not_approve_manager']?.toString() ?? '0') ?? 0,
      pesananDikirim: int.tryParse(json['pesanan_dikirim']?.toString() ?? '0') ?? 0,
      pesananDiterima: int.tryParse(json['pesanan_diterima']?.toString() ?? '0') ?? 0,
      tagihan: int.tryParse(json['tagihan']?.toString() ?? '0') ?? 0,
      siapTagihManager: int.tryParse(json['siap_tagih_manager']?.toString() ?? '0') ?? 0,
      penerimaanVerifikasi: int.tryParse(json['penerimaan_verifikasi']?.toString() ?? '0') ?? 0,
      pesananDibayar: int.tryParse(json['pesanan_dibayar']?.toString() ?? '0') ?? 0,
    );
  }

  int get total =>
      pesananBaru +
      approveManager +
      notApproveManager +
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
        productName: json['product_name']?.toString() ?? json['nama_produk']?.toString() ?? json['name']?.toString() ?? '',
        totalSold: int.tryParse(json['total_sold']?.toString() ?? json['total_penjualan']?.toString() ?? json['qty']?.toString() ?? '0') ?? 0,
        totalRevenue: double.tryParse(json['total_revenue']?.toString() ?? json['total_pendapatan']?.toString() ?? json['total_nominal']?.toString() ?? '0') ?? 0.0,
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
        buyerId: int.tryParse(json['buyer_id']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
        buyerName: json['buyer_name']?.toString() ?? json['name']?.toString() ?? json['nama_buyer']?.toString() ?? '',
        totalTransactions: int.tryParse(json['total_transactions']?.toString() ?? json['total_order']?.toString() ?? json['total_pesanan']?.toString() ?? '0') ?? 0,
        totalSpent: double.tryParse(json['total_spent']?.toString() ?? json['total_nominal']?.toString() ?? json['total_belanja']?.toString() ?? '0') ?? 0.0,
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
        sellerId: int.tryParse(json['seller_id']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
        sellerName: json['seller_name']?.toString() ?? json['name']?.toString() ?? json['nama_seller']?.toString() ?? '',
        sellerCompanyName: json['seller_company_name']?.toString() ?? json['nama_perusahaan']?.toString() ?? json['company_name']?.toString() ?? '',
        totalSalesOrders: int.tryParse(json['total_sales_orders']?.toString() ?? json['total_order']?.toString() ?? json['total_penjualan']?.toString() ?? '0') ?? 0,
        totalRevenue: double.tryParse(json['total_revenue']?.toString() ?? json['total_nominal']?.toString() ?? json['total_pendapatan']?.toString() ?? '0') ?? 0.0,
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
  }) : products = products ?? [],
       buyers = buyers ?? [],
       sellers = sellers ?? [];

  factory TopRankings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TopRankings();
    return TopRankings(
      products: (json['products'] as List? ?? [])
          .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      buyers: (json['buyers'] as List? ?? [])
          .map((e) => TopBuyer.fromJson(e as Map<String, dynamic>))
          .toList(),
      sellers: (json['sellers'] as List? ?? [])
          .map((e) => TopSeller.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Root Model ─────────────────────────────────────────────────────────────

class HomeAdminModel {
  // Aliases for UI compatibility
  int get totalUser => userStatistics.inactiveUsers.total;
  int get totalSeller => userStatistics.inactiveUsers.seller;
  int get totalBuyer => userStatistics.inactiveUsers.buyer;
  int get totalFinance => userStatistics.inactiveUsers.finance;
  int get totalPenerima => userStatistics.inactiveUsers.receiver;
  int get totalManager => userStatistics.inactiveUsers.manager;
  int get totalAudit => userStatistics.inactiveUsers.audit;
  int get totalDireksi => userStatistics.inactiveUsers.direksi;

  int getTotalUser([bool activeOnly = false]) =>
      activeOnly ? userStatistics.activeUsers.total : userStatistics.inactiveUsers.total;
  int getTotalSeller([bool activeOnly = false]) =>
      activeOnly ? userStatistics.activeUsers.seller : userStatistics.inactiveUsers.seller;
  int getTotalBuyer([bool activeOnly = false]) =>
      activeOnly ? userStatistics.activeUsers.buyer : userStatistics.inactiveUsers.buyer;
  int getTotalFinance([bool activeOnly = false]) =>
      activeOnly ? userStatistics.activeUsers.finance : userStatistics.inactiveUsers.finance;
  int getTotalPenerima([bool activeOnly = false]) =>
      activeOnly ? userStatistics.activeUsers.receiver : userStatistics.inactiveUsers.receiver;
  int getTotalManager([bool activeOnly = false]) =>
      activeOnly ? userStatistics.activeUsers.manager : userStatistics.inactiveUsers.manager;
  int getTotalAudit([bool activeOnly = false]) =>
      activeOnly ? userStatistics.activeUsers.audit : userStatistics.inactiveUsers.audit;
  int getTotalDireksi([bool activeOnly = false]) =>
      activeOnly ? userStatistics.activeUsers.direksi : userStatistics.inactiveUsers.direksi;

  List<dynamic> get tbuyer => topRankings.buyers;
  List<dynamic> get tseller => topRankings.sellers;
  List<dynamic> get tproduk => topRankings.products;

  UserStatistics userStatistics;
  PurchaseStatistics purchaseStatistics;
  OrderStatusMonitoring orderStatusMonitoring;
  TopRankings topRankings;

  HomeAdminModel({
    UserStatistics? userStatistics,
    PurchaseStatistics? purchaseStatistics,
    OrderStatusMonitoring? orderStatusMonitoring,
    TopRankings? topRankings,
  }) : userStatistics = userStatistics ?? UserStatistics(),
       purchaseStatistics = purchaseStatistics ?? PurchaseStatistics(),
       orderStatusMonitoring = orderStatusMonitoring ?? OrderStatusMonitoring(),
       topRankings = topRankings ?? TopRankings();

  factory HomeAdminModel.fromJson(Map<String, dynamic> json) {
    // response dibalut dalam { "data": { ... } }
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    return HomeAdminModel(
      userStatistics: UserStatistics.fromJson(
        data['user_statistics'] as Map<String, dynamic>?,
        data['user_list_per_type'] as Map<String, dynamic>?,
      ),
      purchaseStatistics: PurchaseStatistics.fromJson(
        data['purchase_statistics'] as Map<String, dynamic>?,
      ),
      orderStatusMonitoring: OrderStatusMonitoring.fromJson(
        data['order_status_monitoring'] as Map<String, dynamic>?,
      ),
      topRankings: TopRankings.fromJson(
        data['top_rankings'] as Map<String, dynamic>?,
      ),
    );
  }
}


