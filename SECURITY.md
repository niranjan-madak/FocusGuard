# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | ✅ Current |

## Reporting a Vulnerability

**Please do not file public GitHub Issues for security vulnerabilities.**

Report privately via GitHub's [Security Advisories](../../security/advisories/new) feature, or email the maintainer directly.

**What to include:**
- Description of the vulnerability
- Steps to reproduce
- Affected versions and platforms
- Potential impact

**Response timeline:**
- Acknowledgement: within 48 hours
- Assessment: within 7 days
- Fix: within 30 days (critical: within 7 days)
- Disclosure: coordinated after fix is released

## Security Architecture

FocusGuard is designed with a minimal attack surface:

| Property | Detail |
|----------|--------|
| **Network access** | Zero — no HTTP/WebSocket/fetch calls at runtime |
| **Data storage** | In-memory only — no files, no database, no credentials |
| **Sensitive data** | None collected or stored |
| **External services** | None — fully offline |
| **Sandboxing** | OS process sandbox (Flutter native app) |
| **Fonts** | Bundled via `google_fonts` package — no CDN at runtime |
| **Audio** | Local WAV files via `AssetSource` |
| **Notifications** | OS-native via `flutter_local_notifications` — local only |

## Dependency Security

Dependencies are declared in `pubspec.yaml`. To audit:

```bash
flutter pub outdated        # check for outdated packages
flutter pub deps            # show full dependency tree
```

Keep dependencies up to date — particularly `audioplayers`, `flutter_local_notifications`, and `wakelock_plus` which include native (C++) code.

## Platform Permissions

| Platform | Permissions Required |
|----------|---------------------|
| Android | `RECEIVE_BOOT_COMPLETED` (notifications), `POST_NOTIFICATIONS` (Android 13+) |
| iOS | Notification permission (user-prompted) |
| Windows | None beyond standard desktop app |
| macOS | Notification permission (user-prompted) |
| Linux | None |

No location, microphone, camera, contacts, or storage permissions are requested on any platform.
