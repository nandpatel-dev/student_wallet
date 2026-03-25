import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Colors, Curves, BoxShadow, Offset;
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/ios_theme.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:student_app/features/wallet/data/models/wallet_cert_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:student_app/features/auth/presentation/pages/login_page.dart';
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
    // Simple toast notification system
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    /*
    // ──────── OLD DESIGN ────────
    // ...
    */

    // ──────── NEW PREMIUM GLASSMORPHISM DESIGN ────────
    return CupertinoPageScaffold(
      backgroundColor: Colors.black, 
      child: Stack(
        children: [
          // ── Gradient Background ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0F0E0D), const Color(0xFF1C1A18), const Color(0xFF0F0E0D)] // Dark Coffee
                      : [const Color(0xFFF5F5F4), const Color(0xFFF5F5DC), const Color(0xFFE7E5E4)], // Premium Beige Gradient
                ),
              ),
            ),
          ),

          // ── Premium Blur Orbs ──
          Positioned(
            top: 50,
            right: -100,
            child: _blurCircle(450, isDark ? Colors.purple.withOpacity(0.3) : Colors.brown.withOpacity(0.15)),
          ),
          Positioned(
            bottom: 100,
            left: -150,
            child: _blurCircle(500, isDark ? Colors.blue.withOpacity(0.2) : Colors.orange.withOpacity(0.1)),
          ),

          // ── Main Content ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverPadding(padding: EdgeInsets.only(top: 100)), // Space for fixed header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      // Glassy Filter Control
                      _glassmorphismContainer(
                        padding: const EdgeInsets.all(4),
                        borderRadius: 16,
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl<String>(
                            groupValue: _selectedFilter,
                            backgroundColor: Colors.transparent,
                            thumbColor: Colors.white.withOpacity(0.15),
                            onValueChanged: (val) {
                              if (val != null) setState(() => _selectedFilter = val);
                            },
                            children: {
                              for (var f in _filters)
                                f: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    f, 
                                    style: TextStyle(
                                      color: _selectedFilter == f ? Colors.white : Colors.white.withOpacity(0.5),
                                      fontSize: 14,
                                      fontWeight: _selectedFilter == f ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                )
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              _filteredCertificates.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No records found under this filter', 
                          style: TextStyle(color: (isDark ? const Color(0xFFF1EDE8) : Colors.white).withOpacity(0.4), fontSize: 15),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildPremiumCertificateCard(context, _filteredCertificates[index]),
                            );
                          },
                          childCount: _filteredCertificates.length,
                        ),
                      ),
                    ),
            ],
          ),

          // ── Fixed Custom Premium Header ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildCustomPremiumHeader(context, 'Certificates', themeProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPremiumHeader(BuildContext context, String title, ThemeProvider themeProvider) {
    bool isDark = themeProvider.isDarkMode;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 20,
            right: 20,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFF1EDE8),
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => themeProvider.toggleTheme(),
                    child: _glassButtonIcon(isDark ? CupertinoIcons.sun_max : CupertinoIcons.moon_fill),
                  ),
                  const SizedBox(width: 12),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      await Provider.of<WalletProvider>(context, listen: false).logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (_) => const LoginPage()), 
                          (route) => false
                        );
                      }
                    },
                    child: _glassButtonIcon(CupertinoIcons.power, isLogout: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassButtonIcon(IconData icon, {bool isLogout = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isLogout 
            ? const Color(0xFFF87171).withOpacity(0.12) // Subtle Red for Logout
            : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLogout ? const Color(0xFFF87171).withOpacity(0.3) : Colors.white.withOpacity(0.25), 
          width: 1
        ),
      ),
      child: Icon(icon, color: isLogout ? const Color(0xFFF87171) : const Color(0xFFF1EDE8), size: 20),
    );
  }

  Widget _buildPremiumCertificateCard(BuildContext context, WalletCert cert) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final date = DateTime.tryParse(cert.issuedAt);
    final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : cert.issuedAt;

    return _glassmorphismContainer(
      padding: EdgeInsets.zero,
      borderRadius: 30,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showCertificateDetail(context, cert),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Premium Icon Container
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [const Color(0xFFC8A27C), const Color(0xFF1C1A18)] // Caramel to Roasted Dark
                        : [const Color(0xFF78716C), const Color(0xFF44403C)], // Warm Grey/Stone for Light
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? const Color(0xFFC8A27C) : const Color(0xFF78716C)).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Icon(CupertinoIcons.doc_fill, color: isDark ? const Color(0xFFF1EDE8) : Colors.white, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.templateName,
                      style: TextStyle(
                        fontSize: 17, 
                        fontWeight: FontWeight.w800, 
                        color: isDark ? const Color(0xFFF1EDE8) : Colors.white,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cert.issuerName ?? 'JustyfAI Verified',
                      style: TextStyle(fontSize: 13, color: (isDark ? const Color(0xFFF1EDE8) : Colors.white).withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedDate, 
                    style: TextStyle(fontSize: 12, color: (isDark ? const Color(0xFFF1EDE8) : Colors.white).withOpacity(0.4), fontWeight: FontWeight.w700)
                  ),
                  const SizedBox(height: 8),
                  _premiumStatusBadge(cert.lifecycle.state),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumStatusBadge(String state) {
    final color = state == 'Active' ? const Color(0xFF22D3EE) : const Color(0xFFF87171);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        state.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
      ),
    );
  }

  Widget _glassmorphismContainer({required Widget child, EdgeInsets? padding, double borderRadius = 30}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  void _showCertificateDetail(BuildContext context, WalletCert cert) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: CupertinoActionSheet(
          title: Text(cert.templateName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          message: Text('Certified by ${cert.issuerName ?? 'JustyfAI'}'),
          actions: [
            _actionItem(CupertinoIcons.eye, 'View Certificate', () {
              Navigator.pop(context);
              _viewCertificate(context, cert);
            }),
            _actionItem(CupertinoIcons.cloud_download, 'Download (PDF)', () {
              Navigator.pop(context);
              _downloadCertificate(context, cert);
            }),
            _actionItem(CupertinoIcons.checkmark_seal_fill, 'Verify Authenticity', () {
              Navigator.pop(context);
              _verifyCertificate(context, cert);
            }),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel Request'),
          ),
        ),
      ),
    );
  }

  Widget _actionItem(IconData icon, String label, VoidCallback onPressed) {
    return CupertinoActionSheetAction(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }

  /*
  // ── OLD METHODS (Commented out) ──
  Widget _buildCertificateCard(BuildContext context, WalletCert cert) { ... }
  Widget _statusBadge(String state) { ... }
  */

}
