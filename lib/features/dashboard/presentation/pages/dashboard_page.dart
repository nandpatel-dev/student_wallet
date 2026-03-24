import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/student/presentation/pages/certificates_page.dart';
import 'package:student_app/features/student/presentation/pages/profile_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:student_app/features/wallet/data/models/wallet_cert_model.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────
// DASHBOARD WRAPPER — M3 NavigationBar
// ─────────────────────────────────────────────────
class DashboardWrapper extends StatefulWidget {
  const DashboardWrapper({super.key});

  @override
  State<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends State<DashboardWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardPage(),
    const CertificatesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve:  Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),

      // ── M3 NavigationBar ──────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon:          Icon(Icons.dashboard_outlined),
            selectedIcon:  Icon(Icons.dashboard_rounded),
            label:         'Dashboard',
          ),
          NavigationDestination(
            icon:          Icon(Icons.card_membership_outlined),
            selectedIcon:  Icon(Icons.card_membership_rounded),
            label:         'Certificates',
          ),
          NavigationDestination(
            icon:          Icon(Icons.person_outline_rounded),
            selectedIcon:  Icon(Icons.person_rounded),
            label:         'Profile',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// DASHBOARD PAGE — M3 UI
// ─────────────────────────────────────────────────
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).loadWallet();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme   = Theme.of(context).colorScheme;
    final textTheme     = Theme.of(context).textTheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final walletData = walletProvider.walletData;
    final isDark        = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),

      // ── M3 AppBar ───────────────────────────────
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width:  36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                color: colorScheme.onPrimaryContainer,
                size:  20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Text(
              'Dashboard',
              style: textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          // ── Theme Toggle ────────────────────
          IconButton(
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          ),
          // ── Notification ────────────────────
          IconButton(
            onPressed: () {},
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: AppTheme.spacingXSmall),
        ],
      ),

      body: walletProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : walletProvider.error != null
              ? Center(child: Text('Error: ${walletProvider.error}'))
              : Scrollbar(
                  controller:    _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding:    const EdgeInsets.all(AppTheme.spacingMedium),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Greeting Card ──────────────────
                      _buildGreetingCard(context, walletData),
                      const SizedBox(height: AppTheme.spacingLarge),

                      // ── Stats Section ──────────────────
                      Text(
                        'Overview',
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      _buildStatsGrid(context, walletData),
                      const SizedBox(height: AppTheme.spacingLarge),

                      // ── Recent Activity ────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      _buildRecentActivity(context, walletData),
                      const SizedBox(height: AppTheme.spacingLarge),

                    ],
                  ),
                ),
              ),
    );
  }

  // ── Greeting Card ────────────────────────────────
  Widget _buildGreetingCard(BuildContext context, WalletData? data) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final email = data?.session.email ?? 'Student';
    final name = data?.certificates.isNotEmpty == true 
        ? data!.certificates.first.recipientDisplay 
        : 'Student';

    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color:        colorScheme.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back 👋',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Text(
                  name,
                  style: textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSmall,
                    vertical:   AppTheme.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusCircle,
                    ),
                  ),
                  child: Text(
                    email,
                    style: textTheme.labelSmall?.copyWith(
                      color:       Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Avatar ──────────────────────────
          Container(
            width:  56,
            height: 56,
            decoration: BoxDecoration(
              color:  Colors.white.withOpacity(0.2),
              shape:  BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                'RP',
                style: textTheme.titleLarge?.copyWith(
                  color:      Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Grid — M3 Cards ────────────────────────
  Widget _buildStatsGrid(BuildContext context, WalletData? data) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final certCount = data?.certificates.length ?? 0;

    final stats = [
      {
        'label':     'Certificates',
        'value':     certCount.toString(),
        'icon':      Icons.workspace_premium_rounded,
        'color':     colorScheme.primary,
        'container': colorScheme.primaryContainer,
      },
      {
        'label':     'Status',
        'value':     data?.session.valid == true ? 'Active' : 'Expired',
        'icon':      Icons.verified_user_rounded,
        'color':     AppTheme.accentGreen,
        'container': AppTheme.accentGreen.withOpacity(0.12),
      },
    ];

    return GridView.builder(
      shrinkWrap:  true,
      physics:     const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: AppTheme.spacingSmall,
        mainAxisSpacing:  AppTheme.spacingSmall,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              children: [
                Container(
                  width:  44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:        stat['container'] as Color,
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusMedium,
                    ),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size:  22,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: [
                      Text(
                        stat['value'] as String,
                        style: textTheme.titleLarge?.copyWith(
                          color:      stat['color'] as Color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        stat['label'] as String,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // ── Recent Activity — M3 Cards ───────────────────
  Widget _buildRecentActivity(BuildContext context, WalletData? data) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (data == null || data.certificates.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          child: Center(child: Text('No certificates found.')),
        ),
      );
    }

    final certificates = data.certificates.take(5).toList();

    return Card(
      child: Column(
        children: certificates.asMap().entries.map((entry) {
          final index    = entry.key;
          final cert = entry.value;
          final date = DateTime.tryParse(cert.issuedAt);
          final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : cert.issuedAt;

          return Column(
            children: [
              ListTile(
                leading: Container(
                  width:  44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusMedium,
                    ),
                  ),
                  child: Icon(
                    Icons.card_membership_rounded,
                    color: colorScheme.primary,
                    size:  22,
                  ),
                ),
                title: Text(
                  cert.templateName,
                  style: textTheme.titleMedium,
                ),
                subtitle: Text(
                  cert.issuerName ?? 'Unknown Issuer',
                  style: textTheme.bodyMedium,
                ),
                trailing: Text(
                  formattedDate,
                  style: textTheme.bodySmall,
                ),
              ),
              if (index != certificates.length - 1)
                const Divider(height: 1, indent: 72, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
