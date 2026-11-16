---
name: frontend-forms
description: Use when designing or reviewing form UX, form button styling, validation, field behavior, selection components, save states, or dummy-data linkage.
---

# Forms

Shared UX for create/edit, onboarding, profile, persisted-filter forms, and reusable form controls. Platform adapters own syntax.

Exclude copy-only changes, one-click confirmations, stateless search boxes, and display-only pages. For compact inline controls, apply only relevant validation and input rules.

## Read by branch

- Visual changes: `frontend-design-consistency.md` first.
- Remote loading or save failures: `frontend-ui-states.md`.
- Destructive or modal flows: `frontend-interaction-patterns.md`.
- Implementation: `flutter-forms.md` or `nextjs-forms.md`.
- Autofill changes: `frontend-dummy-data.md`.

## Layout and actions

Group related fields; keep submission within easy reach. Complex mobile forms use fullscreen flows or sheets with sticky headers and bottom actions. Wide desktop/tablet forms use readable 2–3 column layouts where space permits. Reuse product-standard dialogs.

**Match the surrounding UI.** Reuse shared buttons, variants, and tokens; extend them instead of adding local overrides. Match adjacent controls' height, typography, spacing, borders, radii, and icons. Prefer compact secondary actions with neutral borders where consistent; preserve primary/destructive hierarchy and colors.

Desktop admin starting points: 32px form buttons, 28px row actions, 12px text, 14px icons, tight horizontal padding. Existing density and readable labels take precedence. Preserve focus, accessible names, disabled/pending states, and larger touch targets.

Limit visual changes to requested controls. Broader restyling, layout, field, or navigation changes need explicit approval; copy-only/nonvisual work grants none.

## Selection

**Titles for people, IDs for payloads.** Show readable linked-record titles in results and selected fields. Preserve selected titles and resolve saved/prefilled ones; retain canonical IDs in draft/submission values. IDs may disambiguate duplicate titles. Use a safe fallback only when no permitted title exists.

Use native searchable selectors/pickers/dialogs for remote, dynamic, searchable, or >5-item lists, not simple dropdowns or custom inline substitutes. For searchable/link dialogs, read [selector behavior](references/selectors.md).

## Validation and input

Validate required fields before submission. Show field-level errors on blur or submit, whichever comes first; a toast/banner alone is insufficient. Block duplicate submissions while saving.

- Email: require `user@domain.tld` form.
- Phone: validate length/format for the selected country.
- URL: require HTTP(S) and a valid host unless the documented contract permits internal hosts, localhost, or other schemes.
- Numbers: reject non-numeric input; enforce applicable bounds.
- Dates: reject future birth dates. Reject past expiry dates for new active credentials by default; permit historical expiry in explicitly supported edit/import workflows.

Match keyboards to email, phone/OTP (telephone/numeric), decimal, integer (numeric), URL, multiline, and search inputs. Obscure passwords. Set supported autocomplete/autofill hints; adapters own syntax.

## Save and development autofill

On success, update the parent list/detail immediately, without manual refresh or a navigation round-trip.

Default to dev-only autofill for non-trivial entry forms using the shared platform generator and the same controlled state as manual input. Copy-only edits do not trigger it. Credentials, OTP, payment, and sensitive forms require an explicit safe testing requirement.

## Verification

- Compare changed buttons in the full form with adjacent controls and a maintained peer screen: labels, icons, alignment, hierarchy, focus, and touch usability at relevant widths.
- Check required/format validation, contract-specific exceptions, keyboard-only submission, and field-attached server errors where possible.
- Check duplicate-save prevention, one clear success/failure outcome, and immediate parent refresh.
- Check desktop and supported mobile widths, including an open keyboard. Report checks run and unverified interactions.
