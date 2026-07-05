---
name: frontend-admin-panels
description: Use when designing admin or back-office UI, operator workflows, density, confirmations, recovery behavior, or task surfaces.
---

Follow these admin-panel rules for all admin and back-office UI work.

## Core Principle

Admin panels are task and workflow surfaces, not marketing pages. Optimize for operators who need to scan, compare, filter, approve, edit, recover from mistakes, and repeat tasks quickly.

## Layout

- Prefer desktop-first information density: side navigation, top bar, tables/lists, filters, status chips, and batch-friendly actions.
- Keep shared top bars minimal unless the page owns the control: title and user/session context are acceptable.
- On desktop admin shells, sidebar collapse/expand controls belong inside the sidebar near bottom utility/session controls, directly before logout when logout is present.
- On narrow layouts where the sidebar becomes a drawer or hidden navigation surface, top bars may expose a menu button whose only job is opening that drawer/sidebar.
- Listing pages should fill the available shell height; top controls and pagination stay outside the row scroll area.
- Avoid extra outer padding inside navigation bodies when the listing/table surface should fill the available area.
- Provide responsive fallbacks for narrow widths without changing the primary desktop workflow.

## Listing Controls

- For admin listings, place search, filters, refresh, and Add/create actions in one aligned top control row.
- Left: search input and primary filters.
- Right: refresh and Add/create, with Add/create as the primary action when creation is allowed.
- When rows are selected, show a compact selected-count action segment alongside search/filters.

## Tables And Pagination

- Use dense, scannable table layouts with consistent column alignment, row shading, header treatment, and horizontal overflow behavior.
- Pagination must remain visible and reachable while rows scroll.
- Use compact footers with page-size controls, page navigation, and total count on desktop/table-like admin listings.
- Detailed listing mechanics live in `frontend-listing-screens.md`.

## Actions And Recovery

- Destructive or high-impact admin actions require explicit confirmation and clear record context before the request is sent.
- Keep admin workflows recoverable: clear errors, preserved user input where practical, retry actions, and no silent failures.
- Frappe Desk is acceptable for internal/back-office customization; user-facing app UI belongs in Flutter or Next.js.
