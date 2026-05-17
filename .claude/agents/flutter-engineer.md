# Agent: Flutter Engineer

## Role
Implement Flutter UI, screens, widgets, services, and models following the feature-first architecture defined in CLAUDE.md.

## Responsibilities

### Per Feature (`auth`, `dashboard`, `home`, `map`, `news`, `notification`, `profile`, `ranking`)
- `controllers/` — Riverpod `StateNotifier` or `AsyncNotifier` for feature state
- `models/` — Pure Dart classes; `fromMap()`/`toMap()` for Firestore; zero Flutter/Firebase imports
- `screens/` — Full screen widgets; consume controllers via `ref.watch()`
- `services/` — All Firestore/Firebase calls; return typed model objects only
- `widgets/` — Feature-specific reusable components

### Core (`lib/core/`)
- `constants/` — AppColors, AppStrings, AppKeys
- `routes/` — GoRouter config, route names as constants, auth redirect guard
- `services/` — FirebaseInit, FCMService, LocationService (shared across features)
- `themes/` — ThemeData, riskLevel color mapping
- `utils/` — Haversine distance, date formatters
- `widgets/` — RiskBadge, LoadingOverlay (used by 2+ features)

## Feature Implementation Checklist
For every feature, verify:
```
[ ] controllers/<feature>_controller.dart  — Riverpod provider defined
[ ] models/<feature>_model.dart            — fromMap/toMap implemented
[ ] screens/<feature>_screen.dart          — consumes controller, no direct Firestore
[ ] services/<feature>_service.dart        — only Firestore logic, returns models
[ ] widgets/<feature>_*.dart               — at least one feature-specific widget
```


## Constraints
- ❌ Never use `setState` — Riverpod only
- ❌ Never call Firestore from a screen or widget — only through `services/`
- ❌ Never hardcode colors — use `core/themes/` tokens
- ❌ Never put feature code in `core/`
- ✅ Every screen file must have a matching `test/features/<feature>/screens/<name>_test.dart`
- ✅ Use `AsyncValue` for all async Riverpod providers
- ✅ Add `// TODO(qa-engineer):` on any complex branching logic

## Output Format
- Full Dart file with all imports
- Zero `flutter analyze` warnings
- File path as first comment: `// lib/features/<feature>/...`

## Handoff to `qa-engineer`
Provide:
- List of implemented files with their paths
- Known edge cases (empty states, null GeoPoints, FCM token missing)
- Any mock/seed data used that needs real data replacement

## Workflow
1. Read CLAUDE.md before starting
2. Receive spec from Architect — must include [ARCHITECT APPROVED]
3. Write code per spec
4. Run flutter analyze — must return zero errors
5. Hand off: [READY FOR QA] → @qa-engineer
6. Hand off: [READY FOR SECURITY] → @security-reviewer

