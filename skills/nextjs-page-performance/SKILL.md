---
name: nextjs-page-performance
description: Use when editing Next.js page.tsx files, route transitions, SSR data loading, or slow navigation in masarnext.
---

Follow these rules to keep Next.js route transitions fast in `next_apps/masarnext/`.

## Core Rule

**Never block a page's server render on data that isn't required for the first paint.**

A server component that `await`s 4 lookup fetches before returning JSX forces the user to wait for the slowest one — on every navigation. If the data is only needed for a later step (registration wizard, modal, dropdown populated after user action), fetch it on the client after the page is already interactive.

## When To Apply

- Adding or modifying any page in `src/app/**/page.tsx`.
- Adding or modifying any listing/index page such as coaches, athletes, clubs, academies, events, or programs. Also read `nextjs-listing-screens.md`.
- Reviewing a route that feels slow to open from a nav link.
- Any `Promise.all([...])` at the top of a server component fetching lookup/reference data.

## Decision Rule

For each piece of data a page needs, ask: **"Is this on the screen within the first second of landing on this route?"**

- **Yes → server-fetch it.** SSR with the data inlined is fine.
- **No → client-fetch it.** Render the page immediately, load the rest in a `useEffect` in the client component that actually uses it.

Examples of data that almost always belongs on the client:
- Options for a multi-step wizard (only step 3 needs them).
- Dropdown choices behind a modal the user may never open.
- Anything gated behind auth/OTP the user hasn't completed yet.

## Pattern

**Bad** — blocks the whole page on 4 round-trips:

```tsx
// app/(auth)/login/page.tsx
export default async function LoginPage() {
  const [roles, sports, genders, countries] = await Promise.all([
    getRoles(), getSports(), getGenders(), getCountries(),
  ]);
  return <LoginForm roles={roles} sports={sports} genders={genders} countries={countries} />;
}
```

**Good** — page renders instantly; options load while the user is typing their phone number:

```tsx
// app/(auth)/login/page.tsx
export default function Page() {
  return <LoginForm />;
}

// features/auth/components/LoginForm.tsx ("use client")
const [roles, setRoles] = useState<Role[]>([]);
// ...
useEffect(() => {
  void fetch("/api/login-options")
    .then((r) => r.json())
    .then((d) => { setRoles(d.roles); /* ... */ });
}, []);
```

## Supporting API Route

When moving fetches to the client, bundle related lookups into a single `/api/<page>-options` route so the client makes one request, not N:

```ts
// app/api/login-options/route.ts
export async function GET() {
  const [roles, sports, genders, countries] = await Promise.all([
    getRoles(), getSports(), getGenders(), getCountries(),
  ]);
  return NextResponse.json({ roles, sports, genders, countries });
}
```

The server-side helpers in `data/` and `features/*/server/` stay unchanged — they're just called from an API route instead of a page.

## Anti-Patterns

- `await Promise.all([...])` of lookup data at the top of a server `page.tsx` when most of that data is for a later step.
- Passing large lookup arrays as props through multiple levels just so the top-level server page can fetch them.
- Creating one API route per lookup (`/api/roles`, `/api/sports`, ...) and calling them in parallel from the client — use one bundled route instead.
- Showing a full-page spinner while client-side options load. Render the parts you can (the first form field), and only gate the sections that actually need the data.
- Fetching every record for a listing page during SSR or on first client load. Fetch one page, then let the user request more with a Load more button.

## Verification

After moving fetches client-side, confirm:
- The page HTML arrives and renders the first interactive element before any lookup request resolves.
- Navigating to the page from the nav bar feels instant even with the network throttled.
- Downstream components handle the initial empty-array state (e.g. `selectedRole` initialized to `""`, populated once options arrive).
