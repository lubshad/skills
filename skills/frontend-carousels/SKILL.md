---
name: frontend-carousels
description: Use when designing carousel or slider UX, behavior, responsiveness, accessibility, and content rules.
---

# Carousels

## Core Rules

- Use one approved carousel implementation per platform/app; do not add a second library for the same project without explicit approval.
- Prefer native horizontal scrolling when the design needs only a simple scrollable row with no autoplay, pagination, looping, or snap behavior.
- Use a carousel when touch swipe, pagination, autoplay, looping, or controlled snap behavior is required.
- Preserve responsive/device layout rules from `frontend-device-layout.md`; do not hardcode sizes that break proportional scaling.

## Patterns

- Hero sliders: full-bleed or strongly visual, one active slide, optional autoplay, clear pagination.
- Row carousels: item/card-based, snap or free-scroll depending on content, touch and trackpad friendly.
- Galleries/testimonials: predictable navigation, readable dwell time, pause on hover where supported.

Use the approved library's timers/drag behavior and platform sizing tokens. Autoplay must allow reading and interaction.

## Platform Adapters

- Next.js Swiper implementation details live in `nextjs-carousels.md`.
