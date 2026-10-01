# CB-EMR — City Boy Election Monitoring & Result Management

Flutter + Dart mobile demo for North-West Nigeria election field capture, multi-tier approval, and Situation Room preview.

**Branding:** City Boy Movement × APC · green `#39a453` · blue `#5cc3e7` · red `#e52b32` · brown `#976532`

**Repo:** https://github.com/rersheed/cb-emr

## Stack

- Flutter / Dart
- Riverpod (state)
- Hive (offline drafts + sync queue)
- GoRouter
- Supabase schema prepared as SQL (`supabase/migrations/`) — **app runs on local `DemoRepository`** first (no live Supabase required)
- Clear swap point: `lib/data/repositories/supabase_repository.dart` stub vs `demo_repository.dart`

## Docs

| Doc | Path |
|-----|------|
| Tech spec & workflow | [docs/TECH_SPEC.md](docs/TECH_SPEC.md) |
| ERD (Mermaid) | [docs/ERD.md](docs/ERD.md) |
| Folder structure | [docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md) |
| Postgres schema + RLS outline | [supabase/migrations/001_initial.sql](supabase/migrations/001_initial.sql) |

## Geography (demo)

North-West only: **Kaduna, Kano, Katsina, Jigawa, Kebbi, Sokoto, Zamfara**.

Asset `assets/data/nw_geography.json` is a **trimmed** subset adapted from [elecmonitor](https://github.com/rersheed/elecmonitor) `nw-geography.json`:

- All **7 states** and **all LGAs**
- Up to **3 wards × 5 PUs** per LGA (~558 wards / ~2.8k PUs) for mobile performance

## Prerequisites

- Flutter **stable** 3.35+ (Dart 3.9+)
- For Android APK: Android SDK / emulator or device
- For smoke without Android: Chrome (web) or Linux desktop toolchain

```bash
# Example install (Linux)
# Extract Flutter to /opt/flutter and:
export PATH="/opt/flutter/bin:$PATH"
flutter doctor
```

## Run

```bash
git clone https://github.com/rersheed/cb-emr.git
cd cb-emr
flutter pub get

# Web smoke test (no Android SDK needed)
flutter run -d chrome
# or
flutter build web

# Analyze / tests
flutter analyze
flutter test

# Android
flutter run                 # connected device / emulator
flutter build apk --release # APK under build/app/outputs/flutter-apk/
```

## Demo accounts (passwordless picker)

On the login screen, tap a role:

| Name | Role | Demo focus |
|------|------|------------|
| Amina Mohammed | Field Agent | Assigned Kaduna North PUs — opening / incident / results |
| Ibrahim Garba | Ward Supervisor | Approve `pending_ward` → `pending_lga` |
| Aisha Suleiman | LGA Supervisor | Approve `pending_lga` → `pending_state` |
| Sani Bello | State Supervisor | Approve `pending_state` → `state_verified` |
| Hauwa Ibrahim | Situation Room | Read-only **state_verified** |
| Amina Yusuf | Super Admin | All pending queues + Situation Room |

### Approval walkthrough

1. Login as **Field Agent** → open a PU → **Enter results** → Submit  
2. Logout → login as **Ward Supervisor** → **Approve**  
3. Repeat as **LGA** then **State** supervisor  
4. Login as **Situation Room** → item appears only when status is `state_verified`

Save drafts with **Save offline** / **Save draft offline**, then open **Offline sync queue** → **Sync now**.

## Project layout (short)

```
lib/
  core/          theme, router, constants, validators
  data/          models, DemoRepository, Hive, seed
  features/      auth, agent, supervisor, offline, situation_room, splash
assets/images/   apc-logo.png, city-boy-logo.png
assets/data/     nw_geography.json
```

## License

Demo / campaign tooling — not for production election certification without further hardening.
