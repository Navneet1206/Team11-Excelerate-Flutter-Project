# SkillTrack Pro (Flutter)

Mobile app UI for SkillTrack Pro.

Important: This repo currently contains the Flutter scaffold and documentation. The full app screens/modules will be added later, but the **design system and UI rules below are FINAL** and must be followed by everyone so the app looks consistent.

## Design System (FINAL)

### 1) Color System

| Purpose | Color Name | Hex |
| --- | --- | --- |
| Primary Brand | Deep Indigo | `#2D2F92` |
| Accent / CTA | Sky Blue | `#4F9DFF` |
| Background | Soft White | `#F7F9FC` |
| Card / Surface | Pure White | `#FFFFFF` |
| Title Text | Charcoal Black | `#1F2933` |
| Body Text | Cool Grey | `#6B7280` |
| Border / Divider | Light Grey | `#E5E7EB` |
| Success | Emerald Green | `#22C55E` |
| Error | Soft Red | `#EF4444` |

Rules:
- Use Background = Soft White for screens.
- Use Card/Surface = Pure White for cards, sheets, inputs.
- Use Accent/CTA = Sky Blue for primary actions.

### 2) Typography (Font System)

Font family everywhere: **Poppins** (Android + iOS)

| Use Case | Size | Weight |
| --- | --- | --- |
| App Title | 24px | Bold |
| Screen Heading | 20px | SemiBold |
| Card Title | 16px | Medium |
| Body Text | 14px | Regular |
| Button Text | 15px | Medium |

### 3) Spacing & Shape Rules

- Screen padding: `16` on all sides
- Vertical gaps between sections: `12–16`
- Cards: border radius `16`
- Buttons: height `48` (full width for primary CTA where possible)
- Shadows: soft only (no dark/heavy shadows)

### 4) Popups (Project Rule)

- **Never use** `showDialog` with a plain `AlertDialog` as the final UI.
- Always implement a **custom, branded app popup** (consistent colors, radius=16, typography above).

## Screens (UI Behavior Spec)

These 4 screens will be built later. Everyone must follow the same UI rules.

### Login Screen

- Background: `#F7F9FC`
- Top: logo/title centered
- Input fields: white card style
- Login button: Sky Blue `#4F9DFF`, full width
- Text field border: Light Grey `#E5E7EB`

### Home Screen

- Header bar: white background
- Greeting text: Charcoal Black `#1F2933`
- Main CTA button: Sky Blue `#4F9DFF`
- Cards: white surface with soft shadow

### Program Listing Screen

- Layout: vertical list of cards
- Each card:
	- Background: `#FFFFFF`
	- Radius: `16`
	- Title: `#1F2933`
	- Subtitle: `#6B7280`
	- Arrow icon: `#4F9DFF`

### Program Details Screen

- Top section: program image/title
- Buttons:
	- Enroll: Sky Blue fill
	- Back: border-only (no fill)

## Team Work Distribution

| Member | Screen Responsibility |
| --- | --- |
| Member 1 | Login Screen |
| Member 2 | Home Screen |
| Member 3 | Program Listing |
| Member 4 | Program Details |

Non-negotiable: Same colors, fonts, spacing across all screens.

## Screenshots Rule (README)

When adding screenshots later, keep this exact order:

1. Login Screen
2. Home Screen
3. Program Listing
4. Program Details

## App Architecture Rules (Must Follow)

To keep the app lightweight and correct:

- The mobile app is **UI + API consumer only** (no business logic / authorization decisions in Flutter).
- Backend is the single source of truth (all permission checks on backend).
- Features must load **lazily** (on-demand) and not on app startup.
- Minimize API calls; never call multiple APIs unnecessarily.
- Pagination is mandatory for any list view.
- Handle network failures gracefully (user-friendly errors + retry when useful).
- Do not store secrets/credentials/private keys in the app.

## Local Dev

Prereq: Flutter SDK installed.

Commands:

- `flutter pub get`
- `flutter run -d chrome`

Notes:

- If `flutter run -d windows` fails with a Visual Studio toolchain error, use Chrome/Web for the prototype.

## Current Prototype Structure (for team contribution)

Entry:

- `lib/main.dart` → starts the app

App wiring:

- `lib/app/app.dart` → MaterialApp + routes
- `lib/app/routes.dart` → route constants

Screens (Week 2):

- `lib/screens/login/login_screen.dart`
- `lib/screens/home/home_screen.dart`
- `lib/screens/programs/program_list_screen.dart`
- `lib/screens/programs/program_detail_screen.dart`

Design system tokens:

- `lib/theme/app_colors.dart`
- `lib/theme/app_theme.dart`

Reusable UI:

- `lib/ui/app_buttons.dart`
- `lib/ui/app_card.dart`
- `lib/ui/app_popup.dart`

## Contributing

Team workflow and PR checklist:

- See `CONTRIBUTING.md`
- PR template is in `.github/pull_request_template.md`

## Next Implementation Checklist (For Later)

This section is a checklist of what will be added when development starts (no code generated yet):

- Add Poppins font setup
- Create theme tokens (colors/typography/radius/spacing)
- Build custom popup component (replaces default alerts)
- Implement screens: Login → Home → Program Listing → Program Details
- Add API client layer (base URL config + error handling)
- Add pagination for program listing

## Screenshots (Add before final submission)

Add screenshots in this exact order (as required):

1. Login Screen
2. Home Screen
3. Program Listing
4. Program Details

Save images under `docs/screenshots/` and link them here:

| Screen | Screenshot |
| --- | --- |
| Login | `docs/screenshots/01-login.png` |
| Home | `docs/screenshots/02-home.png` |
| Program Listing | `docs/screenshots/03-program-list.png` |
| Program Details | `docs/screenshots/04-program-details.png` |

## Docs

- Developer guide: `docs/DEVELOPER_GUIDE.md`
- User manual: `docs/USER_MANUAL.md`
