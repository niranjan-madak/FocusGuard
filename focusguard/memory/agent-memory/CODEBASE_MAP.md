# CODEBASE_MAP — FocusGuard

This file maps the repository files to responsibilities, entry points and risk areas. It is generated from a repository scan (May 24, 2026).

## Top-level layout

- main.js — Electron main process
  - Window creation, tray, menu, IPC handlers, notifications, power save blocker, global shortcuts, security guards
- preload.js — Secure contextBridge
  - Channel allowlists, input sanitization, safe APIs exposed to renderer
- src/index.html — Renderer entrypoint (UI)
- src/renderer.js — UI logic, timer, audio, state, DOM updates
- src/styles.css — Styling
- assets/ — icons and NSIS installer script
- package.json — dependency list + electron-builder configuration

## Entry points
- Application startup: `electron .` runs `main.js` (main process)
- Renderer: `src/index.html` loads `renderer.js` (UI + timer)
- Preload: `preload.js` exposes `window.focusAPI` safe interface

## IPC Channels (observed)
- One-way send from renderer to main (preload allowlist):
  - `timer-state-update` — update tray/time/power-save state
  - `session-alarm` — notify main of completed session
  - `window-flash` — request native window flash
  - `update-config` — update focus/break durations in main state
- Two-way invoke from renderer to main (preload allowlist):
  - `get-platform` — returns process.platform
  - `show-confirm-dialog` — shows a native confirm dialog and returns boolean
- From main to renderer (via contextBridge on handler):
  - `shortcut` — actions: `toggle`, `skip`, `reset`, `mute`

## Risk / Touch Points
- main.js: touches native integrations (tray, notifications, powerSaveBlocker) — modify carefully
- preload.js: security critical — any change risks exposing main process
- renderer.js: core timer logic; add tests before refactors
- package.json: electron-builder settings affect installers and signing

## Files to avoid touching without tests or plan
- Any code in `preload.js` and `main.js` that changes IPC allowlists, window creation, or webRequest CSP injection

## Suggested next steps
- Add unit tests around timer state transitions in `renderer.js`
- Document IPC contracts in `memory/API_REFERENCE.md` (already present but should be expanded)
- Add ADRs for major decisions in `memory/agent-memory/TECH_DECISIONS.md`

