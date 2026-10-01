# CB-EMR Flutter Folder Structure

```
cb-emr/
├── assets/
│   ├── data/nw_geography.json      # Trimmed NW hierarchy (all states/LGAs; sample wards/PUs)
│   └── images/apc-logo.png, city-boy-logo.png
├── docs/
│   ├── TECH_SPEC.md
│   ├── ERD.md
│   └── FOLDER_STRUCTURE.md
├── supabase/migrations/001_initial.sql
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── theme/app_theme.dart
│   │   ├── router/app_router.dart
│   │   └── utils/validators.dart
│   ├── data/
│   │   ├── models/                 # Domain models
│   │   ├── repositories/
│   │   │   ├── emr_repository.dart           # Abstract interface
│   │   │   ├── demo_repository.dart          # In-memory + assets
│   │   │   └── supabase_repository.dart      # Stub for future wiring
│   │   ├── demo/demo_seed.dart               # Users, parties, seed results
│   │   └── local/hive_drafts.dart            # Offline drafts + sync queue
│   └── features/
│       ├── splash/presentation/
│       ├── auth/presentation/                # Login picker, forgot stub
│       ├── agent/presentation/               # Dashboard, PU, forms
│       ├── supervisor/presentation/          # Approval queue
│       ├── offline/presentation/             # Sync queue UI
│       └── situation_room/presentation/      # Read-only verified
├── test/
├── pubspec.yaml
└── README.md
```

## Feature layout convention

Each feature folder holds presentation (screens/widgets). Shared state lives in Riverpod providers next to repositories under `data/`. Prefer thin screens that call repository methods via `ref.watch` / `ref.read`.
