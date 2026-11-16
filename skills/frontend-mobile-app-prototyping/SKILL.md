---
name: frontend-mobile-app-prototyping
description: Use when building browser-hosted clickable mobile prototypes with desktop journey review, realistic device framing, or mobile PWA presentation.
---

# Mobile App Prototypes

**Temporary services, production-quality UI.** Product-named features/screens/types, reusable components/tokens, controlled forms, deterministic sample data, and replaceable service boundaries. Keep review navigation/frame/profiles outside the product app.

Read `frontend-device-layout.md`, then [the prototyping contract](PROTOTYPING.md) before building the review shell or device/mobile presentation. It owns complete journey controls, shell variants, fitting geometry, device accuracy, PWA delivery, and the viewport/zoom matrix. Read other shared behavior skills only for screens being built, then the platform adapter.

## Invariants

- Complete deterministic journeys, direct state links, working/simulated controls, and explicit reset. No dead buttons or simulated outcomes presented as real finance/calling/streaming services.
- Choose lightweight preview, dashboard, or separate settings/journey/device columns by actual complexity. Preserve product/demo/pending state across review navigation and layout changes.
- Desktop shows a complete recognizable frame; exact model claims require verified specifications. Uniformly fit the entire device within measured remaining width/height, reserving its scaled slot and label/stepper space. Never crop/stretch hardware or scale the app separately.
- On actual mobile remove frame, simulated OS chrome, and presentation transforms. Use native safe areas once, bounded content scrolling, reachable actions, and available zoom/panning.
- Installable delivery includes manifest/identity/icons/theme/standalone, useful offline fallback, HTTPS-ready configuration, and service worker only when offline/install behavior is in scope.

## Verification

Use the contract's desktop/mobile widths, short heights, continuous resize, zoom/text/font/profile changes, frame bounds, journey/reset, review-state preservation, drawer keyboard flow, safe areas, standalone mode, reduced motion, and platform checks. Distinguish simulated viewport evidence from real devices.
