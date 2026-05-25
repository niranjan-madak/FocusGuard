# SECURITY_MEMORY — FocusGuard

Updated: 2026-05-25. Framework: Flutter/Dart (rewritten from Electron).

## Security Model

FocusGuard is a **fully offline** Flutter app. The Electron multi-process security model (IPC allowlists, CSP, contextBridge, renderer sandbox) was Electron-specific and no longer applies.

Current security posture is appropriate for the threat model:

## Implemented Controls

- **No network requests at runtime** — `google_fonts` fonts are bundled via package; audio is local WAV files; notifications use local OS APIs
- **No sensitive data** — no credentials, no PII, no auth tokens stored anywhere
- **OS-level sandboxing** — each Flutter platform (Android, iOS, Windows, macOS, Linux) sandboxes the app at the OS level
- **Minimal dependencies** — 6 runtime packages, all MIT/BSD/Apache, actively maintained
- **Input validation** — `SettingsPanel` enforces numeric ranges for durations (1–240 min focus, 1–120 min break)
- **No eval() / dynamic code execution** — Dart is compiled; no runtime code generation

## Platform-Specific Notes

**Android:** Permissions declared in `AndroidManifest`; requests notification permission at runtime (Android 13+). APK sandbox isolates the app.

**iOS:** App Sandbox via entitlements. Notifications require user permission.

**Windows:** `NotificationService` uses GUID `d49b0314-ee7a-4196-8b0b-3b951a7c4f08` and app model ID `com.focusguard.app`. No special permissions required.

**Linux:** Standard process permissions. `LinuxInitializationSettings(defaultActionName: 'Open')`.

## Open Items

- [ ] Code signing — Windows SmartScreen and macOS Gatekeeper will warn on unsigned installers. Obtain EV cert (Windows) and Apple Developer ID (macOS) before wide distribution.
- [ ] `dart pub audit` not automated — add to release checklist until CI is configured.

## Threat Model

| Threat | Status |
|--------|--------|
| Network data exfiltration | Eliminated — no network access |
| Malicious dependency | Low risk — minimal dep set; audit with `dart pub audit` |
| Insecure data storage | Not applicable — no sensitive data |
| Code signing warnings | Present — mitigate by obtaining signing certs |
| Supply chain attack | Low — minimal deps, all well-known packages |

## Removed (Electron-specific, no longer applicable)

- IPC channel allowlists (`preload.js`)
- `contextBridge` / `contextIsolation`
- `nodeIntegration: false`
- Content-Security-Policy header injection
- Navigation and new-window guards
- `Object.prototype` freezing
- Single instance lock

These were Electron security mitigations. Flutter's single-process model with OS-level sandboxing is the equivalent defence in this architecture.

## Secrets

No secrets in the repo. No signing keys, API keys, or credentials anywhere. Keep future signing keys in CI secret stores only.
