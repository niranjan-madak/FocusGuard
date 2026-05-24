# CSP Reference — FocusGuard Security Policy

**Last Updated:** May 24, 2026  
**Status:** Production-ready

## Current policy (main.js)

```
default-src 'self';
script-src 'self';
style-src 'self';
font-src 'self' data:;
img-src 'self' data:;
connect-src 'none';
object-src 'none';
base-uri 'self';
form-action 'none';
```

## Policy breakdown

| Directive | Value | Purpose |
|-----------|-------|---------|
| `default-src` | `'self'` | All content must come from the app's own origin (file://) |
| `script-src` | `'self'` | Only scripts from the app are allowed; no inline scripts or external CDNs |
| `style-src` | `'self'` | Only stylesheets from the app; no inline styles or external CSS |
| `font-src` | `'self' data:` | Fonts from app origin or data: URIs (for embedded fonts) |
| `img-src` | `'self' data:` | Images from app or embedded data: URIs |
| `connect-src` | `'none'` | **ZERO network connections** — no fetch, XHR, WebSocket, etc. |
| `object-src` | `'none'` | Flash, applets, etc. blocked |
| `base-uri` | `'self'` | `<base>` tag can only reference app origin |
| `form-action` | `'none'` | Forms cannot POST anywhere |

## What this means for developers

### ✅ Allowed
- Loading JavaScript from `src/renderer.js` (part of app)
- Loading CSS from `src/styles.css` (part of app)
- Using inline event handlers **via JavaScript** (`addEventListener`):
  ```javascript
  button.addEventListener('click', () => { /* OK */ });
  ```
- Embedding fonts as data: URIs or WOFF2 files
- Embedding images as data: URIs or PNGs

### ❌ NOT allowed
- Inline event handlers in HTML (`onclick`, `onload`, etc.)
- Inline `<style>` tags in HTML
- Loading scripts from external CDNs
- Loading stylesheets from external sites
- Making network requests (fetch, XHR, WebSocket)
- Loading images from external URLs
- Using `eval()` or `new Function()`

## If you need to modify the policy

**Before tightening CSP further:**
1. Test the app thoroughly
2. Check DevTools Console for CSP violations
3. Document why the change is needed

**To test CSP violations:**
```bash
npm start
# Open DevTools (F12)
# Go to Console tab
# Perform actions that might violate CSP
# Look for messages like: "Refused to ... because of Content-Security-Policy"
```

## Common CSP violation scenarios and fixes

### Scenario: Need to load font from external source
**Don't do this.** Instead: Bundle fonts locally in `assets/fonts/` and use @font-face.

### Scenario: Need to make a network request
**Don't do this.** This is a desktop app. To interact with a backend:
1. Use IPC to communicate with main process
2. Main process can make network calls
3. Send results back to renderer via IPC

### Scenario: Need inline styles for dynamic colors
**Don't do this.** Instead:
1. Use CSS variables (already done in styles.css)
2. Update variables via `document.documentElement.style.setProperty('--name', value)`

### Scenario: Need inline JavaScript (event handler)
**Don't do this.** Instead:
1. Add an `id` to the element in HTML
2. Use `addEventListener` in renderer.js:
   ```javascript
   document.getElementById('myBtn').addEventListener('click', () => {
     // handler code
   });
   ```

## Testing CSP compliance

Add this to your test suite:

```javascript
// Test: No CSP violations in console
test('CSP: No violations during app lifetime', () => {
  let violations = [];
  document.addEventListener('securitypolicyviolation', (e) => {
    violations.push(e.violatedDirective);
  });
  
  // Perform app actions...
  
  expect(violations).toEqual([]); // Should be empty
});
```

## CSP evolution

If the app needs new capabilities in the future:

1. **Adding server communication:**
   - Add `https://your-api.com` to `connect-src`
   - Ensure HTTPS only

2. **Adding analytics/monitoring:**
   - Use privacy-focused local solutions (no external beacons)
   - Or use IPC to communicate with main process

3. **Adding Web Workers:**
   - Workers must be same-origin
   - CSP allows them by default with `'self'`

## Security reference

- [MDN: Content-Security-Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)
- [Electron: Security docs](https://www.electronjs.org/docs/tutorial/security)
- [CSP Evaluator](https://csp-evaluator.withgoogle.com/)

---

**Last audit:** 2026-05-24  
**Status:** ✅ Excellent security posture for a desktop app

