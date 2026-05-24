# Font Setup Guide

FocusGuard uses three custom fonts bundled locally for full offline capability and improved CSP security:

## Prerequisites
- Node.js v18+
- Internet connection (for initial font download)

## Quick Setup

Run the following to download fonts from Google Fonts:

```bash
npm run setup:fonts
```

This will:
1. Create the `assets/fonts/` directory
2. Download WOFF2 font files
3. Verify font integrity

## Manual Setup (if script fails)

If the automated script doesn't work, manually download fonts:

### 1. Download fonts from Google Fonts

Visit https://fonts.google.com/ and download:

**Orbitron** (for logo and headings)
- Weight 400 (Regular) → `Orbitron-Regular.woff2`
- Weight 700 (Bold) → `Orbitron-Bold.woff2`
- Weight 900 (Black) → `Orbitron-Black.woff2`

**Share Tech Mono** (for labels and monospace text)
- Weight 400 (Regular) → `ShareTechMono-Regular.woff2`

**Exo 2** (for body text)
- Weight 300 (Light) → `Exo2-Light.woff2`
- Weight 400 (Regular) → `Exo2-Regular.woff2`
- Weight 600 (SemiBold) → `Exo2-SemiBold.woff2`

### 2. Place files in correct directory

Copy all downloaded `.woff2` files to:
```
focusguard/assets/fonts/
```

Directory structure should be:
```
assets/fonts/
├── Orbitron-Regular.woff2
├── Orbitron-Bold.woff2
├── Orbitron-Black.woff2
├── ShareTechMono-Regular.woff2
├── Exo2-Light.woff2
├── Exo2-Regular.woff2
└── Exo2-SemiBold.woff2
```

### 3. Verify setup

Run the app to confirm fonts load:
```bash
npm install
npm start
```

If fonts don't load, check browser console (DevTools) for errors about missing .woff2 files.

## CSP Changes

The following CSP improvements have been made:

**Before:**
```
style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
font-src https://fonts.gstatic.com 'self' data:;
connect-src 'none';
```

**After:**
```
style-src 'self';
font-src 'self' data:;
connect-src 'none';
```

This means:
- ✅ No external stylesheet connections (fonts.googleapis.com removed)
- ✅ No external font files (fonts.gstatic.com removed)
- ✅ No inline styles (CSP compliance improved)
- ✅ True offline capability (all resources bundled)

## Troubleshooting

### Fonts not rendering
1. Check `assets/fonts/` contains all 7 `.woff2` files
2. In DevTools, check Network tab for 404 errors on .woff2 files
3. Check DevTools Console for CSP violations
4. Verify file names match exactly (case-sensitive on Linux/macOS)

### CSP violation errors
If you see CSP errors in console, it means the app is still loading from external sources.
Ensure index.html does NOT have Google Fonts `<link>` tags.

### Font fallbacks
If fonts fail to load, the app will fall back to system fonts:
- Orbitron → monospace
- Share Tech Mono → monospace
- Exo 2 → sans-serif

(App remains fully usable with fallback fonts.)

## Future: Subsetting

To further optimize bundle size, consider font subsetting:
- Only include glyphs needed by the app (digits, letters, punctuation)
- Use tools like `fonttools` or Google Fonts subsetting services
- Can reduce font files from ~30KB to ~5-10KB per font

