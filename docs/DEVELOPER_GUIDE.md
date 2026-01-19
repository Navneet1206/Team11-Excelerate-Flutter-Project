# SkillTrack Pro — Technical Architecture & Developer Guide

This guide provides a deep dive into the system's architecture, design tokens, and development workflows.

---

## 🏗️ System Principles
1. **The Backend is the Single Source of Truth**: No business logic, authorization, or complex data validation lives in the mobile app. The server controls the state.
2. **Stateless UI**: The Flutter application is a high-performance UI shell that consumes the JSON API. It maintains minimal local state, ensuring data consistency.
3. **Institutional Design**: Adherence to the **"Digital Scholastic"** design system is mandatory to ensure a premium educational experience.

---

## 🎨 Design System: Digital Scholastic

### UI Tokens & Styles
Controlled primarily in `frontend/lib/ui/app_theme.dart`.

- **Primary Palette**: Indigo (Main actions) & Slate (Background Surfaces).
- **Surface Radii**: Consistent use of `24px` to `32px` corner radii for containers and dialogs.
- **Shadows**: Subtle, high-elevation shadows for elevated elements (`surfaceContainerHigh`).
- **Typography**:
  - Headers: **Outfit** (Bold/ExtraBold).
  - Body: **Inter** (Regular/Medium).
  - Labels: Uppercase, spacing `1.1`, bold.

### Reusable UI Components
- `AppPopups`: Custom scholastic popups for info, errors, and confirmations.
- `StatCard`: Visual summary of metrics with iconography.
- `TaskTile`: Status-coded curriculum deliverables.

---

## 🔌 Frontend Architecture (Flutter)

### Important Directories
- `lib/app/`: Core wiring (Router, Dependency Injection, App Entry).
- `lib/config/`: Global runtime configuration (`AppConfig`).
- `lib/screens/`: Feature modules grouped by Role (Learner, Mentor, Admin).
- `lib/services/`: API Clients (`ApiClient`), storage (`TokenStore`), and authentication.
- `lib/ui/`: The design system implementation.

### API Configuration (`AppConfig`)
The API base URL is resolved via a priority logic in `lib/config/app_config.dart`.

1. **CLI Define**: `--dart-define=API_BASE_URL=...`
2. **Local Environment**: `frontend/.env`
3. **Platform Defaults**: 
   - Web: `localhost`
   - Android: `10.0.2.2` (mapped back to localhost for local testing).

### Navigation & Routing
Uses `go_router` in `lib/app/router.dart`.
- Includes role-based guardrails to prevent cross-role route access.
- Supports deep-linking and hierarchical navigation patterns.

---

## 🔙 Backend Architecture (Node.js/Express)

### Structure
- `src/routes/`: Domain-specific API handles (Learner, Admin, etc.).
- `src/middleware/`: Security, authentications (JWT Parsing), and RBAC enforcement.
- `src/db/`: Connection pooling and migration management.
- `src/utils/`: Institutional audit logging and error handling.

### Database Strategy
- **PostgreSQL**: Relational integrity with JSONB support for logs/notifications.
- **Migrations**: Found in `src/db/migrations/`.
- **RBAC**: Role-Based Access Control is enforced at the route-middleware level.

---

## 🛠️ Development Workflow

### Adding a New Capability
1. **Data Model**: Update migrations and seed scripts in the backend.
2. **Logistics**: Develop the API endpoint and register it in `app.js`.
3. **Interface**: Create the Flutter screen using `Digital Scholastic` tokens.
4. **Wiring**: Map the new route in `router.dart` and add navigation points.

### Deployment Process
1. **Verification**: Always run `flutter analyze` and `npm run lint`.
2. **Building**: Use the `--dart-define` flag to specify your production API endpoint.
3. **Extraction**: Release APKs or Web bundles are found in the `build/` directory.

---

### Security Checklist
- [ ] No local storage of passwords or sensitive metadata.
- [ ] No client-side validation "shortcuts" that bypass the backend.
- [ ] Use `TokenStore` for secure JWT persistence.
- [ ] All administrative actions must generate an `audit_log`.