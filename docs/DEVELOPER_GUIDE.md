# SkillTrack Pro — Developer Guide

This guide documents the **current** repository state and the rules we will follow while building SkillTrack Pro.

## Current Repository Layout (As of today)

This repository currently contains a **single Flutter application scaffold**.

Key locations:

- `lib/main.dart` — current app entrypoint (template app)
- `test/widget_test.dart` — template widget test
- `docs/` — documentation (this file + user manual)
- `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` — platform targets

Note: Any documentation that mentions `frontend/` or `backend/` folders is **not applicable** to the current repo structure.

## Project Rules (Must Follow)

Core principles:

- The app must remain lightweight and optimized.
- The app is UI + API consumer only.
- No business logic, authorization, or permission checks in Flutter.
- Pagination must be enforced for list views.
- Handle network failures gracefully.
- Do not store secrets/credentials/private keys in the app.

## UI Design System (FINAL)

The finalized design system is defined in the root README.

Single source of truth:

- `README.md` → Colors, typography (Poppins), spacing/radius, popup rules.

Non-negotiable:

- Always use a **custom branded popup** instead of platform/default alerts.

## Local Development

From the repo root:

- `flutter pub get`
- `flutter run`

Recommended:

- Keep changes focused: UI only, no backend-style rule enforcement in the app.

## Planned App Structure (To Be Added Later)

When the actual SkillTrack Pro screens start getting built, we will introduce a clean structure under `lib/`.

Planned (not present yet):

- `lib/app/` — app wiring (routing/startup)
- `lib/screens/` — screens (Login, Home, Program Listing, Program Details)
- `lib/ui/` — reusable UI components (buttons, inputs, popups)
- `lib/services/` — API client + network helpers

Important: This is only a plan. Do not create unnecessary modules until the team starts implementing screens.

## Change Map (Current)

Right now, the only real code path is:

- `lib/main.dart` → the current UI

If you need to add something today, add it minimally and keep it consistent with README design system.

## Troubleshooting

### App won’t run

- Run `flutter doctor` and fix any missing SDK/tooling.
- Run `flutter clean` then `flutter pub get`.

### Lints / analysis issues

- Lints come from `analysis_options.yaml` which includes `flutter_lints`.
