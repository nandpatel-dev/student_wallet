import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/student/presentation/pages/certificates_page.dart';
import 'package:student_app/features/student/presentation/pages/profile_page.dart';

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme   = Theme.of(context).colorScheme;
    final textTheme     = Theme.of(context).textTheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
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

      body: Scrollbar(
        controller:    _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding:    const EdgeInsets.all(AppTheme.spacingMedium),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Greeting Card ──────────────────
            _buildGreetingCard(context),
            const SizedBox(height: AppTheme.spacingLarge),

            // ── Stats Section ──────────────────
            Text(
              'Overview',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildStatsGrid(context),
            const SizedBox(height: AppTheme.spacingLarge),

            // ── Academic Performance ───────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Academic Performance',
                  style: textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildPerformanceList(context),
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
            _buildRecentActivity(context),
            const SizedBox(height: AppTheme.spacingLarge),

          ],
        ),
      ),
    ),
  );
}

  // ── Greeting Card ────────────────────────────────
  Widget _buildGreetingCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

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
                  'Good Morning 👋',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Text(
                  'Raj Patel',
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
                    'B.Tech CSE — Sem 6',
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
  Widget _buildStatsGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    final stats = [
      {
        'label':     'CGPA',
        'value':     '8.7',
        'icon':      Icons.star_rounded,
        'color':     AppTheme.accentOrange,
        'container': AppTheme.accentOrange.withOpacity(0.12),
      },
      {
        'label':     'Attendance',
        'value':     '92%',
        'icon':      Icons.fact_check_rounded,
        'color':     AppTheme.accentGreen,
        'container': AppTheme.accentGreen.withOpacity(0.12),
      },
      {
        'label':     'Certificates',
        'value':     '16',
        'icon':      Icons.workspace_premium_rounded,
        'color':     colorScheme.primary,
        'container': colorScheme.primaryContainer,
      },
      {
        'label':     'Rank',
        'value':     '#4',
        'icon':      Icons.emoji_events_rounded,
        'color':     AppTheme.accentBlue,
        'container': AppTheme.accentBlue.withOpacity(0.12),
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

  // ── Performance List — M3 Cards ──────────────────
  Widget _buildPerformanceList(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final subjects = [
      {
        'subject': 'Data Structures',
        'marks':   '92/100',
        'grade':   'A+',
        'color':   AppTheme.accentGreen,
        'progress': 0.92,
      },
      {
        'subject': 'Operating Systems',
        'marks':   '85/100',
        'grade':   'A',
        'color':   AppTheme.accentBlue,
        'progress': 0.85,
      },
      {
        'subject': 'Database Management',
        'marks':   '78/100',
        'grade':   'B+',
        'color':   AppTheme.accentOrange,
        'progress': 0.78,
      },
      {
        'subject': 'Computer Networks',
        'marks':   '88/100',
        'grade':   'A',
        'color':   colorScheme.primary,
        'progress': 0.88,
      },
    ];

    return Card(
      child: Column(
        children: subjects.asMap().entries.map((entry) {
          final index   = entry.key;
          final subject = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // ── Grade Badge ──────────
                        Container(
                          width:  40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (subject['color'] as Color)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              subject['grade'] as String,
                              style: textTheme.labelLarge?.copyWith(
                                color: subject['color'] as Color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSmall),
                        Expanded(
                          child: Text(
                            subject['subject'] as String,
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          subject['marks'] as String,
                          style: textTheme.labelLarge?.copyWith(
                            color: subject['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    // ── M3 LinearProgressIndicator ──
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusCircle,
                      ),
                      child: LinearProgressIndicator(
                        value:            subject['progress'] as double,
                        minHeight:        6,
                        backgroundColor:  (subject['color'] as Color)
                            .withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          subject['color'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index != subjects.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Recent Activity — M3 Cards ───────────────────
  Widget _buildRecentActivity(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final activities = [
      {
        'title':    'Certificate Uploaded',
        'subtitle': 'Flutter Development — Udemy',
        'time':     'Today, 11:00 AM',
        'icon':     Icons.upload_file_rounded,
        'color':    colorScheme.primary,
      },
      {
        'title':    'Attendance Marked',
        'subtitle': 'Data Structures — Present',
        'time':     'Today, 9:30 AM',
        'icon':     Icons.how_to_reg_rounded,
        'color':    AppTheme.accentGreen,
      },
      {
        'title':    'Result Declared',
        'subtitle': 'Semester 5 — CGPA 8.7',
        'time':     'Yesterday',
        'icon':     Icons.emoji_events_rounded,
        'color':    AppTheme.accentOrange,
      },
      {
        'title':    'Assignment Submitted',
        'subtitle': 'Computer Networks — Unit 4',
        'time':     '18 Jan, 2:00 PM',
        'icon':     Icons.assignment_turned_in_rounded,
        'color':    AppTheme.accentBlue,
      },
    ];

    return Card(
      child: Column(
        children: activities.asMap().entries.map((entry) {
          final index    = entry.key;
          final activity = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width:  44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (activity['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusMedium,
                    ),
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: activity['color'] as Color,
                    size:  22,
                  ),
                ),
                title: Text(
                  activity['title'] as String,
                  style: textTheme.titleMedium,
                ),
                subtitle: Text(
                  activity['subtitle'] as String,
                  style: textTheme.bodyMedium,
                ),
                trailing: Text(
                  activity['time'] as String,
                  style: textTheme.bodySmall,
                ),
              ),
              if (index != activities.length - 1)
                const Divider(height: 1, indent: 72, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
