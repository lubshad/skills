# Browser Device Frame Reference

Use this reference when presenting a fixed logical mobile viewport inside a realistic device shell in a desktop browser.

## Device Profile

Keep device facts in data rather than spreading values through component styles. A profile should define:

```text
model label
logical viewport width
logical viewport height
display corner radius
frame inset or chassis thickness
display cutout type and dimensions
top and bottom safe-area guidance
hardware controls and positions
```

Verify "latest" model requests against current official sources. Distinguish announced products from products currently available for purchase.

## DOM Layers

Use this order:

```text
bounded desktop review area
  unscaled device label
  remaining-space container
    device sizing slot
      hardware chassis
        decorative side controls
        display bezel
          cutout or Dynamic Island
          interactive app viewport
          home indicator
  unscaled journey controls
```

The sizing slot participates in desktop layout. The chassis may be uniformly transformed inside that slot.

## Fit Calculation

Start from the device's unscaled outer width and height. Determine scale from available desktop space:

```text
scale = min(1, available width / outer width, available height / outer height)
reserved width = outer width * scale
reserved height = outer height * scale
```

Account for the device label, journey controls, panel padding, and gaps before calculating available height. Measure the remaining-space container and set a CSS custom property for the scale plus explicit scaled width and height on the sizing slot. Fixed scale presets and desktop-height media queries are not a substitute for this calculation.

- Bound the desktop shell to the actual window. For a dedicated full-window review surface, prefer `position: fixed; inset: 0; height: auto` with `grid-template-rows: minmax(0, 1fr)`. A viewport-height shell is acceptable only when its rendered bounds remain inside the window under magnification; `100dvh` can itself be magnified by CSS zoom. Use `min-height: 0` and `min-width: 0` on nested flex/grid children so content cannot expand the available-space container. Keep this anchoring desktop-only.
- Keep labels and steppers outside that container with `flex-shrink: 0`; let the remaining-space container consume the flexible area. The independent left journey scroller must not determine the device area's height.
- Use `ResizeObserver` on the remaining-space container and unscaled chassis. Measure chassis layout dimensions such as `offsetWidth` and `offsetHeight`, including bezel and borders. Do not feed transformed `getBoundingClientRect()` dimensions back into the scale calculation.
- Include hardware protrusions in the outer dimensions or reserve explicit clearance before fitting. Clamp available dimensions to zero when the container is temporarily hidden; do not divide by zero when chassis dimensions are unavailable.
- Observe sources independent of the scaled slot to avoid resize feedback loops. Disconnect observers and media-query listeners on cleanup. A breakpoint change must clear inline desktop dimensions on mobile and remeasure on returning to desktop.
- Keep the product mounted during fitting. Window resize, font loading, concept/device changes, and browser zoom must not reset forms, navigation, or active calls.

Apply one scale variable to the complete chassis. Do not separately scale the app viewport.

## Desktop Rules

- Use three grid columns for review settings, screen journey, and the remaining device area. Give both sidebars bounded heights and independent content scrollers; long settings/scenario content must not consume the journey list's height.
- Keep concept/role/scenario controls and reset in settings. Put grouped screen links, active state, and progress in the journey column. Its accessible settings toggle must remain available while settings are hidden.
- Collapse settings by changing the review grid, not by covering or remounting the product. The remaining-space observer must re-fit the phone on both collapse and expansion. At mobile widths, hide both sidebars and reset both expanded and collapsed grids to a single product column.
- Use a fixed logical viewport inside the frame.
- Center the device within the remaining review area.
- Keep device labels and journey controls unscaled.
- Reserve the scaled dimensions to prevent overlap and clipping.
- Allow the left journey list to scroll without moving the device.
- Keep hardware controls visible outside the chassis edge.
- Use `overflow: visible` on the sizing/chassis layers and `overflow: hidden` only at the display viewport.

## Mobile Rules

At the chosen mobile/tablet breakpoint:

- Remove all chassis padding, borders, shadows, side controls, cutouts, and review labels.
- Reset transforms.
- Clear measured desktop slot dimensions and scale overrides. Let the frame wrappers inherit `100%` width and height from the bounded mobile app shell; follow `nextjs-responsive-scaling.md` for Next.js viewport ownership.
- Use safe-area environment values where fixed controls approach physical screen edges.

## Common Failures

- **Bottom frame is cut off:** the unscaled device is taller than available height, or transformed height was not reserved.
- **Controls overlap the phone:** labels or steppers were positioned relative to unscaled dimensions.
- **App looks too narrow or tall:** width and height were scaled independently, or the wrong logical viewport was used.
- **Side buttons disappear:** an ancestor clips overflow or decorative controls sit behind the chassis stacking context.
- **Mobile still looks framed:** desktop chassis styles were not fully reset at the mobile breakpoint.
- **Dynamic Island blocks headings:** app safe-area/header spacing does not account for the selected device profile.

## Browser Verification

Inspect at multiple desktop widths and heights, not only a single large screenshot. Confirm the full top and bottom chassis, all visible side controls, device label, and journey controls fit simultaneously. Then test the same URL at real mobile widths and in installed PWA mode to ensure the review shell is absent.

Resize continuously and include short `540px` and `600px` desktop heights. Test browser zoom at 125%, 150%, and 200%, font changes, and crossing the desktop/mobile breakpoint in both directions. Assert that frame and control bounds stay inside the viewport, the reserved slot matches scaled chassis dimensions, and the desktop document has no unintended overflow. Confirm mobile has no transform or stale measured dimensions. Report simulated viewport checks separately from actual browser-zoom and real-device checks.
