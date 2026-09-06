# Safetify — Admin Dashboard

Admin web console for **Safetify**, a real-time crowdsourced incident reporting and safety alert system built as a final year project at Bayero University, Kano (Case Study: Kano State, Nigeria). This repo is the dashboard that public safety administrators use to verify incoming reports, push alerts, and monitor activity across the system. The companion mobile client that residents use to submit reports lives in a separate repo (linked below).

Built with Flutter, targeting web as the primary platform, backed by Firebase.

## What it does

Residents submit geo-tagged incident reports from the Safetify mobile app. This dashboard is where an administrator turns those reports into action:

- **Overview** — at-a-glance counts of pending vs. verified incidents, plus the most recent reports coming in
- **Incidents** — searchable, filterable table of all reports, with a detail view per incident for review and status changes
- **Map** — live map of reported incidents plotted by location, for spotting clusters and hotspots
- **Alerts** — compose and push safety alerts to residents in a target area, and post community updates
- **Analytics** — incident trends over configurable time ranges (last 7 days, last 30 days, all time), built with `fl_chart`
- **Audit Logs** — a record of administrative actions for accountability
- **User Management** — manage resident and administrator accounts
- **Auth** — administrator login and password recovery, backed by Firebase Auth

## Architecture

The dashboard follows a fairly standard layered Flutter structure:

```
lib/
├── config/       # Firebase options, app-wide constants, theming
├── models/       # Incident, alert, user, audit log, community update
├── services/      # Firebase Auth, Cloud Firestore, and FCM wrappers
├── providers/     # State management (Provider) — auth, incidents, users, dashboard, theme
├── views/
│   ├── auth/         # Login, forgot password
│   ├── dashboard/     # Shell: header, sidebar, main layout
│   └── pages/         # Overview, Incidents, Map, Alerts, Analytics, Audit Logs, Users, Settings, Profile
├── widgets/       # Shared UI: cards, buttons, data tables, status badges, skeleton loaders
├── router.dart    # go_router navigation
└── main.dart / app.dart
```

State flows through `provider`, with each domain area (incidents, users, auth, dashboard) getting its own `ChangeNotifier`. Firestore is the source of truth for incidents, alerts, and audit logs, with real-time updates surfaced through streams rather than manual polling — so a report verified on one admin's screen reflects on another's without a refresh.

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter (web) |
| State management | Provider |
| Routing | go_router |
| Backend | Firebase (Auth, Cloud Firestore, Cloud Messaging, Storage) |
| Maps | flutter_map + latlong2 |
| Charts | fl_chart |
| Fonts/UI | google_fonts |

## Running locally

1. Clone the repo and fetch packages:
   ```
   git clone https://github.com/AbubakarAbdulrahim/safetify2.git
   cd safetify2
   flutter pub get
   ```
2. Set up a Firebase project with Authentication, Firestore, Cloud Messaging, and Storage enabled, and add your own `firebase_options.dart` (via `flutterfire configure`) — the one in this repo is tied to the project's own Firebase instance and won't work with your credentials.
3. Run for web:
   ```
   flutter run -d chrome
   ```

## Related repo

- Mobile client (resident-facing incident reporting app): *https://github.com/AbubakarAbdulrahim/Safetify/tree/backend/users*

## Project background

Safetify was developed as a final year project in the Faculty of Computing, Bayero University, Kano, evaluated through unit, integration, system, and usability testing — scoring 4.4/5.0 in usability testing with an average alert delivery latency of approximately 2.1 seconds. It's currently being extended into a research paper and forms the basis of ongoing graduate research proposals in mobile crowdsensing.
