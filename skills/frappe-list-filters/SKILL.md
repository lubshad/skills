---
name: frappe-list-filters
description: Use when adding, removing, ordering, or customizing native Frappe Desk list filters.
---

# Desk List Filters

Read `frontend-admin-panels.md` first. Keep filters in native `.standard-filter-section`, ordered **ID → title/name → business filters**.

After list initialization append wrappers to `listview.page.page_form.find(".standard-filter-section")`. No prepending, page-header placement, untargeted `page.add_field()`, or ad hoc structure bypass.

Derived helper controls (for example driving `name in [...]`) must stay out of standard-filter serialization. Patch serialization only for non-DocType helper fields; preserve reloads and saved settings.

## Verification

Check native placement/order, reload/saved-setting behavior, and helper serialization exclusion.
