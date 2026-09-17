# MindGuard — Architecture & Requirements Analysis

Source of truth: the SRS document (functional requirements FR-01…FR-16) plus the
provided Figma screens. This file is the shared contract between the Flutter app,
the Node.js/Express API, the AI team, the database team and the smartwatch team.

---

## A. Feature list by responsibility

### Flutter (this repository)
- Welcome / role selection, login, registration, session persistence, logout.
- Role-based navigation: patient shell (5 tabs) and caregiver shell (3 tabs).
- Patient home: greeting, day/date/time orientation card with read-aloud, quick
  actions, today's doses preview, SOS button.
- Memory exercises screen: today's exercise entry point and AI topic list.
- Medication reminders: dose list, taken/pending state, mark-as-taken, TTS of the
  reminder sentence.
- Familiar faces: photo gallery with relation labels and spoken introductions.
- My health: watch metrics, heart-rate chart, overall status card.
- Caregiver dashboard: patient status card, headline metrics, weekly memory chart,
  alert feed, language toggle, logout.
- Caregiver medication manager: add/remove doses, review status, family voice notes.
- Caregiver reports: daily/weekly metrics and memory-score trend.
- Cross-cutting: Arabic RTL patient UI, Arabic/English caregiver UI, large accessible
  type, one loading/error/empty renderer, offline-safe error messages, mock mode.

### Node.js / Express (separate repository)
- Auth: register, login, refresh, forgot/reset password, JWT issuing.
- Role-based authorization middleware (`patient`, `caregiver`) and caregiver→patient
  link checks with primary/secondary permission levels.
- CRUD for medications, dose logs, family members, caregiver links.
- Exercise orchestration: request questions from the AI service, store results,
  compute memory score.
- Aggregation for the caregiver dashboard and daily/weekly reports.
- Alerts and notifications: missed dose, safe-zone exit, SOS fan-out.
- Ingestion endpoints for smartwatch data and serving of `/health/*` reads.
- Media handling for family photos and voice notes.
- Validation, rate limiting, audit logging.

### AI engine (not implemented here)
- Adaptive memory-exercise generation and difficulty tuning.
- Scoring of exercise answers and memory-score computation.
- Face recognition assistance for familiar faces.
- Behavioural/anomaly analysis feeding the caregiver alerts.

### Database (not implemented here)
- Users, caregiver-patient links, medications, dose logs, family members,
  exercises/results, health samples, alerts, voice notes, safe zones.

### Smartwatch (not implemented here)
- Device pairing, sensor sampling, sync to the backend ingestion endpoints.

---

## B. Screen map

**Auth**: Welcome (role choice) → Login (role-aware) → Register (role selector) →
Forgot password (placeholder).

**Patient** (`/patient/*`, Arabic RTL, large type): Home, Exercises, Medications,
Family, Health.

**Caregiver** (`/caregiver/*`, Arabic or English): Dashboard, Medication manager,
Reports. Tracking/geofencing, notifications and family management are planned next.

---

## C. Backend API map

Envelope: success `{ success: true, message, data }`, failure
`{ success: false, message, errors }`. Auth via `Authorization: Bearer <jwt>`.

| Endpoint | Method | Request | Response `data` | Auth | Role |
|---|---|---|---|---|---|
| `/api/auth/register` | POST | fullName, email, password, role | token, user | no | – |
| `/api/auth/login` | POST | email, password | token, user | no | – |
| `/api/auth/forgot-password` | POST | email | – | no | – |
| `/api/medications` | GET | `?patientId` | Medication[] | yes | patient (own), caregiver (linked) |
| `/api/medications` | POST | name, time, voiceMessage | Medication | yes | caregiver |
| `/api/medications/:id` | PUT | status \| fields | Medication | yes | patient (status), caregiver |
| `/api/medications/:id` | DELETE | – | – | yes | caregiver (primary) |
| `/api/family` | GET | `?patientId` | FamilyMember[] | yes | patient, caregiver |
| `/api/family` | POST | name, relation, photoUrl | FamilyMember | yes | caregiver |
| `/api/exercises/today` | GET | – | ExerciseTopic[] | yes | patient |
| `/api/exercises/results` | POST | topicId, answers | score | yes | patient |
| `/api/health/latest` | GET | `?patientId` | HealthSnapshot | yes | patient, caregiver |
| `/api/caregiver/dashboard` | GET | `?patientId` | CaregiverDashboard | yes | caregiver |
| `/api/reports` | GET | `?range=daily\|weekly` | ProgressReport | yes | caregiver |
| `/api/voice-notes` | GET/POST | audio/text | VoiceNote[] | yes | caregiver, family |
| `/api/alerts/sos` | POST | location | – | yes | patient |

---

## D. Flutter architecture

```
lib/
  main.dart                  app entry, locale, theme, router
  app/router.dart            every route path in one place + auth redirect
  core/
    theme/                   colours and Material 3 theme (no colour literals in widgets)
    localization/            all user-facing strings, AR/EN, patient RTL wrapper
    network/                 api_config, api_client (envelope + bearer), api_result
    storage/                 token/role persistence
    services/                text-to-speech
    widgets/                 GradientHeader, MgCard, SoftIcon, StatusChip,
                             SpeakButton, AsyncStateView
  features/<feature>/
    data/                    models + repository interface + API and Mock impls
    state/                   Riverpod providers / notifiers
    presentation/            screens and private widgets
```

Rules: screens never call HTTP directly; every screen renders through
`AsyncStateView`; a feature is added by creating `data/ state/ presentation/` and one
route line. `ApiConfig.useMockData` switches the whole app between mock and live API.

Run locally: `cd mindguard_app && flutter pub get && flutter run`.
Point at a real API with
`flutter run --dart-define=USE_MOCK_DATA=false --dart-define=API_BASE_URL=http://10.0.2.2:4000/api`.

---

## E. Development phases

1. Foundation — theme, localization, networking, storage, shared widgets. *(done)*
2. Auth slice — welcome/login/register, token persistence, role routing. *(done)*
3. Patient slice — home, exercises, medications, family, health. *(done)*
4. Caregiver slice — dashboard, medication manager, reports. *(done)*
5. Express API — same contracts, JWT + role middleware, replacing mocks.
6. Tracking & safety — map, safe zones, SOS delivery, push notifications.
7. AI integration — real exercise generation and scoring.
8. Smartwatch ingestion — live health data.
9. Hardening — tests, secure token storage, accessibility audit, release build.

---

## F. Missing or contradictory information

- No password rules, session lifetime, or refresh-token strategy in the SRS.
- Caregiver↔patient linking flow (invite code? caregiver creates the patient?) is not
  specified, yet primary/secondary permissions are required by FR-06.
- Multiple patients per caregiver is implied by the data model but every screen in the
  Figma shows exactly one patient.
- Safe-zone definition (radius, who edits it) and the escalation path for SOS are undefined.
- Exercise scoring scale and how the "memory score" percentage is derived are not stated.
- Voice notes: recording is shown in the designs but no storage format, size limit, or
  retention rule is given.
- The SRS mentions offline use; the designs assume live data. Current app degrades to a
  retryable error state instead.
- Language: the SRS asks for Arabic/English throughout, the designs are Arabic only;
  patient UI is locked to Arabic here by accessibility choice.
- No specified data-retention or medical-privacy policy despite health data being stored.
