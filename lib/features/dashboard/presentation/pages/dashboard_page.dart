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
import 'dart:ui';
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
        backgroundColor: (isDark ? Colors.white : const Color(0xFF2E2A27)).withOpacity(0.05),
        activeColor: isDark ? const Color(0xFFF1EDE8) : const Color(0xFF2E2A27),
        inactiveColor: (isDark ? const Color(0xFFF1EDE8) : const Color(0xFF2E2A27)).withOpacity(0.4),
        border: null,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc),
            activeIcon: Icon(CupertinoIcons.doc_fill),
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

    // ──────── NEW PREMIUM GLASSMORPHISM DESIGN ────────
    return CupertinoPageScaffold(
      backgroundColor: Colors.black, 
      child: Stack(
        children: [
          // ── Animated Background Gradient ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0F0E0D), const Color(0xFF1C1A18), const Color(0xFF0F0E0D)] // Dark Coffee
                      : [const Color(0xFFFAFAF9), const Color(0xFFF5F5DC), const Color(0xFFE7E5E4)], // Warm Beige / Stone
                ),
              ),
            ),
          ),

          // ── Ambient Blur Orbs for Depth ──
          Positioned(
            top: -100,
            left: -100,
            child: _blurCircle(450, isDark ? Colors.blue.withOpacity(0.35) : Colors.orange.withOpacity(0.15)),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: _blurCircle(550, isDark ? Colors.purple.withOpacity(0.25) : Colors.brown.withOpacity(0.1)),
          ),
          Positioned(
            top: 250,
            right: -100,
            child: _blurCircle(350, isDark ? Colors.cyan.withOpacity(0.15) : Colors.orange.withOpacity(0.08)),
          ),

          // ── Dashboard Content ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverPadding(padding: EdgeInsets.only(top: 100)), // Space for fixed header
              SliverToBoxAdapter(
                child: walletProvider.isLoading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 150),
                        child: Center(child: CupertinoActivityIndicator(color: Colors.white)),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting Widget
                            _buildPremiumGlassGreeting(context, walletData),
                            const SizedBox(height: 35),

                            // Statistics Grid
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 18),
                              child: Text(
                                'Your Progress',
                                style: TextStyle(
                                  fontSize: 22, 
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFF1EDE8) : const Color(0xFF2E2A27),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            _buildPremiumGlassStats(context, walletData),
                            const SizedBox(height: 40),

                            // Recent Activity
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent activity',
                                    style: TextStyle(
                                      fontSize: 22, 
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFFF1EDE8) : const Color(0xFF2E2A27),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {},
                                    child: Text(
                                      'View all', 
                                      style: TextStyle(
                                        fontSize: 15, 
                                        color: isDark ? const Color(0xFFF1EDE8).withOpacity(0.6) : const Color(0xFF6D655F),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

          // ── Fixed Custom Premium Header ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildCustomPremiumHeader(context, 'Dashboard', themeProvider),
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
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? const Color(0xFFF1EDE8) : const Color(0xFF2E2A27),
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => themeProvider.toggleTheme(),
                    child: _glassButtonIcon(isDark ? CupertinoIcons.sun_max : CupertinoIcons.moon_fill, isDark),
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
                    child: _glassButtonIcon(CupertinoIcons.power, isDark, isLogout: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Premium Glass Component Builders ──

  Widget _glassButtonIcon(IconData icon, bool isDark, {bool isLogout = false}) {
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
      child: Icon(icon, color: isLogout ? const Color(0xFFF87171) : (isDark ? const Color(0xFFF1EDE8) : const Color(0xFF2E2A27)), size: 20),
    );
  }

  Widget _buildPremiumGlassGreeting(BuildContext context, WalletData? data) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final name = data?.certificates.isNotEmpty == true 
        ? data!.certificates.first.recipientDisplay 
        : 'Student';

    return _glassmorphismCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning,', 
                  style: TextStyle(color: (isDark ? const Color(0xFFF1EDE8) : const Color(0xFF6D655F)).withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.w900, 
                    color: isDark ? const Color(0xFFF1EDE8) : const Color(0xFF2E2A27),
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFFF1EDE8) : Colors.white).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: (isDark ? const Color(0xFFF1EDE8) : Colors.white).withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.mail, size: 12, color: (isDark ? const Color(0xFFF1EDE8) : Colors.white).withOpacity(0.6)),
                      const SizedBox(width: 8),
                      Text(
                        data?.session.email ?? 'authenticating...',
                        style: TextStyle(
                          fontSize: 11, 
                          fontWeight: FontWeight.w600, 
                          color: (isDark ? const Color(0xFFF1EDE8) : const Color(0xFF6D655F)).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _premiumGlassAvatar(context),
        ],
      ),
    );
  }

  Widget _premiumGlassAvatar(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [const Color(0xFFC8A27C), const Color(0xFFE6C7A1)] // Caramel to Latte (Dark Coffee)
              : [const Color(0xFF78716C), const Color(0xFF44403C)], // Stone/Warm Grey (Light)
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFFC8A27C) : const Color(0xFF78716C)).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Center(
        child: Icon(CupertinoIcons.person_fill, color: isDark ? const Color(0xFFF1EDE8) : const Color(0xFFFDFCF0), size: 32),
      ),
    );
  }

  Widget _buildPremiumGlassStats(BuildContext context, WalletData? data) {
    return Row(
      children: [
        Expanded(
          child: _premiumStatCard(
            context,
            'Achievements',
            data?.certificates.length.toString() ?? '0',
            CupertinoIcons.app_badge_fill,
            const Color(0xFFFACC15), // Amber
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _premiumStatCard(
            context,
            'Verification',
            data?.session.valid == true ? 'Active' : 'Pending',
            CupertinoIcons.checkmark_seal_fill,
            const Color(0xFF22D3EE), // Cyan
          ),
        ),
      ],
    );
  }

  Widget _premiumStatCard(BuildContext context, String label, String value, IconData icon, Color accentColor) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return _glassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(height: 24),
          Text(
            value, 
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.w900, 
              color: isDark ? const Color(0xFFF1EDE8) : const Color(0xFF2E2A27),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              fontSize: 12, 
              color: (isDark ? const Color(0xFFF1EDE8) : const Color(0xFF6D655F)).withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumGlassHistory(BuildContext context, WalletData? data) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    if (data == null || data.certificates.isEmpty) {
      return _glassmorphismCard(
        width: double.infinity,
        padding: const EdgeInsets.all(60),
        child: Center(
          child: Column(
            children: [
              Icon(CupertinoIcons.doc_fill, color: Colors.white.withOpacity(0.2), size: 40),
              const SizedBox(height: 16),
              Text(
                'No activity recorded yet', 
                style: TextStyle(color: (isDark ? const Color(0xFFF1EDE8) : const Color(0xFF9C938C)), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    final certs = data.certificates.take(3).toList();

    return _glassmorphismCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: certs.asMap().entries.map((entry) {
          final cert = entry.value;
          final isLast = entry.key == certs.length - 1;
          final date = DateTime.tryParse(cert.issuedAt);
          final formattedDate = date != null ? DateFormat('MMM dd').format(date) : 'Recently';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(CupertinoIcons.doc_fill, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cert.templateName, 
                            style: TextStyle(
                              color: isDark ? const Color(0xFFF1EDE8) : const Color(0xFF2E2A27), 
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            cert.issuerName ?? 'JustyfAI Verified', 
                            style: TextStyle(
                              color: (isDark ? const Color(0xFFF1EDE8) : const Color(0xFF6D655F)).withOpacity(0.7), 
                              fontSize: 13,
                            ),
                          ),
                        ],
                        ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _downloadCertificate(context, cert),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isDark ? const Color(0xFFC8A27C) : const Color(0xFF2E2A27)).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CupertinoIcons.cloud_download,
                          color: isDark ? const Color(0xFFC8A27C) : const Color(0xFF2E2A27),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate, 
                      style: TextStyle(
                        color: (isDark ? const Color(0xFFF1EDE8) : const Color(0xFF9C938C)), 
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 80, right: 20),
                  child: Container(
                    height: 1, 
                    color: Colors.white.withOpacity(0.08)
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _glassmorphismCard({required Widget child, EdgeInsets? padding, double? width, double borderRadius = 30}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
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
      ),
    );
  }

  Future<void> _downloadCertificate(BuildContext context, WalletCert cert) async {
    final downloadUrl = ApiConstants.downloadCertificate(cert.id);
    final safeName = cert.templateName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    await _downloadAndOpenFile(context, downloadUrl, 'Certificate_\$safeName.pdf', openAfterDownload: false);
  }

  Future<void> _downloadAndOpenFile(BuildContext context, String url, String fileName, {bool openAfterDownload = true}) async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final token = await walletProvider.getToken();
    _showToast(context, openAfterDownload ? 'Getting document...' : 'Downloading to local storage...');

    try {
      String savePath;
      if (!openAfterDownload && Theme.of(context).platform == TargetPlatform.android) {
        savePath = '/storage/emulated/0/Download/\$fileName';
      } else {
        final directory = openAfterDownload ? await getTemporaryDirectory() : await getApplicationDocumentsDirectory();
        savePath = '\${directory.path}/\$fileName';
      }

      final dio = Dio();
      await dio.download(
        url,
        savePath,
        options: Options(
          headers: {'x-student-wallet': token},
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
      if (context.mounted) _showToast(context, 'Download Error: \${e.toString()}', isError: true);
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


  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}
