enum TransactionStatus {
  PESANAN_BARU('PESANAN_BARU', 1),
  PESANAN_DITERIMA('PESANAN_DITERIMA', 2),
  PESANAN_DIKIRIM('PESANAN_DIKIRIM', 3),
  PESANAN_TELAH_DITERIMA('PESANAN_TELAH_DITERIMA', -1),
  BARANG_DITERIMA('BARANG_DITERIMA', 4),
  PROSES_PEMBAYARAN('PROSES_PEMBAYARAN', 5),
  TELAH_DIBAYAR('TELAH_DIBAYAR', 6),
  PESANAN_DITOLAK('PESANAN_DITOLAK', -1);

  final String status;
  final int indexStatus;
  const TransactionStatus(this.status, this.indexStatus);

  String statusName() => status.replaceAll('_', ' ');

  static TransactionStatus fromString(String status) {
    TransactionStatus? value;
    TransactionStatus.values.forEach((element) {
      if (element.status == status) {
        value = element;
      }
    });

    return value ?? TransactionStatus.PESANAN_BARU;
  }

  @override
  String toString() {
    return status;
  }
}
