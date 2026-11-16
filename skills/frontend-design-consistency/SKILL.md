---
name: frontend-design-consistency
description: Use when creating or visually changing frontend UI, or connecting a working prototype to real backend data without redesigning it.
---

# Design Consistency

Read before new/visual frontend work on any platform, including prototype integration without intended visual changes. Backend, transport-only, and nonvisual copy edits need no visual audit. New apps follow approved direction with reusable patterns.

## Inspect the baseline

Review theme/tokens, shared components, shell/navigation, and at least one maintained peer screen plus representative components where available. Identify composition, typography/colors, spacing/width/density, surfaces/borders/radii/shadows, icons/headers/buttons, states, supported devices/themes. Prefer repeated maintained patterns over isolated legacy UI. Use runtime/screenshots when available; distinguish source inspection from actual visual evidence. Name references in the report; clarify material conflicts instead of guessing a redesign.

## Prototype integration is not redesign

Treat the working target screen as approved baseline and primary reference—not an unrelated screen that justifies replacing it. Inspect its real components; capture before screenshots where possible or state source/screenshot-only limits.

Preserve composition/journey: shell/navigation, headers/cards/tables/form sections, wizard count/order, side rails/actions/dialogs/uploads, typography/spacing/density/colors/icons, and responsive behavior. Adapt repositories/services, view models, ID/label mapping, and local state/hooks to the presentation. Async data does not justify generic API forms, default controls, or markup/style replacement; internal refactoring must preserve output/interactions.

Local integration/usability improvements may add inline validation, states/retry/pending feedback, focus, real uploads, live searchable selection, or compact workflow actions in existing style. Approval/review uses current task surfaces/shared dialogs where practical. Material layout/component-system/navigation changes, reordered/new wizard steps, changed table/form presentation, or removed task areas need **explicit UI approval first**. Backend plans, required fields, and standardization preferences do not supply it; explain the smallest adjustment.

Retain capabilities/information areas while replacing mocks with records. Unsupported backend areas keep honest empty/unavailable/disabled presentation; explain significant gaps. No fake metrics, links, uploads, approvals, or success claims to fill space.

## Reuse, without copying defects

Use shared components/tokens, extending without unrelated consumer changes. Match behavior/composition, not theme colors alone. Avoid conflicting palettes/fonts/icon families/framework defaults/decorations/local variants. Feature presentation stays local; promote genuinely reusable patterns without feature models/fetching in shared visuals. Preserve contrast/accessibility/focus/responsiveness and fix—not reproduce—existing usability defects. Routine consistency is not an app-wide redesign mandate.

Read relevant shared behavior skills, then adapters. Layout changes add `frontend-device-layout.md`; data-state presentation adds `frontend-ui-states.md`; Flutter theme/widget mechanics use `flutter-theming.md`/`flutter-common-widgets.md`.

## Verification

Compare equivalent before/after states/viewports against the original integration screen and maintained references. Separate real-data differences from layout changes; label mocks. Review replaced markup/CSS/screens, changed steps/capabilities, and unnecessary components; every material departure needs approval. Report local intentional improvements/backend gaps. Check duplicate one-off styling, affected actions/keyboard, relevant phone/tablet/desktop widths and long content, then platform analysis/tests. State runtime/visual limits.
