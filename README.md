# Mawar Cake House App

TMA3084 Software Engineering Laboratory, UNIMAS, Semester 1, 2026/2027.
Group G01 T03, team **Ventora**.
Client: Mawar Cake House, Aiman Mall, Kota Samarahan.

An Android app for the shop tablet and the staff and owner phones. It records cake orders, deposits and order status, keeps the menu and availability up to date, gives customers loyalty points by phone number, and drafts replies to customer questions that staff check before sending.

## Team

| Name | TSPi role | Owns | GitHub |
|---|---|---|---|
| Adam Zackery bin Mohammad | Team Leader | FR-11, FR-12, FR-AI-03 | [@AZ-Stacker](https://github.com/AZ-Stacker) |
| Mohammad Faqrullah bin Rabaee | Planning Manager and Client Liaison | FR-01, FR-03, FR-04, FR-07 | [@mohammadfaqrullah](https://github.com/mohammadfaqrullah) |
| Md Habibullah Habib | Development Manager | FR-02, FR-06, FR-08 | [@hu2602277-code](https://github.com/hu2602277-code) |
| Mohammad Zulirfan Bin Norul | Quality/Process Manager | FR-05, FR-09, FR-10 | [@TheCruelz](https://github.com/TheCruelz) |
| Muhammad Nasriq Bin Man | Support Manager (backend and AI) | FR-AI-01, FR-AI-02 | [@Boci0](https://github.com/Boci0) |

## Tech

- Flutter (Android), Riverpod for state
- Supabase: Postgres database, Auth for owner and staff login, an Edge Function that holds the AI key
- Google Gemini API, called only from the Edge Function, never from the app

## Run it

The Flutter project is not created yet. Once it is:

```bash
flutter pub get
flutter run
```

## Test it

```bash
flutter test --coverage
```

## How we work

- `main` and `develop` are protected. Work on a branch from `develop` and open a pull request.
- Each pull request needs 1 approval and a passing "Analyze, test, coverage" check. The author does not merge their own pull request.
- Branch names and commit messages: see [Git Flow and team rules](docs/GIT_FLOW.md).
- Tasks live in the repo [Issues](https://github.com/ventora-team/tma3084-ventora/issues).

## Docs

- [Git Flow and team rules](docs/GIT_FLOW.md)
- Proposal, SRS and SDD go in `docs/`

## Milestones

| Milestone | Due |
|---|---|
| M1 Proposal and pitch | 17 Oct 2026 (done) |
| M2 Requirement Specification (SRS) | Week 9, 16 to 22 Nov 2026 |
| M3 Design and implementation | Week 13, 14 to 20 Dec 2026 |
| M4 Testing, release v1.0.0 and presentation | Week 15, 28 Dec 2026 to 2 Jan 2027 |

Final submission: Saturday, 2 January 2027, 10:00 PM.
