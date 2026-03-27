import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Colors, Curves, BoxShadow, Offset, Material;
import 'dart:ui';
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
    
    // Theme Colors
    final bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF4F6F9);
    final cardColor = isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final subLabelColor = isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);
    final primaryColor = const Color(0xFF5C55ED); // Professional Purple-Blue
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Top right Theme Toggle
                  Align(
                    alignment: Alignment.topRight,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => themeProvider.toggleTheme(),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: subLabelColor,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // ── Logo Section ──
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('J', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'JUSTIFAI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'Student Wallet',
                    style: TextStyle(
                      color: subLabelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // ── Login Card Section ──
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ]
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Minimal Tab Switcher
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: _buildFlatTabItem('Email', _selectedTab == 0, primaryColor, textColor, subLabelColor),
                            ),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: _buildFlatTabItem('QR Login', _selectedTab == 1, primaryColor, textColor, subLabelColor),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Active Tab View
                        _selectedTab == 0 
                          ? _buildMinimalEmailTab(context, isDark, textColor, subLabelColor, primaryColor, borderColor, cardColor) 
                          : _buildMinimalQRTab(context, isDark, textColor, primaryColor, borderColor, cardColor),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Clean UI Helper Builders ──

  Widget _buildFlatTabItem(String label, bool isSelected, Color primary, Color text, Color subText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? primary : subText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 3,
          width: 40,
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        )
      ],
    );
  }

  Widget _buildMinimalEmailTab(BuildContext context, bool isDark, Color textCol, Color subCol, Color primary, Color borderCol, Color cardCol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          controller: _emailController,
          placeholder: 'name@college.edu',
          onChanged: _validateEmail,
          placeholderStyle: TextStyle(color: subCol, fontSize: 16),
          style: TextStyle(color: textCol, fontSize: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderCol),
          ),
        ),
        const SizedBox(height: 20),
        Consumer<WalletProvider>(
          builder: (context, walletProvider, _) => SizedBox(
            width: double.infinity,
            height: 54,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: primary,
              disabledColor: primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              onPressed: walletProvider.isLoading ? null : _sendOtp,
              child: walletProvider.isLoading 
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const Text(
                      'Send OTP',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 14, color: primary),
            const SizedBox(width: 6),
            Text('Demo Mode - any email - OTP: 1234', style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }

  Widget _buildMinimalQRTab(BuildContext context, bool isDark, Color textCol, Color primary, Color borderCol, Color cardCol) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.qr_code_scanner_rounded, size: 60, color: textCol),
        const SizedBox(height: 24),
        Text(
          'Fast Web Sync',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textCol),
        ),
        const SizedBox(height: 8),
        Text(
          'Scan dashboard QR for instant transfer',
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const QRScannerPage())),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, color: primary),
                const SizedBox(width: 8),
                Text('Open Scanner', style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 16)),
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
