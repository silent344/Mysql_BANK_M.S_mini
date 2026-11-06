import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';

class PdfReceiptService {
  static Future<Uint8List> generateOrderReceipt({
    required String orderNumber,
    required DateTime orderDate,
    required String customerName,
    required String customerPhone,
    required Map<String, dynamic> address,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    required String paymentMethod,
    required String paymentStatus,
  }) async {
    final pdf = pw.Document();

    final shopName = dotenv.env['SHOP_NAME'] ?? AppConstants.appName;
    final shopPhone = dotenv.env['SHOP_PHONE'] ?? '+91 98765 43210';
    final shopEmail = dotenv.env['SHOP_EMAIL'] ?? 'support@softtouchtowels.com';
    final shopAddress = dotenv.env['SHOP_ADDRESS'] ?? '12, Handloom Street, Textile City, India';

    final isPaid = paymentStatus.toLowerCase() == AppConstants.paymentStatusPaid;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        shopName,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#C06C4C'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Premium Bath & Home Textiles',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(shopAddress, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.Text('Phone: $shopPhone  |  Email: $shopEmail',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: isPaid ? PdfColors.green50 : PdfColors.orange50,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(
                        color: isPaid ? PdfColors.green700 : PdfColors.orange700,
                        width: 1,
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'TAX INVOICE / RECEIPT',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: isPaid ? PdfColors.green900 : PdfColors.orange900,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Status: ${paymentStatus.toUpperCase()}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: isPaid ? PdfColors.green800 : PdfColors.orange800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 12),

              // ORDER & BILL TO META
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Order Details
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ORDER DETAILS',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                        pw.SizedBox(height: 6),
                        pw.Text('Order ID: $orderNumber',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Order Date: ${Formatters.formatDate(orderDate)}',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('Payment Method: $paymentMethod',
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),

                  // Customer Shipping Address
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('DELIVERY ADDRESS',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                        pw.SizedBox(height: 6),
                        pw.Text(customerName,
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Phone: $customerPhone',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(
                          '${address['line1'] ?? ''}, ${address['line2'] ?? ''}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        if (address['landmark'] != null && (address['landmark'] as String).isNotEmpty)
                          pw.Text('Landmark: ${address['landmark']}',
                              style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(
                          '${address['city'] ?? ''}, ${address['state'] ?? ''} - ${address['pincode'] ?? ''}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),

              // ITEMS TABLE
              pw.Text('PURCHASED ITEMS',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: const pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                  bottom: const pw.BorderSide(color: PdfColors.grey400, width: 1),
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(0.6), // #
                  1: const pw.FlexColumnWidth(3.5), // Item
                  2: const pw.FlexColumnWidth(1.0), // Qty
                  3: const pw.FlexColumnWidth(1.4), // Unit Price
                  4: const pw.FlexColumnWidth(1.5), // Total
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#FAF7F2')),
                    children: [
                      _buildTableCell('#', isHeader: true),
                      _buildTableCell('Item Description', isHeader: true),
                      _buildTableCell('Qty', isHeader: true, align: pw.TextAlign.center),
                      _buildTableCell('Unit Price', isHeader: true, align: pw.TextAlign.right),
                      _buildTableCell('Amount', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Table Rows
                  for (var i = 0; i < items.length; i++)
                    pw.TableRow(
                      children: [
                        _buildTableCell('${i + 1}'),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                items[i]['product_name'] ?? 'Towel',
                                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                              ),
                              if (items[i]['size'] != null || items[i]['color'] != null)
                                pw.Text(
                                  'Size: ${items[i]['size'] ?? 'Standard'} | Color: ${items[i]['color'] ?? 'Default'}',
                                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                                ),
                            ],
                          ),
                        ),
                        _buildTableCell('${items[i]['quantity'] ?? 1}', align: pw.TextAlign.center),
                        _buildTableCell(
                          '₹${(items[i]['unit_price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                          align: pw.TextAlign.right,
                        ),
                        _buildTableCell(
                          '₹${(items[i]['total_price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                          align: pw.TextAlign.right,
                          isBold: true,
                        ),
                      ],
                    ),
                ],
              ),

              pw.SizedBox(height: 16),

              // FINANCIAL TOTALS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    child: pw.Column(
                      children: [
                        _buildSummaryRow('Subtotal:', '₹${subtotal.toStringAsFixed(2)}'),
                        pw.SizedBox(height: 4),
                        _buildSummaryRow(
                          'Delivery Charges:',
                          shippingFee == 0 ? 'FREE' : '₹${shippingFee.toStringAsFixed(2)}',
                        ),
                        pw.SizedBox(height: 6),
                        pw.Divider(color: PdfColors.grey300, thickness: 1),
                        pw.SizedBox(height: 6),
                        _buildSummaryRow(
                          'Grand Total:',
                          '₹${totalAmount.toStringAsFixed(2)}',
                          isGrandTotal: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // FOOTER
              pw.Divider(color: PdfColors.grey300, thickness: 0.8),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Thank you for choosing SoftTouch Towels!',
                    style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Support: $shopEmail | All taxes included',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 10,
          fontWeight: isHeader || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey800 : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value, {bool isGrandTotal = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: isGrandTotal ? 12 : 10,
            fontWeight: isGrandTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isGrandTotal ? PdfColors.black : PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isGrandTotal ? 13 : 10,
            fontWeight: isGrandTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isGrandTotal ? PdfColor.fromHex('#C06C4C') : PdfColors.black,
          ),
        ),
      ],
    );
  }

  /// Print or share directly using the device's native print / share dialog
  static Future<void> printOrShareReceipt({
    required Uint8List pdfBytes,
    required String orderNumber,
  }) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Invoice_$orderNumber.pdf',
    );
  }

  /// Open print preview
  static Future<void> previewReceipt({
    required Uint8List pdfBytes,
    required String orderNumber,
  }) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Invoice_$orderNumber',
    );
  }
}
