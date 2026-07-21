class DaftarTransaksiBuyerModelDataDetail {
  String? ID;
  String? nama;
  String? harga;
  String? kodeProduk;
  String? size;
  String? deskripsi;
  String? SellerID;
  String? hapus;
  String? foto;
  String? IDKategori;
  String? SellerNama;
  String? noRek;
  String? qty;
  String? hargaAkhir;
  String? diterima;
  String? dikomplain;
  String? komplain;
  String? IDOrder;

  DaftarTransaksiBuyerModelDataDetail({
    this.ID,
    this.nama,
    this.harga,
    this.kodeProduk,
    this.size,
    this.deskripsi,
    this.SellerID,
    this.hapus,
    this.foto,
    this.IDKategori,
    this.SellerNama,
    this.noRek,
    this.qty,
    this.hargaAkhir,
    this.diterima,
    this.dikomplain,
    this.komplain,
    this.IDOrder,
  });

  DaftarTransaksiBuyerModelDataDetail.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('product_snapshot')) {
      // Format Baru (Laravel REST API - ChildOrder)
      ID = json['id']?.toString();
      nama = json['product_snapshot']?['name']?.toString();
      harga = json['product_snapshot']?['price']?.toString();
      qty = json['quantity']?.toString();
      hargaAkhir = json['subtotal']?.toString();
      IDOrder = json['parent_order_id']?.toString();
      foto = json['product_snapshot']?['photo']?.toString() ?? json['product_snapshot']?['image']?.toString();
      deskripsi = json['product_snapshot']?['description']?.toString();
      diterima = json['status']?.toString(); // Atau map logic lainnya
    } else {
      // Format Lama
      ID = json['ID']?.toString();
      nama = json['nama']?.toString();
      harga = json['harga']?.toString();
      kodeProduk = json['kode_produk']?.toString();
      size = json['size']?.toString();
      deskripsi = json['deskripsi']?.toString();
      SellerID = json['SellerID']?.toString();
      hapus = json['hapus']?.toString();
      foto = json['foto']?.toString();
      IDKategori = json['IDKategori']?.toString();
      SellerNama = json['SellerNama']?.toString();
      noRek = json['no_rek']?.toString();
      qty = json['qty']?.toString();
      hargaAkhir = json['harga_akhir']?.toString();
      diterima = json['diterima']?.toString();
      dikomplain = json['dikomplain']?.toString();
      komplain = json['komplain']?.toString();
      IDOrder = json['IDOrder']?.toString();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ID'] = ID;
    data['nama'] = nama;
    data['harga'] = harga;
    data['kode_produk'] = kodeProduk;
    data['size'] = size;
    data['deskripsi'] = deskripsi;
    data['SellerID'] = SellerID;
    data['hapus'] = hapus;
    data['foto'] = foto;
    data['IDKategori'] = IDKategori;
    data['SellerNama'] = SellerNama;
    data['no_rek'] = noRek;
    data['qty'] = qty;
    data['harga_akhir'] = hargaAkhir;
    data['diterima'] = diterima;
    data['dikomplain'] = dikomplain;
    data['komplain'] = komplain;
    data['IDOrder'] = IDOrder;
    return data;
  }
}

class DaftarTransaksiBuyerModelData {
  String? ID;
  String? Created;
  String? Updated;
  String? nomorOrder;
  String? subtotal;
  String? pajak;
  String? ongkir;
  String? total;
  String? BuyerID;
  String? SellerID;
  String? nama;
  String? alamat;
  String? telp;
  String? status;
  String? PengajuanID;
  String? keterangan;
  String? bukti;
  String? penerimaID;
  String? penerimaStr;
  String? keuanganID;
  String? keuanganStr;
  String? estPengiriman;
  String? estPengiriman2;
  String? nomorInvoice;
  String? nomorSuratjalan;
  String? nomorKwitansi;
  String? readStatus;
  String? tglTtdKwitansi;
  String? tglTtdSuratPesanan;
  String? tglTtdSuratJalan;
  String? tglTtdInvoice;
  String? jum;
  String? SellerNama;
  List<DaftarTransaksiBuyerModelDataDetail?>? detail;

  DaftarTransaksiBuyerModelData({
    this.ID,
    this.Created,
    this.Updated,
    this.nomorOrder,
    this.subtotal,
    this.pajak,
    this.ongkir,
    this.total,
    this.BuyerID,
    this.SellerID,
    this.nama,
    this.alamat,
    this.telp,
    this.status,
    this.PengajuanID,
    this.keterangan,
    this.bukti,
    this.penerimaID,
    this.penerimaStr,
    this.keuanganID,
    this.keuanganStr,
    this.estPengiriman,
    this.estPengiriman2,
    this.nomorInvoice,
    this.nomorSuratjalan,
    this.nomorKwitansi,
    this.readStatus,
    this.tglTtdKwitansi,
    this.tglTtdSuratPesanan,
    this.tglTtdSuratJalan,
    this.tglTtdInvoice,
    this.jum,
    this.SellerNama,
    this.detail,
  });

  DaftarTransaksiBuyerModelData.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('order_number')) {
      // Format Baru (Laravel REST API - ParentOrderResource)
      ID = json['id']?.toString();
      Created = json['created_at']?.toString();
      Updated = json['updated_at']?.toString();
      nomorOrder = json['order_number']?.toString();
      nomorInvoice = json['receipt_number']?.toString();
      status = json['payment_status']?.toString(); // TODO: Mapped ke status UI
      
      ongkir = json['shipping']?['cost']?.toString() ?? "0";
      estPengiriman = json['shipping']?['estimated_start']?.toString();
      estPengiriman2 = json['shipping']?['estimated_end']?.toString();
      
      SellerID = json['seller_snapshot']?['id']?.toString();
      SellerNama = json['seller_snapshot']?['name']?.toString();
      
      BuyerID = json['actors_snapshot']?['buyer']?['id']?.toString();
      
      penerimaID = json['actors_snapshot']?['recipient']?['id']?.toString();
      penerimaStr = json['actors_snapshot']?['recipient']?['name']?.toString();
      nama = json['actors_snapshot']?['recipient']?['name']?.toString();
      alamat = json['actors_snapshot']?['recipient']?['address']?.toString();
      telp = json['actors_snapshot']?['recipient']?['phone']?.toString();
      
      keuanganID = json['actors_snapshot']?['finance']?['id']?.toString();
      keuanganStr = json['actors_snapshot']?['finance']?['name']?.toString();

      if (json['children'] != null) {
        final v = json['children'];
        final arr0 = <DaftarTransaksiBuyerModelDataDetail>[];
        v.forEach((v) {
          arr0.add(DaftarTransaksiBuyerModelDataDetail.fromJson(v));
        });
        detail = arr0;
      }
    } else {
      // Format Lama
      ID = json['ID']?.toString();
      Created = json['Created']?.toString();
      Updated = json['Updated']?.toString();
      nomorOrder = json['nomor_order']?.toString();
      subtotal = json['subtotal']?.toString();
      pajak = json['pajak']?.toString();
      ongkir = json['ongkir']?.toString();
      total = json['total']?.toString();
      BuyerID = json['BuyerID']?.toString();
      SellerID = json['SellerID']?.toString();
      nama = json['nama']?.toString();
      alamat = json['alamat']?.toString();
      telp = json['telp']?.toString();
      status = json['status']?.toString();
      PengajuanID = json['PengajuanID']?.toString();
      keterangan = json['keterangan']?.toString();
      bukti = json['bukti']?.toString();
      penerimaID = json['penerimaID']?.toString();
      penerimaStr = json['penerimaStr']?.toString();
      keuanganID = json['keuanganID']?.toString();
      keuanganStr = json['keuanganStr']?.toString();
      estPengiriman = json['estPengiriman']?.toString();
      estPengiriman2 = json['estPengiriman2']?.toString();
      nomorInvoice = json['nomor_invoice']?.toString();
      nomorSuratjalan = json['nomor_suratjalan']?.toString();
      nomorKwitansi = json['nomor_kwitansi']?.toString();
      readStatus = json['read_status']?.toString();
      tglTtdKwitansi = json['tgl_ttd_kwitansi']?.toString();
      tglTtdSuratPesanan = json['tgl_ttd_surat_pesanan']?.toString();
      tglTtdSuratJalan = json['tgl_ttd_surat_jalan']?.toString();
      tglTtdInvoice = json['tgl_ttd_invoice']?.toString();
      jum = json['jum']?.toString();
      SellerNama = json['SellerNama']?.toString();
      if (json['detail'] != null) {
        final v = json['detail'];
        final arr0 = <DaftarTransaksiBuyerModelDataDetail>[];
        v.forEach((v) {
          arr0.add(DaftarTransaksiBuyerModelDataDetail.fromJson(v));
        });
        detail = arr0;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ID'] = ID;
    data['Created'] = Created;
    data['Updated'] = Updated;
    data['nomor_order'] = nomorOrder;
    data['subtotal'] = subtotal;
    data['pajak'] = pajak;
    data['ongkir'] = ongkir;
    data['total'] = total;
    data['BuyerID'] = BuyerID;
    data['SellerID'] = SellerID;
    data['nama'] = nama;
    data['alamat'] = alamat;
    data['telp'] = telp;
    data['status'] = status;
    data['PengajuanID'] = PengajuanID;
    data['keterangan'] = keterangan;
    data['bukti'] = bukti;
    data['penerimaID'] = penerimaID;
    data['penerimaStr'] = penerimaStr;
    data['keuanganID'] = keuanganID;
    data['keuanganStr'] = keuanganStr;
    data['estPengiriman'] = estPengiriman;
    data['estPengiriman2'] = estPengiriman2;
    data['nomor_invoice'] = nomorInvoice;
    data['nomor_suratjalan'] = nomorSuratjalan;
    data['nomor_kwitansi'] = nomorKwitansi;
    data['read_status'] = readStatus;
    data['tgl_ttd_kwitansi'] = tglTtdKwitansi;
    data['tgl_ttd_surat_pesanan'] = tglTtdSuratPesanan;
    data['tgl_ttd_surat_jalan'] = tglTtdSuratJalan;
    data['tgl_ttd_invoice'] = tglTtdInvoice;
    data['jum'] = jum;
    data['SellerNama'] = SellerNama;
    if (detail != null) {
      final v = detail;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['detail'] = arr0;
    }
    return data;
  }
}

class DaftarTransaksiBuyerModel {
  String? result;
  List<DaftarTransaksiBuyerModelData?>? data;

  DaftarTransaksiBuyerModel({
    this.result,
    this.data,
  });

  DaftarTransaksiBuyerModel.fromJson(Map<String, dynamic> json) {
    result = json['result']?.toString() ?? 'success';
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <DaftarTransaksiBuyerModelData>[];
      v.forEach((v) {
        arr0.add(DaftarTransaksiBuyerModelData.fromJson(v));
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
