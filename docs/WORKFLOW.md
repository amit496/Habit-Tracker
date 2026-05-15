# HabitFlow workflow

## Screens

| Screen | Role |
|--------|------|
| Splash | Branding → onboarding (first run) or main shell |
| Onboarding | 2-page intro (skippable) |
| Today | Scheduled habits for today, category filter, progress ring |
| Calendar | Month grid + habits for selected day |
| Stats | 7-day chart, streaks, tap habit → detail |
| Settings | Theme, backup/restore, CSV export, habits |
| Habit form | Create/edit: category, schedule, reminder, archive |
| Habit detail | Streaks, 30-day bars, log history |

## Hive boxes

- `habits` — habit definitions
- `habit_logs` — per-day completion, count, note
- `settings` — `isDarkMode`, `weekStart`, `onboardingComplete`

## Habit fields (v1.2)

- `categoryKey` — general, health, fitness, study, …
- `scheduleDays` — `[1..7]` weekdays; empty = every day
- `reminderHour` / `reminderMinute` — `-1` = off
- `archived` — hidden from Today, kept in backup

## Backup JSON

```json
{
  "version": 1,
  "habits": [...],
  "logs": [...],
  "settings": { "isDarkMode": false, "weekStart": 1 }
}
```

Restore **replaces** all habits and logs.
