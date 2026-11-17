# Kaduna Election Monitoring Demo — Integration and Use Guide

## Dataset prepared
The uploaded Kaduna workbook was normalized into:
- **23 LGAs**
- **255 wards**
- **8,013 polling units**

The app-ready geography file is `kaduna_geography.json`.
The detailed source-derived CSV is `kaduna_polling_units_detailed.csv`.

## A. Add Kaduna data to CB-EMR (Flutter reporting app)
Repository: `rersheed/cb-emr`

1. Copy `kaduna_geography.json` to:
   `assets/data/kaduna_geography.json`
2. Replace:
   `lib/core/constants/app_constants.dart`
   with the supplied `app_constants.dart`.
3. Run:
   `flutter pub get`
4. Validate:
   `flutter analyze`
   `flutter test`
5. Start:
   `flutter run`
6. Login using the built-in demo role picker.
7. The Field Agent demo assignment will resolve against Kaduna North because the repository already prefers Kaduna North when generating demo users.

## B. Add Kaduna data to ElecMonitor (Situation Room)
Repository: `rersheed/elecmonitor`

1. Copy `kaduna-geography.json` to:
   `src/data/kaduna-geography.json`
2. Replace:
   `src/data/geography.ts`
   with the supplied `geography.ts`.
3. Run:
   `npm install`
   `npm run build`
4. Rebuild GitHub Pages:
   `rm -rf docs && cp -a dist docs && touch docs/.nojekyll`
5. Commit and push.

This makes the hierarchy shown in the Situation Room use the Kaduna dataset from the uploaded workbook.

## C. Build the Android reporting APK
Repository: `rersheed/cb-emr`

### Local build
Run:
`flutter pub get`
`flutter analyze`
`flutter test`
`flutter build apk --release`

Output:
`build/app/outputs/flutter-apk/app-release.apk`

### GitHub Actions build
Copy the supplied `build-apk.yml` to:
`.github/workflows/build-apk.yml`

Push to `main` or manually run **Build Android APK** in GitHub Actions.
Download the artifact named:
`cb-emr-kaduna-demo-apk`

## D. Demo walkthrough for tomorrow
1. Open the Situation Room dashboard.
2. Show Kaduna → LGA → Ward → Polling Unit drill-down.
3. Open the reporting app as **Field Agent**.
4. Select an assigned polling unit.
5. Submit an **Opening Report**.
6. Submit a sample **Incident Report**.
7. Enter a sample **Polling Unit Result**.
8. Logout and login as **Ward Supervisor**; approve the result.
9. Repeat approval as **LGA Supervisor**.
10. Repeat approval as **State Supervisor**.
11. Login as **Situation Room**; show the now verified result.
12. Demonstrate **Save offline** and the **Offline sync queue** for areas with poor network connectivity.

## E. Important demo note
The current repository README states that the Supabase demo policies allow anonymous read/write access. Keep the presentation on demonstration data only until authentication and RLS policies are hardened for production.
