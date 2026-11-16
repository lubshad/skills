---
name: nextjs-carousels
description: Use when implementing Swiper carousels in masarnext.
---

# Next.js Carousels

Read `frontend-carousels.md` first. MasarNext uses only Swiper (`swiper/react`), not jQuery/Owl/Slick or a second library.

Render declarative `Swiper`/`SwiperSlide` in `"use client"` components, never `new Swiper`. Import required modules from `swiper/modules` through `modules`, base `swiper/css`, and only module CSS used.

Responsive rows use `slidesPerView="auto"`, token-derived slide widths/gaps, and `nextjs-responsive-scaling.md`. Overrides use CSS Modules `className`/`:global(...)` or Swiper class props.

Convert custom sliders during related work, not a standalone conversion mega-PR.

## Verification

Check module/CSS imports, responsive token use, and shared carousel behavior.
