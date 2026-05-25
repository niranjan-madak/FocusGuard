# FEATURES — FocusGuard

Version: 1.0.1+2 | Framework: Flutter/Dart

## Core Features

### 1. Focus Timer

**Description:** 75-minute focus sessions (configurable 1–240 minutes)

**Implementation:**
- `TimerModel.secsLeft` counts down via `Timer.periodic(1s)`
- `ProgressRing` widget renders `CustomPaint` arc (progress 0.0 → 1.0)
- Time displayed as MM:SS via `timeStr` getter
- States: READY / FOCUSING / PAUSED

**User Controls:**
- Start/Pause/Resume button or `SPACE` key
- Skip (Ctrl+K)
- Reset (Ctrl+R)

**Configuration:**
- `SettingsPanel` widget — range 1–240 min, default 75

---

### 2. Break Timer

**Description:** 20-minute break sessions (configurable 1–120 minutes)

**Implementation:**
- Automatic transition after focus session ends
- Theme accent shifts amber → cyan (`C.mc(isFocus)`)
- Same timer UI and logic as focus mode

**Configuration:**
- `SettingsPanel` widget — range 1–120 min, default 20

---

### 3. Alarm Sounds

**Description:** Four distinct sounds via `audioplayers` package (WAV files)

**Sound files:**

| File | When played |
|------|------------|
| `sounds/focus_alarm.wav` | Break just ended → focus session starts |
| `sounds/break_alarm.wav` | Focus just ended → break starts |
| `sounds/click.wav` | Any button tap or control interaction |
| `sounds/tick.wav` | Last 10 seconds of any session (countdown tick) |

**User Controls:**
- Sound toggle switch (Ctrl+M)
- Volume slider (0–100%)

---

### 4. Native OS Notifications

**Description:** Platform notification on every session transition

**Implementation:** `flutter_local_notifications`

**Platforms:** Android, iOS, Windows, Linux (macOS via DarwinInitializationSettings)

**Content:**
- Focus ending: "Session Done — Take a Break!" / "Rest for N minutes."
- Break ending: "Break Over — Time to Focus!" / "Start your N-min focus session."

**Behavior:**
- High priority, sound disabled (sound handled by app)
- Single notification ID (0) — replaces previous if shown again

---

### 5. Wakelock (Screen-on During Focus)

**Description:** Prevents screen sleep during active focus sessions

**Implementation:** `wakelock_plus` — `WakelockPlus.toggle(enable: running && !paused && isFocus)` called on every `HomeScreen` rebuild

**Behavior:**
- Screen stays on only during active (non-paused) focus sessions
- Screen can sleep normally during breaks and when paused

---

### 6. Session History Timeline

**Description:** Color-coded dot row tracks completed sessions

**Implementation:** `TimelineDots` widget reads `TimerModel.history` (list of `'focus'` | `'break'` strings)

**Display:**
- Amber dot: completed focus session
- Cyan dot: completed break session
- Pulsing dot: current active session

**Limitations:**
- Not persisted across app restarts

---

### 7. Auto-Start

**Description:** Automatically starts next session after alarm

**Implementation:**
- `Future.delayed(isFocus ? 3200ms : 4000ms)` in `_onSessionEnd()`
- Checks `!running && autoStart` before starting

**User Control:** Toggle switch in options row

---

### 8. Keyboard Shortcuts

**Description:** Quick controls without mouse

**Shortcuts:**

| Key | Action |
|-----|--------|
| `SPACE` | Start / Pause / Resume |
| `Ctrl+K` | Skip session |
| `Ctrl+R` | Reset |
| `Ctrl+M` | Toggle mute |

**Implementation:** `KeyboardListener` wrapping `Scaffold` in `HomeScreen`, handles `KeyDownEvent`

---

### 9. Dynamic Theme

**Description:** Amber focus mode → Cyan break mode

**Implementation:**
- `C.mc(isFocus)` returns accent color based on session type
- `C.md(isFocus)` returns dim variant
- `C.mg(isFocus)` returns glow variant
- Applied to: progress ring, status badge, buttons, sliders, box shadows

**Colors:**
- Focus accent: `#F59E0B` (amber)
- Break accent: `#06D6A0` (cyan)
- Background: `#05070F` (dark navy)

---

### 10. Statistics Display

**Description:** Real-time session stats

**Metrics:**
- Sessions completed (focus count)
- Focus time (hours + minutes)
- Full cycles (break count)

**Implementation:** `StatsBar` widget reads `TimerModel` derived values. Updated on every session end.

---

### 11. Settings Panel

**Description:** Customize timer durations

**Settings:**
- Focus duration (1–240 min)
- Break duration (1–120 min)

**Implementation:** `SettingsPanel` widget with text fields; `onApply` calls `TimerModel.applySettings()` which triggers `reset()`

**Note:** Sound / volume / auto-start are in the main options row, not the settings panel.

---

### 12. Alarm Banner

**Description:** In-app alert shown when a session ends

**Implementation:** `AlarmBanner` widget — visible when `TimerModel.alarmActive == true`

**Content:** Shows what the next session is (focus or break), how long it runs, with a dismiss button

**Dismiss:** `m.dismissAlarm()` → `alarmActive = false`

---

### 13. Responsive Desktop Layout

**Description:** Two-column layout on wide screens; single-column on mobile/narrow windows

**Breakpoint:** `constraints.maxWidth >= 800px` (detected via `LayoutBuilder`, not `MediaQuery`)

**Desktop layout (≥800px):**
- Left column (flex 4): Header + `ProgressRing` (scaled) + `ShortcutsBar`
- Right column (flex 5): `StatusBadge` + `ControlsCard` (controls, stats, timeline, options, settings)
- `CrossAxisAlignment.stretch` on `Row` ensures both columns fill full height

**Ring size formula:** `(constraints.maxWidth * 0.22).clamp(260.0, 340.0)` — smooth scaling, caps at 340px

**Mobile layout (<800px):** Single-column `SingleChildScrollView` wrapping `_MainCard`

**Implementation:**
- `LayoutBuilder` wraps the `SafeArea` body in `HomeScreen`
- `_buildDesktopLayout()` and `_buildMobileLayout()` methods on `_HomeScreenState`
- `_ControlsCard` widget — right-column-specific variant of `_MainCard` (no ring)
- `ProgressRing` accepts `size` parameter; fonts and stroke width scale via `size / 230`

---

## Feature Status Matrix

| Feature | Status | Tested | Configurable |
|---------|--------|--------|--------------|
| Focus Timer | ✅ Complete | ❌ No | ✅ Yes |
| Break Timer | ✅ Complete | ❌ No | ✅ Yes |
| Alarm Sounds | ✅ Complete | ❌ No | ✅ Yes |
| OS Notifications | ✅ Complete | ❌ No | ❌ No |
| Wakelock | ✅ Complete | ❌ No | ❌ No |
| Session History | ✅ Complete | ❌ No | ❌ No |
| Auto-Start | ✅ Complete | ❌ No | ✅ Yes |
| Keyboard Shortcuts | ✅ Complete | ❌ No | ❌ No |
| Dynamic Theme | ✅ Complete | ❌ No | ❌ No |
| Statistics | ✅ Complete | ❌ No | ❌ No |
| Settings Panel | ✅ Complete | ❌ No | ✅ Yes |
| Alarm Banner | ✅ Complete | ❌ No | ❌ No |
| Responsive Desktop Layout | ✅ Complete | ❌ No | ❌ No |

## Features Removed in Flutter Rewrite (vs Electron v1.0.0)

| Feature | Reason |
|---------|--------|
| System tray | No stable Flutter tray plugin |
| Global media keys | No Flutter equivalent |
| Window flash on notification | Not applicable in Flutter |
| Security badge UI | Removed (security model changed) |
| Native confirm dialog (IPC) | Not needed without IPC |

## Future Feature Ideas

### High Priority
- Session data persistence (`shared_preferences` already declared)
- Statistics dashboard (daily/weekly charts)
- Custom alarm sounds

### Medium Priority
- System tray (via community plugin)
- Pomodoro mode (25/5)
- Settings persistence (volume, sound, auto-start across restarts)

### Low Priority
- Multiple timer profiles
- Export session data
- Custom themes
