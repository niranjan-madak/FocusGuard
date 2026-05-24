# FocusGuard — Deep Work Interval Timer

A secure, offline desktop application for focused work using 75-minute sessions with 20-minute breaks.

---

## Quick Start (Build Your Own Installer)

### Prerequisites
- [Node.js](https://nodejs.org) v18 or newer (includes npm)
- Windows 10+, macOS 11+, or Ubuntu 20+

### Steps

```bash
# 1. Extract this ZIP and open a terminal in the folder
cd focusguard

# 2. Install dependencies (~1 minute)
npm install

# 3. Run in development mode (optional — test before building)
npm start

# 4. Build your installer
npm run dist              # auto-detects your OS
# OR
npm run dist:win          # Windows NSIS installer (.exe)
npm run dist:mac          # macOS DMG (.dmg)
npm run dist:linux        # Linux AppImage + .deb
```

The installer is saved to the `dist/` folder.

---

## Windows Icon Setup (Required for .exe)

electron-builder needs an `.ico` file for Windows. Convert `assets/icon.png` to `assets/icon.ico` using one of:

- **Online**: https://convertio.co/png-ico/ (upload icon.png, download icon.ico)
- **ImageMagick**: `magick convert assets/icon.png -resize 256x256 assets/icon.ico`
- **GIMP**: Open icon.png → Export As → icon.ico

Place the resulting `icon.ico` in the `assets/` folder, then run `npm run dist:win`.

## macOS Icon Setup (Required for .dmg)

Convert `assets/icon.png` to `assets/icon.icns`:

```bash
# macOS built-in tool
mkdir icon.iconset
sips -z 512 512 assets/icon.png --out icon.iconset/icon_512x512.png
iconutil -c icns icon.iconset -o assets/icon.icns
rm -rf icon.iconset
```

---

## Features

| Feature | Detail |
|---------|--------|
| Focus session | 75 minutes (configurable 1–240 min) |
| Break session | 20 minutes (configurable 1–120 min) |
| Alarm sound | Multi-tone chimes via Web Audio API (no external files) |
| Native OS notifications | System notification on every session switch |
| System tray | Minimizes to tray, shows countdown on macOS menu bar |
| Power save block | Prevents screen sleep during focus sessions |
| Global media keys | Play/Pause key starts/pauses timer |
| Session history | Color-coded timeline dots track your work |
| Auto-start | Automatically starts next session after alarm |
| Keyboard shortcuts | Space, Ctrl+K, Ctrl+R, Ctrl+M |
| Dark theme | Amber focus mode → Cyan break mode |

---

## Security Architecture

| Layer | Implementation |
|-------|---------------|
| Renderer isolation | `nodeIntegration: false`, `contextIsolation: true`, `sandbox: true` |
| IPC security | Channel allowlist in preload.js via `contextBridge` |
| Content-Security-Policy | Injected via session.webRequest — blocks XSS, inline injection, external connections |
| Network access | `connect-src 'none'` — app makes zero network requests after font load |
| Input sanitization | All user inputs HTML-encoded before DOM insertion |
| Prototype pollution | `Object.prototype` frozen on startup |
| Single instance lock | Prevents second process spawning |
| Navigation guard | All `will-navigate` events blocked unless `file://` protocol |
| New window guard | `setWindowOpenHandler` returns `{ action: 'deny' }` |
| Remote module | Disabled (not required) |
| `eval()` | Not used anywhere in codebase |

---

## Project Structure

```
focusguard/
├── main.js          Main Electron process (window, tray, IPC, notifications)
├── preload.js       Secure contextBridge — only safe APIs exposed to renderer
├── package.json     Dependencies + electron-builder config
├── src/
│   ├── index.html   App UI markup
│   ├── styles.css   Dark industrial theme
│   └── renderer.js  Timer logic, audio, display updates
└── assets/
    ├── icon.png     App icon (256×256)
    └── tray-icon.png Tray icon (64×64)
```

---

## License
MIT
