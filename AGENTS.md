# Aura — Life Weather for Your Inner Ecosystem

Privacy-first iOS app that turns passive iPhone signals (HealthKit, movement,
sleep, usage patterns) into an abstract, ambient "weather" of your energy and
rhythm. No numbers, no dashboards. On-device only.

**Aesthetic**: Earthy Editorial & Quiet Luxury — oat/sand/terracotta/sage,
Fraunces + Inter, warm shadows, subtle noise. Keep any UI work on-system.

## Layout

- `web/index.html` — standalone marketing/demo page (open directly in a browser)
- `ios/` — complete SwiftUI prototype: BGAppRefreshTask + HealthKit observer
  queries, WidgetKit timelines, Live Activities/Dynamic Island, generative
  `Canvas` art, PrivacyVault + InsightEngine services. Drop into Xcode as-is.
  Native iOS build/TestFlight requires the Apple Developer account (pending).
- `server/` — optional local-first Node backend (Express, ESM) for manual
  check-ins when you want cross-device data.

## Server

```bash
cd server && npm install && npm start   # http://localhost:8741 (PORT env)
```

Single JSON file storage under `server/data/` (never commit). Bearer-token
auth minted at first handshake; no passwords/accounts.

Endpoints: `POST /api/handshake`, `GET|PUT /api/profile`,
`POST /api/checkins`, `GET /api/checkins?days=30`, `GET /api/summary?days=7`
(state machine: e.g. "drifting"), `GET /api/export`, `DELETE /api/data`.

Check-in schema: `mood` 1–10, `energy` 1–10, `sleep` 0–16 hours required;
optional free-text `note`.

## Rules

1. **Privacy is the product**: never add telemetry, cloud sync, or raw-signal
   uploads. All inference stays on-device (iOS) / localhost (server).
2. iOS code follows the existing service split (HealthSignalManager,
   InsightEngine, PrivacyVault) — keep new signal processing in a service.
3. Weather states/headlines come from the server's state machine or the iOS
   InsightEngine — keep the copy gentle, no numbers in user-facing strings.
