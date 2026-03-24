import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Colors, Curves, BoxShadow, Offset;
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/ios_theme.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:student_app/features/wallet/data/models/wallet_cert_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Revoked', 'Frozen'];

  List<WalletCert> get _filteredCertificates {
    final certs = Provider.of<WalletProvider>(context, listen: false).walletData?.certificates ?? [];
    if (_selectedFilter == 'All') return certs;
    return certs.where((c) => c.lifecycle.state == _selectedFilter).toList();
  }

  // ── VIEW Certificate ───────────────────────────
  Future<void> _viewCertificate(BuildContext context, WalletCert cert) async {
    final rawUrl = cert.viewUrl;
    final viewUrl = rawUrl.contains('localhost') ? rawUrl.replaceAll('localhost', '192.168.1.3') : rawUrl;
    try {
      await launchUrl(Uri.parse(viewUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) _showToast(context, 'Failed to open certificate', isError: true);
    }
  }

  // ── DOWNLOAD Certificate ───────────────────────
  Future<void> _downloadCertificate(BuildContext context, WalletCert cert) async {
    final rawUrl = cert.downloadUrl;
    final downloadUrl = rawUrl.contains('localhost') ? rawUrl.replaceAll('localhost', '192.168.1.3') : rawUrl;
    try {
      await launchUrl(Uri.parse(downloadUrl), mode: LaunchMode.externalApplication);
      _showToast(context, 'Starting download...');
    } catch (e) {
      if (mounted) _showToast(context, 'Failed to start download', isError: true);
    }
  }

  // ── VERIFY Certificate ─────────────────────────
  Future<void> _verifyCertificate(BuildContext context, WalletCert cert) async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    _showToast(context, 'Fetching verification link...');
    try {
      final shareUrl = await walletProvider.getShareableUrl(cert.id);
      if (shareUrl != null && shareUrl.isNotEmpty) {
        final finalUrl = shareUrl.contains('localhost') ? shareUrl.replaceAll('localhost', '192.168.1.3') : shareUrl;
        await launchUrl(Uri.parse(finalUrl), mode: LaunchMode.externalApplication);
      } else {
        throw Exception(walletProvider.error ?? 'Verification URL not found');
      }
    } catch (e) {
      if (context.mounted) _showToast(context, "Verification failed: ${e.toString().split('Exception: ').last}", isError: true);
    }
  }

  void _showToast(BuildContext context, String message, {bool isError = false}) {
    // Simple iOS-style overlay could be added here
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.systemBackground,
      child: Stack(
        children: [
          // Background accents
          Positioned(top: 100, left: -50, child: _blurCircle(150, IOSTheme.primaryBlue.withOpacity(0.05))),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const CupertinoSliverNavigationBar(
                largeTitle: Text('Certificates'),
                border: null,
                backgroundColor: CupertinoColors.systemBackground,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: IOSTheme.paddingM, vertical: 10),
                  child: Column(
                    children: [
                      // Filter Control
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoSlidingSegmentedControl<String>(
                          groupValue: _selectedFilter,
                          onValueChanged: (val) {
                            if (val != null) setState(() => _selectedFilter = val);
                          },
                          children: {
                            for (var f in _filters)
                              f: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(f, style: const TextStyle(fontSize: 13)),
                              )
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _filteredCertificates.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('No certificates found', style: TextStyle(color: CupertinoColors.secondaryLabel))),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(IOSTheme.paddingM, 0, IOSTheme.paddingM, 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final cert = _filteredCertificates[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCertificateCard(context, cert),
                            );
                          },
                          childCount: _filteredCertificates.length,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, WalletCert cert) {
    final date = DateTime.tryParse(cert.issuedAt);
    final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : cert.issuedAt;

    return IOSTheme.glassContainer(
      context: context,
      padding: EdgeInsets.zero,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showCertificateDetail(context, cert),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: IOSTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.doc_fill, color: IOSTheme.primaryBlue, size: 22),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.templateName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: CupertinoColors.label),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cert.issuerName ?? 'JustyfAI',
                      style: const TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formattedDate, style: const TextStyle(fontSize: 11, color: CupertinoColors.secondaryLabel)),
                  const SizedBox(height: 5),
                  _statusBadge(cert.lifecycle.state),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String state) {
    final color = state == 'Active' ? CupertinoColors.systemGreen : CupertinoColors.systemRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        state,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  void _showCertificateDetail(BuildContext context, WalletCert cert) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: CupertinoActionSheet(
          title: Text(cert.templateName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          message: Text('Issued by ${cert.issuerName ?? 'JustyfAI'}'),
          actions: [
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.eye, size: 18),
                  SizedBox(width: 10),
                  Text('View Certificate'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                _viewCertificate(context, cert);
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.cloud_download, size: 18),
                  SizedBox(width: 10),
                  Text('Download (PDF)'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                _downloadCertificate(context, cert);
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.checkmark_seal, size: 18),
                  SizedBox(width: 10),
                  Text('Verify Authenticity'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                _verifyCertificate(context, cert);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
