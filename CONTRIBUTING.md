# Contributing (SkillTrack Pro)

This repo is a **team project**. Keep changes focused, small, and easy to review.

## Branching

Create feature branches from `develop`:

- `feature/member1-login`
- `feature/member2-home`
- `feature/member3-program-list`
- `feature/member4-program-details`

Avoid working directly on `develop`.

## Ownership (Week 2)

- Member 1: Login screen (`lib/screens/login/login_screen.dart`)
- Member 2: Home screen (`lib/screens/home/home_screen.dart`)
- Member 3: Program listing (`lib/screens/programs/program_list_screen.dart`)
- Member 4: Program details (`lib/screens/programs/program_detail_screen.dart`)

## Commit Messages

Use clear, meaningful messages:

- `chore: add base theme tokens`
- `feat(login): build login UI layout`
- `feat(programs): add paginated list UI`
- `fix(ui): align button radius with design system`

## Pull Requests

- Keep PRs small (1 screen / 1 component at a time).
- Add screenshots when UI changes.
- Follow the design system in README.

## App Rules (Non-negotiable)

- Flutter app is **UI + API consumer only**.
- No business logic / permission checks in the client.
- Pagination for list views.
- Handle network errors gracefully.
- Do not store secrets/credentials in the app.
