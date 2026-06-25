# Food Truck Driver — Flutter App

**Package:** `com.hdrelhaj.dms`  
**Traccar:** `https://traccar.hdrelhaj.com`  
**Odoo:** `https://dms.hdrelhaj.com`

---

## Project Structure

```
lib/
├── core/
│   ├── network/        odoo_client.dart       — Odoo JSON-RPC + session
│   ├── storage/        secure_storage.dart    — Encrypted local storage
│   ├── traccar/        traccar_sender.dart    — OsmAnd HTTPS sender
│   └── location/       location_service.dart  — GPS + background service
├── features/
│   ├── auth/                                  — Login, session, auth state
│   ├── orders/                                — Delivery list, detail, status
│   └── tracking/                              — Tracking toggle, status bar
├── shared/
│   ├── theme/          app_theme.dart         — Colors, typography
│   └── utils/          constants.dart, router.dart
└── main.dart
```

---

## Setup

### 1. Flutter create
```bash
flutter create dms \
  --org com.hdrelhaj \
  --platforms android,ios
```
Copy this `lib/` folder and `pubspec.yaml` into the created project.

### 2. Install dependencies
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Configure Traccar
In `lib/shared/utils/constants.dart` confirm:
```dart
static const String traccarBaseUrl = 'https://traccar.hdrelhaj.com';
```

Ensure Nginx proxies OsmAnd protocol:
```nginx
location /osmand {
    proxy_pass http://localhost:5055;
}
```

### 4. Configure Odoo
In `constants.dart`:
```dart
static const String odooBaseUrl = 'https://dms.hdrelhaj.com';
static const String odooDb    = 'dms';   # ← update if db name differs
```

The app calls these Odoo endpoints:
- `POST /web/session/authenticate`
- `POST /web/dataset/call_kw` (model: `delivery.order`)

Your `delivery.order` model must expose these fields:
```
id, name, partner_id, partner_phone,
delivery_address, delivery_lat, delivery_lng,
state, note, scheduled_date, driver_id
```

### 5. Android — Battery Optimization
On first launch, prompt the driver to whitelist the app:
```dart
// In your onboarding flow
await openAppSettings(); // from permission_handler
```
Or direct to: Settings → Apps → Food Truck Driver → Battery → Unrestricted

---

## Build

### Debug APK
```bash
flutter build apk --debug
```

### Release APK (split by ABI — smaller files)
```bash
flutter build apk --release --split-per-abi
# Outputs:
# build/app/outputs/apk/release/app-arm64-v8a-release.apk  ← use this for modern devices
# build/app/outputs/apk/release/app-armeabi-v7a-release.apk
```

### Install on device
```bash
adb install build/app/outputs/apk/release/app-arm64-v8a-release.apk
```

---

## Traccar OsmAnd Protocol

Positions are sent as HTTPS GET:
```
GET https://traccar.hdrelhaj.com/osmand?
  id=driver_42&
  lat=24.688130&
  lon=46.722110&
  timestamp=1719100800&
  speed=45.0&
  bearing=180.0&
  altitude=620.0&
  accuracy=5.0
```

- **Port:** 443 (HTTPS, implicit)
- **Interval:** 30 seconds on route
- **Device ID format:** `driver_{odoo_user_id}`

---

## Order State Machine

```
assigned → picked_up → in_transit → delivered
                                  → failed
```

State updates are written to `delivery.order` via Odoo `write()`.

---

## Next Steps

- [ ] Offline queue (Drift SQLite) for failed pings
- [ ] FCM push notifications for new order assignment
- [ ] In-app map (flutter_map + OSM) for navigation
- [ ] Signature capture on delivery
- [ ] iOS testing + App Store build
