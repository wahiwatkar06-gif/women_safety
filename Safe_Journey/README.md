# Safe Journey — Women's Safety Mobile Application

Safe Journey is a modern, minimal, iOS/Android-inspired personal safety mobile application redesigned with a clean white and light-color theme. It empowers solo commuters, students, and women with proactive arrival check-ins, editable transit routes, and automated escalation to trusted guardians.

---

## 1. Design System & Theme

- **Main Background**: Pure White (`#FFFFFF`)
- **Card Background**: Very light slate gray (`#F8FAFC`)
- **Primary Accent**: Soft Lavender (`#8B7CF6`)
- **Secondary Accent**: Light Pink (`#FCE7F3`)
- **Main Typography**: Dark Charcoal (`#1F2937`)
- **Secondary Text**: Gray (`#6B7280`)
- **Borders**: Subtle Light Gray (`#E5E7EB`)
- **SOS Button**: Soft Red (`#EF4444`) — prominent and accessible, yet minimal and balanced

---

## 2. Redesigned Screen Architecture

```
lib/
├── main.dart                       # App entry point, MainNavigationShell (4 bottom tabs), shared state
├── theme/
│   └── app_theme.dart              # Material 3 light theme, typography, component styles
├── models/
│   ├── journey_data.dart           # Journey state, locations, start/arrival times
│   └── trusted_contact.dart        # Contact model, phone validation, alert toggles
└── screens/
    ├── home_screen.dart            # "Plan your journey" card, editable source/destination, duration chips
    ├── active_journey_screen.dart  # Countdown timer, vertical route timeline, safe completion & SOS
    ├── contacts_screen.dart        # Trusted contacts manager, add/edit/delete, alert toggle, test alert
    ├── settings_screen.dart        # Profile & medical notes, duration preferences, permission statuses
    └── check_in_dialog.dart        # "Are you safe?" 3-tier modal & emergency escalation preview
```

### Screen Highlights:
1. **Home Screen**:
   - Header with logo, app title, and "Your safety, every journey" subtitle.
   - White rounded card: **Plan your journey**.
   - Editable **Starting from** with location-pin icon & "Use current location" button.
   - Quick location swap button.
   - Editable **Going to** with destination icon & quick preset chips (*Home*, *Campus Dorm*, *Metro Station*).
   - Expected arrival time buttons: **15 min**, **20 min**, **30 min**, and **Custom** (slider 5–180 min).
   - Full-width **Start Safe Journey** button with input validation.
   - Quick **SOS — Emergency Alert** button.

2. **Active Journey Screen**:
   - Clean countdown timer (`MM:SS`) in soft lavender with check-in target time.
   - Vertical timeline route visualizer showing Origin, connecting line, and Destination.
   - Metadata summary: Started at, Duration, Expected arrival.
   - **I'm Safe — End Journey** button with accidental end confirmation dialog.
   - Soft red **SOS** emergency button and simulated test check-in prompt.

3. **Safety Check-In System**:
   - Proactive modal: **"Are you safe?"**
   - Two large buttons: **"Yes, I'm safe"** (soft emerald `#10B981`) and **"I need help"** (soft red `#EF4444`).
   - 3-attempt reminder sequence. If unanswered across 3 attempts, automatically initiates guardian alert escalation.

4. **Trusted Contacts Screen**:
   - Full CRUD (Create, Read, Update, Delete) for guardians.
   - Phone number format validation.
   - Per-contact toggle switch: *Receive safety escalations & SMS*.
   - Simulated test alert button to preview SMS dispatch without external charges.

5. **Settings Screen**:
   - Edit personal name and emergency medical note (e.g. blood group, allergies).
   - Default journey duration & safety check-in interval selectors.
   - Transparent permissions indicator: distinguishes active local features from simulated external gateways.
   - Privacy Policy and About Safe Journey dialogs.

---

## 3. Running the App on Android and iOS

### Prerequisites
1. Install Flutter SDK (`>= 3.3.0`): [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
2. Run `flutter doctor` to ensure Android toolchain or Xcode is configured.

### Initial Setup (Generate Platform Runners)
If this folder does not yet contain platform folders (`android/`, `ios/`), generate them once:
```bash
cd Safe_Journey
flutter create .
```

### Run on Android
1. Start an Android emulator from Android Studio or connect a physical Android device via USB (with USB Debugging enabled).
2. Check connected devices:
   ```bash
   flutter devices
   ```
3. Run the app:
   ```bash
   flutter run -d android
   ```

### Run on iOS (macOS required)
1. Open the iOS Simulator:
   ```bash
   open -a Simulator
   ```
2. Navigate to the project and install CocoaPods dependencies:
   ```bash
   cd Safe_Journey/ios && pod install && cd ..
   ```
3. Run the app:
   ```bash
   flutter run -d ios
   ```

### Run on Web / Chrome
```bash
flutter run -d chrome
```

---

## 4. Production Integration Requirements (GPS, SMS & Backend)

To transition from this clean UI prototype to a production emergency service, integrate the following services:

### A. Location Permissions & Real-Time Tracking
- **Package**: `flutter_background_geolocation` or `geolocator`.
- **Android Manifest (`AndroidManifest.xml`)**:
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`
  - `ACCESS_BACKGROUND_LOCATION`
  - `FOREGROUND_SERVICE`
- **iOS Info.plist**:
  - `NSLocationWhenInUseUsageDescription`
  - `NSLocationAlwaysAndWhenInUseUsageDescription`
  - Background Modes: `location`

### B. Cloud Backend & Scheduled Failsafe Timers
*Mobile OSes can kill apps running in the background. A reliable safety timer must run on the server:*
- **Backend Service**: Google Cloud Functions / Firebase Cloud Functions or Node.js backend.
- **Database**: Cloud Firestore with user and active journey documents.
- **Workflow**: When user starts a 20-minute journey, Cloud Functions schedules a Cloud Task for `now + 20min`. If the user does not submit a "safe" token before the deadline, the Cloud Function triggers SMS dispatch automatically, even if the phone battery dies or the phone is lost.

### C. SMS & Emergency Dispatch Gateway
- **Providers**: Twilio, AWS SNS, or MSG91 (for India).
- **Architecture**: Keep API secret keys on the backend (never embed them in the mobile client). The app calls an authenticated endpoint (`POST /api/escalate`) which dispatches the SMS payload to trusted contacts.

### D. Google Maps Platform API
- **APIs**: Places API (for location autocomplete search) and Directions API.
- **Key Storage**: Store the Google Maps API key in `local.properties` (Android) and xcconfig (iOS).
