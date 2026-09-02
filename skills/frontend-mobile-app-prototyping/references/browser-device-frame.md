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
device sizing slot
  hardware chassis
    decorative side controls
    display bezel
      cutout or Dynamic Island
      interactive app viewport
      home indicator
```

The sizing slot participates in desktop layout. The chassis may be uniformly transformed inside that slot.

## Fit Calculation

Start from the device's unscaled outer width and height. Determine scale from available desktop space:

```text
scale = min(1, available width / outer width, available height / outer height)
reserved width = outer width * scale
reserved height = outer height * scale
```

Account for the device label, journey controls, panel padding, and gaps before calculating available height. If static CSS is sufficient, use bounded desktop-height media queries. If the surrounding shell is dynamic, measure the available container and set a CSS custom property.

Apply one scale variable to the complete chassis. Do not separately scale the app viewport.

## Desktop Rules

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
- Set the app viewport to `100%` width and `100svh` height.
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
