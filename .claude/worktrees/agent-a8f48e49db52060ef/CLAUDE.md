# CLAUDE.md — Dengue Risk Alert App (CSC291-AEDESALERT)

## Project Overview

Flutter + Firebase mobile app for dengue fever (Aedes) risk monitoring and alerting.
Users receive push notifications when near high-risk areas, find nearby hospitals, and read prevention articles.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter (Dart) |
| Database | Firebase Firestore |
| Auth | Firebase Auth |
| Push | Firebase Cloud Messaging (FCM) |
| Location | GeoPoint + flutter_geolocator |
| State | Riverpod (controllers per feature) |
| Routing | GoRouter (`lib/core/routes/`) |
| CI/CD | GitHub Actions (`.github/workflows/ci.yml`) |

---

## Folder Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── seed_data.dart
│
├── core/                         # Shared across all features
│   ├── constants/                # App-wide constants (colors, strings, keys)
│   ├── routes/                   # GoRouter route definitions & auth guards
│   ├── services/                 # Global services (Firebase init, FCM setup)
│   ├── themes/                   # ThemeData, text styles, color scheme
│   ├── utils/                    # Helper functions (distance calc, formatters)
│   └── widgets/                  # Shared reusable widgets (RiskBadge, etc.)
│
└── features/                     # Feature-first architecture
    ├── auth/
    │   ├── controllers/          # Riverpod controllers (auth state, login logic)
    │   ├── models/               # AuthUser model, form state models
    │   ├── screens/              # LoginScreen, RegisterScreen, SplashScreen
    │   ├── services/             # FirebaseAuth calls, token refresh
    │   └── widgets/              # AuthTextField, PasswordField, LoginButton
    │
    ├── dashboard/
    │   ├── controllers/          # DashboardController (summary stats)
    │   ├── models/               # DashboardSummary model
    │   ├── screens/              # DashboardScreen
    │   ├── services/             # Fetch aggregated area stats
    │   └── widgets/              # StatCard, RiskOverviewChart
    │
    ├── home/
    │   ├── controllers/          # HomeController (nearby zones, user location)
    │   ├── models/               # HomeState model
    │   ├── screens/              # HomeScreen
    │   ├── services/             # Location polling, nearby area query
    │   └── widgets/              # RiskZoneCard, AlertBanner
    │
    ├── map/
    │   ├── controllers/          # MapController (markers, zoom, selected area)
    │   ├── models/               # MapMarker model
    │   ├── screens/              # MapScreen
    │   ├── services/             # GeoPoint query, radius overlay logic
    │   └── widgets/              # RiskCircleOverlay, HospitalMarker
    │
    ├── news/
    │   ├── controllers/          # NewsController (article list, pagination)
    │   ├── models/               # ArticleModel (maps to `information` collection)
    │   ├── screens/              # NewsListScreen, NewsDetailScreen
    │   ├── services/             # Firestore `information` collection reads
    │   └── widgets/              # ArticleCard, ArticleHeader
    │
    ├── notification/
    │   ├── controllers/          # NotificationController (read/unread state)
    │   ├── models/               # NotificationModel (maps to `notifications`)
    │   ├── screens/              # NotificationListScreen
    │   ├── services/             # FCM handler, notification log reads
    │   └── widgets/              # NotificationTile, UnreadBadge
    │
    ├── profile/
    │   ├── controllers/          # ProfileController (edit, save user data)
    │   ├── models/               # UserProfileModel (maps to `users` collection)
    │   ├── screens/              # ProfileScreen, EditProfileScreen
    │   ├── services/             # Firestore `users` collection read/write
    │   └── widgets/              # ProfileAvatar, ToggleNotificationSwitch
    │
    └── ranking/
        ├── controllers/          # RankingController (sort areas by riskScore)
        ├── models/               # RankingAreaModel
        ├── screens/              # RankingScreen
        ├── services/             # Query `areas` ordered by riskScore desc
        └── widgets/              # RankingCard, RiskLevelChip
```

---

## Firestore Collections (5 total)

### 1. `users`
| Field | Type | Description |
|---|---|---|
| `firstName` | String | User's first name |
| `lastName` | String | User's last name |
| `email` | String | Login email |
| `phoneNumber` | String | Phone number |
| `fcmToken` | String | FCM push token |
| `notificationsEnabled` | Boolean | Notification toggle |

### 2. `areas`
| Field | Type | Description |
|---|---|---|
| `subDistrict` | String | Tambon |
| `district` | String | Amphoe |
| `province` | String | Changwat |
| `location` | GeoPoint | Center lat/lng |
| `radius` | Number | Risk radius (meters) |
| `riskScore` | Double | Computed score 0–100 |
| `riskLevel` | String | `low` / `medium` / `high` / `critical` |
| `reportedAt` | Timestamp | First reported date |
| `updatedAt` | Timestamp | Last updated date |

### 3. `places`
| Field | Type | Description |
|---|---|---|
| `name` | String | Facility name |
| `description` | String | Details |
| `location` | GeoPoint | lat/lng |
| `phoneNumber` | String | Contact number |
| `type` | String | `hospital` / `clinic` |

### 4. `information`
| Field | Type | Description |
|---|---|---|
| `title` | String | Article title |
| `content` | String | Body text |
| `imageHeader` | String | Header image URL |
| `source` | String | Attribution |

### 5. `notifications`
| Field | Type | Description |
|---|---|---|
| `title` | String | Notification title |
| `body` | String | Body text |
| `relatedZone` | Reference | Reference to `areas` doc |
| `sentAt` | Timestamp | Time sent |

---

## Feature → Firestore Collection Mapping

| Feature | Primary Collection | Secondary |
|---|---|---|
| `auth` | `users` | — |
| `dashboard` | `areas` | — |
| `home` | `areas` | `places` |
| `map` | `areas` | `places` |
| `news` | `information` | — |
| `notification` | `notifications` | `areas` |
| `profile` | `users` | — |
| `ranking` | `areas` | — |

---

## Coding Rules (All Agents Must Follow)

- ❌ Never use `setState` — use Riverpod controllers only
- ❌ Never call Firestore directly from a screen or widget — always go through `services/`
- ❌ Never hardcode colors — use `core/themes/` tokens
- ✅ Each feature is self-contained: controllers, models, screens, services, widgets stay inside its folder
- ✅ Shared logic only goes in `core/`
- ✅ Risk level colors: `low`→green, `medium`→yellow, `high`→orange, `critical`→red
- ✅ Every screen must have a `_test.dart` counterpart

---

## Firestore Security Rules

### Development (open — never deploy to production)
```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### Production
```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /areas/{areaId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    match /places/{placeId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    match /information/{infoId} {
      allow read: if true;
      allow write: if false;
    }
    match /notifications/{notifId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

---

## Environment & Secrets

- `firebase_options.dart` — generated by FlutterFire CLI, never commit
- `google-services.json` — Android Firebase config, never commit
- `GoogleService-Info.plist` — iOS Firebase config, never commit
- All CI secrets stored in GitHub Actions Secrets
- Agent config in `.claude/agents/`, CI pipeline in `.github/workflows/ci.yml`
