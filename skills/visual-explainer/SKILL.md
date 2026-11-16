---
name: visual-explainer
description: Use when visually explaining a plan, implementation, workflow, comparison, or concept through diagrams or interactive HTML.
---

# Visual Explainer

**Show behavior, not decorative arrows around prose.** Answer what happens, why, and what changes with one dominant visual and minimal supporting copy.

Before creating/updating an artifact, read [the visual guide](VISUAL-GUIDE.md). It owns design tokens, device/dashboard variants, offline assets, accessibility, serving/browser workflow, and delivery checks. Start from `templates/visual-explanation.html`, adapting rather than filling every section.

## Workflow

1. Establish audience/question, mode, evidence, target project, and permission. Planning distinguishes proposed/assumed/undecided; implementation uses inspected source; comparisons align current/proposed changes. Concepts need no codebase. Ask only material missing decisions.
2. Model actors, trigger, path/decisions, visible/persisted outcome, and failure/cancellation/denial. Do not invent implemented contracts or expose secrets.
3. Choose the right sequence/state/boundary/timeline/comparison visual. Label directions/actions, keep actor placement stable, and encode meaning beyond color. A stepper changes the actual visual, not only its caption.
4. When authorized, update the same feature HTML in target-project docs, preserving approved decisions/unrelated work. Discussion stays in conversation; plan approval or agent switch does not authorize application changes.
5. Follow the guide's self-contained/local-asset standard, safe HTML insertion, keyboard/focus/reduced-motion/print behavior, and static fallback. Simulations never call production or modify data.
6. Serve only the intended docs/assets directory over HTTP and open that URL with discovered browser tools and explicit tab ID. Direct-file preview is not browser validation. Verify interactions/rendering/evidence; keep the server available for review and report lifecycle limits.

## Verification and delivery

Check structure/JS/links, diagram semantics, step/reset/branch/copy behavior, assets/licenses, desktop/mobile bounds, accessibility, and applicable device/dashboard checks from the guide. Report actual versus unrun checks; DOM simulation is not rendering or end-to-end product evidence. If server/browser access is blocked, say validation is incomplete rather than bypass restrictions.

Lead with served URL, then source path and essential findings/limits. Without serving, lead with source and the browser-review blocker.
