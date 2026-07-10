# Aura — Life Weather for Your Inner Ecosystem

**Privacy-first. Background-native. Beautiful.**

Aura turns passive signals from your iPhone (HealthKit, movement, usage patterns, sleep) into a living, abstract "weather" of your energy, creativity, and rhythm. No numbers. No dashboards. Just gentle, always-present awareness.

It is deliberately designed to **run itself** in the background using modern iOS features so you rarely have to open the app.

## ✨ What makes it special

- **True background operation**: BGAppRefreshTask + HealthKit observer queries + WidgetKit timelines keep your "ecosystem weather" fresh without you lifting a finger.
- **Live Activities + Dynamic Island**: Your current state ("Flowing", "Hushed", "Stirring"...) lives in the Dynamic Island and on the Lock Screen.
- **Home & Lock Screen Widgets**: Gorgeous, glanceable weather with tiny generative art.
- **On-device only**: All inference, history, and insights happen locally. Your raw signals never leave the device.
- **The aesthetic**: The exact "Earthy Editorial & Quiet Luxury" system (oat, sand, terracotta, sage, Fraunces + Inter, warm tactile shadows, subtle noise texture). Calm, premium, intentional.
- **Generative art**: The same organic flowing visualizations from the marketing demo, now running natively with SwiftUI `Canvas`.

This repo contains:
- `web/index.html` — the original stunning marketing/hero demo (open it in any browser)
- `ios/` — complete, high-fidelity SwiftUI prototype ready to drop into Xcode

---

## 🚀 Quick Preview (Web Demo)

```bash
cd aura
open web/index.html
```

Or view the hosted version after GitHub Pages is enabled.

The web page shows exactly what the iOS experience feels like (phone frame + interactive generative canvases).

---

## 📱 Run the Real iOS App (Background-Native Prototype)

### 1. Create a new Xcode project (iOS 17+ / iOS 18 recommended)

- Xcode → File → New → Project → iOS → App (SwiftUI)
- Name: `Aura`
- Interface: SwiftUI
- Language: Swift
- **Important**: Check "Include Widget Extension" and "Include Live Activity" if the wizard offers it (or add them manually later).

### 2. Replace / add the files from this repo

Copy the contents of `ios/Aura/` into your project (merge with the generated files).

Key files you'll get:
- `AuraApp.swift` — registers the background refresh task
- `ContentView.swift` + `EcosystemView.swift` — the beautiful main experience (matches the web demo)
- `Models/WeatherState.swift`
- `Services/HealthSignalManager.swift` — passive + background signal collection
- `Services/InsightEngine.swift` — pattern detection + micro-experiments
- `Services/PrivacyVault.swift` — local encrypted-ish storage (demo)
- `Widgets/AuraWidget.swift`
- `LiveActivity/AuraLiveActivity.swift`

### 3. Capabilities & Entitlements (required for real background behavior)

In the main `Aura` target:
- **HealthKit** (read: steps, heart rate, HRV, sleep)
- **Background Modes** → Background fetch + Background processing

For the Widget target and Live Activity:
- Enable the same + ActivityKit (for Live Activities)

Add the `BackgroundTasks` framework and register the task identifier `app.aura.refresh`.

### 4. Run

- Build & run on a real device (simulator has limited Health + background behavior).
- Grant Health permissions.
- Lock the phone. The state will continue to evolve via simulated + real background mechanisms.
- Add the Aura widget to your Home Screen / Lock Screen.
- Start a Live Activity from inside the app — watch it appear in the Dynamic Island.

The app is intentionally quiet. Most of the magic happens without you opening it.

---

## 🧠 How It Actually Runs in the Background

| Mechanism                  | What it does                                      | iOS Feature                  |
|----------------------------|---------------------------------------------------|------------------------------|
| BGAppRefreshTask           | Periodically wakes the app to recompute weather   | `BGAppRefreshTask`           |
| HealthKit Observer Queries | Reacts to new samples (steps, HR, sleep)          | `HKObserverQuery` + background delivery |
| Widget Timelines           | Updates widgets on a smart schedule               | `TimelineProvider`           |
| Live Activities            | Pushes state changes to Dynamic Island + LS       | `ActivityKit`                |
| On-device Insight Engine   | Detects shifts, suggests gentle experiments       | Pure Swift + local history   |

All processing is deliberately **passive** and low-power.

---

## 🎨 Design System

This entire experience follows the strict "Earthy Editorial & Quiet Luxury" rules defined in the original research conversations:

- Palette: `--oat`, `--sand`, `--espresso`, `--terracotta`, `--sage`, `--amber`, `--clay`
- Typography: Fraunces (serif, 500) for poetry + Inter for clarity
- Tactile pressed shadows, generous radii, subtle noise grain
- Italic emphasis on emotional words
- No harsh tech blues. Warm, grounded, editorial.

The web demo and the iOS prototype are pixel-spirit siblings.

---

## 🛠 Next Steps (Real Product Ideas)

- Replace simulation with real CoreMotion + on-device audio valence (SpeechAnalyzer or CreateML audio model)
- Persist longitudinal history with SwiftData
- Real Live Activity push updates from a silent push or CloudKit (private)
- Multiple "insight packs" as App Intents
- Export anonymized aggregates (opt-in) for the "Zero-Human" research angle

See the original chat logs (`chat-Zero-Human Company Framework Analysis.txt`) for the full product brief and the earlier ship-kit sketches.

---

## License & Philosophy

Prototype / concept. Use it, fork it, ship something beautiful and gentle.

Your inner ecosystem is not a product.

Built following the design system and concept from the Zero-Human explorations.

---

**Open `web/index.html` right now to fall in love with the aesthetic.**

Then bring the real thing to life on your phone.