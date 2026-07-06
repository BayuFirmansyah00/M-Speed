import 'package:intl/intl.dart';

String convertBulan(int angkaBulan) {
  List<String> listBulan = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];
  return listBulan[angkaBulan - 1];
}

String convertTglIndo(String date) {
  date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
  final datted = date.split('-');
  return "${datted[0]} ${convertBulan(int.parse(datted[1]))} ${datted[2]}";
}

String convertTglCombine(String date) =>
    DateFormat('yyyyMMddHHmmss').format(DateTime.parse(date));

String convertTglIndoShortMonth(String date) =>
    DateFormat('dd MMM yyyy').format(DateTime.parse(date));

String convertTglGarisMiring(String date) =>
    DateFormat('dd/MM/yyyy').format(DateTime.parse(date));

String convertTglGarisStrip(String date) =>
    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));

String convertJamDurasi(String date, String date2) {
  date = DateFormat.Hm().format(DateTime.parse(date));
  date2 = DateFormat.Hm().format(DateTime.parse(date2));
  return "$date-$date2";
}

String convertJamMenit(String date) =>
    DateFormat.Hm().format(DateTime.parse(date));

String convertJam(String date) => DateFormat.H().format(DateTime.parse(date));
