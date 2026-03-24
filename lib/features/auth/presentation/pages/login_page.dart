import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Colors, Image, Curves, BoxShadow, Offset;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/ios_theme.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:student_app/features/auth/presentation/pages/qr_scanner_page.dart';
import 'dart:ui';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  bool _isEmailValid = false;
  String _errorText = '';
  int _selectedTab = 0; // 0 for Email, 1 for QR

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      _isEmailValid = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(value);
      _errorText = '';
    });
  }

  Future<void> _sendOtp() async {
    if (!_isEmailValid) {
      setState(() => _errorText = 'Please enter a valid email address');
      return;
    }
    _emailFocus.unfocus();

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final success = await walletProvider.sendOtp(_emailController.text);

    if (success) {
      if (mounted) _showOtpDialog();
    } else {
      if (mounted) {
        setState(() => _errorText = walletProvider.error ?? 'Failed to send OTP');
      }
    }
  }

  void _showOtpDialog() {
    _otpController.clear();
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Verify Your Email'),
        message: Column(
          children: [
            const Text('Enter the 6-digit OTP sent to'),
            Text(_emailController.text, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CupertinoTextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              autofocus: true,
              placeholder: '· · · · · ·',
              style: const TextStyle(fontSize: 32, letterSpacing: 8, color: IOSTheme.primaryBlue),
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        actions: [
          Consumer<WalletProvider>(
            builder: (context, walletProvider, _) => CupertinoActionSheetAction(
              onPressed: walletProvider.isLoading ? () {} : () async {
                final success = await walletProvider.verifyOtp(
                    _emailController.text, _otpController.text);
                if (success) {
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (_) => const DashboardWrapper()),
                    );
                  }
                }
              },
              child: walletProvider.isLoading
                  ? const CupertinoActivityIndicator()
                  : const Text('Verify & Continue'),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return CupertinoPageScaffold(
      backgroundColor: IOSTheme.systemBackground,
      child: Stack(
        children: [
          // ── Background Gradient ──────────────────
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0F0F1A), const Color(0xFF1A1A2E), const Color(0xFF0D0D1A)]
                      : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3), const Color(0xFFE0EAFC)],
                ),
              ),
            ),
          ),

          // ── Decorative Blurred Shapes ────────────
          Positioned(
            top: -100,
            right: -50,
            child: _blurCircle(250, IOSTheme.primaryBlue.withOpacity(0.15)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _blurCircle(300, const Color(0xFF6C63FF).withOpacity(0.12)),
          ),

          // ── Content ──────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: IOSTheme.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      
                      // ── Header Section ──────────
                      Center(
                        child: IOSTheme.glassContainer(
                          padding: const EdgeInsets.all(20),
                          borderRadius: 30,
                          context: context,
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: IOSTheme.primaryBlue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.school_rounded,
                                    color: IOSTheme.primaryBlue,
                                    size: 40,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'JUSTYFAI',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                'Your academic journey in one place',
                                style: TextStyle(
                                  color: IOSTheme.secondaryLabel.resolveFrom(context),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ── Stats Section ───────────
                      IOSTheme.glassContainer(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        context: context,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _statItem('16+', 'Certs'),
                            _divider(),
                            _statItem('8.7', 'CGPA'),
                            _divider(),
                            _statItem('92%', 'Attd'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ── Tab Switcher ────────────
                      Center(
                        child: IOSTheme.glassContainer(
                          padding: const EdgeInsets.all(4),
                          borderRadius: 14,
                          context: context,
                          child: SizedBox(
                            width: double.infinity,
                            child: CupertinoSlidingSegmentedControl<int>(
                              groupValue: _selectedTab,
                              backgroundColor: CupertinoColors.transparent,
                              thumbColor: isDark 
                                  ? CupertinoColors.systemGrey5.darkColor 
                                  : CupertinoColors.white,
                              children: {
                                0: _tabItem(Icons.email_outlined, 'Email', _selectedTab == 0),
                                1: _tabItem(Icons.qr_code_scanner_rounded, 'QR login', _selectedTab == 1),
                              },
                              onValueChanged: (val) => setState(() => _selectedTab = val!),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ── Active Tab View ─────────
                      _selectedTab == 0 ? _buildEmailTab(context) : _buildQRTab(context),

                      const SizedBox(height: 40),
                      
                      // ── Theme Toggle ───────────
                      Center(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => themeProvider.toggleTheme(),
                          child: IOSTheme.glassContainer(
                            padding: const EdgeInsets.all(12),
                            borderRadius: 50,
                            context: context,
                            child: Icon(
                              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              size: 20,
                              color: IOSTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Sign in with your institutional email',
          style: TextStyle(color: IOSTheme.secondaryLabel.resolveFrom(context)),
        ),
        const SizedBox(height: 20),
        IOSTheme.glassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          context: context,
          child: CupertinoTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            placeholder: 'name@college.edu',
            onChanged: _validateEmail,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: null,
            prefix: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.email_outlined, color: IOSTheme.primaryBlue, size: 20),
            ),
            suffix: _isEmailValid 
                ? const Icon(Icons.check_circle_rounded, color: CupertinoColors.systemGreen, size: 20)
                : null,
          ),
        ),
        if (_errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(_errorText, style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 13)),
          ),
        const SizedBox(height: 25),
        Consumer<WalletProvider>(
          builder: (context, walletProvider, _) => SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(16),
              onPressed: walletProvider.isLoading ? null : _sendOtp,
              child: walletProvider.isLoading 
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                  : const Text('Send Verification OTP', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _demoHint(context),
      ],
    );
  }

  Widget _buildQRTab(BuildContext context) {
    return Column(
      children: [
        IOSTheme.glassContainer(
          padding: const EdgeInsets.all(25),
          borderRadius: 40,
          context: context,
          child: const Icon(Icons.qr_code_scanner_rounded, size: 60, color: IOSTheme.primaryBlue),
        ),
        const SizedBox(height: 20),
        const Text(
          'Sync from Web',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Scan the QR code on your dashboard\nto transfer your wallet instantly.',
          textAlign: TextAlign.center,
          style: TextStyle(color: IOSTheme.secondaryLabel.resolveFrom(context)),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: IOSTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const QRScannerPage())),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, color: IOSTheme.primaryBlue),
                SizedBox(width: 8),
                Text('Open Scanner', style: TextStyle(color: IOSTheme.primaryBlue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabItem(IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: isSelected ? IOSTheme.primaryBlue : CupertinoColors.systemGrey),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(fontSize: 11, color: CupertinoColors.systemGrey)),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 25, color: CupertinoColors.systemGrey.withOpacity(0.2));

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _demoHint(BuildContext context) {
    return IOSTheme.glassContainer(
      padding: const EdgeInsets.all(12),
      context: context,
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: IOSTheme.primaryBlue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo Mode: Use any valid email and OTP: 1234',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
