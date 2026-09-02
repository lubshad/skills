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

The desktop presentation uses two stable areas:

- A fixed left-side journey navigator.
- A device presentation area containing the interactive mobile application.

The journey navigator should include:

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

On desktop review surfaces only, the complete device presentation may be uniformly scaled to fit the available height. This is an exception to the normal no-transform-scaling product-layout rule because it scales a presentation artifact, not the product UI's responsive layout.

- Scale chassis, bezel, app viewport, cutout, and controls as one unit.
- Reserve the post-scale width and height in layout; transforms alone do not change document flow.
- Use a top-centered or top-left transform origin that matches the reserved slot.
- Never scale the app independently from the hardware frame.
- Never crop the bottom chassis to preserve a larger preview.
- Never stretch width and height independently.
- Keep the model label and previous/next controls outside the scaled unit.
- Use bounded desktop height classes or a measured container, not browser zoom.

## Mobile And PWA Behavior

On actual mobile and tablet-width browsers:

- Hide the desktop journey navigator.
- Remove the decorative hardware frame.
- Hide simulated operating-system chrome, including prototype status bars, clocks, signal indicators, and home indicators. These belong only to the desktop device preview.
- Render the product edge-to-edge at the real browser viewport.
- Respect safe-area insets for fixed headers, bottom actions, navigation, and media controls.
- For an edge-to-edge iOS standalone experience, use `viewport-fit=cover` and a translucent Apple status bar style, then let the active screen background paint behind the top safe area.
- Preserve top safe-area spacing after hiding a simulated status bar so product controls do not collide with a notch, Dynamic Island, or native status indicators.
- Set the browser and manifest theme colors to an intentional product-shell color so browser chrome and launch transitions do not expose an unrelated dark strip.
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
- Previous and next controls remain visible and reachable.
- The left journey navigator scrolls independently.
- Every journey entry opens the intended screen or state.
- Reset restores deterministic demo state.
- No content is obscured by a Dynamic Island, notch, home indicator, or unsafe edge.
- Actual mobile and installed-PWA views show only native operating-system chrome, with no duplicate simulated status bar and no unintended dark safe-area strip.
- Mobile widths show no desktop navigator, device chassis, or presentation scaling.
- PWA browser and standalone modes remain usable.
- Keyboard focus is visible and logical.
- Reduced-motion preferences are respected.
- Platform linting, type checks, tests, and production builds pass.
