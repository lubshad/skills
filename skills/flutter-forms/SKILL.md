---
name: flutter-forms
description: Use when implementing Flutter forms, field controls, validation, selection dialogs, or save feedback.
---

# Flutter Forms

Read `frontend-forms.md` first for UX. Use sections, readable widths, scrollable bodies, and reachable submission; complex mobile forms use fullscreen/safe-area sheets with sticky actions, wide forms readable 2–3 columns. Save belongs in the local detail header/action row, not a nested shared admin user/session appbar.

## Dynamic forms

Create metadata futures in the parent detail `State.initState()`, parallel with record BLoC loading. Pass the shared future to the form; parent replaces it on retry. Use `AdminDynamicDetailTabBar` for `FrappeTabSchema` inside `DefaultTabController`, and `AdminFormSectionTitle` with useful subtitles only.

## Selection

Keep picker labels separate from IDs; resolve initial/external changes with stale-value/disposal guards. Prefer explicit label, then readable search description/title if Frappe returns `label == value`, then ID only when unavailable. Submit IDs, never titles; update the ordinary draft/controllers.

Static newline-metadata Frappe `Select` uses `DropdownButtonFormField`/native inline dropdown. Remote/dynamic/searchable/non-static options use a mobile selection screen returning the value, or desktop search dialog/overlay.

Desktop: Space/Enter opens; arrows navigate and scroll highlighted rows into view (keys/measured bounds for variable heights). Enter selects the highlighted row, otherwise searches. Mark selection inside results, not separate callouts. Debounce typing about 300ms. Build link `or_filters` from confirmed requested/searchable fields: `name`, and `title`/`id` only if metadata/requested fields confirm existence.

## Inputs and styling

Set `keyboardType`: email → `emailAddress`, phone → `phone`, decimals → `numberWithOptions(decimal: true)`, integers → `number`, URL → `url`, multiline → `multiline` with `maxLines > 1`, search → `text` with `TextInputAction.search`. Use needed `inputFormatters` and `autofillHints`.

Keep iOS/Android keyboards dismissible, including numeric/phone. Single-line fields without a next target use `TextInputAction.done`; use native solutions, not custom Done toolbars or `keyboard_actions`.

Use `InputDecorationTheme` and shared label/error/disabled tokens: subtle fill against white canvas and darker outline borders, not per-field overrides.

## Autofill and save

For autofill changes follow `frontend-dummy-data.md`: `Fill Dummy Data`, `kDebugMode`, shared `lib/core/utils/dummy_data_generator.dart`, no feature generators.

For feedback read `flutter-theming.md`; use shared toasts, not snackbar/ScaffoldMessenger messages. Screen-level distinct create/update states emit exactly one correctly typed outcome, not duplicate listing/detail feedback. Preserve inline field errors.

## Verification

Search changed form files for snackbar calls. Verify one toast per outcome with field errors preserved. Run `dart format` and targeted analysis.
