/*
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required to scan QR')),
        );
      }
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.contains('token=')) {
        setState(() => _isScanning = false);
        
        // Extract token from URI
        final uri = Uri.tryParse(code);
        final token = uri?.queryParameters['token'];

        if (token != null) {
          _handleToken(token);
          break;
        }
      }
    }
  }

  Future<void> _handleToken(String token) async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await walletProvider.handleDeepLink(token);

    if (mounted) {
      Navigator.pop(context); // Pop loading
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardWrapper()),
          (route) => false,
        );
      } else {
        setState(() => _isScanning = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(walletProvider.error ?? 'Invalid QR Code')),
        );
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Login'),
        actions: [
          IconButton(
            onPressed: () => controller.toggleTorch(),
            icon: const Icon(Icons.flash_on_rounded),
          ),
          IconButton(
            onPressed: () => controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          
          // Overlay
          IgnorePointer(
            child: Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: colorScheme.primary,
                  borderRadius: 20,
                  borderLength: 40,
                  borderWidth: 10,
                  cutOutSize: 280,
                ),
              ),
            ),
          ),

          // Hint
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Align QR code within the frame',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final center = rect.center;
    final halfCutOut = cutOutSize / 2;

    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Background
    canvas.drawPath(
      Path()
        ..addRect(rect)
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(center.dx - halfCutOut, center.dy - halfCutOut,
                cutOutSize, cutOutSize),
            Radius.circular(borderRadius)))
        ..fillType = PathFillType.evenOdd,
      paint,
    );

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final cutOutRect = Rect.fromLTWH(center.dx - halfCutOut,
        center.dy - halfCutOut, cutOutSize, cutOutSize);

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left, cutOutRect.top + borderLength)
        ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
        ..quadraticBezierTo(
            cutOutRect.left, cutOutRect.top, cutOutRect.left + borderRadius, cutOutRect.top)
        ..lineTo(cutOutRect.left + borderLength, cutOutRect.top),
      borderPaint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - borderLength, cutOutRect.top)
        ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top)
        ..quadraticBezierTo(
            cutOutRect.right, cutOutRect.top, cutOutRect.right, cutOutRect.top + borderRadius)
        ..lineTo(cutOutRect.right, cutOutRect.top + borderLength),
      borderPaint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left, cutOutRect.bottom - borderLength)
        ..lineTo(cutOutRect.left, cutOutRect.bottom - borderRadius)
        ..quadraticBezierTo(cutOutRect.left, cutOutRect.bottom,
            cutOutRect.left + borderRadius, cutOutRect.bottom)
        ..lineTo(cutOutRect.left + borderLength, cutOutRect.bottom),
      borderPaint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - borderLength, cutOutRect.bottom)
        ..lineTo(cutOutRect.right - borderRadius, cutOutRect.bottom)
        ..quadraticBezierTo(cutOutRect.right, cutOutRect.bottom,
            cutOutRect.right, cutOutRect.bottom - borderRadius)
        ..lineTo(cutOutRect.right, cutOutRect.bottom - borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutSize: cutOutSize,
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:student_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required to scan QR')),
        );
      }
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.contains('token=')) {
        setState(() => _isScanning = false);
        
        // Extract token from URI
        final uri = Uri.tryParse(code);
        final token = uri?.queryParameters['token'];

        if (token != null) {
          _handleToken(token);
          break;
        }
      }
    }
  }

  Future<void> _handleToken(String token) async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await walletProvider.handleDeepLink(token);

    if (mounted) {
      Navigator.pop(context); // Pop loading
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardWrapper()),
          (route) => false,
        );
      } else {
        setState(() => _isScanning = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(walletProvider.error ?? 'Invalid QR Code')),
        );
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1E50FF)),
                  ),
                  const Spacer(),
                  const Icon(Icons.account_balance_wallet, color: Color(0xFF1E50FF), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'The Academic Ledger',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E50FF),
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF141B34),
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Text(
                        'Sync with Web App',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF141B34),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Position the QR code from your browser\ninside the frame.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: const Color(0xFF141B34).withOpacity(0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // QR Scanner Frame
                    Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E50FF).withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: MobileScanner(
                                controller: controller,
                                onDetect: _onDetect,
                              ),
                            ),
                            
                            // Blue Frame Corners Overlay
                            IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFF1E50FF).withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: _ScannerCornersPainter(color: const Color(0xFF1E50FF)),
                                  child: Container(),
                                ),
                              ),
                            ),

                            // Scanning Indicator Text
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.document_scanner, color: Color(0xFF1E50FF), size: 14),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'ACTIVE SCANNING...',
                                    style: TextStyle(
                                      color: Color(0xFF1E50FF),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Manual Code Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Placeholder
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E50FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Scan Manual Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Back to Login Button
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.restart_alt_rounded, color: Colors.grey, size: 20),
                        label: const Text('Back to Login', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerCornersPainter extends CustomPainter {
  final Color color;
  _ScannerCornersPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    const double length = 32;
    const double offset = 4;
    final double w = size.width;
    final double h = size.height;

    // Top Left
    canvas.drawLine(const Offset(offset, offset + length), const Offset(offset, offset + 16), paint);
    canvas.drawArc(Rect.fromLTWH(offset, offset, 32, 32), 3.14, 1.57, false, paint);
    canvas.drawLine(const Offset(offset + 16, offset), const Offset(offset + length, offset), paint);

    // Top Right
    canvas.drawLine(Offset(w - offset - length, offset), Offset(w - offset - 16, offset), paint);
    canvas.drawArc(Rect.fromLTWH(w - offset - 32, offset, 32, 32), 4.71, 1.57, false, paint);
    canvas.drawLine(Offset(w - offset, offset + 16), Offset(w - offset, offset + length), paint);

    // Bottom Left
    canvas.drawLine(Offset(offset, h - offset - length), Offset(offset, h - offset - 16), paint);
    canvas.drawArc(Rect.fromLTWH(offset, h - offset - 32, 32, 32), 1.57, 1.57, false, paint);
    canvas.drawLine(Offset(offset + 16, h - offset), Offset(offset + length, h - offset), paint);

    // Bottom Right
    canvas.drawLine(Offset(w - offset, h - offset - length), Offset(w - offset, h - offset - 16), paint);
    canvas.drawArc(Rect.fromLTWH(w - offset - 32, h - offset - 32, 32, 32), 0, 1.57, false, paint);
    canvas.drawLine(Offset(w - offset - 16, h - offset), Offset(w - offset - length, h - offset), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
