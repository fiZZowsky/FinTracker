import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/receipt_model.dart';

class ExportService {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String _formatCurrency(double amount, String currencyCode) {
    return '${NumberFormat.currency(symbol: '', decimalDigits: 2).format(amount).trim()} $currencyCode';
  }

  Future<void> exportToCsv(List<ReceiptModel> receipts, DateTime start,
      DateTime end, String targetCurrency) async {
    List<List<dynamic>> rows = [];

    rows.add(["Data zakupu", "Sklep", "Kategoria", "Kwota ($targetCurrency)"]);

    double totalSum = 0.0;

    for (var receipt in receipts) {
      totalSum += receipt.totalAmount;
      rows.add([
        _dateFormat.format(receipt.dateShopping),
        receipt.storeName,
        receipt.categoryName ?? "Brak",
        receipt.totalAmount.toStringAsFixed(2).replaceAll('.', ',')
      ]);
    }

    rows.add([]);
    rows.add([
      "Suma całkowita",
      "",
      "",
      totalSum.toStringAsFixed(2).replaceAll('.', ',')
    ]);

    String csvData =
        const ListToCsvConverter(fieldDelimiter: ';').convert(rows);

    final bom = '\uFEFF';
    final csvContent = bom + csvData;

    final directory = await getTemporaryDirectory();
    final path =
        "${directory.path}/wydatki_${_dateFormat.format(start)}_do_${_dateFormat.format(end)}.csv";
    final file = File(path);
    await file.writeAsString(csvContent);

    await Share.shareXFiles([XFile(path)],
        text: 'Raport wydatków (CSV) w walucie $targetCurrency');
  }

  Future<void> exportToPdf(List<ReceiptModel> receipts, DateTime start,
      DateTime end, String targetCurrency) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final totalSum = receipts.fold(0.0, (sum, item) => sum + item.totalAmount);

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
          margin: const pw.EdgeInsets.all(20),
        ),
        header: (context) =>
            _buildPdfHeader(start, end, fontBold, targetCurrency),
        footer: (context) => _buildPdfFooter(context, font),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildPdfTable(receipts, font, fontBold, targetCurrency),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Suma całkowita: ${_formatCurrency(totalSum, targetCurrency)}",
              style: pw.TextStyle(font: fontBold, fontSize: 14),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
        bytes: await doc.save(),
        filename:
            'raport_${_dateFormat.format(start)}_${_dateFormat.format(end)}.pdf');
  }

  pw.Widget _buildPdfHeader(
      DateTime start, DateTime end, pw.Font fontBold, String targetCurrency) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("FinTracker - Raport Wydatków ($targetCurrency)",
            style: pw.TextStyle(font: fontBold, fontSize: 18)),
        pw.Text(
            "Okres: ${_dateFormat.format(start)} - ${_dateFormat.format(end)}"),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        "Strona ${context.pageNumber} z ${context.pagesCount}",
        style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey),
      ),
    );
  }

  pw.Widget _buildPdfTable(List<ReceiptModel> receipts, pw.Font font,
      pw.Font fontBold, String targetCurrency) {
    return pw.TableHelper.fromTextArray(
      headers: ['Data', 'Sklep', 'Kategoria', 'Kwota'],
      data: receipts
          .map((r) => [
                _dateFormat.format(r.dateShopping),
                r.storeName,
                r.categoryName ?? "-",
                _formatCurrency(r.totalAmount, targetCurrency),
              ])
          .toList(),
      headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
      cellStyle: pw.TextStyle(font: font, fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        3: pw.Alignment.centerRight,
      },
    );
  }
}
