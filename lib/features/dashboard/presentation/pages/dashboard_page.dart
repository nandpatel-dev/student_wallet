import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Colors, Curves, BoxShadow, Offset, Theme, TargetPlatform, ScaffoldMessenger, SnackBar, SnackBarBehavior, RoundedRectangleBorder;
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/ios_theme.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/student/presentation/pages/certificates_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:student_app/features/wallet/data/models/wallet_cert_model.dart';
import 'package:student_app/features/auth/presentation/pages/login_page.dart';
import 'package:intl/intl.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:student_app/core/constants/api_constants.dart';

class DashboardWrapper extends StatefulWidget {
  const DashboardWrapper({super.key});

  @override
  State<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends State<DashboardWrapper> {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF),
        activeColor: const Color(0xFF5C55ED), // Primary Blue/Purple
        inactiveColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0))),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(top: 4, bottom: 2), child: Icon(CupertinoIcons.square_grid_2x2)),
            activeIcon: Padding(padding: EdgeInsets.only(top: 4, bottom: 2), child: Icon(CupertinoIcons.square_grid_2x2_fill)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(top: 4, bottom: 2), child: Icon(CupertinoIcons.doc)),
            activeIcon: Padding(padding: EdgeInsets.only(top: 4, bottom: 2), child: Icon(CupertinoIcons.doc_fill)),
            label: 'Certs',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            if (index == 0) return const DashboardPage();
            return const CertificatesPage();
          },
        );
      },
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final walletData = walletProvider.walletData;
    final isDark = themeProvider.isDarkMode;

    /*
    // ──────── OLD DESIGN (Commented out) ────────
    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.systemBackground,
      child: Stack(
        children: [
          // ── Background Depth ─────────────────────
          Positioned(
            top: -50,
            right: -20,
            child: _blurCircle(200, IOSTheme.primaryBlue.withOpacity(0.1)),
          ),

          // ── Scrollable Content ───────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text('Dashboard'),
                backgroundColor: IOSTheme.systemBackground.withOpacity(0.5),
                border: null,
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => themeProvider.toggleTheme(),
                  child: Icon(
                    isDark ? CupertinoIcons.sun_max : CupertinoIcons.moon_fill,
                    size: 22,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: walletProvider.isLoading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Center(child: CupertinoActivityIndicator()),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(IOSTheme.paddingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGreeting(context, walletData),
                            const SizedBox(height: 25),
                            const Text(
                              'Quick Overview',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            _buildStatsGrid(context, walletData),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Recent History',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                  child: const Text('See All', style: TextStyle(fontSize: 15)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildRecentActivity(context, walletData),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
    */

    // Theme Colors
    final bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF4F6F9);
    final cardColor = isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final subLabelColor = isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);
    final primaryColor = const Color(0xFF5C55ED); 
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return CupertinoPageScaffold(
      backgroundColor: bgColor, 
      child: SafeArea(
        child: Column(
          children: [
            // ── Fixed Custom Premium Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: bgColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dashboard',
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
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: primaryColor, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await Provider.of<WalletProvider>(context, listen: false).logout();
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                              CupertinoPageRoute(builder: (_) => const LoginPage()), 
                              (route) => false
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.square_arrow_right, color: Color(0xFFEF4444), size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Dashboard Content ──
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: walletProvider.isLoading
                        ? const Padding(
                            padding: EdgeInsets.only(top: 150),
                            child: Center(child: CupertinoActivityIndicator()),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Greeting Widget
                                _buildPremiumGlassGreeting(context, walletData),
                                const SizedBox(height: 30),

                                // Statistics Grid
                                Text(
                                  'YOUR PROGRESS',
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold,
                                    color: subLabelColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildPremiumGlassStats(context, walletData),
                                const SizedBox(height: 30),

                                // Recent Activity
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'RECENT ACTIVITY',
                                      style: TextStyle(
                                        fontSize: 12, 
                                        fontWeight: FontWeight.bold,
                                        color: subLabelColor,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {},
                                      child: Text(
                                        'View all', 
                                        style: TextStyle(
                                          fontSize: 13, 
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildPremiumGlassHistory(context, walletData),
                                const SizedBox(height: 100), 
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Clean Components Builders ──

  Widget _buildPremiumGlassGreeting(BuildContext context, WalletData? data) {
    final name = data?.certificates.isNotEmpty == true 
        ? data!.certificates.first.recipientDisplay 
        : 'Student';
    final email = data?.session.email ?? 'authenticating...';
    final primaryColor = const Color(0xFF5C55ED);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('C', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good morning,', 
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email, 
                  style: const TextStyle(
                    fontSize: 12, 
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumGlassStats(BuildContext context, WalletData? data) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final subLabelColor = isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return Row(
      children: [
        Expanded(
          child: _premiumStatCard(
            context,
            'Achievements',
            data?.certificates.length.toString() ?? '0',
            Icons.military_tech,
            const Color(0xFFF59E0B), // Amber/Orange
            cardColor, textColor, subLabelColor, borderColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _premiumStatCard(
            context,
            'Verification',
            data?.session.valid == true ? 'Active' : 'Pending',
            Icons.check_box_rounded,
            const Color(0xFF10B981), // Green
            cardColor, textColor, subLabelColor, borderColor,
            valueColor: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _premiumStatCard(BuildContext context, String label, String value, IconData icon, Color accentColor, Color cardCol, Color textCol, Color subCol, Color borderCol, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardCol,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: valueColor == null ? [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.02), offset: const Offset(0, 4))] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 28),
          const SizedBox(height: 20),
          Text(
            value, 
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: valueColor ?? textCol,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              fontSize: 13, 
              color: subCol,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumGlassHistory(BuildContext context, WalletData? data) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final subLabelColor = isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final primaryColor = const Color(0xFF5C55ED);

    if (data == null || data.certificates.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
        child: Center(
          child: Text(
            'No activity recorded yet', 
            style: TextStyle(color: subLabelColor, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final certs = data.certificates.take(3).toList();

    return Column(
      children: certs.map((cert) {
        final date = DateTime.tryParse(cert.issuedAt);
        final formattedDate = date != null ? DateFormat('MMM dd').format(date) : 'Mar 27';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(CupertinoIcons.doc_fill, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.templateName, 
                      style: TextStyle(
                        color: textColor, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cert.issuerName ?? 'JustyfAI Verified', 
                      style: TextStyle(
                        color: subLabelColor, 
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formattedDate, style: TextStyle(color: subLabelColor, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  )
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _downloadCertificate(BuildContext context, WalletCert cert) async {
    final downloadUrl = ApiConstants.downloadCertificate(cert.id);
    final safeName = cert.templateName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    await _downloadAndOpenFile(context, downloadUrl, 'Certificate_$safeName.pdf', openAfterDownload: false);
  }

  Future<void> _downloadAndOpenFile(BuildContext context, String url, String fileName, {bool openAfterDownload = true}) async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final token = await walletProvider.getToken();
    _showToast(context, openAfterDownload ? 'Getting document...' : 'Downloading to local storage...');

    try {
      String savePath;
      if (!openAfterDownload && Theme.of(context).platform == TargetPlatform.android) {
        savePath = '/storage/emulated/0/Download/$fileName';
      } else {
        final directory = openAfterDownload ? await getTemporaryDirectory() : await getApplicationDocumentsDirectory();
        savePath = '${directory.path}/$fileName';
      }

      final dio = Dio();
      await dio.download(
        url,
        savePath,
        options: Options(
          headers: {'x-student-wallet': token},
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (openAfterDownload) {
        _showToast(context, 'Opening document...');
        final result = await OpenFilex.open(savePath);
        if (result.type != ResultType.done) {
          throw Exception(result.message);
        }
      } else {
        _showToast(context, '✅ Downloaded to device storage!');
      }
    } catch (e) {
      if (!openAfterDownload && Theme.of(context).platform == TargetPlatform.android) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final fallbackPath = '\${directory.path}/\$fileName';
          await Dio().download(url, fallbackPath, options: Options(headers: {'x-student-wallet': token}));
          _showToast(context, '✅ Saved to app documents!');
          return;
        } catch (_) {}
      }
      if (context.mounted) _showToast(context, 'Error: \${e.toString()}', isError: true);
    }
  }

  void _showToast(BuildContext context, String message, {bool isError = false}) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message, 
          style: TextStyle(
            color: isError ? Colors.white : (isDark ? const Color(0xFF1C1A18) : Colors.white),
            fontWeight: FontWeight.w600
          )
        ),
        backgroundColor: isError 
            ? const Color(0xFFEF4444) 
            : (isDark ? const Color(0xFFC8A27C) : const Color(0xFF2E2A27)).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /*
  // ── OLD HELPER METHODS (Commented out) ──
  Widget _buildGreeting(BuildContext context, WalletData? data) { ... }
  Widget _buildStatsGrid(BuildContext context, WalletData? data) { ... }
  Widget _statCard(BuildContext context, String label, String value, IconData icon, Color color) { ... }
  Widget _buildRecentActivity(BuildContext context, WalletData? data) { ... }
  */

}
