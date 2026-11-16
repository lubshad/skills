---
name: frappe-app-branding
description: Use when branding CoreAxis Frappe apps across Desk, login, website, splash, print, or email.
---

# Frappe App Branding

App owns assets/hooks/setup under `apps/<app>/<app>/`. `apps/via_veritas/` is a coverage/structure reference, not a source of another product's names/colors/assets.

Before a branding pass, read [the surface and implementation checklist](BRANDING.md). It owns exact hooks, setup/revert fields, login variants, CSS ordering/cache invalidation, splash geometry, and live checks.

## Boundaries

- Read shared admin/auth UX before those changes, then `frappe-customizations.md`. File APIs need `frappe-file-images.md`; icons/sidebars need `frappe-app-navigation.md`.
- Declarative hooks contain no import-time writes. Idempotent install/uninstall setup commits changes and reverts only this app's owned values, not unrelated site branding.
- Scope CSS; preserve supported auth states/integrations. Full-bleed splash resets inherited centering, and login overrides account for wrapper geometry, bundle order, and initially empty banners.
- Version changed stylesheet/script URLs and verify served HTML. Cache clearing alone does not invalidate browser assets.
- Navigation JSON changes bump modified and require same-turn site migration.

## Verification

Follow the detailed browser/layout/auth checks, not file presence alone: Desk, splash, login desktop/mobile/status behavior, assets, print Letter Head, and scoped email branding. Report unavailable runtime checks honestly.
