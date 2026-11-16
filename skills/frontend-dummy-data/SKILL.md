---
name: frontend-dummy-data
description: Use when adding or changing development-only form autofill.
---

# Development Autofill

Activate for autofill changes, not merely because a form exists. Sensitive credentials/OTP/payment forms require an explicit safe test need. Never populate real secrets or submit/trigger external actions automatically.

**One shared generator per platform.** No feature generators or inline fake values. Add uncovered primitives centrally; populate the same controlled state/controllers as manual input and respect dependency order (start date before derived end date).

| Platform | Generator | Guard | Label |
|---|---|---|---|
| Next.js | `src/lib/dev/DummyDataGenerator.ts` | `process.env.NODE_ENV === 'development'` | Fill Random Data |
| Flutter | `lib/core/utils/dummy_data_generator.dart` | `kDebugMode` | Fill Dummy Data |

Guard control **and** generator import/use so release builds expose none.

## Primitive contract

Both generators cover full/first/last names, safe test email, project-country phone, HTTPS URL, sentence/paragraph, minimal-HTML `richText`, past/future `date(opts)`, time, IANA timezone, bounded integer/decimal (optional precision), percentage (0–100), boolean, `pick(array)`, UUID where supported, placeholder `imageUrl`, valid `youtubeUrl`, and duration in minutes. Keep implementation examples in platform form/utility guidance.

## Verification

Check release exclusion, ordinary draft updates, dependent validation, and no automatic submission, secrets, or external effects.
