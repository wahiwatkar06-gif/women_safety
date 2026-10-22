# Safe Journey — Women's Safety Mobile Application

Safe Journey is a modern, minimal, iOS/Android-inspired personal safety application designed to empower women and solo travelers with proactive arrival check-ins, editable transit routes, and automated emergency escalation to trusted guardians.

---

## 🌟 Key Features

- **Proactive Journey Monitoring**: Set expected arrival time before stepping out. At your ETA, the app checks in on you automatically ("Are you safe?").
- **3-Tier Automated Escalation**: If check-ins go unanswered across 3 reminders, the app dispatches an emergency broadcast with your route and last known GPS coordinates to your Guardian Circle.
- **Editable Route Planning**: Customize and swap your starting location and destination on demand.
- **Flexible Time Selection**: 15 min, 20 min, 30 min, and Custom duration options (5 to 180 min).
- **One-Tap SOS Panic Button**: Instant emergency dispatch and siren trigger.
- **Trusted Contacts Management**: Add, edit, delete, and toggle which contacts receive alerts, plus test simulated SMS alerts.
- **Clean Light Aesthetics**: Modern, minimal white and soft lavender theme inspired by iOS and Material 3 design principles.

---

## 📁 Repository Structure

```
.
├── Safe_Journey/                # Flutter Mobile Application Source
│   ├── lib/
│   │   ├── main.dart            # Main navigation shell & app lifecycle
│   │   ├── theme/               # Material 3 light design system
│   │   ├── models/              # Journey & Trusted Contact data models
│   │   └── screens/             # Home, Active Journey, Contacts, Settings, Check-in
│   ├── test/                    # Widget and unit tests
│   └── pubspec.yaml             # Flutter dependencies
│
└── web_preview/                 # Interactive Browser Simulator & Demo Website
    ├── index.html               # High-fidelity live web simulator
    └── assets/                  # UI assets and illustrations
```

---

## 🚀 Running the Project

### Option 1: Live Web Simulator (Instant Preview)
Open `web_preview/index.html` in any modern web browser or serve it with Python:
```bash
python -m http.server 8085 --directory web_preview
```
Navigate to `http://localhost:8085` to interact with the full prototype.

### Option 2: Flutter Mobile App (Android & iOS)
Inside the `Safe_Journey` directory:
```bash
cd Safe_Journey

# 1. Generate platform runners (first time only)
flutter create .

# 2. Get dependencies
flutter pub get

# 3. Run on connected Android or iOS device / emulator
flutter run
```

---

## 🛡️ Production Roadmap
For production emergency deployment:
1. Integrate background GPS tracking with `flutter_background_geolocation`.
2. Connect Firebase Cloud Functions for cloud-side scheduled timers (so escalations trigger even if phone battery dies).
3. Connect an SMS gateway (Twilio / AWS SNS / MSG91) via a secure backend API.
