/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/auth/presentation/pages/login_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();



  // ── URL Launchers ──────────────────────────────
  Future<void> _launchEmail(BuildContext context) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path:   'raj.patel@college.edu',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackbar(context, 'Could not open email app');
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path:   '+919876543210',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackbar(context, 'Could not open dialer');
    }
  }

  Future<void> _launchLinkedIn(BuildContext context) async {
    final Uri uri = Uri.parse('https://linkedin.com/in/rajpatel');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackbar(context, 'Could not open LinkedIn');
    }
  }

  // ── Snackbar — M3 ─────────────────────────────
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Edit Profile Bottom Sheet — M3 ────────────
  void _showEditBottomSheet(BuildContext context) {
    final nameController  = TextEditingController(text: 'Raj Patel');
    final emailController = TextEditingController(
      text: 'raj.patel@college.edu',
    );
    final phoneController = TextEditingController(
      text: '+91 98765 43210',
    );
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      useSafeArea:        true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLarge,
              AppTheme.spacingSmall,
              AppTheme.spacingLarge,
              AppTheme.spacingXLarge,
            ),
            child: Column(
              mainAxisSize:      MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Drag Handle ───────────────
                Center(
                  child: Container(
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
                ),

                // ── Title Row ─────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        AppTheme.spacingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size:  20,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Text(
                      'Edit Profile',
                      style: textTheme.headlineMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXLarge),

                // ── Name Field ────────────────
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText:  'Full Name',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // ── Email Field ───────────────
                TextField(
                  controller:   emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText:  'Email Address',
                    prefixIcon: Icon(Icons.email_rounded),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // ── Phone Field ───────────────
                TextField(
                  controller:   phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText:  'Phone Number',
                    prefixIcon: Icon(Icons.phone_rounded),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXLarge),

                // ── Action Buttons ────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showSnackbar(
                            context,
                            'Profile updated successfully!',
                          );
                        },
                        icon:  const Icon(Icons.check_rounded),
                        label: const Text('Save'),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  // ── Achievement Detail Bottom Sheet — M3 ──────
  void _showAchievementDetail(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    showModalBottomSheet(
      context:     context,
      useSafeArea: true,
      builder: (context) {
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

              // ── Icon ──────────────────────
              Container(
                width:  80,
                height: 80,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size:  38,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // ── Title ─────────────────────
              Text(
                item['title'] as String,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXSmall),

              // ── Subtitle ──────────────────
              Text(
                item['subtitle'] as String,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // ── Verified Badge ────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                  vertical:   AppTheme.spacingXSmall,
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
                    const SizedBox(width: AppTheme.spacingXSmall),
                    Text(
                      'Verified Achievement',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXLarge),

              // ── Close Button ──────────────
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon:  const Icon(Icons.close_rounded),
                label: const Text('Close'),
              ),

            ],
          ),
        );
      },
    );
  }

  // ── Logout Confirm Dialog — M3 ─────────────────
  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            Icons.logout_rounded,
            color: colorScheme.error,
            size:  32,
          ),
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout from your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<WalletProvider>(context, listen: false).logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
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
    final isDark        = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),

      // ── M3 AppBar ───────────────────────────
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: textTheme.titleLarge,
        ),
        actions: [
          // ── Theme Toggle ──────────────────
          IconButton(
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          ),
          // ── Edit Button ───────────────────
          IconButton(
            onPressed: () => _showEditBottomSheet(context),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Profile',
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

            // ── Profile Hero Card ────────────
            _buildProfileHeroCard(context),
            const SizedBox(height: AppTheme.spacingLarge),

            // ── Academic Info ────────────────
            _buildSectionHeader(
              context,
              title: 'Academic Info',
              icon:  Icons.school_rounded,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildAcademicInfo(context),
            const SizedBox(height: AppTheme.spacingLarge),

            // ── Skills ───────────────────────
            _buildSectionHeader(
              context,
              title: 'Skills',
              icon:  Icons.code_rounded,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildSkills(context),
            const SizedBox(height: AppTheme.spacingLarge),

            // ── Contact Info ─────────────────
            _buildSectionHeader(
              context,
              title: 'Contact Info',
              icon:  Icons.contact_page_rounded,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildContactInfo(context),
            const SizedBox(height: AppTheme.spacingLarge),

            // ── Achievements ─────────────────
            _buildSectionHeader(
              context,
              title: 'Achievements',
              icon:  Icons.emoji_events_rounded,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildAchievements(context),
            const SizedBox(height: AppTheme.spacingXLarge),

            // ── Logout Button ─────────────────
            _buildLogoutButton(context),
            const SizedBox(height: AppTheme.spacingLarge),

          ],
        ),
      ),
    ),
  );
}

  // ── Profile Hero Card ────────────────────────────
  Widget _buildProfileHeroCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final walletProvider = Provider.of<WalletProvider>(context);
    final data = walletProvider.walletData;
    
    final email = data?.session.email ?? 'Student';
    final name = data?.certificates.isNotEmpty == true 
        ? data!.certificates.first.recipientDisplay 
        : 'Student';
    final certCount = data?.certificates.length ?? 0;

    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color:        colorScheme.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
      ),
      child: Column(
        children: [

          // ── Avatar ──────────────────────
          Stack(
            children: [
              Container(
                width:  84,
                height: 84,
                decoration: BoxDecoration(
                  color:  Colors.white.withOpacity(0.2),
                  shape:  BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    name.substring(0, name.contains(' ') ? 1 : (name.length > 1 ? 2 : name.length)).toUpperCase(),
                    style: textTheme.displayLarge?.copyWith(
                      color:      Colors.white,
                      fontSize:   28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // ── Name ────────────────────────
          Text(
            name,
            style: textTheme.headlineLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXSmall),

          // ── Email ────────────────────────
          Text(
            email,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // ── Stats Badges ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _heroBadge(
                icon:  Icons.workspace_premium_rounded,
                label: '$certCount Certificates',
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              _heroBadge(
                icon:  Icons.verified_user_rounded,
                label: data?.session.valid == true ? 'Active Session' : 'Expired',
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _heroBadge({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical:   AppTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: AppTheme.spacingXSmall),
          Text(
            label,
            style: const TextStyle(
              fontFamily:  'Poppins',
              color:       Colors.white,
              fontSize:    11,
              fontWeight:  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header — M3 ─────────────────────────
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(
            icon,
            color: colorScheme.onPrimaryContainer,
            size:  16,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSmall),
        Text(
          title,
          style: textTheme.titleLarge,
        ),
      ],
    );
  }

  // ── Academic Info — M3 Card ──────────────────────
  Widget _buildAcademicInfo(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final info = [
      {
        'label': 'University',
        'value': 'Gujarat Technological University',
        'icon':  Icons.account_balance_rounded,
        'color': AppTheme.primaryColor,
      },
      {
        'label': 'Course',
        'value': 'B.Tech Computer Science',
        'icon':  Icons.menu_book_rounded,
        'color': AppTheme.accentBlue,
      },
      {
        'label': 'Year',
        'value': '3rd Year — Semester 6',
        'icon':  Icons.calendar_month_rounded,
        'color': AppTheme.accentOrange,
      },
      {
        'label': 'Roll Number',
        'value': 'GTU — 210010107142',
        'icon':  Icons.badge_rounded,
        'color': AppTheme.accentGreen,
      },
      {
        'label': 'Division',
        'value': 'Division A — Batch B2',
        'icon':  Icons.groups_rounded,
        'color': AppTheme.accentRed,
      },
    ];

    return Card(
      child: Column(
        children: info.asMap().entries.map((entry) {
          final index = entry.key;
          final item  = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width:  40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusMedium,
                    ),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size:  20,
                  ),
                ),
                title: Text(
                  item['label'] as String,
                  style: textTheme.bodySmall,
                ),
                subtitle: Text(
                  item['value'] as String,
                  style: textTheme.titleMedium,
                ),
              ),
              if (index != info.length - 1)
                const Divider(
                  height:   1,
                  indent:   72,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Skills — M3 FilterChip ───────────────────────
  Widget _buildSkills(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final skills = [
      {'name': 'Flutter',  'color': AppTheme.primaryColor},
      {'name': 'Python',   'color': AppTheme.accentBlue},
      {'name': 'Firebase', 'color': AppTheme.accentOrange},
      {'name': 'UI/UX',    'color': AppTheme.accentGreen},
      {'name': 'MySQL',    'color': AppTheme.accentRed},
      {'name': 'Git',      'color': const Color(0xFF2C3E50)},
      {'name': 'REST API', 'color': AppTheme.primaryColor},
      {'name': 'Figma',    'color': const Color(0xFF8E44AD)},
    ];

    return Wrap(
      spacing:    AppTheme.spacingSmall,
      runSpacing: AppTheme.spacingSmall,
      children: skills.map((skill) {
        return InkWell(
          onTap: () => _showSnackbar(
            context,
            '${skill['name']} skill tapped!',
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical:   AppTheme.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: (skill['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
              border: Border.all(
                color: (skill['color'] as Color).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width:  8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:  skill['color'] as Color,
                    shape:  BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingXSmall),
                Text(
                  skill['name'] as String,
                  style: textTheme.labelLarge?.copyWith(
                    color: skill['color'] as Color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Contact Info — M3 Card ───────────────────────
  Widget _buildContactInfo(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final contacts = [
      {
        'label':  'Email',
        'value':  'raj.patel@college.edu',
        'icon':   Icons.email_rounded,
        'color':  AppTheme.primaryColor,
        'action': 'email',
      },
      {
        'label':  'Phone',
        'value':  '+91 98765 43210',
        'icon':   Icons.phone_rounded,
        'color':  AppTheme.accentGreen,
        'action': 'phone',
      },
      {
        'label':  'Address',
        'value':  'Ahmedabad, Gujarat, India',
        'icon':   Icons.location_on_rounded,
        'color':  AppTheme.accentRed,
        'action': 'address',
      },
      {
        'label':  'LinkedIn',
        'value':  'linkedin.com/in/rajpatel',
        'icon':   Icons.link_rounded,
        'color':  AppTheme.accentBlue,
        'action': 'linkedin',
      },
    ];

    return Card(
      child: Column(
        children: contacts.asMap().entries.map((entry) {
          final index = entry.key;
          final item  = entry.value;
          return Column(
            children: [
              ListTile(
                onTap: () {
                  final action = item['action'] as String;
                  if (action == 'email') {
                    _launchEmail(context);
                  } else if (action == 'phone') {
                    _launchPhone(context);
                  } else if (action == 'linkedin') {
                    _launchLinkedIn(context);
                  } else {
                    _showSnackbar(context, item['value'] as String);
                  }
                },
                leading: Container(
                  width:  40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusMedium,
                    ),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size:  20,
                  ),
                ),
                title: Text(
                  item['label'] as String,
                  style: textTheme.bodySmall,
                ),
                subtitle: Text(
                  item['value'] as String,
                  style: textTheme.titleMedium,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size:  14,
                  color: AppTheme.textSecondary(context),
                ),
              ),
              if (index != contacts.length - 1)
                const Divider(
                  height:    1,
                  indent:    72,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Achievements — M3 Cards ──────────────────────
  Widget _buildAchievements(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final achievements = [
      {
        'title':    'Hackathon Winner',
        'subtitle': 'Smart India Hackathon 2023',
        'icon':     Icons.emoji_events_rounded,
        'color':    AppTheme.accentOrange,
      },
      {
        'title':    'Research Paper',
        'subtitle': 'Published in IEEE Journal',
        'icon':     Icons.description_rounded,
        'color':    AppTheme.accentBlue,
      },
      {
        'title':    'Best Student Award',
        'subtitle': 'GTU University — 2024',
        'icon':     Icons.military_tech_rounded,
        'color':    AppTheme.primaryColor,
      },
    ];

    return Card(
      child: Column(
        children: achievements.asMap().entries.map((entry) {
          final index = entry.key;
          final item  = entry.value;
          return Column(
            children: [
              ListTile(
                onTap: () => _showAchievementDetail(context, item),
                leading: Container(
                  width:  44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusMedium,
                    ),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size:  22,
                  ),
                ),
                title: Text(
                  item['title'] as String,
                  style: textTheme.titleMedium,
                ),
                subtitle: Text(
                  item['subtitle'] as String,
                  style: textTheme.bodyMedium,
                ),
                trailing: Icon(
                  Icons.verified_rounded,
                  color: item['color'] as Color,
                  size:  20,
                ),
              ),
              if (index != achievements.length - 1)
                const Divider(
                  height:    1,
                  indent:    72,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Logout Button — M3 ──────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon:  const Icon(Icons.logout_rounded),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      ),
    );
  }
}
*/
