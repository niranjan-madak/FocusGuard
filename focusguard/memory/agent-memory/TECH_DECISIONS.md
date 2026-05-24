# TECH_DECISIONS — FocusGuard

This file records architecture/technology decisions and their trade-offs.

## ADR-001: Desktop framework — Electron
Date: 2026-05-24
Status: Accepted

### Decision
Use Electron to provide a cross-platform desktop app with native integrations (tray, notifications, power save blocker).

### Reasoning
- Rapid development using web technologies
- Easy packaging via electron-builder
- Access to native features (notifications, tray, global shortcuts)

### Alternatives considered
- Tauri: smaller bundle, Rust-based backend — rejected because the codebase is already Electron and migration cost is non-trivial.
- Native (Swift/C#): higher maintenance and platform-specific code.

### Consequences
- App size larger (~80-120MB installers)
- Mature developer ecosystem for packaging and auto-update

## ADR-002: Vanilla JavaScript (no framework)
Date: 2026-05-24
Status: Accepted

### Decision
Keep renderer as plain HTML/CSS/JS instead of adding a heavy frontend framework.

### Reasoning
- Small UI surface area — framework adds unnecessary bundle size and complexity
- Easier to audit security surface (no runtime transforms)

### Alternatives considered
- React / Svelte — beneficial for complex UI but overkill here

### Consequences
- Simpler build and lower dependency surface
- Maintainability relies on clear code organization and tests

## ADR-003: Security posture — CSP + sandbox + contextBridge
Date: 2026-05-24
Status: Accepted

### Decision
Enforce strict CSP via session.webRequest, disable Node integration, use contextIsolation and a small allowlist in preload.js.

### Reasoning
- Minimize attack surface while keeping necessary native access

### Alternatives considered
- Allow broader IPC for feature speed, but that increases risk

### Consequences
- Some flexibility lost (no dynamic remote content) but security is strong

## Future decisions to document
- Code signing approach and certificate provider
- Whether to bundle fonts locally (offline requirement)
- Whether to adopt TypeScript for business-critical logic

