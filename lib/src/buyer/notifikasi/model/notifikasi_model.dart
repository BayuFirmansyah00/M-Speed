/// Model Notifikasi — disesuaikan dengan Laravel `LogActivityResource`.
///
/// Laravel `GET /api/log-activities` response:
/// ```json
/// {
///   "data": [
///     {
///       "id": 1051,
///       "type": "order_status_change",
///       "target": { "table": "parent_orders", "subject_id": 124 },
///       "payload_properties": { ... },
///       "message": "Pesanan 0117/SPS/M-Speed/24 berhasil dikirim",
///       "actor": { "user_id": 5, "name": "...", "email": "..." },
///       "timestamp": "2024-09-03T10:26:44+00:00"
///     }
///   ]
/// }
/// ```
///
/// POST Mark read: `POST /api/log-activities/mark-read`
/// POST Mark all read: `POST /api/log-activities/mark-all-read`

class NotifikasiModelData {
  String? id;
  String? type;

  /// Waktu kejadian (dari field `timestamp` di LogActivityResource)
  String? timestamp;

  /// Pesan notifikasi (dari field `message`)
  String? message;

  /// ID order terkait (dari `target.subject_id` jika `target.table` = `parent_orders`)
  String? parentOrderId;

  /// Tabel subject (dari `target.table`)
  String? targetTable;

  /// Properties tambahan dari payload (JSON object)
  Map<String, dynamic>? payloadProperties;

  /// Info aktor yang memicu aktivitas
  String? actorName;

  NotifikasiModelData({
    this.id,
    this.type,
    this.timestamp,
    this.message,
    this.parentOrderId,
    this.targetTable,
    this.payloadProperties,
    this.actorName,
  });

  NotifikasiModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    type = json['type']?.toString();

    // Format baru (LogActivityResource)
    timestamp = json['timestamp']?.toString();
    message = json['message']?.toString();

    final target = json['target'];
    if (target != null) {
      targetTable = target['table']?.toString();
      parentOrderId = target['subject_id']?.toString();
    }

    final actor = json['actor'];
    if (actor != null) {
      actorName = actor['name']?.toString();
    }

    if (json['payload_properties'] is Map) {
      payloadProperties = Map<String, dynamic>.from(json['payload_properties']);
    }

    // Fallback format lama
    if (timestamp == null) {
      timestamp = json['activity_at']?.toString();
    }
    if (message == null) {
      message = json['activity_message']?.toString() ?? json['pesan']?.toString();
    }
    if (parentOrderId == null) {
      parentOrderId = json['parent_order_id']?.toString();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['timestamp'] = timestamp;
    data['message'] = message;
    data['target'] = {
      'table': targetTable,
      'subject_id': parentOrderId,
    };
    data['actor'] = {'name': actorName};
    return data;
  }

  // ─── Backward compatibility getters ───
  // Digunakan oleh view yang masih pakai field lama

  /// Getter: waktu aktivitas (compat lama: `activity_at`)
  String? get activityAt => timestamp;

  /// Getter: pesan aktivitas (compat lama: `activity_message`)
  String? get activityMessage => message;

  /// Getter: pesan pendek (compat lama: `pesan`)
  String? get pesan => message;

  /// Getter: judul notifikasi — diambil dari `type` atau `payloadProperties`
  String? get judul {
    if (payloadProperties != null && payloadProperties!.containsKey('title')) {
      return payloadProperties!['title']?.toString();
    }
    // Fallback: format type menjadi label yang dibaca
    return type?.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  /// Getter: foto produk (tidak ada di LogActivityResource — kosong)
  String? get foto => payloadProperties?['photo']?.toString();

  /// Getter: apakah sudah dibaca (tidak ada field is_read di LogActivityResource)
  /// Gunakan `type == "read"` atau `payloadProperties['is_read']`
  String? get isRead => payloadProperties?['is_read']?.toString();

  /// Getter: nomor order referensi (compat lama: `activity_fk_number`)
  String? get activityFkNumber =>
      payloadProperties?['order_number']?.toString();
}

class NotifikasiModel {
  String? result;
  List<NotifikasiModelData?>? data;

  NotifikasiModel({
    this.result,
    this.data,
  });

  NotifikasiModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString() ?? 'success';
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <NotifikasiModelData>[];
      v.forEach((v) {
        arr0.add(NotifikasiModelData.fromJson(v));
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
