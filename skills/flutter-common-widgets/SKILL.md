---
name: flutter-common-widgets
description: Use when creating or modifying Flutter shared widgets or widget file boundaries.
---

# Flutter Shared Widgets

Check existing widgets first. Cross-feature UI belongs in `lib/core/widgets/`; feature-only UI in `features/<feature>/widgets/`. One public widget per matching snake_case file.

**Values and callbacks, not feature dependencies.** Shared widgets do not import feature models, BLoCs, repositories, or API clients. Features own state, persistence, loading, selection, and side effects. Pagination emits callbacks; table headers receive labels/widths/alignment/select-all state.

## Admin presentation

- Use `AdminDynamicDetailTabBar` for `FrappeTabSchema` compact-pill tabs; the form owns `DefaultTabController`/`TabBarView`.
- Use `AdminFormSectionTitle` for accent/underline headings and optional useful subtitles. Neither widget fetches metadata or changes draft state.
- Reuse loading/empty/error/retry widgets; behavior belongs to `frontend-ui-states.md`.
- Detail shimmer: one layout-driven, theme-agnostic scaffold with tab row, field sections, and optional desktop overview rail, filling available height without feature dependencies.
- Listing shimmer matches real selection/action rails and field bars without extra outer padding. Available APIs: `AdminListingLoadingPlaceholder` (count/divider/row styling), `AdminListingShimmerRow`, and `AdminListingShimmerCell` (fixed/flex widths).

## Images and attachments

Ordinary network images use `cached_network_image`, not direct `Image.network`. Frappe/ERPNext images use one shared core widget receiving a normalized URL: on web, `Image.network` with `WebHtmlElementStrategy.fallback` handles cross-origin decoding limits; elsewhere use `CachedNetworkImage`. Expose placeholder/error builders and useful debug errors. Every network image needs fallback UI; features must not duplicate URL/fallback logic.

Frappe view/download actions use the shared opener, not direct launchers, anchors, or `window.open`. Masar Admin: `FrappeFileUrl.normalize(...)`, then `FrappeFileOpener.open(...)` from `lib/core/utils/frappe_file_opener.dart`. Features decide visibility and pass context, URL, and `attachmentName`; the opener owns auth, bytes, blobs, MIME, and error snackbars.

## Verification

Check generic boundaries, shared component reuse, image fallbacks, and authenticated file-action delegation.
