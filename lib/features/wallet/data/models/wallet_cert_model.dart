class WalletCert {
  final String id;
  final String templateName;
  final String recipientDisplay;
  final String issuedAt;
  final String status;
  final CertLifecycle lifecycle;
  final String? txHash;
  final String? network;
  final String? issuerName;
  final String viewUrl;
  final String downloadUrl;
  final String verifyUrl;

  WalletCert({
    required this.id,
    required this.templateName,
    required this.recipientDisplay,
    required this.issuedAt,
    required this.status,
    required this.lifecycle,
    this.txHash,
    this.network,
    this.issuerName,
    required this.viewUrl,
    required this.downloadUrl,
    required this.verifyUrl,
  });

  factory WalletCert.fromJson(Map<String, dynamic> j) {
    return WalletCert(
      id: j['id'] ?? '',
      templateName: j['templateName'] ?? '',
      recipientDisplay: j['recipientDisplay'] ?? '',
      issuedAt: j['issuedAt'] ?? '',
      status: j['status'] ?? '',
      lifecycle: CertLifecycle.fromJson(j['lifecycle'] ?? {}),
      txHash: j['txHash'],
      network: j['network'],
      issuerName: j['issuerName'],
      viewUrl: j['viewUrl'] ?? '',
      downloadUrl: j['downloadUrl'] ?? '',
      verifyUrl: j['verifyUrl'] ?? '',
    );
  }
}

class CertLifecycle {
  final String state; // 'Active' | 'Revoked' | 'Frozen'
  final String? reason;

  CertLifecycle({
    required this.state,
    this.reason,
  });

  factory CertLifecycle.fromJson(Map<String, dynamic> j) {
    return CertLifecycle(
      state: j['state'] ?? 'Active',
      reason: j['reason'],
    );
  }
}

class WalletData {
  final SessionData session;
  final List<WalletCert> certificates;

  WalletData({
    required this.session,
    required this.certificates,
  });

  factory WalletData.fromJson(Map<String, dynamic> j) {
    return WalletData(
      session: SessionData.fromJson(j['session'] ?? {}),
      certificates: (j['certificates'] as List<dynamic>?)
              ?.map((c) => WalletCert.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SessionData {
  final String email;
  final bool valid;

  SessionData({
    required this.email,
    required this.valid,
  });

  factory SessionData.fromJson(Map<String, dynamic> j) {
    return SessionData(
      email: j['email'] ?? '',
      valid: j['valid'] ?? false,
    );
  }
}
