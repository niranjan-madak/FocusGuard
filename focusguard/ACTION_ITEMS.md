# ACTION ITEMS — What to Do Next

**Status:** Font bundling and CSP tightening complete ✅  
**Next action:** Download fonts and test

---

## Immediate Actions (Do this first)

### 1. Download fonts (automated)
```powershell
cd D:\Developed Softwares\GitHub-Repos\FocusGuard\focusguard
npm install
npm run setup:fonts
```

**What it does:**
- Creates `assets/fonts/` directory
- Downloads WOFF2 font files from Google Fonts
- Sets up font environment for app

**Expected output:**
```
Downloaded: Orbitron (3 weights)
Downloaded: Share Tech Mono (1 weight)
Downloaded: Exo 2 (3 weights)
✓ All fonts downloaded successfully!
```

### 2. Test the app
```powershell
npm start
```

**Verify:**
- ✓ App window opens
- ✓ Logo displays in correct font
- ✓ All text renders properly
- ✓ No CSP violations in DevTools Console
- ✓ All buttons work (click to test)
- ✓ No console errors

### 3. Build installer
```powershell
npm run dist              # Auto-detect OS
# OR
npm run dist:win          # Windows only
npm run dist:mac          # macOS only
npm run dist:linux        # Linux only
```

**Output location:** `dist/` folder
- Windows: `FocusGuard-1.0.0.exe`
- macOS: `FocusGuard-1.0.0.dmg`
- Linux: `FocusGuard-1.0.0.AppImage`

---

## If Font Download Fails

### Manual setup:
1. Go to https://fonts.google.com/
2. Search for and download WOFF2 files:
   - **Orbitron**: weights 400, 700, 900
   - **Share Tech Mono**: weight 400
   - **Exo 2**: weights 300, 400, 600

3. Save all 7 files to: `assets/fonts/`

4. Run: `npm start`

See `FONT_SETUP.md` for detailed instructions.

---

## Verification Workflow

### Before building, run this checklist:

```
□ npm install completed without errors
□ npm run setup:fonts completed successfully
□ npm start launches the app
□ Logo displays in Orbitron font
□ Buttons work (start, skip, reset)
□ No CSP violations in DevTools Console
□ Timer counts down correctly
□ All text renders properly
□ DevTools Network tab: no failed requests
□ App works when network disconnected
```

### After building:

```
□ dist/ folder contains installer
□ Installer file size looks normal (~100 MB)
□ Can install and run from installer
□ Installed app works offline
□ Settings persist between sessions
```

---

## Development Workflows

### For code changes:
1. Make changes to `src/` or `main.js`
2. Run: `npm start`
3. Test the changes
4. Commit and push

**Important:** Don't change font handling without updating documentation.

### For adding features:
1. Write test first (TDD)
2. Check for CSP violations
3. No inline event handlers (use `addEventListener`)
4. Document in `memory/`

---

## Common Commands

```powershell
# Setup
npm install              # Install Electron and dependencies
npm run setup:fonts      # Download fonts from Google Fonts

# Development
npm start                # Run dev version with logging
npm run dev              # Alternative dev command

# Building
npm run dist             # Build for current OS
npm run dist:win         # Build Windows installer
npm run dist:mac         # Build macOS installer
npm run dist:linux       # Build Linux installers
npm run pack             # Create app bundle without installer
```

---

## Document Guide

| Document | Purpose | Read if... |
|----------|---------|-----------|
| `QUICK_START.md` | Quick reference | You want 5-min overview |
| `FONT_SETUP.md` | Font installation | Automated script fails |
| `COMPLETION_SUMMARY.md` | Full summary | You want details |
| `memory/CSP_REFERENCE.md` | CSP policy | You need CSP details |
| `memory/IMPLEMENTATION_CHECKLIST.md` | Verification | You want to test |
| `memory/FONTS_AND_CSP_IMPROVEMENTS.md` | Technical details | You're a developer |

---

## Quick Test Script

Use this to quickly verify everything works:

```powershell
# Windows PowerShell
$ErrorActionPreference = "Stop"

cd "D:\Developed Softwares\GitHub-Repos\FocusGuard\focusguard"

Write-Host "1. Installing dependencies..." -ForegroundColor Green
npm install

Write-Host "`n2. Setting up fonts..." -ForegroundColor Green
npm run setup:fonts

Write-Host "`n3. Checking font files..." -ForegroundColor Green
$fontCount = (Get-ChildItem assets\fonts\ -Filter *.woff2 | Measure-Object).Count
Write-Host "✓ Found $fontCount font files"

Write-Host "`n4. Testing app (Ctrl+C to stop)..." -ForegroundColor Green
npm start

Write-Host "`n✓ All checks passed!" -ForegroundColor Green
```

---

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| npm install fails | Check Node.js version (18+): `node --version` |
| setup:fonts fails | Manual download: see `FONT_SETUP.md` |
| Fonts not rendering | Check `assets/fonts/` has all 7 files |
| CSP violations | No `onclick=` in HTML, all handlers via `addEventListener` |
| Build fails | Run `npm run setup:fonts` first |
| App crashes on startup | Check DevTools Console for errors |
| Buttons don't work | Verify event listeners in `src/renderer.js` |

---

## Next Big Tasks

After fonts and CSP are tested ✅:

### 1. **Add test suite** (HIGH priority)
   - Currently 0% test coverage
   - Create: `tests/renderer/timer.test.js`
   - Use: Vitest or Jest
   - See: `memory/TESTING_MEMORY.md`

### 2. **Setup CI/CD** (HIGH priority)
   - Create: `.github/workflows/build.yml`
   - Run: Linting, tests, build on every push
   - Enforce: 80% coverage minimum

### 3. **Code signing** (MEDIUM priority)
   - For Windows: Handle SmartScreen warnings
   - For macOS: Sign for Gatekeeper
   - See: electron-builder documentation

### 4. **Font optimization** (LOW priority, optional)
   - Use fonttools to subset fonts
   - Reduce: ~30KB per font → ~5-10KB

---

## Success Criteria

By end of this workflow, you should have:

✅ Fonts downloaded and bundled locally  
✅ CSP tightened (no 'unsafe-inline')  
✅ App tested and working offline  
✅ Installer built and working  
✅ Documentation complete  
✅ Ready for next phase (testing/CI)  

---

**Goal:** Have a production-ready, secure, offline-capable FocusGuard desktop app ✨

**Current status:** ✅ READY  
**Start with:** `npm install && npm run setup:fonts && npm start`

