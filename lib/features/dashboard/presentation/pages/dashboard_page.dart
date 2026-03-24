import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Colors, Curves, BoxShadow, Offset;
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/ios_theme.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/student/presentation/pages/certificates_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:student_app/features/wallet/data/models/wallet_cert_model.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class DashboardWrapper extends StatefulWidget {
  const DashboardWrapper({super.key});

  @override
  State<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends State<DashboardWrapper> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: IOSTheme.systemBackground.withOpacity(0.8),
        activeColor: IOSTheme.primaryBlue,
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
                            // ── Greeting Section ──────────
                            _buildGreeting(context, walletData),
                            const SizedBox(height: 25),

                            // ── Overview Section ──────────
                            const Text(
                              'Quick Overview',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            _buildStatsGrid(context, walletData),
                            const SizedBox(height: 30),

                            // ── Recent Activity ───────────
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
                            const SizedBox(height: 80), // Padding for tab bar
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, WalletData? data) {
    final name = data?.certificates.isNotEmpty == true 
        ? data!.certificates.first.recipientDisplay 
        : 'Student';

    return IOSTheme.glassContainer(
      context: context,
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome Back,', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                IOSTheme.glassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  borderRadius: 100,
                  showBorder: false,
                  context: context,
                  child: Text(
                    data?.session.email ?? 'Loading...',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)]),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: const Center(
              child: Icon(CupertinoIcons.person_fill, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WalletData? data) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            context,
            'Certificates',
            data?.certificates.length.toString() ?? '0',
            CupertinoIcons.app_badge_fill,
            CupertinoColors.systemBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            context,
            'Wallet Status',
            data?.session.valid == true ? 'Verified' : 'Pending',
            CupertinoIcons.checkmark_seal_fill,
            CupertinoColors.systemGreen,
          ),
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return IOSTheme.glassContainer(
      context: context,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, WalletData? data) {
    if (data == null || data.certificates.isEmpty) {
      return IOSTheme.glassContainer(
        context: context,
        width: double.infinity,
        child: const Center(child: Text('No recent activity')),
      );
    }

    final certs = data.certificates.take(4).toList();

    return IOSTheme.glassContainer(
      context: context,
      padding: EdgeInsets.zero,
      child: Column(
        children: certs.asMap().entries.map((entry) {
          final cert = entry.value;
          final isLast = entry.key == certs.length - 1;
          final date = DateTime.tryParse(cert.issuedAt);
          final formattedDate = date != null ? DateFormat('MMM dd').format(date) : 'N/A';

          return Column(
            children: [
              CupertinoListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: IOSTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(CupertinoIcons.doc_fill, color: IOSTheme.primaryBlue, size: 20),
                ),
                title: Text(cert.templateName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                subtitle: Text(cert.issuerName ?? 'Verify by JustyfAI', style: const TextStyle(fontSize: 13)),
                additionalInfo: Text(formattedDate, style: const TextStyle(fontSize: 12)),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: Container(height: 0.5, color: CupertinoColors.separator.resolveFrom(context)),
                ),
            ],
          );
        }).toList(),
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
