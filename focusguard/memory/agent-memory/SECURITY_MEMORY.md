# SECURITY_MEMORY — FocusGuard

Recorded security decisions, findings and recommended mitigations.

## Implemented controls
- Renderer isolation: nodeIntegration: false, contextIsolation: true, sandbox: true
- Preload allowlist: `SEND_CHANNELS`, `INVOKE_CHANNELS`, `RECV_CHANNELS` in `preload.js`
- Input sanitization in preload and renderer
- Strict CSP injected via `session.webRequest.onHeadersReceived`:
  - `script-src 'self'` (no unsafe-inline)
  - `style-src 'self'` (no unsafe-inline, no external stylesheets)
  - `font-src 'self' data:` (all fonts bundled locally)
  - `connect-src 'none'` (zero external connections)
- Navigation and new-window guards
- Prototype freezing to harden object prototype
- Disabled remote module and avoided eval
- Single instance lock to prevent multiple processes
- All event handlers moved from inline onclick to `addEventListener` (CSP compliance)
- Fonts bundled locally as WOFF2 files (true offline, no external dependencies)

## Recent improvements (May 2026)
- Removed external Google Fonts dependency (https://fonts.googleapis.com, https://fonts.gstatic.com)
- Bundled all fonts locally in `assets/fonts/` as WOFF2 files
- Tightened CSP to remove `'unsafe-inline'` from script-src and style-src
- Removed all inline event handlers from HTML, replaced with addEventListener in renderer.js
- Added CSP validation: `connect-src 'none'` means zero network access (fonts no longer fetched)

## Short-term recommendations (already implemented)
- [x] Bundle fonts locally to make app truly offline
- [x] Remove `'unsafe-inline'` from CSP
- [ ] Add code signing for Windows and macOS releases to avoid SmartScreen and Gatekeeper friction

## Medium-term recommendations
1. Add SAST scanning and dependency CVE scanning to CI pipeline (npm audit / OSS tools)
2. Harden CSP further with report-uri and validate no violations occur
3. Limit API surface of preload to smallest possible set and keep it audited
4. Font subsetting: reduce font file sizes from ~30KB to ~5-10KB per font using fonttools

## Runtime protections to consider
- Use electron-builder's auto-update with signed updates (if remote updates added)
- Consider sandboxing the main process (limited benefits) and additional process separation for heavy work

## Secrets
- Currently none stored in repo. Keep all production secrets out of code and use CI secret stores for signing keys.

## Threat model notes
- Attack vector: malicious local plugin or extension — mitigated by disabling webviews and blocking new windows
- Attack vector: compromised developer machine / supply chain — mitigate with strict dependency pinning, CI checks and signing
- Attack vector: external resource hijacking — ELIMINATED by bundling fonts locally; no external connections possible



