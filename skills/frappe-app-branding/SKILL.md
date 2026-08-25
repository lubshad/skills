---
name: frappe-app-branding
description: Use when adding or updating full branding for a CoreAxis Solutions Frappe app.
---

Use this skill when adding or updating full branding for a CoreAxis Solutions Frappe app.

Apply it for:
- New Frappe app branding.
- Rebranding an existing Frappe app.
- Adding or changing logo, favicon, splash, login, website, print, or email branding.

Use `apps/via_veritas/` as the reference for coverage and structure only. Do not copy app-specific names, colors, copy, or assets.

## Reading Order

- Read `frontend-admin-panels.md` first for Frappe Desk and back-office product intent.
- Read `frontend-auth-entry-ui.md` before changing login, signup, OTP, forgot-password, or account access UI.
- Read `frappe-customizations.md` for app-owned files, hooks, install/uninstall setup, declarative app documents, and migration rules.
- Read `frappe-file-images.md` when branding assets are uploaded, stored in `File`, or returned by APIs.
- Read `frappe-app-navigation.md` when branding includes `desktop_icon/` or `workspace_sidebar/`.

## Branding Checklist

Branding should be app-owned and live under `apps/<app>/<app>/`.

### Hooks

Update `<app>/<app>/hooks.py` with the brand metadata and includes needed by the app:

- `app_title = "<App Title>"`
- `app_logo_url = "/assets/<app>/images/<brand_logo_asset>"`
- `website_context = {"favicon": "...", "splash_image": "..."}`
- `app_include_css = "/assets/<app>/css/<app>.css"`
- `web_include_css = "/assets/<app>/css/<app>.css"`
- `email_css = "/assets/<app>/css/<app>_email.css"` when email branding is included
- `after_install = "<app>.setup.install.after_install"`
- `after_uninstall = "<app>.setup.install.after_uninstall"`

Keep hooks declarative. Put database writes in install/uninstall setup functions, not at import time.

### Public Assets

Place brand assets in `<app>/<app>/public/images/`.

- Include a PNG logo/favicon suitable for Frappe settings and browser favicon use.
- Include SVG only when useful; Frappe settings that expect image URLs should have a PNG fallback.
- Reference assets through `/assets/<app>/...`, not filesystem paths.

### CSS

Place global brand CSS in `<app>/<app>/public/css/<app>.css`.

- Scope overrides tightly so they do not destabilize Desk or website pages.
- Use this for splash styling and small Desk-safe global brand adjustments.
- Avoid broad resets, marketing-page styling, or unrelated component overrides.
- Frappe's Desk splash is rendered as `<div class="centered splash">`; `.centered` applies `top: 50%`, `left: 50%`, and `transform: translate(-50%, -50%)`. A full-viewport splash override must reset all three (`top: 0`, `left: 0`, and `transform: none`) as well as setting `position: fixed` and `inset: 0`. Otherwise the viewport-sized layer is shifted by half its own size and only a quadrant is visible.
- Frappe serves app public assets with a long public cache lifetime. After a Desk splash or global app CSS visual fix, add or bump a version query on `app_include_css`, clear the site cache, and confirm the Desk HTML references the new URL. Clearing the server cache alone does not invalidate an already-cached browser stylesheet.

Place email-specific CSS in `<app>/<app>/public/css/<app>_email.css` only when branded emails are required.

### Login

When branded auth is required, add:

- `<app>/<app>/www/login.py` that reuses Frappe's login context and hides default header/footer when needed.
- `<app>/<app>/www/login.html` that preserves Frappe login states and JS behavior while replacing the layout.
- `<app>/<app>/public/css/login.css` for the login-only layout.

The login page must keep user/pass login, LDAP, social login, signup-disabled, forgot-password, no-script, validation, loading, and mobile states working unless the product explicitly disables one.

Follow `frontend-auth-entry-ui.md`: desktop/tablet-wide auth screens use a left branding panel and a right focused form; narrow mobile screens collapse to a form-focused layout.

If the app brands Frappe's stock `/login` page through `web_include_css` and `web_include_js` instead of a full `www/login.*` override:

- Expect Frappe's `login.bundle.css` to load after app `web_include_css`. Use tightly scoped selectors with enough specificity for `body[data-path="login"]`, and verify the actual rendered page in a browser.
- Reset Frappe's page wrappers for full-bleed auth layouts: `main.container`, `.page-content-wrapper`, `.page_content`, and `.page_content > div` often need `width: 100vw`, `max-width: none`, `margin: 0`, and `padding: 0`.
- Reset both spelling variants used across Frappe versions and templates: `.page-content` and `.page_content`, including their direct child wrappers. Do not consider the layout full bleed until the branded root has computed `x = 0` and `width = window.innerWidth`; a centered Bootstrap `main.container` can leave dark gutters even when inner wrappers are set to `width: 100%`.
- Frappe login status banners contain child SVG or `span` nodes while visually empty. Keep `.login-error-banner` and `.login-success-banner` hidden initially and let `login.js` reveal them with inline `display` after a real response. Do not use `:not(:empty)` to control visibility because the permanent child nodes make it true before any message exists.
- Inspect the supplied logo before composing brand text beside it. If the image is a complete lockup containing its own wordmark, render the asset alone at a readable size; adding a separate product-name element duplicates the brand.
- If bundle order still wins, inject a small login-only runtime `<style>` from the app login JS after `DOMContentLoaded`, and set the wrapper inline styles directly. Keep this scoped to `body[data-path="login"]`.
- Add a cache-busting query string to login CSS/JS includes after visual changes, then run `bench --site <site> migrate` and hard-refresh the browser. Confirm the served `/login` HTML references the new query string.
- When product requirements remove "login with email link", disable it through `System Settings.login_with_email_link = 0` in an idempotent patch/install setup, and remove/hide any already-rendered email-link section in the login JS.
- Verify the opened browser tab, not only `curl`: check that the brand panel reaches the viewport edge, the form inputs/buttons are visibly styled, and removed auth options are absent from the rendered UI.
- Verify computed layout at desktop and narrow-mobile widths: the branded root begins at the viewport origin, fills the viewport width, the desktop brand panel is hidden on mobile, and no horizontal overflow is present.
- Verify auth status behavior, not only the initial screenshot: error/success banners have `display: none` and zero layout height initially, then an invalid login shows a non-empty error message without shifting or breaking the form.

### Install Setup

Create or update `<app>/<app>/setup/install.py` for persisted branding settings.

Include idempotent setup and revert functions for:

- Navbar Settings: set `app_logo`.
- Website Settings: set `favicon`, `splash_image`, `app_name`, `title_prefix`, `brand_html`, and footer branding when required.
- Website Theme: create/update a branded `Website Theme`, colors, font settings, and minimal custom overrides.
- Letter Head: create/update a default branded `Letter Head` for print documents.
- System Settings: set branded email footer address when email branding is required.

Rules:

- `after_install()` must call all setup functions and then `frappe.db.commit()`.
- `after_uninstall()` must call all revert functions and then `frappe.db.commit()`.
- Setup functions must be idempotent.
- Revert functions must only clear or delete values owned by this app. Do not erase unrelated site branding.
- Use `frappe.get_single`, `frappe.get_doc`, `frappe.new_doc`, `frappe.db.exists`, and `frappe.db.set_single_value` rather than raw SQL.

### Desk Entry Branding

If the app needs a Desk entry point or branded sidebar, use `frappe-app-navigation.md`.

- Put Desktop Icon JSON in `<app>/<app>/desktop_icon/`.
- Put Workspace Sidebar JSON in `<app>/<app>/workspace_sidebar/`.
- Use Lucide icon names.
- Bump `"modified"` on every JSON edit.
- Run `bench --site <site> migrate` in the same turn after changing these declarative JSON files.

## Verification

After implementation, verify the actual site, not just file presence:

- `/app` shows the branded Desk logo/navbar and any Desktop Icon or Workspace Sidebar changes.
- Browser favicon and splash image resolve from `/assets/<app>/...`.
- During the `/app` boot splash, verify its background covers the complete viewport and its logo is centered; this catches inherited `.centered` transforms.
- After changing app-wide CSS, confirm the `/app` HTML references the expected versioned stylesheet URL before judging the browser result.
- `/login` renders the branded layout at desktop and mobile widths and preserves login, forgot-password, signup, social/LDAP, and disabled states that are enabled on the site.
- A printable document uses the branded default Letter Head.
- Email footer/CSS is present when email branding is included.
- If declarative app documents changed, `bench --site <site> migrate` completed successfully.

## Reference Coverage

The `apps/via_veritas/` reference includes these branding surfaces:

- `hooks.py` app metadata, logo, website context, CSS includes, email CSS, install and uninstall hooks.
- `public/images/` favicon/logo assets.
- `public/css/` global, login, and email CSS.
- `www/login.py` and `www/login.html` login override.
- `setup/install.py` persisted Navbar Settings, Website Settings, Website Theme, Letter Head, and System Settings branding.
