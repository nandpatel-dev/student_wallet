import re
import sys

def replace_in_file(filepath, get_build_body):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the start of the build method
    # It must match '  @override\n  Widget build(BuildContext context)' and then capture until 'return CupertinoPageScaffold('
    build_pattern = r"  @override\s+Widget build\(BuildContext context\) \{.*?return \w+\("
    match = re.search(build_pattern, content, flags=re.DOTALL)
    
    if not match:
        print(f"Could not find build method in {filepath}")
        return
        
    # We will rename the old build method to 'Widget _oldBuild(BuildContext context)'
    content = content.replace("  @override\n  Widget build(BuildContext context)", "  // @override\n  Widget _oldBuild(BuildContext context)")
    
    insert_pos = content.find("  // @override\n  Widget _oldBuild(BuildContext context)")
    
    if insert_pos == -1:
         insert_pos = content.find("Widget _oldBuild(BuildContext context)")
         
    new_code = get_build_body()
    
    final_content = content[:insert_pos] + new_code + "\n\n" + content[insert_pos:]
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(final_content)
    print(f"Patched {filepath}")

def login_code():
    return """
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo + Title (Centered)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3B82F6).withOpacity(0.1) : const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('J', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'JUSTIFAI',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  Text(
                    'Student Wallet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: subtitleColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 40),

                  // Container Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : const Color(0xFFCBD5E1)).withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Custom Tab Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              __buildCustomTab('Email', _selectedTab == 0, () => setState(() => _selectedTab = 0), isDark),
                              __buildCustomTab('QR Login', _selectedTab == 1, () => setState(() => _selectedTab = 1), isDark),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Active Tab
                        _selectedTab == 0 ? __buildEmailTabContent(context, isDark) : __buildQRTabContent(context, isDark),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  Center(
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(12),
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(50),
                      onPressed: () => themeProvider.toggleTheme(),
                      child: Icon(
                        isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
                        color: textColor,
                        size: 20,
                      ),
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

  Widget __buildCustomTab(String title, bool isSelected, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? const Color(0xFF1E293B) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected 
                  ? (isDark ? Colors.white : const Color(0xFF0F172A))
                  : (isDark ? const Color(0xFF64748B) : const Color(0xFF64748B)),
            ),
          ),
        ),
      ),
    );
  }

  Widget __buildEmailTabContent(BuildContext context, bool isDark) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CupertinoTextField(
          controller: _emailController,
          placeholder: 'name@college.edu',
          onChanged: _validateEmail,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          style: TextStyle(color: textColor, fontSize: 16),
          placeholderStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 16),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(height: 24),
        Consumer<WalletProvider>(
          builder: (context, walletProvider, _) => Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              onPressed: walletProvider.isLoading ? null : _sendOtp,
              child: walletProvider.isLoading 
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const Text(
                      'Send OTP',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'i Demo Mode - any email - OTP: 1234',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF3B82F6), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget __buildQRTabContent(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.qr_code_scanner, size: 48, color: Color(0xFF3B82F6)),
        ),
        const SizedBox(height: 24),
        Text(
          'Fast Web Sync',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 8),
        Text(
          'Scan dashboard QR for instant transfer',
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF3B82F6)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const QRScannerPage())),
            child: const Text('Open Scanner', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
"""

def dashboard_code():
    return """
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final walletData = walletProvider.walletData;
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 80,
                  left: 20, right: 20, bottom: 40,
                ),
                sliver: SliverToBoxAdapter(
                  child: walletProvider.isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CupertinoActivityIndicator()))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // User Gradient Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('C', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Good morning,', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                                      Text(
                                        walletData?.certificates.isNotEmpty == true ? walletData!.certificates.first.recipientDisplay : 'Certificate',
                                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        walletData?.session.email ?? 'nand@justifai.com',
                                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // STATS
                          Row(
                            children: [
                              Expanded(
                                child: __buildStatCard(
                                  'Achievements', 
                                  walletData?.certificates.length.toString() ?? '0',
                                  '🎖️', surfaceColor, borderColor, textColor, subtitleColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: __buildStatCard(
                                  'Verification', 
                                  walletData?.session.valid == true ? 'Active' : 'Pending',
                                  '✅', surfaceColor, borderColor, walletData?.session.valid == true ? const Color(0xFF10B981) : textColor, subtitleColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // RECENT ACTIVITY
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('RECENT ACTIVITY', style: TextStyle(color: subtitleColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              const Text('View all', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // list
                          Container(
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                            ),
                            child: (walletData == null || walletData.certificates.isEmpty) 
                                ? const Padding(
                                    padding: EdgeInsets.all(30), 
                                    child: Center(child: Text('No activity')),
                                  )
                                : Column(
                                    children: walletData.certificates.take(3).map((e) => __buildActivityItem(context, e, isDark)).toList(),
                                  ),
                          ),
                          const SizedBox(height: 100),
                        ],
                    ),
                ),
              ),
            ],
          ),
          
          // Custom Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 20, right: 20, bottom: 16),
              color: bgColor.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dashboard', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => themeProvider.toggleTheme(),
                        child: Icon(isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill, color: const Color(0xFFF59E0B), size: 22),
                      ),
                      const SizedBox(width: 16),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await Provider.of<WalletProvider>(context, listen: false).logout();
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(CupertinoPageRoute(builder: (_) => const LoginPage()), (route) => false);
                          }
                        },
                        child: const Icon(CupertinoIcons.power, color: Color(0xFFEF4444), size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget __buildStatCard(String title, String value, String icon, Color bg, Color border, Color valColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: valColor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: subColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget __buildActivityItem(BuildContext context, WalletCert cert, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    
    final date = DateTime.tryParse(cert.issuedAt);
    final dateStr = date != null ? DateFormat('MMM dd').format(date) : 'Recent';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(CupertinoIcons.doc_text_fill, color: Color(0xFF6366F1), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cert.templateName, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15), maxLines: 1),
                Text(cert.issuerName ?? 'University', style: TextStyle(color: subtitleColor, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(dateStr, style: TextStyle(color: subtitleColor, fontSize: 12)),
              const SizedBox(height: 4),
              const Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          )
        ],
      ),
    );
  }
"""

def cert_code():
    return """
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: CupertinoSlidingSegmentedControl<String>(
                        groupValue: _selectedFilter,
                        backgroundColor: Colors.transparent,
                        thumbColor: surfaceColor,
                        onValueChanged: (val) {
                          if (val != null) setState(() => _selectedFilter = val);
                        },
                        children: {
                          for (var f in _filters)
                            f: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _selectedFilter == f ? FontWeight.bold : FontWeight.w500,
                                  color: _selectedFilter == f ? textColor : subtitleColor,
                                ),
                              ),
                            )
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (_filteredCertificates.isEmpty)
                SliverFillRemaining(
                  child: Center(child: Text('No records found', style: TextStyle(color: subtitleColor))),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cert = _filteredCertificates[index];
                        return __buildCertItem(context, cert, isDark, surfaceColor, borderColor, textColor, subtitleColor);
                      },
                      childCount: _filteredCertificates.length,
                    ),
                  ),
                ),
            ],
          ),

          // Custom Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 20, right: 20, bottom: 16),
              color: bgColor.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Certificates', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget __buildCertItem(BuildContext context, WalletCert cert, bool isDark, Color surfaceColor, Color borderColor, Color textColor, Color subtitleColor) {
    final date = DateTime.tryParse(cert.issuedAt);
    final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : cert.issuedAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(20),
        onPressed: () => _showCertificateDetail(context, cert),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(CupertinoIcons.doc_text_fill, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cert.templateName, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600), maxLines: 1),
                  const SizedBox(height: 4),
                  Text(cert.issuerName ?? 'University', style: TextStyle(color: subtitleColor, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formattedDate, style: TextStyle(color: subtitleColor, fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  cert.lifecycle.state.toUpperCase(),
                  style: TextStyle(
                    color: cert.lifecycle.state == 'Active' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
"""

if __name__ == "__main__":
    base_dir = r"c:\Users\NAND\Desktop\JQ_Flutter\sd_history\lib\features"
    replace_in_file(base_dir + r"\auth\presentation\pages\login_page.dart", login_code)
    replace_in_file(base_dir + r"\dashboard\presentation\pages\dashboard_page.dart", dashboard_code)
    replace_in_file(base_dir + r"\student\presentation\pages\certificates_page.dart", cert_code)
