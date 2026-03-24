import 'package:flutter/material.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:student_app/features/wallet/data/models/wallet_cert_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage>
    with SingleTickerProviderStateMixin {

  // ── State ──────────────────────────────────────
  String _selectedFilter          = 'All';
  late TabController _tabController;
  final Map<String, bool> _downloading = {};
  final Map<String, bool> _downloaded  = {};

  // ── Filter List ────────────────────────────────
  final List<String> _filters = [
    'All',
    'Active',
    'Revoked',
    'Frozen',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _filters.length,
      vsync:  this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedFilter = _filters[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Filtered List ──────────────────────────────
  List<WalletCert> get _filteredCertificates {
    final certs = Provider.of<WalletProvider>(context, listen: false).walletData?.certificates ?? [];
    if (_selectedFilter == 'All') return certs;
    return certs
        .where((c) => c.lifecycle.state == _selectedFilter)
        .toList();
  }

  // ── Summary Counts ─────────────────────────────
  int _countByCategory(String state) {
    final certs = Provider.of<WalletProvider>(context, listen: false).walletData?.certificates ?? [];
    if (state == 'All') return certs.length;
    return certs
        .where((c) => c.lifecycle.state == state)
        .length;
  }

  // ── Snackbar Helper ────────────────────────────
  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size:  18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? AppTheme.accentRed
            : AppTheme.accentGreen,
        behavior:  SnackBarBehavior.floating,
        duration:  const Duration(seconds: 3),
      ),
    );
  }

  // ── VIEW Certificate ───────────────────────────
  Future<void> _viewCertificate(
    BuildContext context,
    WalletCert cert,
  ) async {
    final viewUrl  = cert.viewUrl;
    try {
      await launchUrl(Uri.parse(viewUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(
          context,
          'Failed to open certificate.',
          isError: true,
        );
      }
    }
  }

  // ── DOWNLOAD Certificate ───────────────────────
  Future<void> _downloadCertificate(
    BuildContext context,
    WalletCert cert,
  ) async {
    final downloadUrl = cert.downloadUrl;
    try {
      await launchUrl(Uri.parse(downloadUrl), mode: LaunchMode.externalApplication);
      _showSnackbar(context, 'Starting download...');
    } catch (e) {
      if (mounted) {
        _showSnackbar(
          context,
          'Failed to start download.',
          isError: true,
        );
      }
    }
  }

  // ── Certificate Detail Bottom Sheet — M3 ──────
  void _showCertificateDetail(
    BuildContext context,
    WalletCert cert,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final title       = cert.templateName;
    final date = DateTime.tryParse(cert.issuedAt);
    final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : cert.issuedAt;

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      useSafeArea:        true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDownloading = _downloading[title] ?? false;
            final isDownloaded  = _downloaded[title]  ?? false;

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLarge,
                AppTheme.spacingSmall,
                AppTheme.spacingLarge,
                AppTheme.spacingXLarge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ── Drag Handle ───────────────
                  Container(
                    width:  40,
                    height: 4,
                    margin: const EdgeInsets.only(
                      bottom: AppTheme.spacingLarge,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.outlineColor(context),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusCircle,
                      ),
                    ),
                  ),

                  // ── Certificate Icon ──────────
                  Container(
                    width:  80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.card_membership_rounded,
                      color: colorScheme.primary,
                      size:  38,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  // ── Title ─────────────────────
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingXSmall),

                  // ── Issuer ────────────────────
                  Text(
                    cert.issuerName ?? 'Unknown Issuer',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),

                  // ── Detail Chips Row ──────────
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      _detailChip(
                        context,
                        label: 'Date',
                        value: formattedDate,
                        icon:  Icons.calendar_month_rounded,
                        color: AppTheme.accentBlue,
                      ),
                      _detailChip(
                        context,
                        label: 'Status',
                        value: cert.status,
                        icon:  Icons.info_outline_rounded,
                        color: AppTheme.accentOrange,
                      ),
                      _detailChip(
                        context,
                        label: 'State',
                        value: cert.lifecycle.state,
                        icon:  Icons.category_rounded,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),

                  // ── Verified Badge ────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical:   AppTheme.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusCircle,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: colorScheme.onPrimaryContainer,
                          size:  16,
                        ),
                        const SizedBox(
                          width: AppTheme.spacingXSmall,
                        ),
                        Text(
                          'Verified on Blockchain (${cert.network ?? 'polygon'})',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXLarge),

                  // ── 3 Action Buttons ──────────
                  Row(
                    children: [

                      // ── Close ─────────────────
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon:  const Icon(
                            Icons.close_rounded,
                            size: 18,
                          ),
                          label: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),

                      // ── View ──────────────────
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _viewCertificate(
                              context,
                              cert,
                            );
                          },
                          icon:  const Icon(
                            Icons.visibility_rounded,
                            size: 18,
                          ),
                          label: const Text('View'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),

                      // ── Download ──────────────
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            await _downloadCertificate(
                              context,
                              cert,
                            );
                          },
                          icon: Icon(
                            Icons.download_rounded,
                            size: 18,
                          ),
                          label: Text('Download'),
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Detail Chip Widget ─────────────────────────
  Widget _detailChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width:  52,
          height: 52,
          decoration: BoxDecoration(
            color:        color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: AppTheme.spacingXSmall),
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.labelLarge?.copyWith(color: color),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),

      // ── M3 AppBar with TabBar ──────────────
      appBar: AppBar(
        title: Text(
          'My Certificates',
          style: textTheme.titleLarge,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(
              right: AppTheme.spacingMedium,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSmall,
              vertical:   AppTheme.spacingXSmall,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(
                AppTheme.radiusCircle,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size:  14,
                ),
                const SizedBox(width: AppTheme.spacingXSmall),
                Consumer<WalletProvider>(
                  builder: (context, provider, child) {
                    final count = provider.walletData?.certificates.length ?? 0;
                    return Text(
                      '$count Total',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller:          _tabController,
          isScrollable:        true,
          tabAlignment:        TabAlignment.start,
          dividerColor:        Colors.transparent,
          indicatorSize:       TabBarIndicatorSize.tab,
          indicatorColor:      colorScheme.primary,
          labelColor:          colorScheme.primary,
          unselectedLabelColor: AppTheme.textSecondary(context),
          labelStyle:          textTheme.labelLarge,
          unselectedLabelStyle: textTheme.labelLarge,
          tabs: _filters.map((f) => Tab(text: f)).toList(),
        ),
      ),

      body: Column(
        children: [

          // ── Summary Cards Row ──────────────
          Container(
            color: AppTheme.surfaceColor(context),
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: _buildSummaryRow(context),
          ),

          // ── Certificate List ───────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _filteredCertificates.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      key: ValueKey(_selectedFilter),
                      padding: const EdgeInsets.all(
                        AppTheme.spacingMedium,
                      ),
                      itemCount: _filteredCertificates.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(
                            height: AppTheme.spacingSmall,
                          ),
                      itemBuilder: (context, index) =>
                          _buildCertificateCard(
                        context,
                        _filteredCertificates[index],
                        index,
                      ),
                    ),
            ),
          ),

        ],
      ),
    );
  }

  // ── Summary Row ─────────────────────────────────
  Widget _buildSummaryRow(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    final summary = [
      {
        'label': 'Active',
        'count': _countByCategory('Active').toString(),
        'color': AppTheme.accentGreen,
        'icon':  Icons.check_circle_rounded,
      },
      {
        'label': 'Revoked',
        'count': _countByCategory('Revoked').toString(),
        'color': AppTheme.accentRed,
        'icon':  Icons.cancel_rounded,
      },
      {
        'label': 'Frozen',
        'count': _countByCategory('Frozen').toString(),
        'color': AppTheme.accentBlue,
        'icon':  Icons.ac_unit_rounded,
      },
    ];

    return Row(
      children: summary.asMap().entries.map((entry) {
        final index = entry.key;
        final item  = entry.value;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = item['label'] as String;
                _tabController.animateTo(
                  _filters.indexOf(item['label'] as String),
                );
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: index == summary.length - 1
                    ? 0
                    : AppTheme.spacingSmall,
              ),
              padding: const EdgeInsets.symmetric(
                vertical:   AppTheme.spacingSmall,
                horizontal: AppTheme.spacingXSmall,
              ),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppTheme.radiusMedium,
                ),
                border: Border.all(
                  color: _selectedFilter == item['label']
                      ? (item['color'] as Color)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size:  18,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['count'] as String,
                    style: textTheme.titleMedium?.copyWith(
                      color:      item['color'] as Color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item['label'] as String,
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Certificate Card Widget ───────────────────
  Widget _buildCertificateCard(
    BuildContext context,
    WalletCert cert,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final date = DateTime.tryParse(cert.issuedAt);
    final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : cert.issuedAt;

    return Card(
      child: InkWell(
        onTap: () => _showCertificateDetail(context, cert),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Row(
            children: [

              // ── Icon ──────────────────
              Container(
                width:  52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(
                    AppTheme.radiusMedium,
                  ),
                ),
                child: Icon(
                  Icons.card_membership_rounded,
                  color: colorScheme.primary,
                  size:  24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),

              // ── Details ───────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.templateName,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      cert.issuerName ?? 'Unknown Issuer',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // ── Trailing ──────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedDate,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSmall,
                      vertical:   2,
                    ),
                    decoration: BoxDecoration(
                      color: cert.lifecycle.state == 'Active' 
                          ? AppTheme.accentGreen.withOpacity(0.12)
                          : AppTheme.accentRed.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusCircle,
                      ),
                    ),
                    child: Text(
                      cert.lifecycle.state,
                      style: textTheme.labelSmall?.copyWith(
                        color: cert.lifecycle.state == 'Active'
                            ? AppTheme.accentGreen
                            : AppTheme.accentRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }


  // ── Empty State ──────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_membership_rounded,
                size:  48,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'No Certificates Found',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'No certificates in $_selectedFilter yet',
              style:     textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                  _tabController.animateTo(0);
                });
              },
              icon:  const Icon(Icons.list_rounded),
              label: const Text('View All Certificates'),
            ),
          ],
        ),
      ),
    );
  }
}
