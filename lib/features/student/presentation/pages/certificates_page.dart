import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:student_app/core/theme/app_theme.dart';

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
    'Technical',
    'Academic',
    'Sports',
    'Extra',
  ];

  // ── Certificate Data ───────────────────────────
  final List<Map<String, dynamic>> _certificates = [
    {
      'title':    'Flutter Development',
      'issuer':   'Udemy',
      'date':     '15 Jan 2025',
      'category': 'Technical',
      'icon':     Icons.phone_android_rounded,
      'color':    AppTheme.primaryColor,
      'grade':    'Distinction',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Python Programming',
      'issuer':   'Coursera',
      'date':     '10 Dec 2024',
      'category': 'Technical',
      'icon':     Icons.code_rounded,
      'color':    AppTheme.accentBlue,
      'grade':    'Merit',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Web Development',
      'issuer':   'freeCodeCamp',
      'date':     '20 Nov 2024',
      'category': 'Technical',
      'icon':     Icons.web_rounded,
      'color':    AppTheme.accentGreen,
      'grade':    'Distinction',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'UI/UX Design',
      'issuer':   'Google',
      'date':     '01 Nov 2024',
      'category': 'Technical',
      'icon':     Icons.design_services_rounded,
      'color':    AppTheme.primaryColor,
      'grade':    'Merit',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Leaving Certificate',
      'issuer':   'GTU University',
      'date':     '01 Jun 2021',
      'category': 'Academic',
      'icon':     Icons.school_rounded,
      'color':    AppTheme.primaryColor,
      'grade':    'Official',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Semester 1 Marksheet',
      'issuer':   'GTU University',
      'date':     '15 Mar 2022',
      'category': 'Academic',
      'icon':     Icons.description_rounded,
      'color':    AppTheme.accentBlue,
      'grade':    'CGPA 8.2',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Semester 2 Marksheet',
      'issuer':   'GTU University',
      'date':     '20 Aug 2022',
      'category': 'Academic',
      'icon':     Icons.description_rounded,
      'color':    AppTheme.accentBlue,
      'grade':    'CGPA 8.4',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Semester 3 Marksheet',
      'issuer':   'GTU University',
      'date':     '18 Mar 2023',
      'category': 'Academic',
      'icon':     Icons.description_rounded,
      'color':    AppTheme.accentBlue,
      'grade':    'CGPA 8.5',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Semester 4 Marksheet',
      'issuer':   'GTU University',
      'date':     '22 Aug 2023',
      'category': 'Academic',
      'icon':     Icons.description_rounded,
      'color':    AppTheme.accentBlue,
      'grade':    'CGPA 8.6',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Semester 5 Marksheet',
      'issuer':   'GTU University',
      'date':     '10 Mar 2024',
      'category': 'Academic',
      'icon':     Icons.description_rounded,
      'color':    AppTheme.accentBlue,
      'grade':    'CGPA 8.7',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Scholarship Certificate',
      'issuer':   'State Government',
      'date':     '05 Apr 2024',
      'category': 'Academic',
      'icon':     Icons.workspace_premium_rounded,
      'color':    AppTheme.accentOrange,
      'grade':    'Merit Based',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Best Student Award',
      'issuer':   'GTU University',
      'date':     '05 Dec 2024',
      'category': 'Academic',
      'icon':     Icons.emoji_events_rounded,
      'color':    AppTheme.accentOrange,
      'grade':    'Gold',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Cricket Tournament',
      'issuer':   'College Sports Dept',
      'date':     '10 Nov 2024',
      'category': 'Sports',
      'icon':     Icons.sports_cricket_rounded,
      'color':    AppTheme.accentRed,
      'grade':    '1st Place',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
    {
      'title':    'Science Exhibition',
      'issuer':   'State Board',
      'date':     '15 Oct 2024',
      'category': 'Extra',
      'icon':     Icons.science_rounded,
      'color':    AppTheme.accentBlue,
      'grade':    '2nd Place',
      'viewUrl':  'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      'downloadUrl': 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    },
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
  List<Map<String, dynamic>> get _filteredCertificates {
    if (_selectedFilter == 'All') return _certificates;
    return _certificates
        .where((c) => c['category'] == _selectedFilter)
        .toList();
  }

  // ── Summary Counts ─────────────────────────────
  int _countByCategory(String category) {
    return _certificates
        .where((c) => c['category'] == category)
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
    Map<String, dynamic> cert,
  ) async {
    final title    = cert['title'] as String;
    final viewUrl  = cert['viewUrl'] as String;

    try {
      // First download to temp then open
      final tempDir  = await getTemporaryDirectory();
      final fileName = '${title.replaceAll(' ', '_')}_view.pdf';
      final filePath = '${tempDir.path}/$fileName';
      final file     = File(filePath);

      // Show loading snackbar
      _showSnackbar(context, 'Opening $title...');

      // Download if not already cached
      if (!await file.exists()) {
        await Dio().download(viewUrl, filePath);
      }

      // Open the file
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        if (context.mounted) {
          _showSnackbar(
            context,
            'Could not open file. No PDF viewer found.',
            isError: true,
          );
        }
      }
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
    Map<String, dynamic> cert,
  ) async {
    final title       = cert['title'] as String;
    final downloadUrl = cert['downloadUrl'] as String;

    // Already downloaded check
    if (_downloaded[title] == true) {
      _showSnackbar(context, '$title already downloaded!');
      return;
    }

    // Set downloading state
    setState(() => _downloading[title] = true);

    try {
      // Get downloads directory
      final dir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      // Create if not exists
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final fileName = '${title.replaceAll(' ', '_')}.pdf';
      final filePath = '${dir.path}/$fileName';

      // Download with progress
      await Dio().download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          // Progress available here if needed
        },
      );

      // Update state
      if (mounted) {
        setState(() {
          _downloading[title] = false;
          _downloaded[title]  = true;
        });
        _showSnackbar(
          context,
          '$title downloaded successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloading[title] = false);
        _showSnackbar(
          context,
          'Download failed. Please try again.',
          isError: true,
        );
      }
    }
  }

  // ── Certificate Detail Bottom Sheet — M3 ──────
  void _showCertificateDetail(
    BuildContext context,
    Map<String, dynamic> cert,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final title       = cert['title'] as String;

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
                      color: (cert['color'] as Color)
                          .withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cert['icon'] as IconData,
                      color: cert['color'] as Color,
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
                    cert['issuer'] as String,
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
                        value: cert['date'] as String,
                        icon:  Icons.calendar_month_rounded,
                        color: AppTheme.accentBlue,
                      ),
                      _detailChip(
                        context,
                        label: 'Grade',
                        value: cert['grade'] as String,
                        icon:  Icons.grade_rounded,
                        color: AppTheme.accentOrange,
                      ),
                      _detailChip(
                        context,
                        label: 'Category',
                        value: cert['category'] as String,
                        icon:  Icons.category_rounded,
                        color: cert['color'] as Color,
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
                          'Verified Certificate',
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
                          onPressed: isDownloading
                              ? null
                              : () async {
                                  await _downloadCertificate(
                                    context,
                                    cert,
                                  );
                                  setSheetState(() {});
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: isDownloaded
                                ? AppTheme.accentGreen
                                : null,
                          ),
                          icon: isDownloading
                              ? const SizedBox(
                                  width:  16,
                                  height: 16,
                                  child:  CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  isDownloaded
                                      ? Icons.check_rounded
                                      : Icons.download_rounded,
                                  size: 18,
                                ),
                          label: Text(
                            isDownloading
                                ? 'Saving...'
                                : isDownloaded
                                    ? 'Saved'
                                    : 'Download',
                          ),
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
                Text(
                  '${_certificates.length} Total',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
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
    final summary = [
      {
        'label': 'Technical',
        'count': _countByCategory('Technical').toString(),
        'color': AppTheme.primaryColor,
        'icon':  Icons.code_rounded,
      },
      {
        'label': 'Academic',
        'count': _countByCategory('Academic').toString(),
        'color': AppTheme.accentOrange,
        'icon':  Icons.school_rounded,
      },
      {
        'label': 'Sports',
        'count': _countByCategory('Sports').toString(),
        'color': AppTheme.accentGreen,
        'icon':  Icons.sports_rounded,
      },
      {
        'label': 'Extra',
        'count': _countByCategory('Extra').toString(),
        'color': AppTheme.accentBlue,
        'icon':  Icons.star_rounded,
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

  // ── Certificate Card — M3 ────────────────────────
  Widget _buildCertificateCard(
    BuildContext context,
    Map<String, dynamic> cert,
    int index,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final title     = cert['title'] as String;
    final isDownloading = _downloading[title] ?? false;
    final isDownloaded  = _downloaded[title]  ?? false;

    return Card(
      child: InkWell(
        onTap: () => _showCertificateDetail(context, cert),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            children: [

              // ── Top Row ─────────────────────
              Row(
                children: [

                  // ── Icon ──────────────────
                  Container(
                    width:  52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: (cert['color'] as Color)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: Icon(
                      cert['icon'] as IconData,
                      color: cert['color'] as Color,
                      size:  24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),

                  // ── Content ───────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cert['issuer'] as String,
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(
                          height: AppTheme.spacingXSmall,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size:  11,
                              color: AppTheme.textSecondary(context),
                            ),
                            const SizedBox(
                              width: AppTheme.spacingXSmall,
                            ),
                            Text(
                              cert['date'] as String,
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Grade Chip ────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSmall,
                      vertical:   AppTheme.spacingXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: (cert['color'] as Color)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusCircle,
                      ),
                    ),
                    child: Text(
                      cert['grade'] as String,
                      style: textTheme.labelSmall?.copyWith(
                        color:      cert['color'] as Color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                ],
              ),

              // ── Divider ─────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.spacingSmall,
                ),
                child: Divider(height: 1),
              ),

              // ── Action Buttons Row ───────────
              Row(
                children: [

                  // ── View Button ─────────────
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewCertificate(
                        context,
                        cert,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingSmall,
                        ),
                        side: BorderSide(
                          color: (cert['color'] as Color)
                              .withOpacity(0.5),
                        ),
                        foregroundColor: cert['color'] as Color,
                      ),
                      icon:  const Icon(
                        Icons.visibility_rounded,
                        size: 16,
                      ),
                      label: const Text('View'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),

                  // ── Download Button ──────────
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isDownloading
                          ? null
                          : () => _downloadCertificate(
                                context,
                                cert,
                              ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingSmall,
                        ),
                        backgroundColor: isDownloaded
                            ? AppTheme.accentGreen
                            : cert['color'] as Color,
                        foregroundColor: Colors.white,
                      ),
                      icon: isDownloading
                          ? const SizedBox(
                              width:  14,
                              height: 14,
                              child:  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              isDownloaded
                                  ? Icons.check_rounded
                                  : Icons.download_rounded,
                              size: 16,
                            ),
                      label: Text(
                        isDownloading
                            ? 'Saving...'
                            : isDownloaded
                                ? 'Saved'
                                : 'Download',
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
