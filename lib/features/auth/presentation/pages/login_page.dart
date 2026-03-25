import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Colors, Image, Curves, BoxShadow, Offset, Divider;
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
  String? _errorText;
  int _selectedTab = 0; // 0 for Email, 1 for QR

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // No extra controllers needed for email-only login

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
      builder: (context) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        return CupertinoActionSheet(
          title: Text(
            'Verify Your Email',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          message: Column(
            children: [
              Text(
                'Enter the 6-digit OTP sent to',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                _emailController.text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 25),
              CupertinoTextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                autofocus: true,
                placeholder: '· · · · · ·',
                style: const TextStyle(
                  fontSize: 32,
                  letterSpacing: 8,
                  color: Color(0xFF0081FF),
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A3D) : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
          actions: [
            Consumer<WalletProvider>(
              builder: (context, walletProvider, _) => CupertinoActionSheetAction(
                onPressed: walletProvider.isLoading
                    ? () {}
                    : () async {
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
                    : const Text(
                        'Verify & Continue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            isDestructiveAction: true,
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return CupertinoPageScaffold(
      backgroundColor: isDark ? const Color(0xFF0B0B14) : CupertinoColors.systemGroupedBackground,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            child: Column(
              children: [
            // ── Header Section (New Design) ──────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, bottom: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [const Color(0xFF151525), const Color(0xFF0B0B14)]
                      : [const Color(0xFF0081FF), const Color(0xFF00BCFF)],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.school_rounded,
                        color: Color(0xFF0081FF),
                        size: 35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'JUSTYFAI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Sign in to your learning account to continue your journey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Login Form Card ────────────────────
            Transform.translate(
              offset: const Offset(0, -20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Tab Switcher (New Design) ────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A3D) : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CupertinoSlidingSegmentedControl<int>(
                        groupValue: _selectedTab,
                        backgroundColor: CupertinoColors.transparent,
                        thumbColor: isDark ? const Color(0xFF3D3D52) : CupertinoColors.white,
                        children: {
                          0: _buildTabItem(Icons.email_outlined, 'Email', _selectedTab == 0, isDark),
                          1: _buildTabItem(Icons.qr_code_scanner_rounded, 'QR login', _selectedTab == 1, isDark),
                        },
                        onValueChanged: (val) => setState(() => _selectedTab = val!),
                      ),
                    ),
                    const SizedBox(height: 30),

                    _selectedTab == 0 ? _buildEmailForm(isDark) : _buildQRSection(isDark),
                  ],
                ),
              ),
            ),
            
            // ── Theme Toggle Button ──────────────────
            const SizedBox(height: 20),
            Center(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => themeProvider.toggleTheme(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? Colors.amber : const Color(0xFF0081FF),
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  ),
);
}

  // ── Helper Widgets for New Design ────────────────

  Widget _buildEmailForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          placeholder: 'student@example.com',
          keyboardType: TextInputType.emailAddress,
          isDark: isDark,
          onChanged: _validateEmail,
          prefixIcon: Icons.email_outlined,
        ),
        if (_errorText != null && _errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        const SizedBox(height: 25),
        Consumer<WalletProvider>(
          builder: (context, walletProvider, _) => Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0081FF), Color(0xFF00BCFF)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0081FF).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: walletProvider.isLoading ? null : _sendOtp,
              child: walletProvider.isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _demoHintWidget(isDark),
      ],
    );
  }

  Widget _demoHintWidget(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3D) : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF0081FF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo Mode: Use any valid email and OTP: 1234',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection(bool isDark) {
    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF0081FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 50,
              color: Color(0xFF0081FF),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Sync from Web',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Scan the QR code on your dashboard\nto transfer your wallet instantly.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: const Color(0xFF0081FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => const QRScannerPage()),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, color: Color(0xFF0081FF)),
                SizedBox(width: 8),
                Text(
                  'Open Scanner',
                  style: TextStyle(
                    color: Color(0xFF0081FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(IconData icon, String label, bool isSelected, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? const Color(0xFF0081FF) : (isDark ? Colors.grey[600] : Colors.grey),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF0081FF) : (isDark ? Colors.grey[600] : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets for New Design ────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    bool isPassword = false,
    bool obscureText = false,
    bool isDark = false,
    IconData? prefixIcon,
    VoidCallback? onToggleVisibility,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3D) : CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: null,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        placeholderStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey, fontSize: 15),
        prefix: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(prefixIcon, color: isDark ? Colors.grey[600] : Colors.grey, size: 20),
              )
            : null,
        suffix: isPassword
            ? CupertinoButton(
                padding: const EdgeInsets.only(right: 12),
                onPressed: onToggleVisibility,
                child: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }
}
