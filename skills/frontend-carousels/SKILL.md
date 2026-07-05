---
name: frontend-carousels
description: Use when designing carousel or slider UX, behavior, responsiveness, accessibility, and content rules.
---

Follow these carousel/slider UX rules for frontend platforms.

## Core Rules

- Use one approved carousel implementation per platform/app; do not add a second library for the same project without explicit approval.
- Prefer native horizontal scrolling when the design needs only a simple scrollable row with no autoplay, pagination, looping, or snap behavior.
- Use a carousel when touch swipe, pagination, autoplay, looping, or controlled snap behavior is required.
- Preserve responsive/device layout rules from `frontend-device-layout.md`; do not hardcode sizes that break proportional scaling.

## Patterns

- Hero sliders: full-bleed or strongly visual, one active slide, optional autoplay, clear pagination.
- Row carousels: item/card-based, snap or free-scroll depending on content, touch and trackpad friendly.
- Galleries/testimonials: predictable navigation, readable dwell time, pause on hover where supported.

## Anti-Patterns

- Installing multiple carousel libraries in one app.
- Hand-rolling timers and drag behavior when the platform-approved library covers the use case.
- Hardcoding card widths/gaps outside the platform's token/layout system.
- Autoplay that prevents users from reading or interacting with content.

## Platform Adapters

- Next.js Swiper implementation details live in `nextjs-carousels.md`.
