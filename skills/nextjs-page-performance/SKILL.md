---
name: nextjs-page-performance
description: Use when editing Next.js page.tsx, SSR loading, or route transitions in masarnext.
---

# Next.js First Paint

**SSR waits only for first-paint data.** For each load ask, “Is it on screen in the first second?” Server-fetch yes; client-fetch later-step wizard, unopened-modal, or post-auth/OTP options after the page is interactive. Even parallel server lookups hold the page for the slowest request.

Apply to every edited `src/app/**/page.tsx`, slow navigation, and server-page lookup `Promise.all`. Listings also read `nextjs-listing-screens.md`.

## Pattern

Return the client form from the page immediately. Fetch its options in `useEffect`; render usable fields while only dependent sections wait. Bundle related lookups behind one `/api/<page>-options` route using `Promise.all`; existing `data/`/feature-server helpers remain reusable. Avoid per-lookup browser routes, large lookup props passed through layers, or full-page option spinners.

Listings fetch one page, then Load more—not all records on SSR or first client load.

## Verification

Confirm HTML/first interactive input precedes lookup resolution; throttle network and check navigation responsiveness. Downstream controls must handle initial empty arrays/empty selections and populate when results arrive.
