import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'header.dart';
import 'uploadpage.dart';
import 'image_viewer.dart';

class ResultsPage extends StatefulWidget {
  final Map<String, dynamic> result;
  final Uint8List originalImageBytes;
  final bool hasDetections;

  const ResultsPage({
    super.key,
    required this.result,
    required this.originalImageBytes,
    required this.hasDetections,
  });

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> isZoomEnabled = ValueNotifier<bool>(false);
  late final AnimationController _animationController;
  bool _showOverlay = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
      _showOverlay
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  Future<void> _generateAndDownloadPdf() async {
    setState(() => _isGenerating = true);

    try {
      final pdf = pw.Document();
      final image = widget.hasDetections
          ? pw.MemoryImage(widget.result['full_image'])
          : pw.MemoryImage(widget.originalImageBytes);

      // Get all predictions (or empty list)
      final predictions = widget.hasDetections
          ? widget.result['individual_predictions'] as List<dynamic>
          : <dynamic>[];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            final content = <pw.Widget>[];

            // Header
            content.add(_buildReportHeader());
            content.add(pw.SizedBox(height: 20));

            // Main image
            content.add(
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey800),
                  ),
                  child: pw.Image(image,
                      width: 500, height: 300, fit: pw.BoxFit.contain),
                ),
              ),
            );
            content.add(pw.SizedBox(height: 30));

            // Detected opacities
            content.add(_buildDetectedOpacitiesSection());
            content.add(pw.SizedBox(height: 20));

            // Detailed analysis and full table
            if (widget.hasDetections) {
              content.add(
                pw.Text('DETAILED ANALYSIS OF OPACITIES',
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey600)),
              );
              content.add(pw.Divider(thickness: 0.5));
              content.add(pw.SizedBox(height: 10));
              // full table for all predictions
              content.add(_buildPredictionsTable(predictions));
              content.add(pw.SizedBox(height: 20));
            }

            // Conclusion always last
            if (predictions.length == 2) {
              content.add(pw.SizedBox(height: 60)); // Increased spacing
            }

            content.add(pw.Container(
              child: _buildConclusionSection(),
            ),
            );

            return content;
          },
        ),
      );

      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'mammography_report.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        await Printing.sharePdf(
            bytes: pdfBytes, filename: 'mammography_report.pdf');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF ready!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  pw.Table _buildPredictionsTable(List<dynamic> predictions) {
    final tableData = predictions.map<List<dynamic>>((prediction) {
      try {
        final features = prediction['features'] ?? {};
        final morph = features['morphology'] ?? {};
        final intensity = features['intensity'] ?? {};
        final texture = features['texture'] ?? {};

        final featuresString = [
          if (morph['area_mm2'] != null)
            'Area: ${morph['area_mm2']?.toStringAsFixed(2)}mm²',
          if (morph['circularity'] != null)
            'Circulation: ${morph['circularity']?.toStringAsFixed(2)}',
          if (intensity['mean'] != null)
            'Intensity: ${intensity['mean']?.toStringAsFixed(1)}',
          if (texture['glcm_homogeneity'] != null)
            'Homogeneity: ${texture['glcm_homogeneity']?.toStringAsFixed(2)}',
        ].join(', ');

        final imageBytes = prediction['crop'] as Uint8List?;

        return [
          prediction['label'] ?? 'N/A',
          '${((prediction['score'] ?? 0) * 100).toStringAsFixed(1)}%',
          featuresString,
          prediction['classification'] ?? 'N/A',
          pw.ClipRRect(
            horizontalRadius: 5,
            verticalRadius: 5,
            child: pw.Image(
              pw.MemoryImage(imageBytes ?? Uint8List(0)),
              width: 50,
              height: 50,
            ),
          ),
        ];
      } catch (_) {
        return ['Error', 'N/A', 'Could not process', 'N/A', pw.SizedBox(width: 50, height: 50)];
      }
    }).toList();

    return pw.TableHelper.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      headers: ['Opacity', 'Score', 'Features', 'Class', 'Visualization'],
      data: tableData,
    );
  }

  pw.Widget _buildReportHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('MAMMOGRAPHY DIAGNOSTIC REPORT',
            style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600)),
        pw.Text('Supported by SafeScan system',
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600)),
        pw.Divider(thickness: 1),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Patient Name: Eliana Riversong',
                style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildDetectedOpacitiesSection() {
    int masscount = 0;
    int calccount = 0;

    if (widget.hasDetections) {
      for (var prediction in widget.result['individual_predictions']) {
        if (prediction['label'] == 'mass') {
          masscount++;
        } else if (prediction['label'] == 'calc') {calccount++;}
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('DETECTED OPACITIES',
            style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600)),
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 10),
        if (!widget.hasDetections)
          pw.Text('No suspicious opacities detected',
              style: const pw.TextStyle(fontSize: 12))
        else
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (masscount > 0)
                pw.Text('- $masscount ${masscount == 1 ? 'mass' : 'masses'}',
                    style: const pw.TextStyle(fontSize: 12)),
              if (calccount > 0)
                pw.Text('- $calccount ${calccount == 1 ? 'calcification' : 'calcifications'}',
                    style: const pw.TextStyle(fontSize: 12)),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildConclusionSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('CONCLUSION',
            style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600)),
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 10),
        pw.Wrap(
          runSpacing: 8,
          children: [
            if (!widget.hasDetections)
              pw.Text(
                  'The mammogram appears within normal limits with no evidence of suspicious opacities, masses, or calcification. Routine follow-up is recommended as per standard screening guidelines.',
                  style: const pw.TextStyle(fontSize: 12))
            else
              pw.Text(
                  'The mammogram demonstrates ${widget.result['individual_predictions'].length} suspicious opacity/opacities requiring further evaluation. Correlation with additional imaging and clinical findings is recommended.',
                  style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(121, 0, 0, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          foregroundColor: Colors.white,
        ),
        onPressed: _isGenerating ? null : _generateAndDownloadPdf,
        icon: _isGenerating
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.download, size: 20),
        label: Text(
          _isGenerating ? 'Generating...' : 'Download Prediction PDF',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildImageViewer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxW = screenWidth * 0.9;
    final maxH = screenHeight * 0.9;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ImageViewer(
            result: widget.result,
            originalImageBytes: widget.originalImageBytes,
            hasDetections: widget.hasDetections,
            isZoomEnabled: isZoomEnabled,
            animationController: _animationController,
            showOverlay: _showOverlay,
            onToggleOverlay: _toggleOverlay,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(121, 0, 0, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
          foregroundColor: Colors.white,
        ),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UploadHome(),
          ),
        ),
        child: const Text('Back to Upload', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: const Color.fromARGB(150, 42, 14, 24),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        buildHeader(context, screenWidth),
                        _buildDownloadButton(),
                        _buildImageViewer(context),
                        _buildBackButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
