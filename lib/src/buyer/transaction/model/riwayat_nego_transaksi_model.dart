/// Model Riwayat Nego Transaksi — disesuaikan dengan Laravel `NegoResource`.
///
/// Laravel `GET /api/negos?product_id={id}` response:
/// ```json
/// {
///   "data": [
///     {
///       "id": 1,
///       "value": 450000,
///       "cart": {
///         "id": 10,
///         "qty": 2,
///         "initial_price": 500000,
///         "final_price": 450000,
///         "product": { "id": 5, "name": "BOR LISTRIK" },
///         "buyer": { "id": 3, "name": "Budi Santoso" }
///       },
///       "created_at": "...",
///       "updated_at": "..."
///     }
///   ]
/// }
/// ```
class RiwayatNegoTransaksiModelData {
  int? id;

  /// Nilai tawaran nego (dari field `value` di NegoResource)
  String? value;

  /// Harga awal / initial_price dari cart
  String? initialPrice;

  /// Harga final / final_price dari cart
  String? finalPrice;

  /// Nama produk yang dinego
  String? productName;

  /// Status nego (cart.nego_status jika ada)
  String? negoStatus;

  RiwayatNegoTransaksiModelData({
    this.id,
    this.value,
    this.initialPrice,
    this.finalPrice,
    this.productName,
    this.negoStatus,
  });

  RiwayatNegoTransaksiModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toInt();

    // Format baru (NegoResource)
    value = json['value']?.toString();

    final cart = json['cart'];
    if (cart != null) {
      initialPrice = cart['initial_price']?.toString();
      finalPrice = cart['final_price']?.toString();
      productName = cart['product']?['name']?.toString();
      negoStatus = cart['nego_status']?.toString();
    } else {
      // Fallback format lama
      initialPrice = json['harga_awal']?.toString();
      value = json['nego']?.toString() ?? value;
      negoStatus = json['status']?.toString();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['value'] = value;
    data['cart'] = {
      'initial_price': initialPrice,
      'final_price': finalPrice,
      'product': {'name': productName},
    };
    return data;
  }

  // ─── Backward compatibility getters ───
  // Digunakan oleh `detail_transaction_view.dart`

  /// Getter: harga awal (untuk UI label harga sebelum nego)
  String? get hargaAwal => initialPrice;

  /// Getter: nilai tawaran nego (ditampilkan di UI sebagai harga nego)
  String? get nego => value ?? finalPrice;

  /// Getter: status nego
  String? get status => negoStatus;
}

class RiwayatNegoTransaksiModel {
  String? result;
  List<RiwayatNegoTransaksiModelData?>? data;

  RiwayatNegoTransaksiModel({
    this.result,
    this.data,
  });

  RiwayatNegoTransaksiModel.fromJson(Map<String, dynamic> json) {
    // Support format baru (Laravel ResourceCollection: { "data": [...] })
    // dan format lama ({ "result": "success", "data": [...] })
    result = json['result']?.toString() ?? 'success';
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <RiwayatNegoTransaksiModelData>[];
      v.forEach((v) {
        arr0.add(RiwayatNegoTransaksiModelData.fromJson(v));
      });
      this.data = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['result'] = result;
    if (this.data != null) {
      final v = this.data;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['data'] = arr0;
    }
    return data;
  }
}
