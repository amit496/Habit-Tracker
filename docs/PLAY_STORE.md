# Google Play — bina apni website ke

HabitFlow **sirf app** hai. Users ke liye sab kuch app ke andar hai:

**Settings → Legal →** Privacy Policy, Terms of Service, About

---

## Play Console ek URL maangta hai (ye website nahi)

Google Play **Privacy policy URL** field **required** hai. Iska matlab apka khud ka business website hona zaroori **nahi**.

### Option 1 — Google Sites (free, 10 minute)

1. [sites.google.com](https://sites.google.com) par jao  
2. Ek page banao: title **HabitFlow Privacy Policy**  
3. Text copy karo: project ki file `docs/PRIVACY_POLICY.md`  
4. **Publish** → jo link mile wo Play Console mein paste karo  

Ye sirf Play ke form ke liye hai. App users ko website par bhejne ki zarurat nahi.

### Option 2 — GitHub (agar repo public ho)

Agar code GitHub par hai, ye URL use kar sakte ho:

`https://github.com/YOUR_USERNAME/Habit-Tracker/blob/main/docs/PRIVACY_POLICY.md`

---

## Play Console — Data safety (short)

| Question | Answer |
|----------|--------|
| Collects user data? | **No** (local on device) |
| Shares with third parties? | **No** |
| Account required? | **No** |
| Encrypted in transit | N/A (no server) |
| Delete data | Uninstall app |

Permissions: Notifications, Alarms, Files (backup / custom sound only).

---

## Build upload

```bash
flutter build appbundle --release
```

File: `build/app/outputs/bundle/release/app-release.aab`

---

## Email

App mein: `lib/core/constants/app_info.dart` → `contactEmail`

Play Console **Developer contact** mein wahi email use karo.
