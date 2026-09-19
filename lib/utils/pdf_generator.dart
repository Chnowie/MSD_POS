import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:msd_pos/data/models/sale_transaction_model.dart';
import 'package:msd_pos/data/models/sale_item_model.dart';
import 'package:msd_pos/data/models/purchase_transaction_model.dart';
import 'package:msd_pos/data/models/purchase_item_model.dart';
import 'package:msd_pos/data/models/customer_model.dart';
import 'package:msd_pos/data/models/supplier_model.dart';
import 'package:msd_pos/data/models/item_model.dart';

class PdfGenerator {
  static final formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final formatDate = DateFormat('dd MMM yyyy');

  static Future<Uint8List> generateInvoice({
    required SaleTransactionModel transaction,
    required CustomerModel customer,
    required List<SaleItemModel> items,
    required Map<int, ItemModel> itemMap,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader('FAKTUR PENJUALAN', transaction.invoiceNumber,
                transaction.date),
            pw.SizedBox(height: 20),
            _buildCustomerInfo(customer.name),
            pw.SizedBox(height: 20),
            _buildItemTable(
              items.map((e) {
                final item = itemMap[e.itemId];
                return _ItemRow(
                  name: item?.name ?? 'Unknown Item',
                  partNumber: item?.partNumber ?? '-',
                  qty: e.qty,
                  price: e.price,
                  subtotal: e.subtotal,
                );
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            _buildTotals(transaction.grandTotal),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generatePurchaseOrder({
    required PurchaseTransactionModel purchase,
    required SupplierModel supplier,
    required List<PurchaseItemModel> items,
    required Map<int, ItemModel> itemMap,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader('PURCHASE ORDER', purchase.poNumber, purchase.date),
            pw.SizedBox(height: 20),
            _buildSupplierInfo(supplier.name),
            pw.SizedBox(height: 20),
            _buildItemTable(
              items.map((e) {
                final item = itemMap[e.itemId];
                return _ItemRow(
                  name: item?.name ?? 'Unknown Item',
                  partNumber: item?.partNumber ?? '-',
                  qty: e.qty,
                  price: e.price,
                  subtotal: e.subtotal,
                );
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            _buildTotals(purchase.grandTotal),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String title, String number, DateTime date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text('MITRA SETIA DIESEL',
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(title,
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('No: $number',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Tanggal: ${formatDate.format(date)}'),
              ],
            ),
          ],
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(String customerName) {
    return pw.Row(
      children: [
        pw.Text('Kepada Yth: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(customerName),
      ],
    );
  }

  static pw.Widget _buildSupplierInfo(String supplierName) {
    return pw.Row(
      children: [
        pw.Text('Supplier: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(supplierName),
      ],
    );
  }

  static pw.Widget _buildItemTable(List<_ItemRow> items) {
    return pw.TableHelper.fromTextArray(
      headers: ['Part Number', 'Nama Barang', 'Qty', 'Harga', 'Subtotal'],
      data: items
          .map((e) => [
                e.partNumber,
                e.name,
                e.qty.toString(),
                formatCurrency.format(e.price),
                formatCurrency.format(e.subtotal),
              ])
          .toList(),
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildTotals(double grandTotal) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text('Grand Total: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 10),
          pw.Text(formatCurrency.format(grandTotal),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('Hormat Kami,'),
            pw.SizedBox(height: 60),
            pw.Text('( Mitra Setia Diesel )'),
          ],
        ),
      ],
    );
  }
}

class _ItemRow {
  final String name;
  final String partNumber;
  final int qty;
  final double price;
  final double subtotal;

  _ItemRow({
    required this.name,
    required this.partNumber,
    required this.qty,
    required this.price,
    required this.subtotal,
  });
}
