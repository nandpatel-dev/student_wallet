# Flutter Student Wallet API Integration Guide

> **Base URL:** `https://your-api-domain.com`
> All headers are the same for mobile and web. CORS is open (`*`).

---

## Authentication Flow (Email + OTP — like the web)

### Step 1 — Request OTP

```
POST /api/student-wallet/request-otp
Content-Type: application/json

{ "email": "student@example.com" }
```

**Dart:**
```dart
final res = await http.post(
  Uri.parse('$baseUrl/api/student-wallet/request-otp'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email}),
);
```

**Response:**
```json
{ "success": true, "message": "OTP sent to your email", "data": { "email": "student@example.com", "expiresInMinutes": 10 } }
```

---

### Step 2 — Verify OTP → Get Session Token

```
POST /api/student-wallet/verify-otp
Content-Type: application/json

{ "email": "student@example.com", "otp": "123456" }
```

**Dart:**
```dart
final res = await http.post(
  Uri.parse('$baseUrl/api/student-wallet/verify-otp'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'otp': otp}),
);
final sessionToken = jsonDecode(res.body)['data']['sessionToken'];
// Save this! Use it as header for all subsequent calls.
await secureStorage.write(key: 'walletToken', value: sessionToken);
```

**Response:**
```json
{ "success": true, "data": { "sessionToken": "eyJ...", "email": "student@example.com" } }
```

---

## QR Code Flow (Scan from Web — No OTP needed!)

When the student is logged in on the **web** and taps **"Open in App"**, a QR code appears encoding:
```
justifai://wallet/open?token=<appToken>
```

### Handle Deep Link in Flutter

In your Flutter app, listen for the `justifai://wallet/open` deep link and extract `token`:

```dart
// Using uni_links or go_router deep link
// When deep link arrives:
String appToken = uri.queryParameters['token']!;
await exchangeAppToken(appToken);
```

### Exchange App Token for Session

```
POST /api/student-wallet/exchange-app-token
Content-Type: application/json

{ "appToken": "<token_from_qr>" }
```

**Dart:**
```dart
Future<String> exchangeAppToken(String appToken) async {
  final res = await http.post(
    Uri.parse('$baseUrl/api/student-wallet/exchange-app-token'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'appToken': appToken}),
  );
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body)['data'];
    final sessionToken = data['sessionToken'];
    await secureStorage.write(key: 'walletToken', value: sessionToken);
    return sessionToken;
  }
  throw Exception('Token expired or already used');
}
```

> ⚠️ App token is **single-use** and expires in 15 minutes. If expired, ask user to scan again from web.

---

## Fetch All Certificates (Single Call)

Use the `/me` endpoint for the most efficient app startup — returns session + all certs in one call.

```
GET /api/student-wallet/me
x-student-wallet: <sessionToken>
```

**Dart:**
```dart
Future<WalletData> fetchWallet(String token) async {
  final res = await http.get(
    Uri.parse('$baseUrl/api/student-wallet/me'),
    headers: {'x-student-wallet': token},
  );
  final body = jsonDecode(res.body);
  if (res.statusCode == 401) {
    // Token expired — go back to OTP or QR scan
    throw UnauthorizedException();
  }
  return WalletData.fromJson(body['data']);
}
```

**Response shape:**
```json
{
  "success": true,
  "data": {
    "session": { "email": "student@example.com", "valid": true },
    "certificates": [
      {
        "id": "uuid-here",
        "templateName": "Bachelor of Technology",
        "recipientDisplay": "Yash Patel",
        "issuedAt": "2024-05-15T10:30:00.000Z",
        "status": "Generated",
        "lifecycle": { "state": "Active", "reason": null },
        "txHash": "0xabc...",
        "network": "polygon-amoy",
        "issuerName": "Gujarat University",
        "viewUrl": "https://api.../view?sw=...",
        "downloadUrl": "https://api.../download?sw=...",
        "verifyUrl": "https://app.../verify?jobId=..."
      }
    ],
    "pagination": { "total": 3, "page": 1, "limit": 20, "totalPages": 1 }
  }
}
```

---

## View / Download Certificate PDF

Both URLs are returned inside each certificate object. They include the auth token as a query param:

```dart
// Open PDF in-app viewer
final viewUrl = cert['viewUrl'];
// This URL already has ?sw=<token> appended, so no extra header needed
await launchUrl(Uri.parse(viewUrl));
```

---

## Verify Certificate (Blockchain)

Open the `verifyUrl` in a WebView or external browser — it shows the full blockchain verification page:

```dart
final verifyUrl = cert['verifyUrl'];
// Opens: https://app.../verify?jobId=<id>
await launchUrl(Uri.parse(verifyUrl), mode: LaunchMode.externalApplication);
```

---

## Dart Model Classes

```dart
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

  WalletCert.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        templateName = j['templateName'],
        recipientDisplay = j['recipientDisplay'],
        issuedAt = j['issuedAt'],
        status = j['status'],
        lifecycle = CertLifecycle.fromJson(j['lifecycle']),
        txHash = j['txHash'],
        network = j['network'],
        issuerName = j['issuerName'],
        viewUrl = j['viewUrl'],
        downloadUrl = j['downloadUrl'],
        verifyUrl = j['verifyUrl'];
}

class CertLifecycle {
  final String state; // 'Active' | 'Revoked' | 'Frozen'
  final String? reason;
  CertLifecycle.fromJson(Map<String, dynamic> j)
      : state = j['state'], reason = j['reason'];
}
```

---

## All Endpoints Summary

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/student-wallet/request-otp` | None | Send OTP to email |
| POST | `/api/student-wallet/verify-otp` | None | Verify OTP → get sessionToken |
| POST | `/api/student-wallet/exchange-app-token` | None | Exchange QR token → get sessionToken |
| GET | `/api/student-wallet/me` | `x-student-wallet` | Session + all certs (single call) |
| GET | `/api/student-wallet/session` | `x-student-wallet` | Check session validity |
| GET | `/api/student-wallet/certificates` | `x-student-wallet` | Paginated cert list |
| GET | `/api/student-wallet/certificates/:id/view` | `x-student-wallet` | Stream PDF inline |
| GET | `/api/student-wallet/certificates/:id/download` | `x-student-wallet` | Download PDF |
| POST | `/api/student-wallet/certificates/:id/share` | `x-student-wallet` | Get shareable verify URL |
| POST | `/api/student-wallet/generate-app-token` | `x-student-wallet` | Generate QR token for Flutter |

---

## Token Expiry

| Token | Default Expiry | Storage |
|-------|---------------|---------|
| `sessionToken` (JWT) | 7 days | `flutter_secure_storage` |
| `appToken` (QR magic token) | 15 minutes | Not stored (single use) |
