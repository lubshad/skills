---
name: frontend-mobile-app-prototyping
description: Use when building a browser-hosted, clickable mobile app prototype with production-oriented code, a desktop client journey navigator, a realistic device frame, and an installable mobile PWA experience.
---

# Frontend Mobile App Prototyping

Build mobile concepts as credible applications with deterministic demo behavior. The temporary part is the data and service layer, not the feature architecture, component names, interaction quality, or responsive implementation.

## When to Use

Apply this skill when a mobile app concept must be:

- Presented interactively in a desktop browser.
- Navigated by a client through a defined screen journey.
- Displayed inside a recognizable real-device frame.
- Opened directly on a phone as an edge-to-edge PWA.
- Structured so approved UI can continue into production development.

Read `frontend-device-layout.md` first. Also read the relevant interaction, form, authentication, listing, video, and platform implementation skills for the screens being built.

## Production-Oriented Structure

- Name features, components, screens, routes, and domain types after the product behavior, not `prototype`, `mockup`, `concept`, or `demo`.
- Isolate deterministic sample records in an explicitly temporary data source such as `data/demoData`.
- Keep the product application independent from the desktop review presentation.
- Put device profiles, review navigation, and frame rendering in a review/presentation layer rather than the product feature.
- Keep service boundaries replaceable so connecting real authentication, payments, calling, streaming, or backend APIs does not require renaming the UI tree.
- Use reusable product components and tokens instead of one-off markup for each review screen.
- Do not place all screens and interactions in one unbounded component when the implementation is expected to continue into production. Split by product feature or screen responsibility.

Recommended conceptual boundaries:

```text
app or routes
shared components
product features
  product components
  product screens
  demo data
  domain types
review presentation
  client journey navigator
  device frame
  device profiles
```

Exact paths and syntax belong to the selected platform adapter.

## Interactive Journey

- Build complete task journeys, not a gallery of disconnected screenshots.
- Every journey entry must open a deterministic screen or state directly through a route, hash, or review-state identifier.
- Provide meaningful transitions between related screens so clients can use the app naturally.
- Do not leave visible controls dead. Implement the interaction, navigate to the intended state, or show explicit simulated feedback.
- Use realistic content lengths, image ratios, balances, timestamps, loading outcomes, and empty/error variants where they materially affect the design.
- Prevent duplicate simulated submissions and preserve controlled form state just as production code would.
- Provide a reset action that restores all demo state to a documented baseline.
- Keep review controls outside the product viewport so they do not contaminate the mobile UI being assessed.

## Desktop Client Review Shell

The desktop presentation uses three stable columns when review settings and journey navigation are both present:

- **Review settings:** branding, a short concept introduction, concept and role/persona selectors, scenario controls, and reset-demo action.
- **Screen journey:** a dedicated full-height, independently scrolling screen/task navigator, with an active-screen indicator and current position/total count.
- **Device preview:** the interactive mobile application, complete device frame, model label, and previous/next controls in the remaining space.

Do not squeeze a long journey list below settings, introductory copy, and scenario controls in a single sidebar. Group journey entries by product phase or role when useful, preserving their sequence and direct navigation. Settings content scrolls independently when expanded scenarios exceed its available height; keep reset and journey progress reachable.

Use compact, readable sidebar widths before reducing device space. Provide an accessible settings-panel toggle in the journey header so narrower desktop windows can retain journey navigation and a useful preview. Collapsing or expanding settings must re-fit the device without remounting or resetting the app. At the mobile/tablet fallback, hide both review sidebars and remove desktop column constraints.

The review sidebars collectively should include:

- Product and concept identity.
- A short direction or review description.
- A scrollable ordered list of screens or tasks.
- A clear active-screen indication.
- Role, persona, or mode switching when relevant.
- Reset-demo control.
- Current position and total journey count.

The device area should include:

- Device model and logical viewport label.
- Complete visible hardware frame.
- Previous and next journey controls.
- Enough reserved layout space for the scaled device so controls never sit behind or below it.

Keep the journey list independently scrollable when its content exceeds the viewport. The product viewport must not scroll the desktop review page itself.

## Real Device Frame

- Use a real, currently available device model when the user asks for a named or latest device. Verify current availability and official display specifications before labeling it.
- Store each device's logical CSS viewport, display corner radius, frame dimensions, safe areas, and hardware treatment in a reusable device profile.
- Show the complete chassis rather than using only a thick rounded border.
- Include the model's recognizable display cutout, Dynamic Island, or notch when applicable.
- Include visible side controls that materially define the silhouette, such as action, volume, power, or camera controls.
- Include the bottom home indicator for gesture-navigation devices.
- Use subtle materials, highlights, antenna details, and shadows; the frame should support the app rather than dominate it.
- CSS/SVG frames are preferred for crisp scaling. A licensed frame asset is acceptable when its terms and dimensions are known.
- Do not claim an exact device model while rendering a generic or materially inaccurate frame.

Detailed browser implementation guidance lives in `references/browser-device-frame.md`.

## Device Scaling Exception

The app inside the device retains the exact logical viewport and aspect ratio from the device profile.

On desktop review surfaces only, size the complete device presentation from the actual available width and height. Uniformly scale it down when needed. This is an exception to the normal no-transform-scaling product-layout rule because it scales a presentation artifact, not the product UI's responsive layout.

- Scale chassis, bezel, app viewport, cutout, and controls as one unit.
- Reserve the post-scale width and height in layout; transforms alone do not change document flow.
- Use a top-centered or top-left transform origin that matches the reserved slot.
- Never scale the app independently from the hardware frame.
- Never crop the bottom chassis to preserve a larger preview.
- Never stretch width and height independently.
- Keep the model label and previous/next controls outside the scaled unit.
- Bound the desktop review shell to the available browser viewport, not only a minimum height. Reserve label, previous/next controls, padding, and gaps before measuring the remaining device area.
- Calculate `scale = min(1, available width / unscaled outer width, available height / unscaled outer height)`. Include clearance for protruding hardware controls. Use actual unscaled chassis dimensions, not transformed bounds or only the inner screen dimensions.
- Recalculate when available space or chassis dimensions change, including window resizing, browser zoom, font loading, device changes, and review-shell layout changes. Do not use fixed scale presets or height breakpoints as the final fitting mechanism, and never require users to zoom out to see the complete device.
- Keep fitting in the review layer; it must not remount the product app or reset its state. Clear desktop sizing overrides when entering the mobile layout and recalculate when returning to desktop.

## Mobile And PWA Behavior

Follow the shared Safe Areas rules and verification in `frontend-device-layout.md` for both prototypes and production PWAs. Preview-specific behavior belongs here; browser implementation belongs in the platform adapter.

On actual mobile and tablet-width browsers:

- Hide the desktop journey navigator.
- Remove the decorative hardware frame.
- Hide simulated operating-system chrome, including prototype status bars, clocks, signal indicators, and home indicators. These belong only to the desktop device preview.
- Render the product edge-to-edge at the real browser viewport.
- Use the shared bounded-app scroll behavior from `frontend-device-layout.md`. Review/frame wrappers must inherit the product viewport on mobile, not impose the desktop preview's dimensions.
- Follow the platform adapter for viewport sizing, wrapper constraints, explicit scrollers, keyboard handling, and edge-to-edge metadata. For Next.js, these live in `nextjs-responsive-scaling.md` and apply equally to production PWAs; do not duplicate shell-height workarounds here.
- Preserve top safe-area spacing after hiding a simulated status bar so product controls do not collide with a notch, Dynamic Island, or native status indicators.
- Use the selected device profile's safe-area values only inside the desktop preview. Switch the shared content-clearance source to native browser insets on actual devices; do not carry preview offsets into the mobile/PWA layout.
- Set the browser and manifest theme colors to an intentional product-shell color so browser chrome and launch transitions do not expose an unrelated dark strip.
- Keep page zoom available. Do not set `user-scalable=no`, restrictive maximum-scale values, or `touch-action: none`; document scroll locking must not prevent pinch zoom or visual-viewport panning.
- Do not apply the desktop device-preview transform to the product UI.
- Keep the journey usable through normal product navigation; review-only direct links may remain available.

For installable PWA delivery, provide:

- Web app manifest.
- Correct app name, icons, theme color, and standalone display mode.
- Service worker registration when offline/install behavior is in scope.
- Useful offline fallback.
- HTTPS-ready production configuration.
- Mobile browser and installed-standalone verification.

## Visual And Interaction Quality

- Treat prototype status as permission to simulate services, not to lower UI quality.
- Use production spacing, typography, focus states, semantics, touch targets, validation, and pending states.
- Preserve keyboard accessibility in the desktop review shell and product UI.
- Provide reduced-motion behavior without removing essential state feedback.
- Use optimized, stable-size media to avoid layout shift.
- Avoid native browser alerts and confirms.
- Clearly distinguish simulated financial, calling, or streaming outcomes without exposing implementation notes inside the product UI.

## Verification

Verify the desktop review at widths `1280`, `1440`, `1600`, and `1920`, and at heights `720`, `800`, `900`, and `1080`.

Verify the mobile product at widths `360`, `390`, `402`, and `430`, plus the exact logical viewport of the selected device profile.

Confirm that:

- The complete device chassis is visible at every supported desktop size.
- The displayed model name and logical viewport are accurate.
- Scaling preserves the device aspect ratio and does not distort the product UI.
- The scaled device reserves correct layout space.
- Continuously resizing the window keeps the whole frame, side controls, label, and stepper visible without desktop document overflow. Include short laptop heights such as `540` and `600`, and sizes between the standard verification points.
- Browser zoom at 125%, 150%, and 200%, increased default text size, loaded fonts, and device/profile changes trigger a correct fit or the intended mobile fallback. Verify actual element bounds rather than screenshots alone.
- Previous and next controls remain visible and reachable.
- The left journey navigator scrolls independently.
- Settings and journey occupy separate desktop columns; expanding scenarios does not shorten the journey list. Verify grouped navigation, settings collapse/expand, persistent reset/progress controls, and device re-fitting. Both sidebars disappear at the mobile fallback, including when settings were previously collapsed.
- Every journey entry opens the intended screen or state.
- Reset restores deterministic demo state.
- No content is obscured by a Dynamic Island, notch, home indicator, or unsafe edge.
- Run the shared safe-area checks from `frontend-device-layout.md` and verify that changing preview device profiles changes content clearance without moving the shell.
- Actual mobile and installed-PWA views show only native operating-system chrome, with no duplicate simulated status bar and no unintended dark safe-area strip.
- The product background reaches every viewport edge while top and bottom controls remain inside their safe areas as dynamic browser chrome changes.
- The document itself does not scroll or rubber-band; only designated content regions scroll, and fixed navigation remains stationary.
- Mobile widths show no desktop navigator, device chassis, or presentation scaling.
- PWA browser and standalone modes remain usable.
- Pinch zoom and panning remain usable at 200% without losing access to controls.
- Keyboard focus is visible and logical.
- Reduced-motion preferences are respected.
- Platform linting, type checks, tests, and production builds pass.
