# PRODUCT_OVERVIEW — FocusGuard

## Product Identity

**Name:** FocusGuard
**Tagline:** Deep Work Focus Timer
**Type:** Cross-platform Application (Mobile + Desktop)
**Version:** 1.0.1+2
**Framework:** Flutter / Dart
**License:** MIT

## Value Proposition

FocusGuard is a secure, fully offline application designed to help users maintain deep work focus through structured interval timing. It implements the 75-minute focus / 20-minute break pattern (configurable), with alarm sounds, OS notifications, and session history tracking.

## Target Users

**Primary Persona:** Knowledge workers, developers, writers, researchers, and students who need sustained focus periods.
**Secondary Persona:** Productivity enthusiasts using time-blocking techniques.
**User Type:** B2C (individual users)

## Core Value Proposition

- **Privacy-First:** Fully offline, no data collection, no cloud dependencies
- **Cross-Platform:** Android, iOS, Windows, macOS, Linux from one codebase
- **Distraction-Free:** Minimal UI designed to stay out of the way
- **Zero Cost:** Free and open-source, no subscription required
- **No Sign-up:** Works immediately with zero configuration

## Business Model

**Model:** Free / Open Source
**Revenue:** None (personal project)
**Monetization:** Not applicable

## Success Metrics

Since this is a free personal project without analytics, success metrics are qualitative:
- User adoption (GitHub stars, forks, downloads)
- Community contributions (issues, PRs)
- User feedback (positive reviews, feature requests)

## User Journey

1. **Install:** Download from GitHub Releases or build from source
2. **Launch:** App opens with default 75/20 minute settings
3. **Configure:** Optionally customize durations, volume, auto-start in settings
4. **Use:** Tap START or press SPACE — timer runs with alarm sound at session end
5. **Notifications:** Native OS notification on every session transition
6. **Track:** Session history shown as color-coded dots in timeline
7. **Repeat:** Automatic or manual session cycling

## Platform Support

| Platform | Status |
|----------|--------|
| Android | ✅ Supported |
| iOS | ✅ Supported |
| Windows | ✅ Supported |
| macOS | ✅ Supported |
| Linux | ✅ Supported |

## Key Differentiators

vs. Web-based timers:
- ✅ Works offline completely
- ✅ Native OS notifications
- ✅ No browser tabs needed
- ✅ Mobile app experience

vs. Other desktop timers:
- ✅ Also runs on mobile (Android/iOS)
- ✅ Open source and auditable
- ✅ Zero data collection
- ✅ Keyboard shortcuts for power users

## Current Status

**Development Stage:** Active
**Release Status:** v1.0.1+2
**Maintenance Mode:** Active

## Future Roadmap (Potential)

- Session data persistence across app restarts (shared_preferences already declared)
- Statistics dashboard (daily/weekly focus time)
- Custom alarm sounds
- System tray integration (community Flutter plugin)
- Settings persistence (volume, sound, auto-start)
- Pomodoro mode (25/5) as alternative
