import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Colors, Curves, BoxShadow, Offset;
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/ios_theme.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/auth/presentation/pages/login_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ── URL Launchers ──────────────────────────────
  Future<void> _launchEmail() async {
    final Uri uri = Uri(scheme: 'mailto', path: 'raj.patel@college.edu');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchPhone() async {
    final Uri uri = Uri(scheme: 'tel', path: '+919876543210');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _showLogoutAction(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Logout'),
        message: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              Provider.of<WalletProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final data = walletProvider.walletData;
    final name = data?.certificates.isNotEmpty == true 
        ? data!.certificates.first.recipientDisplay 
        : 'Student User';
    final email = data?.session.email ?? 'student@college.edu';

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.systemBackground,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Profile'),
            border: null,
            backgroundColor: CupertinoColors.systemBackground,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => themeProvider.toggleTheme(),
              child: Icon(
                themeProvider.isDarkMode ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
                size: 22,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(IOSTheme.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Hero ────────────────
                  _buildProfileHero(context, name, email),
                  const SizedBox(height: 30),

                  // ── Academic Info ───────────────
                  _sectionHeader('Academic Information', CupertinoIcons.book_fill),
                  const SizedBox(height: 12),
                  _buildAcademicSection(context),
                  const SizedBox(height: 30),

                  // ── Contact Info ────────────────
                  _sectionHeader('Contact Details', CupertinoIcons.phone_fill),
                  const SizedBox(height: 12),
                  _buildContactSection(context, email),
                  const SizedBox(height: 30),

                  // ── Achievements ───────────────
                  _sectionHeader('Achievements', CupertinoIcons.star_fill),
                  const SizedBox(height: 12),
                  _buildAchievementsSection(context),
                  const SizedBox(height: 40),

                  // ── Logout ──────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.systemRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () => _showLogoutAction(context),
                      child: const Text('Sign Out', style: TextStyle(color: CupertinoColors.systemRed, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHero(BuildContext context, String name, String email) {
    return IOSTheme.glassContainer(
      context: context,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [IOSTheme.primaryBlue, Color(0xFF63A4FF)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: IOSTheme.primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Center(
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(fontSize: 14, color: CupertinoColors.secondaryLabel)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statBadge('3rd Year', CupertinoIcons.calendar),
              const SizedBox(width: 10),
              _statBadge('Div A', CupertinoIcons.person_2_fill),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: IOSTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 12, color: IOSTheme.primaryBlue),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: IOSTheme.primaryBlue)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: CupertinoColors.secondaryLabel),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.secondaryLabel, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildAcademicSection(BuildContext context) {
    return IOSTheme.glassContainer(
      context: context,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _infoTile('University', 'Gujarat Tech University', CupertinoIcons.building_2_fill),
          _separator(),
          _infoTile('Course', 'B.Tech Computer Science', CupertinoIcons.book_fill),
          _separator(),
          _infoTile('Roll No', '210010107142', CupertinoIcons.number),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, String email) {
    return IOSTheme.glassContainer(
      context: context,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _infoTile('Email', email, CupertinoIcons.mail_fill, onTap: _launchEmail),
          _separator(),
          _infoTile('Phone', '+91 98765 43210', CupertinoIcons.phone_fill, onTap: _launchPhone),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return IOSTheme.glassContainer(
      context: context,
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _chip('Top Scorer', CupertinoColors.systemYellow),
          _chip('100% Attendance', CupertinoColors.systemGreen),
          _chip('Quiz Winner', CupertinoColors.systemOrange),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _infoTile(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: IOSTheme.primaryBlue),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CupertinoColors.label)),
                ],
              ),
            ),
            if (onTap != null) const Icon(CupertinoIcons.chevron_right, size: 14, color: CupertinoColors.separator),
          ],
        ),
      ),
    );
  }

  Widget _separator() => Container(height: 0.5, color: CupertinoColors.separator, margin: const EdgeInsets.only(left: 50));
}
