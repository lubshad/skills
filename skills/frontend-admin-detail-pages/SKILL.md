---
name: frontend-admin-detail-pages
description: Use when designing admin detail/profile/edit pages, tabbed forms, overview rails, save/reset, or page states.
---

# Admin Detail Pages

Owns full-record task-surface UX; adapters own state/routing/API syntax and components. Open directly from list/route/profile link, not an intermediate listing overview sidebar. Fetch current full data by stable ID; row objects are only optional route hints. Metadata starts at page level in parallel; overview rail reuses loaded state, never refetches the same record.

## Header and composition

Readable record name is title; ID is default subtitle, with status/compact metadata where useful. Shared admin user/session appbar appears only on first-level destinations, **not nested detail/create/edit/profile/forms**. Use a compact local Back/Save/Reset/Edit/workflow/Refresh row, no global search/notifications/user details/marketing. Actions use the controlled draft; Save/Reset disable while saving or without editable data.

Editable form dominates. Desktop may have a secondary read-only right overview rail, not a duplicate of every field. Tablet/mobile collapse to full-width single column. Use white root/background, subtle borders, constrained widths and section spacing, not nested cards/heavy chrome.

## Tabs and saves

Coherent domain tabs (Overview/Company/Personal/Salary/Contact/Permissions) replace one mixed long form. Prefer fixed tapped controls, not swipe-only navigation; preserve unsaved values across switches. Shared-draft Save/Reset stays outside tabs.

Desktop prefers header actions; sticky bottom is for established/mobile reachability. Block duplicates. Save updates detail immediately; create/update emits one explicit in-screen toast/status before listing return, not duplicate detail/listing notices. Failure preserves draft/loaded data with product-styled recovery.

## States

Support initial loading, retryable load error, saving/save error, and plain missing-value fallbacks (`Not set`, `No email`). Keep loaded data on refresh/save failure.

Reusable shimmer mirrors final height: left tab-row plus field-section rows, optional desktop overview rail. Initial record load can shimmer both; when record exists but metadata waits, shimmer only the form because the rail can use loaded state.

## Adapters and verification

Flutter uses relevant `flutter-forms.md`, `flutter-state-management.md`, `flutter-routing.md`, `flutter-common-widgets.md`, and `flutter-linting.md`; Next.js uses relevant `nextjs-forms.md`, `nextjs-page-performance.md`, `nextjs-responsive-scaling.md`, and routing/data guidance.

## Verification

Check ID-based current load, parallel schema/reused rail, correct header ownership, draft/tab persistence, pending guards, one save outcome, recoverable states, and desktop/mobile form/rail/shimmer hierarchy.
