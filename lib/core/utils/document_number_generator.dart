/// Utility untuk membuat nomor dokumen (invoice/PO) otomatis berformat
/// "PREFIX/DDMMYY/XXXX" — nomor urut 4 digit yang reset setiap hari
/// mengikuti tanggal transaksi (bukan tanggal disimpan).
class DocumentNumberGenerator {
  /// Bangun awalan nomor dokumen untuk tanggal tertentu, contoh:
  /// buildPrefix('MSD/INV', tanggal 5 Jan 2026) -> "MSD/INV/050126/"
  static String buildPrefix(String prefix, DateTime date) {
    final ddmmyy = "${date.day.toString().padLeft(2, '0')}"
        "${date.month.toString().padLeft(2, '0')}"
        "${(date.year % 100).toString().padLeft(2, '0')}";
    return '$prefix/$ddmmyy/';
  }

  /// Cari nomor urut berikutnya berdasarkan nomor-nomor yang sudah ada
  /// dengan awalan yang sama. Pakai nilai urut TERBESAR + 1 (bukan jumlah
  /// data), supaya tetap aman/tidak bentrok walau ada nomor yang sudah dihapus.
  static String next(String fullPrefix, List<String> existingNumbersWithSamePrefix) {
    int maxSeq = 0;
    for (final number in existingNumbersWithSamePrefix) {
      if (!number.startsWith(fullPrefix)) continue;
      final seq = int.tryParse(number.substring(fullPrefix.length));
      if (seq != null && seq > maxSeq) maxSeq = seq;
    }
    return '$fullPrefix${(maxSeq + 1).toString().padLeft(4, '0')}';
  }
}
