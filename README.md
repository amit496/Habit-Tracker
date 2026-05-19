# HabitFlow

Offline habit tracker for Android & iOS — build streaks, track daily habits, and view progress. **No account, no cloud, no internet required.**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)
![License](https://img.shields.io/badge/License-MIT-blue)

## Features

- **Today** — check off habits, daily progress ring, category filters
- **Calendar** — month view, complete habits for any past day
- **Stats** — 7-day chart, per-habit streaks, monthly completions
- **Habits** — icon, color, categories, optional daily target count
- **Weekly schedule** — e.g. gym on Mon / Wed / Fri only
- **Reminders** — daily local notifications with 5 built-in sounds + custom audio
- **Notes** — long-press a habit to add a note for that day
- **Backup** — export / restore full JSON; export logs as CSV
- **Archive** — hide habits without losing history
- **Dark mode** — light & dark themes

## Screenshots

_Add screenshots here after publishing._

## Tech stack

| Layer | Choice |
|--------|--------|
| UI | Flutter (Material 3) |
| State | Provider |
| Storage | Hive (local) |
| Charts | fl_chart |
| Calendar | table_calendar |
| Notifications | flutter_local_notifications |

## Getting started

### Requirements

- Flutter SDK 3.x
- Android Studio / Xcode (for device builds)

### Run

```bash
git clone https://github.com/amit496/Habit-Tracker.git
cd Habit-Tracker
flutter pub get
flutter run
```

Use **`flutter clean`** then a full **Run** (not hot restart) after changing icons or notification plugins.

### Build release

```bash
# Android APK (install on phone)
flutter build apk --release

# Android App Bundle (Google Play)
flutter build appbundle --release

# iOS (requires Xcode + signing)
flutter build ios --release
```

Output:

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## Project structure

```
lib/
├── core/theme/       # App colors & theme
├── models/           # Habit & log models
├── providers/        # HabitProvider
├── screens/          # Today, Calendar, Stats, Settings, …
├── services/         # Hive, reminders, backup, export
└── widgets/          # Habit tiles, charts, logo
```

See [docs/WORKFLOW.md](docs/WORKFLOW.md) for screen flow and Hive boxes.

## Privacy & legal

All data stays on your device. HabitFlow does not send habit data to any server.

**Everything is in the app** — no website needed for users:

**Settings → Legal** → Privacy Policy, Terms of Service, About

For Google Play submission (one public URL for the store form only): see [docs/PLAY_STORE.md](docs/PLAY_STORE.md). Copy text from [docs/PRIVACY_POLICY.md](docs/PRIVACY_POLICY.md) if you use free Google Sites.

## License

MIT — see [LICENSE](LICENSE) if added.

## Author

Built with Flutter. Contributions welcome via pull requests.
