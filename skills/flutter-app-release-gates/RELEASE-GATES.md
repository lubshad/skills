# Flutter App Release Gates

## When to Use

Integrate Android/iOS release policy published by the existing Frappe
`flutter_utils` app. Reuse its API and settings; do not create a second backend
configuration or endpoint for each client app.

Apply this skill during new Flutter mobile deployment setup as well, including
GitHub Actions builds/releases. Release gates are part of the initial client
setup for apps using Flutter Utils, not a separate optional follow-up. Inspect
and reuse existing integration when present. Pair with
`github-actions-deployment.md` and the applicable `flutter-android-release.md`
or `flutter-ios-release.md`. Deployment setup does not authorize enabling a
live forced update or changing site policy before a release is available.

Read shared UI skills first: `frontend-ui-states.md`,
`frontend-interaction-patterns.md`, `frontend-device-layout.md`, and
`frontend-api-client.md`. Then apply `flutter-networking.md`,
`flutter-state-management.md`, `flutter-dialogs.md`, `flutter-utilities.md`, and
`flutter-linting.md`. Read `project-connections.md` to identify the correct
backend/environment. Independent startup requests follow `api-parallelization.md`.

## Backend Contract

The existing guest-callable endpoint is:

```text
GET /api/method/flutter_utils.api.app_settings.get_app_config
  ?platform=android|ios
  &app_version=<installed release version>
  &app=<logical application identifier>
```

- Use the application's configured shared Dio client, including local site
  headers. Explicitly mark this request public using that client's auth mode;
  do not attach stored credentials or create a feature-local Dio instance.
- Unwrap Frappe's outer `message` object in the repository. Return a typed model
  with safe defaults for absent/null keys. Do not catch transport errors in the
  repository; handle them in the BLoC/startup boundary.
- Consume `managed`, `update_available`, `update_required`, `force_update`,
  `unavailable`, `unavailable_message`, `current_version`, `store_url`,
  `support_email`, and `support_url`. Optional metadata includes
  `minimum_version`, `release_notes_url`, and `released_on`.
- Pass `PackageInfo.fromPlatform().version`, not `buildNumber`. For
  `1.0.27+28`, send `1.0.27`, not `28`. Backend numeric version comparison ignores
  build metadata; do not replace it with client string comparison.
- Detect Android/iOS explicitly. Skip gating on web and desktop; never classify
  all non-Android platforms as iOS.
- These controls are advisory client policy, not API authorization. Existing
  endpoints remain accessible and credentials are not revoked.
- Inspect `apps/flutter_utils/docs/app-settings.md` and the current backend
  implementation before integrating; deployed schema/validation may differ.

## Application Identifier

- Define a stable app-specific identifier in shared application configuration.
  Use the same logical value for release checks and existing Flutter Utils push
  registration. Do not copy Sync's `sync_dating` identifier into another app.
- Match **Flutter Utils Settings → Application Identifier** exactly. A nonempty
  mismatched client identifier produces `managed: false` and suppresses gates.
- This value is not automatically the Android application ID/iOS bundle ID.
  Inspect the actual client configuration and deployed settings, not branding.
- Flutter Utils Settings is a site-level single document, not a multi-app release
  registry. Identifier matching prevents accidental cross-app gating; it does
  not provide independent policies for several apps on the same site.
- Do not change a shipped identifier or backend settings without authorization.

## Decision Order and Bottom Sheets

Only apply flags when `managed == true`, in this order:

| Condition | UI | Dismissal |
|---|---|---|
| `unavailable` | Maintenance message, Try again, configured support actions | Blocked |
| `update_required && force_update` | Update now, Try again, configured support actions | Blocked |
| `update_available` | Update now, Later | Allowed |
| Missing/unmanaged/no flags | Normal app | No sheet |

- Use the app's branded bottom-sheet components on both Android and iOS, not
  separate native dialogs or full-screen update pages by default.
- Optional updates allow Later, outside tap, swipe-down, Android Back, and Escape.
  Remember dismissal for the process session; it must never suppress forced
  updates or maintenance returned by a later check.
- Blocking sheets disable outside-tap, drag, Back/predictive Back, Escape, and
  underlying iOS navigation gestures. Do not offer Later or a close control.
  This deliberate blocking policy applies to managed mobile platforms, not
  ordinary dismissible desktop dialogs.
- Mount the sheet host above the entire app navigator, including pushed routes,
  dialogs, and deep links. Wrapping only `home` allows other routes to bypass it.
  Preserve navigation/form state, but hide it behind a branded launch background
  for blocking states. Block underlying pointer, keyboard, and semantics access.
- Show the startup sheet after the existing splash completes. Do not replay the
  splash or add another splash delay on resume.
- Move focus into the sheet and restore focus when it closes. Respect runtime
  safe-area insets and make long messages/actions scrollable on short screens.
- A raw Flutter `BottomSheet` with drag enabled requires an animation controller;
  test swipe dismissal, not just button dismissal. Use correct route contexts
  if using a modal-route-based implementation.

## Lifecycle and State Ownership

- Use an app-wide release BLoC, separate from auth and product feature flags:
  widget → BLoC → repository → shared client.
- Check at startup, on **every resumed transition**, and on Try again. Returning
  from the store must trigger the same recheck. Do not add continuous polling or
  backend realtime infrastructure merely for this feature.
- Keep the lifecycle listener mounted at the root across login, logout, pushed
  screens, and sheets; dispose it with the app. Use `AppLifecycleListener` or
  the project's root observer rather than route-local callbacks.
- Collapse repeated concurrent manual requests. If resume happens while an
  older lookup is running, queue one fresh foreground lookup instead of dropping
  resume. Do not let the pre-resume result temporarily clear confirmed policy.
- Bound network waiting. Initial failure/timeout must not invent a blocking
  state. On refresh failure, retain the last confirmed blocking state and show
  human-readable retry feedback; do not silently unlock it.
- A successful response updates, replaces, or removes the sheet. Prevent stale
  requests and disposed emitters from changing state after shutdown.
- Keep independent product configuration fetches parallel at startup. Existing
  product maintenance banners remain informational unless explicitly specified;
  Flutter Utils owns blocking mobile release policy.

## Store and Support Actions

- Open the configured Android Play Store or iOS App Store URL externally using
  `url_launcher`. TestFlight testing can use that app's public invitation link;
  the generic Apple TestFlight listing does not open the client's app update.
- Validate URLs and handle both thrown errors and `launchUrl == false`. Allow
  only intended schemes (normally HTTPS/HTTP, and `mailto` for email). Missing
  links must show useful feedback and leave retry/support available.
- Prevent duplicate launches while pending; do not expose raw exceptions.
- Opening a store is not updating the app. The installed version must meet the
  minimum after the user actually installs an update, or policy must be relaxed.

## Operator Configuration and Test Matrix

Enable **App Settings**, set the matching identifier, and configure Android and
iOS independently. Publish the real store release and verify access before
enabling a mandatory update for real users. Do not mutate site settings merely
to test UI without explicit authorization.

Example for installed version **1.0.27**:

| Desired state | Current Version | Minimum Version | Force Update | Unavailable |
|---|---|---|---|---|
| Normal | 1.0.27 | empty | Off | Off |
| Optional | 1.0.28 | empty | Off | Off |
| Forced | 1.0.28 | 1.0.28 | On | Off |
| Maintenance | 1.0.27 | empty | Off | On |

Minimum is inclusive: installed **equal to minimum** is allowed. With current
`1.0.31`, minimum `1.0.27`, and Force Update on, installed `1.0.27` gets an
optional sheet, not a forced sheet. Force applies strictly below minimum.

Save settings, then launch or background/foreground the app (or tap Try again).
Saving does not push to an app that remains foregrounded. Fully restart when
retesting an optional prompt already dismissed for the current session.

## Reference Implementation

See [Sync implementation reference](references/sync-implementation.md) for file
locations, integration choices, and focused tests. Adapt identifiers, client
auth modes, design tokens, and app ownership; do not blindly copy the feature.

## Verification

- Model/repository: outer envelope, absent values, identifier/platform/version
  query values, no credentials on public requests, Android/iOS detection, and
  unmanaged web/desktop behavior.
- BLoC: precedence, optional dismissal, failed initial fetch, refresh failure
  retaining a gate, timeout, successful recovery, concurrent checks, and one
  queued fresh check after resume during an in-flight lookup.
- Widgets: each sheet, Later/outside/swipe/Back dismissal for optional updates,
  blocked dismissal for forced/maintenance, invalid/failed link feedback, retry
  pending/error, narrow/landscape layouts, safe areas, and accessible focus.
- Navigation: push a route while gated, verify the sheet stays above it, and
  verify Android Back cannot pop through blocking policy.
- Lifecycle regression: background a mounted app, change mocked server policy,
  resume without rebuilding, and assert forced/maintenance sheets appear. Clear
  policy and resume again to assert recovery. Verify disposal removes callbacks.
- Run `dart format`, `flutter analyze`, and focused tests; run the app suite when
  practical. Do not build/deploy or start servers as routine lint verification.
- Report real-device/store testing separately from mocked tests. Before release,
  verify Android predictive Back, iOS gestures, store return, and a real supported
  store version on both platforms. Older builds without the integration cannot
  be made to show sheets solely by changing backend settings.
