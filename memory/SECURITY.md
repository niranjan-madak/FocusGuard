# SECURITY — FocusGuard

## Security Overview

FocusGuard is a **fully offline, local-only** Flutter application. It collects no data, makes no network requests, and has no authentication or backend.

**Security Posture:** Appropriate for scope
**Known Vulnerabilities:** 0
**External Attack Surface:** None (no network, no auth, no server)

---

## Threat Model

| Threat | Likelihood | Impact | Mitigation |
|--------|-----------|--------|------------|
| Network data exfiltration | None | N/A | App makes no network requests |
| Malicious dependency | Low | Medium | Minimal dep set; `dart pub audit` |
| Insecure data storage | None | N/A | No sensitive data stored |
| Code signing warnings | Present | Low | OS SmartScreen/Gatekeeper on first launch |

---

## Security Layers

### Layer 1: No Network Access

The app makes **zero network requests at runtime**.

- `google_fonts` fonts are bundled via the package — no CDN calls
- `audioplayers` plays local WAV files from `assets/sounds/`
- `flutter_local_notifications` uses local OS APIs only
- No analytics, telemetry, crash reporting, or update server

### Layer 2: No Persistent Sensitive Data

- No user accounts, passwords, or credentials
- No personally identifiable information (PII)
- Timer state is in-memory only (resets on restart)
- `shared_preferences` is declared but not yet used — when wired, it will store only non-sensitive settings (durations, volume, sound toggle)

### Layer 3: Minimal Dependency Surface

Only 6 runtime packages, all well-known, actively maintained, MIT/BSD/Apache licensed:

```
provider, audioplayers, flutter_local_notifications,
wakelock_plus, shared_preferences, google_fonts
```

Run `dart pub audit` regularly for CVE checks.

### Layer 4: Platform Sandboxing (OS-level)

Flutter apps on each platform run within the OS sandbox:

- **Android:** APK runs in Android sandbox, permissions declared in AndroidManifest
- **iOS:** App Sandbox, entitlements only for notifications
- **Windows:** Standard Win32 app permissions
- **macOS:** Hardened runtime (when code-signed)
- **Linux:** Standard process permissions

The app requests only:
- Notification permission (Android 13+)
- Wakelock (prevent screen sleep during focus)

### Layer 5: Input Validation

The `SettingsPanel` widget validates focus and break duration inputs before calling `applySettings()`. Ranges enforced: focus 1–240 min, break 1–120 min.

---

## Security Checklist

### ✅ Implemented

- [x] No network requests at runtime
- [x] No sensitive data storage
- [x] No user authentication (not needed)
- [x] Minimal dependency set (6 runtime packages)
- [x] Input validation on settings fields
- [x] All dependencies MIT/BSD/Apache licensed
- [x] No eval() or dynamic code execution

### ⚠️ Partial / Pending

- [ ] Code signing — installers not code-signed; OS will show SmartScreen/Gatekeeper warning on first run
- [ ] `dart pub audit` not automated in CI (no CI configured yet)

### ❌ Not Applicable (by design)

- N/A — CSP, IPC sandbox, contextBridge (Electron-only — not relevant to Flutter)
- N/A — Authentication (app has no auth)
- N/A — Database (app has no database)
- N/A — External API security (app has no external APIs)

---

## Dependency Audit

```bash
# Check for known CVEs in dependencies
dart pub audit

# Check for outdated packages
flutter pub outdated
```

Run monthly or before any release.

---

## Code Signing

**Current status:** Not implemented.

**Risk:** OS Gatekeeper (macOS) and SmartScreen (Windows) will warn on first launch.

**Recommendation:** Obtain platform certificates for distribution builds:
- Windows: EV Code Signing Certificate
- macOS: Apple Developer ID Application certificate

---

## Privacy

**GDPR Status:** Not applicable — no personal data collected or processed.
**Data Collection:** None.
**Analytics / Telemetry:** None.
**Third-party services:** None at runtime.

---

## Vulnerability Response

**If a CVE is found in a dependency:**
1. Run `dart pub upgrade <package>` to latest patched version
2. Test on all target platforms
3. Release new version
4. Document in CHANGELOG.md

**Timeline:** Critical CVE → patch within 7 days. High → within 30 days.

---

## Summary

FocusGuard's security posture is appropriate for a local-only productivity app:

- Zero network access at runtime
- No sensitive data collected or stored
- Minimal, auditable dependency set
- OS-level sandboxing on all target platforms
- Only missing: code signing for distribution installers

**Security Philosophy:** Offline by design. Minimal surface. Least privilege.
