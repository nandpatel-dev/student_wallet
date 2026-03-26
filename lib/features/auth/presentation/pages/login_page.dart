import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Colors, Image, Curves, BoxShadow, Offset, Material;
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/ios_theme.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:student_app/features/auth/presentation/pages/qr_scanner_page.dart';

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
      duration: const Duration(milliseconds: 200),
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
      _showToast('Please enter a valid institution email', isError: true);
      return;
    }
    _emailFocus.unfocus();

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final success = await walletProvider.sendOtp(_emailController.text);

    if (success) {
      if (mounted) {
        _showToast('OTP sent successfully to your email');
        _showOtpDialog();
      }
    } else {
      if (mounted) {
        final error = walletProvider.error ?? 'Failed to send OTP';
        setState(() => _errorText = error);
        _showToast(error, isError: true);
      }
    }
  }

  void _showOtpDialog() {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
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
              placeholderStyle: TextStyle(
                fontSize: 32, 
                letterSpacing: 8, 
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
              ),
              style: TextStyle(
                fontSize: 32, 
                letterSpacing: 8, 
                fontWeight: FontWeight.bold,
                color: isDark 
                    ? const Color(0xFFC8A27C) // Caramel Gold (Dark Coffee Theme)
                    : const Color(0xFF78350F), // Deep Amber/Brown (Light Beige Theme)
              ),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFFF1EDE8) : Colors.black).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? const Color(0xFFF1EDE8) : Colors.black).withOpacity(0.1),
                ),
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
                    _showToast('Verification successful! Welcome back.');
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (_) => const DashboardWrapper()),
                    );
                  }
                } else {
                  if (mounted) {
                    _showToast(walletProvider.error ?? 'Invalid OTP. Please try again.', isError: true);
                  }
                }
              },
              child: walletProvider.isLoading
                  ? const CupertinoActivityIndicator()
                  : Text('Verify & Continue', style: TextStyle(color: isDark ? const Color(0xFFC8A27C) : const Color(0xFF2E2A27))),
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
      backgroundColor: Colors.black, // Base for better contrast
      child: Stack(
        children: [
          // ── Premium Gradient Background ──
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0F0E0D), const Color(0xFF1C1A18), const Color(0xFF0F0E0D)] // Dark Coffee
                      : [const Color(0xFFF5F5F4), const Color(0xFFF5F5DC), const Color(0xFFE7E5E4)], // Light Grey / Beige
                ),
              ),
            ),
          ),

          Positioned(
            top: -50,
            left: -50,
            child: _blurCircle(300, isDark ? Colors.blue.withOpacity(0.3) : Colors.orange.withOpacity(0.15)),
          ),
          Positioned(
            bottom: 50,
            right: -80,
            child: _blurCircle(400, isDark ? Colors.purple.withOpacity(0.2) : Colors.brown.withOpacity(0.1)),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      
                      // ── Header Section ──
                      _buildGlassContainer(
                        borderRadius: 30,
                        padding: const EdgeInsets.all(24),
                        isDark: isDark,
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFFF1EDE8) : Colors.white).withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: (isDark ? const Color(0xFFF1EDE8) : Colors.white).withOpacity(0.2)),
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.school_rounded,
                                  color: isDark ? const Color(0xFFF1EDE8) : Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'JUSTYFAI',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFF1EDE8) : const Color(0xFF2E2A27),
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'Student Wallet',
                              style: TextStyle(
                                color: isDark ? const Color(0xFFF1EDE8).withOpacity(0.7) : const Color(0xFF6D655F),
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      // ── Glass Login Card ──
                      _buildGlassContainer(
                        borderRadius: 35,
                        padding: const EdgeInsets.all(28),
                        isDark: isDark,
                        child: Column(
                          children: [
                            // Glass Tab Switcher
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CupertinoSlidingSegmentedControl<int>(
                                groupValue: _selectedTab,
                                backgroundColor: Colors.transparent,
                                thumbColor: Colors.white.withOpacity(0.2),
                                children: {
                                  0: _buildGlassTabItem(Icons.email_outlined, 'Email', _selectedTab == 0, isDark),
                                  1: _buildGlassTabItem(Icons.qr_code_scanner_rounded, 'QR login', _selectedTab == 1, isDark),
                                },
                                onValueChanged: (val) => setState(() => _selectedTab = val!),
                              ),
                            ),
                            
                            const SizedBox(height: 35),
                            
                            // Active Tab View
                            _selectedTab == 0 
                              ? _buildGlassEmailTab(context, isDark) 
                              : _buildGlassQRTab(context, isDark),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      
                      // ── Theme Toggle ──
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => themeProvider.toggleTheme(),
                        child: _buildGlassContainer(
                          borderRadius: 50,
                          padding: const EdgeInsets.all(15),
                          isDark: isDark,
                          child: Icon(
                            isDark ? Icons.coffee_rounded : Icons.dark_mode_rounded,
                            color: isDark ? const Color(0xFFC8A27C) : const Color(0xFF2E2A27),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
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

  // ── Glass UI Helper Builders ──

  Widget _buildGlassContainer({
    required Widget child,
    double borderRadius = 20,
    EdgeInsets padding = const EdgeInsets.all(16),
    bool isDark = true,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0.1 : 0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassTabItem(IconData icon, String label, bool isSelected, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            size: 18, 
            color: isSelected 
              ? (isDark ? Colors.white : Colors.black) 
              : (isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4))
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected 
                ? (isDark ? const Color(0xFFF1EDE8) : const Color(0xFF2E2A27)) 
                : (isDark ? const Color(0xFFF1EDE8).withOpacity(0.5) : const Color(0xFF9C938C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassEmailTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        CupertinoTextField(
          controller: _emailController,
          placeholder: 'name@college.edu',
          onChanged: _validateEmail,
          placeholderStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.4) : const Color(0xFF9C938C)),
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2E2A27)),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF2E2A27).withOpacity(0.1)),
          ),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(Icons.email_outlined, color: isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF6D655F), size: 20),
          ),
        ),
        const SizedBox(height: 30),
        Consumer<WalletProvider>(
          builder: (context, walletProvider, _) => Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFFC8A27C), const Color(0xFF1C1A18)] // Caramel to Roasted Coffee
                    : [const Color(0xFF44403C), const Color(0xFF78716C)], // Deep Stone/Brown for Light Beige
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? const Color(0xFFC8A27C) : const Color(0xFF44403C)).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CupertinoButton(
              onPressed: walletProvider.isLoading ? null : _sendOtp,
              child: walletProvider.isLoading 
                  ? CupertinoActivityIndicator(color: isDark ? const Color(0xFFF1EDE8) : Colors.white)
                  : Text(
                      'Send OTP',
                      style: TextStyle(color: isDark ? const Color(0xFFF1EDE8) : Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _demoHint(context),
      ],
    );
  }

  Widget _buildGlassQRTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
          ),
          child: Icon(Icons.qr_code_scanner_rounded, size: 60, color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 24),
        Text(
          'Fast Web Sync',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 10),
        Text(
          'Scan dashboard QR for instant transfer',
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)),
        ),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1)),
          ),
          child: CupertinoButton(
            onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const QRScannerPage())),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, color: isDark ? Colors.white : Colors.black87),
                const SizedBox(width: 10),
                Text('Open Scanner', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /*
  @override
  Widget buildOld(BuildContext context) {
    final themeProvider = Provider.of<WalletProvider>(context); // Fixed provider type here as well if needed, but it's orignally commented.
    // ... rest of commented code
  }
  */

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

  void _showToast(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
              border: Border.all(
                color: isError ? Colors.redAccent.withOpacity(0.5) : Colors.greenAccent.withOpacity(0.5),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: isError ? Colors.redAccent : Colors.greenAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
