---
name: frontend-dummy-data
description: Use when adding or changing development-only random data filling behavior for frontend forms.
---

This skill applies to development-only random data filling for frontend forms.

## Core Rule

Each platform has exactly one shared dummy data generator. Never create feature-specific generators or inline fake values in form components.

| Platform | Canonical path |
|----------|---------------|
| Next.js | `src/lib/dev/DummyDataGenerator.ts` |
| Flutter | `lib/core/utils/dummy_data_generator.dart` |

## Dev-Only Guards

| Platform | Guard |
|----------|-------|
| Next.js | `process.env.NODE_ENV === 'development'` |
| Flutter | `kDebugMode` |

The autofill control and generator import/use must be behind the platform guard so release builds do not expose the feature.

## Labels

- Next.js: `Fill Random Data`.
- Flutter: `Fill Dummy Data`.

## Behavior

- Autofill writes into the same controlled state/controllers as manual input.
- Populate dependent fields in valid order, such as setting a start date before deriving an end date.
- Add new primitives to the shared generator when a form needs an uncovered field type.

## Required Primitives

Both platform generators must cover:

| Primitive | Description |
|-----------|-------------|
| `fullName()` / name equivalent | Full name |
| `firstName()` / `lastName()` | Name parts |
| `email()` | Safe test email |
| `phone()` | Project-default country code format |
| `url()` | Valid HTTPS URL |
| `sentence()` / `paragraph()` | Text content |
| `richText()` | Minimal HTML paragraph |
| `date(opts)` | Date string with past/future support |
| `time()` | Time string |
| `timezone()` | IANA timezone |
| `int(min, max)` / integer equivalent | Integer range |
| `decimal(min, max, decimals?)` | Decimal range |
| `percentage()` | 0-100 style values |
| `boolean()` | Boolean |
| `pick(array)` | Random item |
| `uuid()` | UUID where platform supports it |
| `imageUrl()` | Placeholder image URL |
| `youtubeUrl()` | Valid YouTube URL |
| `duration()` | Duration in minutes |

Implementation examples belong in the platform-specific form or utility skill, not here.
