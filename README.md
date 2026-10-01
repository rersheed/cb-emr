# CB-EMR — City Boy Election Monitoring & Result Management

Flutter + Dart mobile/web demo for North-West Nigeria election field capture, multi-tier approval, and Situation Room preview.

**Branding:** City Boy Movement × APC · green `#39a453` · blue `#5cc3e7` · red `#e52b32` · brown `#976532`

**Repo:** https://github.com/rersheed/cb-emr  
**Live web (GitHub Pages):** https://rersheed.github.io/cb-emr/

## Stack

- Flutter / Dart
- Riverpod (state)
- Hive (offline drafts + sync queue)
- GoRouter
- **Supabase** (live project `sullcpwiddjrbzhlqfrn`) — hybrid with local demo fallback
- Schema: `supabase/migrations/` (+ temporary demo RLS policies in `002_demo_anon_policies.sql`)

## Supabase (live)

| | |
|--|--|
| Project URL | `https://sullcpwiddjrbzhlqfrn.supabase.co` |
| Project ref | `sullcpwiddjrbzhlqfrn` |
| Client key | **anon** (public) — see `.env.example` / `lib/core/supabase_config.dart` |

The app uses a **hybrid** repository (`SupabaseRepository`):

1. Always boots `DemoRepository` + Hive so the UI never breaks offline.
2. On startup probes `parties` via the anon client; sets **Connected to Supabase** or **Demo local**.
3. Upserts demo profiles; persists results / openings / incidents / approvals to Supabase when connected (best-effort).
4. Splash + login show a small cloud indicator for connection status.

> **Security note:** Demo RLS policies currently allow anon R/W (`anon_all_demo`). Tighten before any real election use.

### dart-define / env

```bash
# See .env.example
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://sullcpwiddjrbzhlqfrn.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-jwt>
```

Defaults are baked into `lib/core/supabase_config.dart` for the public demo build.

### Seeded data

- Parties (APC, PDP, NNPP, LP) + demo election `11111111-1111-1111-1111-111111111111`
- NW geography from `assets/data/nw_geography.json` (~7 states / 185 LGAs / 556 wards / 2772 PUs)
- Demo profiles (UUID) for passwordless role picker
- Optional full SQL dump: `supabase/seed_geography.sql`

## Docs

| Doc | Path |
|-----|------|
| Tech spec & workflow | [spec/TECH_SPEC.md](spec/TECH_SPEC.md) |
| ERD (Mermaid) | [spec/ERD.md](spec/ERD.md) |
| Folder structure | [spec/FOLDER_STRUCTURE.md](spec/FOLDER_STRUCTURE.md) |
| Postgres schema | [supabase/migrations/001_initial.sql](supabase/migrations/001_initial.sql) |
| Temporary demo RLS | [supabase/migrations/002_demo_anon_policies.sql](supabase/migrations/002_demo_anon_policies.sql) |

## Geography (demo)

North-West only: **Kaduna, Kano, Katsina, Jigawa, Kebbi, Sokoto, Zamfara**.

Asset `assets/data/nw_geography.json` is a **trimmed** subset adapted from [elecmonitor](https://github.com/rersheed/elecmonitor) `nw-geography.json`:

- All **7 states** and **all LGAs**
- Up to **3 wards × 5 PUs** per LGA for mobile performance

## Prerequisites

- Flutter **stable** 3.35+ (Dart 3.9+)
- For Android APK: Android SDK / emulator or device
- For smoke without Android: Chrome (web) or Linux desktop toolchain

```bash
export PATH="/opt/flutter/bin:$PATH"
flutter doctor
```

## Run

```bash
git clone https://github.com/rersheed/cb-emr.git
cd cb-emr
flutter pub get

# Web smoke test (no Android SDK needed)
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://sullcpwiddjrbzhlqfrn.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-jwt>

flutter build web --base-href /cb-emr/ \
  --dart-define=SUPABASE_URL=https://sullcpwiddjrbzhlqfrn.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-jwt>

flutter analyze
flutter test
```

### GitHub Pages deploy (from repo root)

```bash
export PATH="/opt/flutter/bin:$PATH"
flutter pub get
flutter build web --base-href /cb-emr/ \
  --dart-define=SUPABASE_URL=https://sullcpwiddjrbzhlqfrn.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-jwt>
rm -rf docs && mkdir docs && cp -a build/web/. docs/ && touch docs/.nojekyll
git add -A && git commit -m "Connect CB-EMR Flutter web to Supabase cb-emr project" && git push origin main
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
  core/          theme, router, constants, supabase_config, validators
  data/          models, DemoRepository, SupabaseRepository (hybrid), Hive, seed
  features/      auth, agent, supervisor, offline, situation_room, splash
assets/images/   apc-logo.png, city-boy-logo.png
assets/data/     nw_geography.json
supabase/        migrations + geography seed SQL
```

## License

Demo / campaign tooling — not for production election certification without further hardening.
