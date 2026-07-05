---
name: nextjs-forms
description: Use when implementing forms in the Next.js masarnext app, including form layout, validation, and server interactions.
---

Follow these Next.js implementation rules for forms in `next_apps/masarnext/`. Read `frontend-forms.md` first; it owns form UX behavior.

## Input Types & Keyboard Hints

Set the correct `type` and `inputMode` on `<input>` elements:

| Field | `type` | `inputMode` |
|-------|--------|-------------|
| Email | `email` | `email` |
| Phone / OTP | `tel` | `tel` or `numeric` for OTP |
| Decimal numeric | `text` | `decimal` |
| Integer numeric | `text` | `numeric` |
| URL | `url` | `url` |
| Search | `search` | — |
| Password | `password` | — |

Set `autoComplete` where applicable.

## State And Autofill

- Keep inputs controlled through React state or the established form state layer.
- Autofill must write into the same state as manual input.
- Follow `frontend-dummy-data.md`.
- Button label: `Fill Random Data`.
- Show only when `process.env.NODE_ENV === 'development'`.
- Import from `src/lib/dev/DummyDataGenerator.ts`.

## Custom Form Components

Use standardized components from `src/components/ui/` instead of raw HTML/native pickers where they exist.

### Search Selection

- Use `SearchSelect` for searchable selections such as nationality, sport position, roles, and Link-field style options.
- Provide clean `SearchSelectOption` data, descriptive placeholders, and search placeholders.

### Date Selection

- Use `DatePicker` for Date of Birth and profile-related dates.
- Do not use `<input type="date">` when the custom picker is available.
- Set appropriate `minYear` / `maxYear` bounds.
