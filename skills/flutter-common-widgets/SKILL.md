---
name: flutter-common-widgets
description: Use when creating or modifying Flutter shared widgets, core widgets, reusable components, or widget file boundaries.
---

Follow these Flutter shared-widget rules strictly.

## Shared Widgets

- Check `lib/core/widgets/` before building a reusable widget.
- Use existing shared widgets instead of one-off alternatives.
- Put cross-feature widgets in `lib/core/widgets/`.
- Put feature-only reusable widgets in `features/<feature>/widgets/`.
- One public widget per file, with snake_case filename matching the class.
- For Flutter admin detail forms, use `AdminDynamicDetailTabBar` for metadata-backed `FrappeTabSchema` tabs instead of local `TabBar` styling.
- For Flutter admin form sections, use `AdminFormSectionTitle` instead of feature-local section title widgets.

## Generic Boundaries

- Shared widgets must not depend on feature-specific models, BLoCs, repositories, or API clients.
- Shared widgets receive values and callbacks; feature screens own state, persistence, side effects, and data loading.
- Shared pagination widgets render controls and emit callbacks; BLoC/repository/helper code loads and saves page-size preferences.
- Shared table header widgets render labels, widths, alignment, and optional select-all controls; feature screens own row data and selection state.

## UI State Widgets

- Use shared loading, empty, error, and retry widgets for repeated states.
- `frontend-ui-states.md` owns the product behavior for these states; this file owns Flutter widget placement and reuse boundaries.
- For admin detail pages with form tabs, prefer one shared placeholder widget (for example `AdminDetailLoadingPlaceholder`) that renders:
  - a tab row shimmer area,
  - reusable form field shimmer sections,
  - optional right-side overview shimmer rail.
- Keep placeholder widgets theme-agnostic and layout-driven: they should stretch/fill available height and avoid feature-level dependencies.

## Images

- Use `cached_network_image` for ordinary network images, not `Image.network` directly.
- For Frappe/ERPNext file and image fields in Flutter web/custom frontends, use a shared core image widget instead of direct `CachedNetworkImage` in feature widgets.
- The shared Frappe image widget should:
  - receive an already-normalized URL from the app's shared file URL helper
  - use `Image.network` with `webHtmlElementStrategy: WebHtmlElementStrategy.fallback` on web so browser-renderable Frappe images still display when Flutter byte decoding is blocked by cross-origin behavior
  - use `CachedNetworkImage` on non-web platforms
  - expose placeholder and error builders, and log useful debug errors while preserving the normal fallback UI
- Do not rebuild Frappe file URL or web image fallback logic inside individual employee/profile/list/detail widgets.
- Provide placeholder and error widgets for every network/Frappe file image.

## Frappe File Actions

- For buttons or links that view/download Frappe attachments, use the shared file-opening utility instead of feature-local launch logic.
- In Masar Admin, use `FrappeFileOpener.open(...)` from `lib/core/utils/frappe_file_opener.dart` after URL normalization with `FrappeFileUrl.normalize(...)`.
- Do not call `launchUrlString`, `launchUrl`, raw anchors, or `window.open` directly for Frappe private file URLs in detail/listing/linked-document widgets.
- Keep feature widgets responsible only for deciding whether an attachment action is visible and passing `context`, normalized URL, and `attachmentName`; the shared opener owns authentication, byte fetching, blob creation, MIME detection, and error snackbars.

## Listing Shimmer Placeholders

- For table/list loading states, use shared shimmer row skeletons that match the actual row structure (selection/action regions + field bars), and avoid extra outer container padding in the shared component.
- Reusable API currently available in core widgets:
  - `AdminListingLoadingPlaceholder` (list-level shell + item count + divider and row styling options).
  - `AdminListingShimmerRow` (single reusable row).
  - `AdminListingShimmerCell` (fixed-width or flex-width cell definition for row composition).

## Admin Form Widgets

- `AdminDynamicDetailTabBar` renders scrollable metadata-backed detail tabs as branded compact pills. Keep `DefaultTabController` and `TabBarView` ownership in the screen/form surface.
- `AdminFormSectionTitle` renders section headings with the shared accent marker, underline, and optional subtitle treatment.
- These widgets are presentation-only. They must receive schema/text values and must not fetch metadata, mutate form state, or depend on feature BLoCs/repositories.
