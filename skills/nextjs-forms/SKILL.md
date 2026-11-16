---
name: nextjs-forms
description: Use when implementing masarnext forms, validation, field controls, or submission.
---

# Next.js Forms

Read `frontend-forms.md` first. Keep inputs controlled by React/established form state; autofill writes the same state.

## Inputs

Use input `type`/`inputMode`: email → email/email; phone → tel/tel; OTP → tel/numeric; decimal → text/decimal; integer → text/numeric; URL → url/url; search → search; password → password. Set applicable `autoComplete`.

Reuse `src/components/ui/` controls: `SearchSelect` with clean `SearchSelectOption`, descriptive input/search placeholders; `DatePicker` for birth/profile dates with `minYear`/`maxYear`, not native date inputs when available.

Autofill changes follow `frontend-dummy-data.md`: label `Fill Random Data`, development-only `process.env.NODE_ENV`, shared `src/lib/dev/DummyDataGenerator.ts`.

## Verification

Check input semantics, controlled/manual/autofill parity, custom selectors/date bounds, and shared form UX.
