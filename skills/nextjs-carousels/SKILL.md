---
name: nextjs-carousels
description: Use when implementing Swiper or carousel behavior in the Next.js masarnext app.
---

Follow these Next.js carousel implementation rules in `next_apps/masarnext/`. Read `frontend-carousels.md` first; it owns carousel UX behavior.

## Library

- Use Swiper (`swiper/react`) for carousel/slider implementations.
- Do not install jQuery-based libraries such as Owl Carousel or Slick.
- Do not add a second carousel library to masarnext.

## Client Component

Swiper touches the DOM, so components rendering `<Swiper>` must be client components:

```tsx
"use client";

import { Swiper, SwiperSlide } from "swiper/react";
import { Autoplay, Pagination } from "swiper/modules";
import "swiper/css";
```

Import module CSS only for modules you use.

## Implementation Rules

- Modules such as Pagination, Autoplay, Navigation, FreeMode, Mousewheel, and EffectFade are imported from `swiper/modules` and passed through the `modules` prop.
- Use `<Swiper>` and `<SwiperSlide>`, not imperative `new Swiper(...)`.
- Use `slidesPerView="auto"` with token-derived per-slide widths for responsive rows.
- Keep spacing tied to CSS tokens; do not hardcode px gaps that break `nextjs-responsive-scaling.md`.
- CSS overrides should use CSS Modules via `className` and `:global(...)`, or Swiper class props where available.

## Migration

Convert existing custom sliders opportunistically when touching them for related work. Do not land a standalone mega-PR just to convert every carousel.
