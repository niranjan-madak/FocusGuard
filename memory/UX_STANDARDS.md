# UX_STANDARDS — FocusGuard

Framework: Flutter/Dart. Updated 2026-05-25.

## UX Philosophy

FocusGuard is designed for **deep work** — the UI should be minimal, non-distracting, and stay out of the way while providing essential information at a glance.

**Core Principles:**
- **Minimalism:** Only essential elements visible
- **Focus:** Timer is the primary focus
- **Non-intrusive:** Notifications and tray integration
- **Immediate:** One-click actions for common tasks
- **Feedback:** Clear visual feedback for all actions

---

## Visual Design

### Color Scheme

**Theme:** Dark industrial aesthetic

**Colors:**
- Background: `#05070f` (deep blue-black)
- Surface: `#141c2e` (slightly lighter)
- Focus accent: `#f59e0b` (amber)
- Break accent: `#06d6a0` (cyan)
- Text: `#e8eaf0` (off-white)
- Text muted: `#8899b4` (blue-gray)

**Theme Switching:**
- Focus mode: Amber accents
- Break mode: Cyan accents
- Smooth transition (0.8s)

**Rationale:** Dark theme reduces eye strain during long focus sessions. Color coding provides instant mode recognition.

---

### Typography

**Fonts:**
- Logo: `Orbitron` (monospace, futuristic)
- Timer: `Orbitron` (monospace, digital clock feel)
- Labels: `Share Tech Mono` (monospace, technical)
- Body: `Exo 2` (sans-serif, readable)

**Font Sizes:**
- Logo: 1.4rem
- Timer: 2.8rem
- Labels: 0.58-0.73rem
- Body text: 0.83rem

**Rationale:** Monospace fonts for technical elements, sans-serif for readability. Orbitron reinforces the "timer" aesthetic.

---

### Layout

**Structure:**
```
Header (logo + tagline)
    ↓
Status badge
    ↓
Main card
  - Timer ring (center)
  - Control buttons
  - Statistics
  - Timeline
  - Options
  - Settings
    ↓
Keyboard shortcuts
    ↓
Security badge
```

**Spacing:**
- Card padding: 2.2rem 1.8rem
- Element gaps: 1.4rem
- Button gaps: 10px

**Rationale:** Vertical flow with clear hierarchy. Timer is central and largest.

---

## Component Design

### Timer Display

**Widget:** `ProgressRing` (CustomPaint)

**Elements:**
- Time: `MM:SS` format via `Orbitron` font (40sp)
- Label: "REMAINING" below time
- Mode: "FOCUS SESSION" or "BREAK TIME"
- Ring: `CustomPaint` arc showing progress (0.0–1.0)

**Behavior:**
- Repaints on every second via `notifyListeners()`
- `shouldRepaint` guards unnecessary repaints
- Glow effect via `MaskFilter.blur` on arc

**Rationale:** Large, central, impossible to miss. Ring provides visual progress countdown.

---

### Control Buttons

**Widget:** `_Controls` inside `_MainCard`

**Buttons:**
1. START / PAUSE / RESUME (primary, wider)
2. SKIP (secondary, smaller)
3. RESET (danger, red border)

**Implementation:** `GestureDetector` + `Container` — no `ElevatedButton` (custom style)

**Rationale:** Primary action is most prominent. RESET uses red (`C.danger`) to signal destructive action.

---

### Statistics

**Widget:** `StatsBar`

**Metrics:**
- Sessions completed
- Focus time (hours + minutes)
- Full cycles

**Rationale:** Provides progress tracking. Compact display below controls.

---

### Session Timeline

**Widget:** `TimelineDots`

**Dot Types:**
- Amber (`C.focus`): Completed focus session
- Cyan (`C.brk`): Completed break session
- Pulsing dot: Current active session

**Behavior:**
- `Wrap` widget — wraps to new line automatically
- Updates after each session end

**Rationale:** Visual history provides sense of accomplishment.

---

### No System Tray

System tray integration was removed in the Flutter rewrite. There is no tray icon, no background operation indicator, and the app window must remain visible while running.

**Rationale for removal:** No stable Flutter tray plugin exists for all target platforms. Mobile targets don't support tray.

---

## Interaction Design

### Keyboard Shortcuts

**Primary Shortcuts:**
- `Space` — Start/Pause (most common)
- `Ctrl+K` — Skip session
- `Ctrl+R` — Reset timer
- `Ctrl+M` — Toggle mute

**Implementation:** `KeyboardListener` wrapping `Scaffold` in `HomeScreen`. Handles `KeyDownEvent` only.

**Limitation:** Shortcuts only work when the app window is focused (not global). Flutter's `KeyboardListener` is not a global hotkey.

**Rationale:** Power users prefer keyboard. Shortcuts are documented in the `_ShortcutsBar` widget at the bottom of the screen.

---

### Mouse Interactions

**Click Targets:**
- Buttons: Minimum 44×44px (WCAG AA)
- Toggles: 38×21px
- Settings inputs: 74px wide

**Feedback:**
- Hover states on all interactive elements
- Active states on click
- Cursor pointer on clickable elements
- Disabled state visual feedback

**Rationale:** Large click targets prevent misclicks. Clear feedback confirms actions.

---

### Notifications

**Implementation:** `flutter_local_notifications` — platform-native UI

**Platforms:** Android, iOS, Windows, Linux

**Content:**
- Focus ending: "Session Done — Take a Break!" / "Rest for N minutes."
- Break ending: "Break Over — Time to Focus!" / "Start your N-min focus session."

**Behavior:**
- High priority, sound disabled (app plays its own alarm sound)
- Single notification ID — replaces previous notification

**Rationale:** OS notifications alert users even when the app is not in the foreground.

---

### Alarm Banner

**Widget:** `AlarmBanner`

**Content:**
- Message indicating next session (focus or break) and duration
- Dismiss button → `m.dismissAlarm()`

**Behavior:**
- Visible when `TimerModel.alarmActive == true`
- Dismissed by user tap or on `reset()`
- Auto-start begins even while banner is visible (if `autoStart == true`)

**Rationale:** In-app visual backup alongside OS notification.

---

## Accessibility

### Keyboard Navigation

**Requirements:**
- All interactive elements keyboard accessible
- Tab order logical
- Focus indicators visible
- Shortcuts documented

**Status:**
- ✅ Tab navigation works
- ✅ Focus indicators visible
- ✅ Shortcuts documented in UI
- ⚠️ Some elements may not be fully accessible (needs audit)

---

### Screen Readers

**Requirements:**
- Semantic HTML
- ARIA labels where needed
- Alt text for images
- Live regions for dynamic content

**Status:**
- ✅ Semantic HTML used
- ⚠️ ARIA labels not implemented
- ⚠️ Live regions not implemented
- ⚠️ Needs accessibility audit

---

### Color Contrast

**Requirements:** WCAG AA (4.5:1 for normal text, 3:1 for large text)

**Status:**
- ✅ Background to text contrast: ~12:1 (excellent)
- ✅ Button text contrast: ~4.5:1 (meets AA)
- ✅ Status badge contrast: ~5:1 (exceeds AA)

---

### Visual Indicators

**Requirements:**
- Not color-only indicators
- Icons + color for status
- Text labels for icons

**Status:**
- ✅ Status badge has text + dot
- ✅ Timeline has color + tooltips
- ✅ Buttons have icons + text labels

---

## Responsive Design

### Layout Breakpoint

**Breakpoint:** 800px (`LayoutBuilder` on `constraints.maxWidth`)

**≥800px — Desktop two-column layout:**
- Left column (flex 4): Header → scaled `ProgressRing` → `ShortcutsBar`
- Right column (flex 5): `StatusBadge` → `ControlsCard` (controls + stats + timeline + options + settings)
- `Row` uses `CrossAxisAlignment.stretch` so both columns fill full height
- `ProgressRing` size: `(maxWidth * 0.22).clamp(260.0, 340.0)` — scales with window, caps at 340px

**<800px — Mobile single-column layout:**
- `SingleChildScrollView` → `_MainCard` (full ring + controls combined)
- Same layout as before responsive redesign
- Max content width: 440px (constrained via `ConstrainedBox`)

**Scroll:** Right column uses `SingleChildScrollView`; left column is non-scrollable (fixed)

**Rationale:** Wide desktop windows felt narrow and mobile-like before the redesign. Two-column layout uses horizontal space and places the ring prominently on the left.

---

### Platform Adaptations

**Mobile (Android/iOS):**
- `SafeArea` handles notch / status bar
- Touch targets via `GestureDetector`
- System bar color inherits from `scaffoldBackgroundColor`
- Single-column layout (below 800px breakpoint)

**Desktop (Windows/macOS/Linux):**
- `KeyboardListener` enables keyboard shortcuts
- `SystemChrome.setApplicationSwitcherDescription` updates task-switcher title
- Two-column layout (above 800px breakpoint)

**No system tray or menu bar integration** — Flutter does not provide these on all platforms.

---

## Loading States

### App Launch

**Behavior:**
- `main()` awaits `AudioService.init()` and `NotificationService.init()` before `runApp()`
- First frame shows default timer state immediately
- No loading spinner or splash screen beyond the OS default

**Rationale:** Async init is fast (~100ms). User sees the timer immediately.

---

## Error States

### Input Validation

**Behavior:**
- Settings inputs have min/max constraints
- Invalid inputs revert to defaults
- No error messages shown (silent correction)

**Rationale:** Prevents invalid state. Silent correction is less intrusive than error messages.

---

### Confirmation Dialogs

**Current behavior:** No confirmation dialogs. Skip and Reset are immediate actions.

**Rationale:** Skip and Reset are reversible within the same session (user can restart). Confirmation dialogs add friction to common actions. If needed in future, use Flutter's `showDialog` with `AlertDialog`.

---

## Performance

### Animation Performance

**Target:** 60fps for all animations

**Optimizations:**
- Flutter animations use `AnimationController` (hardware-accelerated)
- `_StatusBadge` pulse uses `AnimationController` with `repeat(reverse: true)`
- `ProgressRing` `shouldRepaint()` prevents unnecessary canvas redraws

**Status:** Animations are Flutter-native and hardware-accelerated.

---

### Timer Precision

**Target:** 1-second precision

**Implementation:** `Timer.periodic(const Duration(seconds: 1), _tick)`

**Accuracy:** May drift slightly over long periods (acceptable for a focus timer)

---

## Localization

### Current Status

**Languages:** English only  
**RTL Support:** Not implemented  
**Date/Time Formats:** English only

### Future Enhancement

**If adding localization:**
- Extract all strings to translation files
- Use i18n library (e.g., i18next)
- Support RTL layouts
- Test on all target languages

---

## User Feedback

### Visual Feedback

**Actions with Feedback:**
- Button clicks: Scale animation
- Timer start: Button text changes
- Session end: Flash animation + notification
- Settings apply: Panel closes + timer resets

**Rationale:** Every action should have visible feedback.

---

### Audio Feedback

**Sounds (WAV files via `audioplayers`):**
- Button clicks: `click.wav`
- Timer tick: `tick.wav` (last 10 seconds)
- Focus alarm: `focus_alarm.wav` (break ending → focus starts)
- Break alarm: `break_alarm.wav` (focus ending → break starts)

**Volume Control:**
- Slider in UI (0–100%) via `setVolume()`
- Mute toggle (Ctrl+M) via `toggleSound()`

**Rationale:** Audio feedback reinforces the timer state. Fully disableable.

---

## UX Best Practices

### Do's

✅ Keep UI minimal and focused  
✅ Provide clear visual feedback  
✅ Use platform-native components  
✅ Support keyboard shortcuts  
✅ Make common actions one-click  
✅ Use color for information, not decoration  
✅ Design for accessibility  
✅ Test on all target platforms  

### Don'ts

❌ Clutter UI with unnecessary elements  
❌ Hide important features  
❌ Use custom UI components when native exists  
❌ Require mouse for common actions  
❌ Use color as only indicator  
❌ Ignore accessibility  
❌ Assume all users have same abilities  

---

## UX Testing

### Recommended Tests

- **Usability Testing:** Watch users complete common tasks
- **A11y Testing:** Screen reader testing, keyboard navigation
- **Platform Testing:** Test on Windows, macOS, Linux
- **Performance Testing:** Measure animation frame rates
- **A/B Testing:** Test alternative UI designs (if making changes)

### Current Status

**Testing:** None performed  
**User Feedback:** None collected  
**Analytics:** None implemented

---

## Summary

FocusGuard UX is designed for deep work with:
- Minimal, distraction-free interface
- Clear visual hierarchy with timer as focus
- Platform-native integration (tray, notifications)
- Keyboard shortcuts for power users
- Dark theme for reduced eye strain
- Color-coded modes for instant recognition

**UX Philosophy:** Stay out of the way, provide essential information, respect user's focus.

**Current Status:** UX is well-designed for its purpose. Accessibility audit recommended.
