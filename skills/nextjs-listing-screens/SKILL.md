---
name: nextjs-listing-screens
description: Use when implementing Next.js collection pages, loading/search/filter/sort APIs, or live listing integration.
---

# Next.js Listings

Read `frontend-listing-screens.md` first. Applies to public/authenticated collections and static-to-live integration in MasarNext.

## Fetch and append

Initial render fetches one page using explicit limit/offset or page/page_size. Public pages default to visible Load more unless page-number navigation is requested. Preserve query/filter/sort and scroll while appending; reset page/results on query or category changes. Disable pending requests, avoid duplicates, hide at end, and preserve existing rows with retry on later-page failure.

Follow `nextjs-page-performance.md`: SSR waits only for first-paint data. Row/card detail navigation uses established route segments/search params and loads full detail on demand without replacing the admin shell.

## API contract

Bound default/max page sizes server-side; return only row/card fields plus `has_more`, `next_offset`, or total. If counting is costly, request one extra row for `has_more`. Detail endpoints may return full records; listing APIs do not absorb invisible detail fields.

## Verification

Check first-page-only load, duplicate-free append, pending/end button states, first-page query resets, retained rows on error, and shell-preserving detail navigation.
