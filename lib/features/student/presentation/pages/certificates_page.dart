import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Icons,
        Colors,
        Theme,
        TargetPlatform,
        ScaffoldMessenger,
        SnackBar,
        SnackBarBehavior,
        RoundedRectangleBorder,
        CircularProgressIndicator,
        Divider;
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:student_app/features/wallet/data/models/wallet_cert_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:student_app/features/auth/presentation/pages/login_page.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:student_app/core/constants/api_constants.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Revoked', 'Frozen'];

  /// Cert IDs currently in a loading (fetching/downloading) state.
  final Set<String> _loadingCertIds = {};

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<WalletCert> get _filteredCertificates {
    // Always use the State's own context here
    final certs =
        Provider.of<WalletProvider>(context, listen: false).walletData?.certificates ?? [];
    if (_selectedFilter == 'All') return certs;
    return certs.where((c) => c.lifecycle.state == _selectedFilter).toList();
  }

  void _setLoading(String certId, bool loading) {
    if (!mounted) return;
    setState(() {
      loading ? _loadingCertIds.add(certId) : _loadingCertIds.remove(certId);
    });
  }

  bool _isLoading(String certId) => _loadingCertIds.contains(certId);

  // ─────────────────────────────────────────────────────────────────────────
  // TOAST  – always uses this.context (State's own, always valid until dispose)
  // ─────────────────────────────────────────────────────────────────────────
  void _toast(String message, {bool isError = false}) {
    if (!mounted) return;
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : (isDark ? const Color(0xFF5C55ED) : const Color(0xFF1E293B)).withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VIEW  –  GET /api/student-wallet/certificates/:id/view
  //          Header: x-student-wallet
  //          Server streams PDF bytes inline → we save to temp → OpenFilex
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _viewCertificate(WalletCert cert) async {
  if (!mounted) return;
  _setLoading(cert.id, true);

  try {
    final token =
        await Provider.of<WalletProvider>(context, listen: false).getToken();

    if (token == null || token.isEmpty) {
      _toast('❌ Token missing', isError: true);
      return;
    }

    final url = ApiConstants.viewCertificate(cert.id);
    debugPrint("VIEW URL: $url");

    final dio = Dio();

    final response = await dio.get(
      url,
      options: Options(
        headers: {
          'x-student-wallet': token,
          // TRY THIS IF BACKEND USES AUTH HEADER
          // 'Authorization': 'Bearer $token',
        },
        responseType: ResponseType.bytes,
        validateStatus: (status) => true,
      ),
    );

    debugPrint("STATUS: ${response.statusCode}");

    if (response.statusCode == 401) {
      _toast("Session expired", isError: true);
      return;
    }

    if (response.statusCode != 200) {
      final msg = String.fromCharCodes(response.data ?? []);
      _toast("❌ Server error: $msg", isError: true);
      return;
    }

    final bytes = response.data;

    if (bytes == null || bytes.isEmpty) {
      _toast("Empty PDF", isError: true);
      return;
    }

    // ✅ CHECK PDF SIGNATURE
    final header = String.fromCharCodes(bytes.take(20));
    if (!header.contains("%PDF")) {
      _toast("❌ Not a valid PDF", isError: true);
      debugPrint(header);
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = "${dir.path}/cert_${cert.id}.pdf";

    final file = File(path);
    await file.writeAsBytes(bytes);

    final result = await OpenFilex.open(path);

    if (result.type != ResultType.done) {
      _toast("No app to open PDF", isError: true);
    }
  } catch (e) {
    debugPrint("VIEW ERROR: $e");
    _toast("View failed: $e", isError: true);
  } finally {
    _setLoading(cert.id, false);
  }
}

  // ─────────────────────────────────────────────────────────────────────────
  // DOWNLOAD  –  GET /api/student-wallet/certificates/:id/download
  //              Header: x-student-wallet
  //              Saves PDF to app documents directory (works on all Android versions)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _downloadCertificate(WalletCert cert) async {
  if (!mounted) return;
  _setLoading(cert.id, true);

  try {
    final token =
        await Provider.of<WalletProvider>(context, listen: false).getToken();

    if (token == null || token.isEmpty) {
      _toast("❌ Token missing", isError: true);
      return;
    }

    final url = ApiConstants.downloadCertificate(cert.id);
    debugPrint("DOWNLOAD URL: $url");

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        "Certificate_${cert.templateName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf";

    final savePath = "${dir.path}/$fileName";

    final dio = Dio();

    final response = await dio.download(
      url,
      savePath,
      options: Options(
        headers: {
          'x-student-wallet': token,
          // 'Authorization': 'Bearer $token',
        },
        validateStatus: (status) => true,
      ),
    );

    debugPrint("STATUS: ${response.statusCode}");

    if (response.statusCode == 401) {
      _toast("Session expired", isError: true);
      return;
    }

    if (response.statusCode != 200) {
      _toast("❌ Download failed: ${response.statusCode}", isError: true);
      return;
    }

    _toast("✅ PDF saved successfully");

    // OPTIONAL: auto open after download
    await OpenFilex.open(savePath);
  } catch (e) {
    debugPrint("DOWNLOAD ERROR: $e");
    _toast("Download failed: $e", isError: true);
  } finally {
    _setLoading(cert.id, false);
  }
}

  // ─────────────────────────────────────────────────────────────────────────
  // VERIFY / SHARE  –  POST /api/student-wallet/certificates/:id/share
  //                    Header: x-student-wallet
  //                    Returns: shareable verification URL → open in browser
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _verifyCertificate(WalletCert cert) async {
  if (!mounted) return;

  if (cert.lifecycle.state != 'Active') {
    _toast("Certificate not active", isError: true);
    return;
  }

  _setLoading(cert.id, true);

  try {
    final walletProvider =
        Provider.of<WalletProvider>(context, listen: false);

    final url = await walletProvider.getShareableUrl(cert.id);

    debugPrint("VERIFY URL: $url");

    if (url == null || url.isEmpty) {
      _toast("❌ No verification link", isError: true);
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null || !uri.hasScheme) {
      _toast("❌ Invalid URL", isError: true);
      return;
    }

    final canLaunch = await canLaunchUrl(uri);

    if (!canLaunch) {
      _toast("❌ Cannot open link", isError: true);
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint("VERIFY ERROR: $e");
    _toast("Verify failed: $e", isError: true);
  } finally {
    _setLoading(cert.id, false);
  }
}

  // ─────────────────────────────────────────────────────────────────────────
  // Action sheet  – uses sheetCtx (sheet's own context) to dismiss the sheet,
  //                  and this.context (State context) for all API calls.
  // ─────────────────────────────────────────────────────────────────────────
  void _showCertificateDetail(WalletCert cert) {
    showCupertinoModalPopup<void>(
      context: context, // State's context → correct navigator scope
      builder: (sheetCtx) => CupertinoActionSheet(
        title: Text(
          cert.templateName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        message: Text('Certified by ${cert.issuerName ?? 'JustyfAI'}'),
        actions: [
          // ── View  (GET …/view) ──────────────────────────────
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetCtx); // dismiss sheet using sheet's own ctx
              _viewCertificate(cert);  // uses this.context internally
            },
            child: _actionRow(
              CupertinoIcons.eye,
              'View Certificate',
              'Streams PDF inline',
            ),
          ),

          // ── Download  (GET …/download) ──────────────────────
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetCtx);
              _downloadCertificate(cert);
            },
            child: _actionRow(
              CupertinoIcons.cloud_download,
              'Download PDF',
              'Save to device storage',
            ),
          ),

          // ── Verify  (POST …/share) ──────────────────────────
          CupertinoActionSheetAction(
            isDestructiveAction: cert.lifecycle.state != 'Active',
            onPressed: () {
              Navigator.pop(sheetCtx);
              _verifyCertificate(cert);
            },
            child: _actionRow(
              CupertinoIcons.checkmark_seal_fill,
              'Verify Authenticity',
              cert.lifecycle.state == 'Active'
                  ? 'Get shareable verification URL'
                  : 'Unavailable — cert is ${cert.lifecycle.state}',
              disabled: cert.lifecycle.state != 'Active',
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(sheetCtx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // ── Action row widget (pure UI, no tap handling) ──────────────────────────
  Widget _actionRow(
    IconData icon,
    String label,
    String subtitle, {
    bool disabled = false,
  }) {
    final iconColor = disabled ? const Color(0xFF94A3B8) : const Color(0xFF5C55ED);
    final labelColor = disabled ? const Color(0xFF94A3B8) : null;
    final subColor = disabled
        ? const Color(0xFFEF4444).withOpacity(0.7)
        : const Color(0xFF64748B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: labelColor,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: subColor),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor   = isDark ? const Color(0xFF0D1117) : const Color(0xFFF4F6F9);
    final cardColor = isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final subLabel  = isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);
    final primary   = const Color(0xFF5C55ED);
    final border    = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // ── Fixed Premium Header ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: bgColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Certificates',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => themeProvider.toggleTheme(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: border),
                          ),
                          child: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await Provider.of<WalletProvider>(context, listen: false)
                              .logout();
                          if (mounted) {
                            Navigator.of(context, rootNavigator: true)
                                .pushAndRemoveUntil(
                              CupertinoPageRoute(
                                  builder: (_) => const LoginPage()),
                              (route) => false,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.square_arrow_right,
                            color: Color(0xFFEF4444),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Main Scrollable Content ───────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Filter segmented control
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl<String>(
                            groupValue: _selectedFilter,
                            backgroundColor: Colors.transparent,
                            thumbColor: isDark
                                ? const Color(0xFF30363D)
                                : const Color(0xFFE2E8F0),
                            onValueChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedFilter = val);
                              }
                            },
                            children: {
                              for (final f in _filters)
                                f: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    f,
                                    style: TextStyle(
                                      color: _selectedFilter == f
                                          ? primary
                                          : subLabel,
                                      fontSize: 13,
                                      fontWeight: _selectedFilter == f
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // List or empty state
                  _filteredCertificates.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.doc_text,
                                  size: 48,
                                  color: subLabel.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No records found',
                                  style:
                                      TextStyle(color: subLabel, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, index) {
                                final cert = _filteredCertificates[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildCard(
                                    cert,
                                    cardColor,
                                    textColor,
                                    subLabel,
                                    border,
                                    primary,
                                  ),
                                );
                              },
                              childCount: _filteredCertificates.length,
                            ),
                          ),
                        ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Certificate card ──────────────────────────────────────────────────────
  Widget _buildCard(
    WalletCert cert,
    Color cardColor,
    Color textColor,
    Color subLabel,
    Color border,
    Color primary,
  ) {
    final date = DateTime.tryParse(cert.issuedAt);
    final formatted =
        date != null ? DateFormat('MMM dd, yyyy').format(date) : cert.issuedAt;
    final loading = _isLoading(cert.id);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          // ── Top part (Clickable to show full details modal) ────
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: loading ? null : () => _showCertificateDetail(cert),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: loading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(CupertinoIcons.doc_fill,
                            color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert.templateName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cert.issuerName ?? 'JustyfAI Verified',
                          style: TextStyle(fontSize: 13, color: subLabel),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatted,
                          style: TextStyle(
                            fontSize: 11,
                            color: subLabel.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusBadge(cert.lifecycle.state),
                ],
              ),
            ),
          ),

          // ── Footer part (The 3 buttons) ───────────────────────
          Divider(height: 1, thickness: 0.5, color: Colors.transparent),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _cardActionButton(
                  icon: CupertinoIcons.eye_fill,
                  label: 'View',
                  onPressed: loading ? null : () => _viewCertificate(cert),
                  color: primary,
                  textColor: textColor,
                ),
                _cardActionButton(
                  icon: CupertinoIcons.cloud_download_fill,
                  label: 'Download',
                  onPressed: loading ? null : () => _downloadCertificate(cert),
                  color: primary,
                  textColor: textColor,
                ),
                _cardActionButton(
                  icon: CupertinoIcons.checkmark_seal_fill,
                  label: 'Verify',
                  onPressed: loading || cert.lifecycle.state != 'Active' 
                      ? null 
                      : () => _verifyCertificate(cert),
                  color: cert.lifecycle.state == 'Active' ? primary : Colors.grey,
                  textColor: textColor,
                  isDisabled: cert.lifecycle.state != 'Active',
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Card action button helper ─────────────────────────────────────────────
  Widget _cardActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    required Color textColor,
    bool isDisabled = false,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(isDisabled ? 0.05 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: isDisabled ? Colors.grey : color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDisabled ? Colors.grey : textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status badge ──────────────────────────────────────────────────────────
  Widget _statusBadge(String state) {
    final color =
        state == 'Active' ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        state.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}