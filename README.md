<div align="center">

<img src="assets/images/solo_system_logo.png" width="120" height="120" alt="Solo System Logo" />

# ⚔ Solo Leveling — Personal System Builder

**Turn your real life into an RPG.**
Build quests, track habits, climb ranks, and face consequences for failure — just like the hunters of *Solo Leveling*.

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-22C55E?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-4A9EFF?style=flat-square)](https://flutter.dev)

</div>

---

## 📸 Overview

Solo Leveling System is a productivity app with a dark RPG aesthetic inspired by the *Solo Leveling* anime/manhwa. The core idea is simple: your daily goals become quests with real XP rewards, your failures spawn penalty tasks with escalating consequences, and your growth is reflected through a hunter profile with ranks, stats, and achievements.

No deadlines means no pressure. Missed deadlines means the system punishes you. The system always watches.

---

## ✨ Features

### ⚔ Quest Board (Tab 1)
- Active quest cards with **Legendary / Epic / Rare / Common** rarity tiers
- **Optional deadlines** — set a date/time or mark quests as open-ended (∞ No Deadline)
- **One-tap Complete or Fail** — completing earns XP, failing spawns penalties
- Quests auto-fail on app open if the deadline has passed
- **Penalty quest section** shown urgently at the top in red
- **Level Up dialog** with animation when you hit the XP threshold

### 🔁 Habit Tracker (Tab 2)
- Repeating quests that reset on schedule — daily, weekly, monthly, or every N days
- **Weekday picker** for fine-grained control (e.g. Mon/Wed/Fri only)
- **Forever or end date** — run a habit indefinitely or set a stop date
- **Streak tracking** — consecutive completions build your streak; missing a day resets it
- Habits with penalties enabled auto-spawn a penalty quest the next time you open the app if yesterday's scheduled habit was missed

### 📋 Task Archive (Tab 3)
- Full quest management: All / Active / No Deadline / Completed / Failed / Locked
- **Live search** and **rarity filter**
- Tap any quest to edit — title, description, XP, rarity, deadline, tags, penalty config, unlock level
- Delete or archive with confirmation

### 📌 Reminders (Tab 4)
- Passive notes with no deadlines or actions required
- **Pin** important reminders to keep them at the top
- 6 categories: General, Health, Productivity, Personal, Learning, Other
- 16 emoji choices and 8 color swatches per reminder
- Tap to edit, trash to delete — no system consequences

### 👤 Hunter Profile (Tab 5)
- Profile photo from gallery + editable name and custom title
- **Rank badge** (E → D → C → B → A → S) tied to your level
- **XP progress bar** with exponential level scaling
- **7-day XP activity chart**
- **5 hunter stats**: Strength, Agility, Intelligence, Endurance, Perception — auto-boosted on level-up
- Mission report: total quests, completion rate, penalty count
- **Achievements** — 7 to unlock with XP bonuses
- **Rank Progression** screen showing all 6 tiers and their unlock levels
- Settings: edit name/title, reset all data

---

## ⚠ Penalty Escalation System

This is what separates this app from every other todo list.

When you fail a quest or miss a habit, a **penalty quest** is spawned with a 24-hour deadline. If you ignore that too, the system escalates:

| Tier | Time Limit | XP Lost if Ignored | Title |
|:---:|:---:|:---:|:---|
| 0 | 24 hours | base | ⚠ PENALTY |
| 1 | 12 hours | +50 XP | 🔴 ESCALATED |
| 2 | 6 hours | +100 XP | 💀 SEVERE PENALTY |
| 3 | 3 hours | +200 XP | ☠ FINAL WARNING |

Tier 3 is the last escalation. After that the quest is simply failed — but the XP loss and the shame remain.

On app open, if any penalties escalated overnight, a **System Warning dialog** appears immediately showing how many escalated and how much XP was deducted. Every penalty card also shows a **live countdown timer** that turns orange under 3 hours and red when overdue.

---

## 🏆 Progression

| Level Range | Rank | Title |
|:---:|:---:|:---|
| 1 – 9 | **E** | Novice Hunter |
| 10 – 24 | **D** | Awakened Hunter |
| 25 – 39 | **C** | Seasoned Hunter |
| 40 – 59 | **B** | Elite Hunter |
| 60 – 79 | **A** | Master Hunter |
| 80+ | **S** | Shadow Monarch |

XP required per level scales exponentially: `1000 × 1.15^(level - 1)`. At level 17 you need ~10,000 XP to advance; by level 50 you're looking at ~117,000.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.0.0
- Dart ≥ 3.0.0
- Android Studio or VS Code with Flutter & Dart plugins
- Android emulator / physical device **or** iOS Simulator / physical device

### Install & Run

```bash
# Clone the repo
git clone https://github.com/yourusername/solo-leveling-system.git
cd solo-leveling-system

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Build APK (Android)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build IPA (iOS)

```bash
flutter build ios --release
# Then archive via Xcode
```

---

## 📁 Project Structure

```
lib/
├── main.dart                         # App entry, provider setup, escalation warning
├── theme/
│   └── app_theme.dart                # Color system, text styles, ThemeData
│
├── models/
│   ├── quest.dart                    # Quest — rarity, status, deadline, penaltyTier, xpPenaltyOnExpiry
│   ├── habit.dart                    # Habit — RepeatConfig, streak, penalty fields
│   ├── hunter.dart                   # Hunter — rank, stats, XP history, achievements
│   └── reminder.dart                 # Reminder — note, emoji, category, pin, color
│
├── providers/
│   ├── quest_provider.dart           # Quest CRUD, overdue check, penalty escalation, achievements
│   ├── habit_provider.dart           # Habit CRUD, missed-day detection, penalty spawning
│   └── reminder_provider.dart        # Reminder CRUD, pin toggle
│
├── services/
│   └── storage_service.dart          # Singleton — SharedPreferences persistence for all models
│
├── screens/
│   ├── main_shell.dart               # 5-tab bottom nav with per-tab accent colors
│   ├── splash_screen.dart            # Animated boot screen
│   ├── quests/
│   │   ├── quests_screen.dart        # Tab 1 — quest board, hunter header, penalty section
│   │   ├── quest_detail_screen.dart  # Full-screen quest view with complete/fail actions
│   │   └── level_up_dialog.dart      # Animated level-up overlay
│   ├── habits/
│   │   ├── habits_screen.dart        # Tab 2 — today view with progress ring, all-habits tab
│   │   └── habit_form_sheet.dart     # Add/edit habit — frequency, weekdays, until-when, penalty
│   ├── tasks/
│   │   └── tasks_screen.dart         # Tab 3 — archive with search, filter, 6 sub-tabs
│   ├── reminders/
│   │   ├── reminders_screen.dart     # Tab 4 — pinned + all reminders
│   │   └── reminder_form_sheet.dart  # Add/edit — emoji picker, color swatches, categories
│   └── profile/
│       ├── profile_screen.dart       # Tab 5 — stats, XP chart, achievements, settings nav
│       ├── rank_progression_screen.dart  # All 6 rank tiers with unlock levels
│       └── settings_screen.dart      # Edit name/title, reset data
│
└── widgets/
    ├── common/
    │   └── common_widgets.dart       # GlassContainer, XpProgressBar, RankBadge, StatBar,
    │                                 # SystemButton, TagChip, SectionHeader, SystemDivider
    └── quest/
        ├── quest_card.dart           # Full card + compact card + penalty countdown timer
        └── quest_form_sheet.dart     # Add/edit quest — all fields, no-deadline toggle, penalty
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.1 | State management via ChangeNotifier |
| `shared_preferences` | ^2.2.3 | Local key-value persistence |
| `flutter_animate` | ^4.5.0 | Entrance animations, scale, fade, slide |
| `fl_chart` | ^0.68.0 | XP activity line chart on profile |
| `image_picker` | ^1.1.3 | Profile photo from gallery |
| `uuid` | ^4.4.0 | Unique IDs for all models |
| `intl` | ^0.19.0 | Date/time formatting |
| `percent_indicator` | ^4.2.4 | Circular progress ring |
| `shimmer` | ^3.0.0 | Loading skeletons |
| `table_calendar` | ^3.1.2 | Calendar view (extensible) |
| `cached_network_image` | ^3.3.1 | Image caching |
| `path_provider` | ^2.1.3 | File system paths |
| `confetti` | ^0.7.0 | Level-up celebration effect |
| `lottie` | ^3.1.0 | Lottie animation support |
| `glassmorphism` | ^3.0.0 | Glass effect utilities |
| `hive` + `hive_flutter` | ^2.2.3 | Structured local DB (optional migration) |

---

## 🎨 Design System

The entire UI follows a Solo Leveling system aesthetic — deep dark backgrounds, blue system accents, and per-rank color coding.

### Color Palette

| Role | Hex | Usage |
|---|---|---|
| Background Deep | `#05050F` | Scaffold, status bar |
| Background Primary | `#0A0A1A` | Screen backgrounds |
| Background Card | `#0D0D1F` | Cards, containers |
| System Blue | `#4A9EFF` | Primary accent, XP bar, nav |
| Rank S — Gold | `#FFD700` | S-rank, achievements |
| Rank A — Purple | `#A855F7` | A-rank, epic rarity |
| Rank B — Blue | `#4A9EFF` | B-rank, rare rarity |
| Rank C — Green | `#22C55E` | C-rank, common rarity, habits |
| Danger Red | `#EF4444` | Penalties, failures, warnings |
| Warning Amber | `#F59E0B` | Streaks, urgency |
| Mana Purple | `#8B5CF6` | Reminders tab accent |

### Rarity Accent Colors

Each quest card has a left-edge accent bar in its rarity color, an XP badge, and matching tag chips — all consistent across the quest board, archive, and detail screen.

---

## 🔧 Customization

### Change XP scaling
```dart
// lib/models/hunter.dart
static int _calculateXpRequired(int level) {
  return (1000 * pow(1.15, level - 1)).toInt(); // adjust the 1.15 multiplier
}
```

### Change rank thresholds
```dart
// lib/models/hunter.dart
void _updateRank() {
  if (level >= 80) rank = HunterRank.s;
  else if (level >= 60) rank = HunterRank.a;
  // adjust thresholds here
}
```

### Add a new achievement
```dart
// lib/providers/quest_provider.dart — inside _checkAndGrantAchievements()
_AchievementCheck('your_id', 'Title', 'Description', '🏆',
    _hunter.someCondition, xpBonus),
```

### Add a new hunter stat
```dart
// lib/models/hunter.dart — HunterStats class
int charisma = 10; // add field + update toJson/fromJson

// lib/screens/profile/profile_screen.dart — _buildStatsCard()
StatBar(label: 'Charisma', value: hunter.stats.charisma,
    color: AppColors.rankS, icon: Icons.star),
```

### Change penalty escalation timing
```dart
// lib/providers/quest_provider.dart — _spawnEscalatedPenalty()
final (hours, xpLoss, prefix) = switch (tier) {
  1 => (12, ..., '🔴 ESCALATED'),   // change hours here
  2 => (6,  ..., '💀 SEVERE PENALTY'),
  _ => (3,  ..., '☠ FINAL WARNING'),
};
```

---

## 🧠 Architecture

The app uses a straightforward **Provider + Service** pattern:

```
UI Widgets
    │
    ▼
ChangeNotifier Providers          ← quest_provider, habit_provider, reminder_provider
    │
    ▼
StorageService (Singleton)        ← SharedPreferences wrapper, idempotent init()
    │
    ▼
Models                            ← Quest, Habit, Hunter, Reminder (plain Dart classes)
```

**Key design decisions:**
- `StorageService` is a singleton with an idempotent `init()` — each provider calls `await _storage.init()` independently so initialization order doesn't matter
- `HabitProvider` takes a `QuestProvider` reference via `ChangeNotifierProxyProvider` — this lets it spawn penalty quests and deduct XP from the hunter without circular dependencies
- `QuestProvider.init()` returns `PenaltyEscalationResult` so `AppLoader` can show the system warning dialog without extra state
- All form sheets use `PopScope` + `MediaQuery.viewInsets` padding pattern to fix the Android keyboard-refocus bug

---

## 🤝 Contributing

Pull requests are welcome. For major changes, open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

**The system does not forgive weakness.**

*Built with Flutter · Inspired by Solo Leveling*

</div>
