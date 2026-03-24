import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Colors, Curves, BoxShadow, Offset;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/ios_theme.dart';
import 'package:student_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';

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
        // iOS style alert
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Camera Permission'),
            content: const Text('Please enable camera access in settings to scan QR codes.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Settings'),
                onPressed: () => openAppSettings(),
              ),
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
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
    
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CupertinoActivityIndicator(radius: 15)),
    );

    final success = await walletProvider.handleDeepLink(token);

    if (mounted) {
      Navigator.pop(context); // Pop loading
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (_) => const DashboardWrapper()),
          (route) => false,
        );
      } else {
        setState(() => _isScanning = true);
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(walletProvider.error ?? 'Invalid QR Code'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
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
    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.systemBackground,
      child: Stack(
        children: [
          // ── Scanner Layer ────────────────────────
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // ── Premium Glass Overlay ───────────────
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Stack(
                children: [
                  // Cutout window
                  Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Stack(
                        children: [
                          _corner(Alignment.topLeft),
                          _corner(Alignment.topRight),
                          _corner(Alignment.bottomLeft),
                          _corner(Alignment.bottomRight),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Top Navigation ───────────────────────
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.white.withOpacity(0.2),
                        child: const Icon(CupertinoIcons.xmark, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.white.withOpacity(0.2),
                      child: const Text(
                        'Scan QR Code',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => controller.toggleTorch(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.white.withOpacity(0.2),
                        child: const Icon(CupertinoIcons.lightbulb_fill, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Message ───────────────────────
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: IOSTheme.glassContainer(
              context: context,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              borderRadius: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Syncing with Web Wallet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Align the QR code from your browser dashboard within the frame to authenticate instantly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: (alignment == Alignment.topLeft || alignment == Alignment.topRight)
                ? const BorderSide(color: IOSTheme.primaryBlue, width: 4)
                : BorderSide.none,
            bottom: (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight)
                ? const BorderSide(color: IOSTheme.primaryBlue, width: 4)
                : BorderSide.none,
            left: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft)
                ? const BorderSide(color: IOSTheme.primaryBlue, width: 4)
                : BorderSide.none,
            right: (alignment == Alignment.topRight || alignment == Alignment.bottomRight)
                ? const BorderSide(color: IOSTheme.primaryBlue, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
