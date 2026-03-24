import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/theme/theme_provider.dart';
import 'package:student_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:student_app/features/wallet/presentation/providers/wallet_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  // ── Controllers ────────────────────────────────
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController   = TextEditingController();
  final FocusNode _emailFocus                  = FocusNode();

  // ── State ──────────────────────────────────────
  bool _isEmailValid      = false;
  String _errorText       = '';

  // ── Animation ──────────────────────────────────
  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve:  Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve:  Curves.easeOut,
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

  // ── Email Validation ───────────────────────────
  void _validateEmail(String value) {
    setState(() {
      _isEmailValid = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(value);
      _errorText = '';
    });
  }

  // ── Send OTP ───────────────────────────────────
  Future<void> _sendOtp() async {
    if (!_isEmailValid) {
      setState(() => _errorText = 'Please enter a valid email address');
      return;
    }
    _emailFocus.unfocus();
    
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final success = await walletProvider.sendOtp(_emailController.text);
    
    if (success) {
      if (mounted) _showOtpBottomSheet();
    } else {
      if (mounted) {
        setState(() => _errorText = walletProvider.error ?? 'Failed to send OTP');
      }
    }
  }

  // ── OTP Bottom Sheet — M3 ──────────────────────
  void _showOtpBottomSheet() {
    _otpController.clear();
    String dialogError = '';

    showModalBottomSheet(
      context:           context,
      isScrollControlled: true,
      useSafeArea:       true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final walletProvider = Provider.of<WalletProvider>(context);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingLarge,
                  AppTheme.spacingSmall,
                  AppTheme.spacingLarge,
                  AppTheme.spacingXLarge,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ── M3 Drag Handle ──────────
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

                    // ── Icon Container ───────────
                    Container(
                      width:  72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),

                    // ── Title ────────────────────
                    Text(
                      'Verify Your Email',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),

                    // ── Subtitle ─────────────────
                    Text(
                      'Enter the 6-digit OTP sent to',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      _emailController.text,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingXLarge),

                    // ── OTP Input ────────────────
                    TextField(
                      controller:   _otpController,
                      keyboardType: TextInputType.number,
                      maxLength:    6,
                      textAlign:    TextAlign.center,
                      autofocus:    true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(
                            letterSpacing: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                          ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText:    '· · · · · ·',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                              letterSpacing: 10,
                              color: AppTheme.outlineColor(context),
                            ),
                      ),
                      onChanged: (_) {
                        setSheetState(() => dialogError = '');
                      },
                    ),

                    // ── Error Text ───────────────
                    if (walletProvider.error != null || dialogError.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacingSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Theme.of(context).colorScheme.error,
                            size: 14,
                          ),
                          const SizedBox(width: AppTheme.spacingXSmall),
                          Text(
                            dialogError.isNotEmpty ? dialogError : walletProvider.error!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error,
                                ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppTheme.spacingXLarge),

                    // ── Verify Button — M3 ───────
                    FilledButton(
                      onPressed: walletProvider.isLoading ? null : () async {
                        final success = await walletProvider.verifyOtp(
                          _emailController.text, 
                          _otpController.text
                        );
                        if (success) {
                          if (mounted) {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardWrapper(),
                              ),
                            );
                          }
                        }
                      },
                      child: walletProvider.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Verify & Continue'),
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),

                    // ── Resend Row ───────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive OTP? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showOtpBottomSheet();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Resend'),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark        = themeProvider.isDarkMode;
    final colorScheme   = Theme.of(context).colorScheme;
    final textTheme     = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),

      // ── Theme Toggle Button ─────────────────────
      floatingActionButton: FloatingActionButton.small(
        onPressed:       () => themeProvider.toggleTheme(),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation:       AppTheme.elevationLow,
        tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
        child: Icon(
          isDark
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          size: 20,
        ),
      ),

      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── Hero Banner ──────────────────
                  Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacingLarge,
                      AppTheme.spacingXLarge,
                      AppTheme.spacingLarge,
                      AppTheme.spacingXLarge,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(
                          AppTheme.radiusXXLarge,
                        ),
                        bottomRight: Radius.circular(
                          AppTheme.radiusXXLarge,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [

                        // ── App Logo ──────────────
                        Container(
                          width:  88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size:  44,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),

                        // ── App Name ──────────────
                        Text(
                          'Student Portfolio',
                          style: textTheme.headlineLarge?.copyWith(
                            color:       Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXSmall),

                        // ── Tagline ───────────────
                        Text(
                          'Your academic journey in one place',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXLarge),

                        // ── Stats Row ─────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingMedium,
                            vertical:   AppTheme.spacingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusLarge,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              _statItem('16+', 'Certificates'),
                              _statDivider(),
                              _statItem('8.7', 'CGPA'),
                              _statDivider(),
                              _statItem('92%', 'Attendance'),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),

                  // ── Form Section ─────────────────
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: AppTheme.spacingSmall),

                        // ── Welcome Text ──────────
                        Text(
                          'Welcome Back!',
                          style: textTheme.headlineLarge,
                        ),
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          'Login with your college email to continue',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingXLarge),

                        // ── Email Input — M3 ──────
                        TextField(
                          controller:   _emailController,
                          focusNode:    _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          onChanged:    _validateEmail,
                          textInputAction: TextInputAction.done,
                          onSubmitted:  (_) => _sendOtp(),
                          style: textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText:  'example@college.edu',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: _isEmailValid
                                  ? AppTheme.accentGreen
                                  : colorScheme.onSurfaceVariant,
                            ),
                            suffixIcon: _isEmailValid
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppTheme.accentGreen,
                                  )
                                : null,
                            errorText: _errorText.isNotEmpty
                                ? _errorText
                                : null,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                              borderSide: BorderSide(
                                color: _isEmailValid
                                    ? AppTheme.accentGreen
                                    : colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXLarge),

                        // ── Send OTP Button — M3 ──
                        Consumer<WalletProvider>(
                          builder: (context, walletProvider, child) {
                            return FilledButton(
                              onPressed: walletProvider.isLoading ? null : _sendOtp,
                              style: FilledButton.styleFrom(
                                backgroundColor: _isEmailValid
                                    ? colorScheme.primary
                                    : colorScheme.surfaceVariant,
                                foregroundColor: _isEmailValid
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                              child: walletProvider.isLoading
                                  ? const SizedBox(
                                      width:  22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.send_rounded,
                                          size: 18,
                                        ),
                                        SizedBox(width: AppTheme.spacingSmall),
                                        Text('Send OTP'),
                                      ],
                                    ),
                            );
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingLarge),

                        // ── Demo Hint — M3 Card ───
                        Card(
                          color: colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppTheme.spacingMedium,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.tips_and_updates_rounded,
                                  color: colorScheme.onPrimaryContainer,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: AppTheme.spacingSmall,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Demo Mode',
                                        style: textTheme.labelLarge
                                            ?.copyWith(
                                          color: colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Enter any valid email and use OTP: 1234',
                                        style: textTheme.bodySmall
                                            ?.copyWith(
                                          color: colorScheme
                                              .onPrimaryContainer
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Stat Item Widget ───────────────────────────
  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily:  'Poppins',
            color:       Colors.white,
            fontSize:    AppTheme.fontLarge,
            fontWeight:  FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            color:      Colors.white.withOpacity(0.75),
            fontSize:   AppTheme.fontSmall,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width:  1,
      height: 32,
      color:  Colors.white.withOpacity(0.25),
    );
  }
}
