# CB-EMR Technical Specification

**Product:** City Boy Election Monitoring & Result Management System (CB-EMR)  
**Stack:** Flutter + Dart · Riverpod · Hive (offline drafts) · Supabase (schema ready; app ships on local demo data)  
**Geography:** North-West Nigeria — Kaduna, Kano, Katsina, Jigawa, Kebbi, Sokoto, Zamfara  
**Branding:** APC green `#39a453`, blue `#5cc3e7`, red `#e52b32`, white, brown `#976532`

## 1. Purpose

CB-EMR is a mobile-first field + supervision app for election-day opening reports, incidents, and polling-unit result capture, with a multi-tier approval chain ending in a read-only Situation Room view of **state-verified** results only.

## 2. Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Flutter UI (features/)                                  │
│  Auth · Agent · Supervisor · Offline · Situation Room    │
└───────────────────────┬─────────────────────────────────┘
                        │ Riverpod providers
┌───────────────────────▼─────────────────────────────────┐
│  Repository abstraction                                  │
│  DemoRepository (in-memory + JSON assets + Hive drafts)  │
│  SupabaseRepository (future — same interface)            │
└───────────────────────┬─────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        ▼                               ▼
  assets/data/nw_geography.json    Hive boxes (drafts, sync queue)
  seed results / incidents         (local only until sync)
```

- **No live Supabase** is required to run the demo. Migrations under `supabase/migrations/` define the target PostgreSQL schema and RLS outline.
- Swap `repositoryProvider` from `DemoRepository` to `SupabaseRepository` when a project is configured.

## 3. Roles

| Role | Scope | Capabilities |
|------|--------|--------------|
| Field Agent | Assigned PUs / ward | Opening report, incident, result entry; view own submissions |
| Ward Supervisor | Ward | Approve/reject `pending_ward` → `pending_lga` |
| LGA Supervisor | LGA | Approve/reject `pending_lga` → `pending_state` |
| State Supervisor | State | Approve/reject `pending_state` → `state_verified` |
| Situation Room Analyst | Region (NW) | Read-only view of `state_verified` results + high-level incidents |
| Super Admin | System | All of the above + demo user management (stub) |

Passwordless **demo login picker** selects a seeded profile; no real credentials.

## 4. Workflow chain

```
Agent captures → draft (Hive if offline)
       │
       ▼ submit / sync
pending_ward  ──Ward approve──► pending_lga
       │ reject + reason
       ▼
pending_lga   ──LGA approve───► pending_state
       │ reject
       ▼
pending_state ──State approve─► state_verified
       │ reject
       ▼
state_verified ──► Situation Room (only this status)
```

Rejection returns the item to the agent with a reason; agent may edit and resubmit (`pending_ward` again).

## 5. Domain objects

- **Geography:** State → LGA → Ward → Polling Unit  
- **Election / Parties:** Demo election; parties APC, PDP, NNPP, LP  
- **Opening report:** PU opened, materials, officials present, GPS stub, timestamp  
- **Incident:** Category, description, optional photo path, GPS stub, severity  
- **Polling result:** Per-party votes, accredited voters, valid/invalid ballots; auto total + validation  
- **Approval:** Actor, from/to status, reason, timestamp  
- **Audit log:** Append-only client-side trail of mutations  

## 6. Offline

- Hive stores result/incident/opening **drafts** and a **sync queue**.  
- Sync queue UI lists pending uploads; in demo mode “Sync now” applies them into `DemoRepository` memory.  
- When online Supabase is wired, the same queue posts to REST/RPC.

## 7. Validation rules (results)

- Party votes ≥ 0 integers  
- Sum(party votes) ≤ accredited voters (soft warning if equal to valid votes expected)  
- `totalVotes` must equal sum of party votes  
- Required: PU, election, at least one party line  

## 8. Platforms

- Primary: Android APK (`flutter run` / `flutter build apk`)  
- Smoke: Web (`flutter run -d chrome` / `flutter build web`) when Android SDK unavailable  

## 9. Security notes (future Supabase)

- RLS by `profiles.role` + geography FKs on results/incidents  
- Service role never embedded in the app  
- See migration comments for policy sketches  

## 10. Non-goals (v1 demo)

- Live maps, push notifications, real camera EXIF pipeline, multi-election admin UI  
