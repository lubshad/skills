---
name: penpot-solution-design
description: Use when designing or reviewing editable architecture, journeys, wireframes, UI systems, or prototypes in Penpot through MCP.
---

# Penpot Solution Design

Connect business needs, system responsibilities, and UX at the requested depth. Not for implementation without design changes, generic architecture without Penpot output, or OpenCode/MCP configuration.

## Read by branch

UI design first reads matching shared behavior: admin listings use `frontend-admin-panels.md`, `frontend-listing-screens.md`, `frontend-ui-states.md`; editing uses admin, `frontend-forms.md`, states, then `frontend-admin-detail-pages.md`. Other forms/auth/interactions load only when designed. Dynamic metadata adds dynamic-field companions; responsive/safe-area work uses `frontend-device-layout.md`; connections use `project-connections.md`.

Do not load Flutter/Next.js/backend implementation adapters merely because a diagram mentions them. Penpot-only mobile prototypes do not activate browser-hosted `frontend-mobile-app-prototyping.md`.

## Working contract

Confirm outcome/scope/audience/file/core journey from existing context; ask only material missing decisions. Separate facts, proposals, assumptions, and questions—no invented implemented APIs or permissions. Design-only work changes no app code, packages, deployments, or MCP config.

Inspect the connected file first; preserve unrelated boards/libraries/user work, asking before deletion/replacement or broad shared-asset changes. Establish architecture and one complete journey before multiplying screens. Checkpoint substantial decisions, not each shape. Use the simplest justified architecture and native editable text/shapes/paths/components/tokens, not flattened-image substitutes.

Represent server authorization/tenancy/data ownership, integrations, and failure/retry where relevant. Label connector meaning/direction and distinguish sync/async/conceptual links. Verify each batch structurally and visually; configured prototype navigation is not a working backend.

## Workflow and tools

Follow [design workflow](references/design-workflow.md): discover → inspect → outline boards/fidelity/checkpoints → model context/modules/data/sequences → wireframe/visual design → connect journey/requirement traceability → review → handoff. Create only agreed artifacts.

Before Penpot tools read [MCP execution](references/penpot-mcp.md) and the server overview once per conversation. Discover documented APIs rather than guessing methods/properties. If no design file is attached, ask the user to connect it; do not reinstall/reconfigure MCP. Review-only remains read-only.

## Verification

Check scope/file/preserved work, fact/proposal labels, coherent ownership/security/connectors, and priority journey. Keep content editable and named consistently. Inspect exports for clipped/overlapping text, missing labels, unreadable connectors, and overflow. Review relevant viewport/contrast/focus/validation/data/recovery intent; static specifications are not runtime passes. Inspect triggers/destinations and exercise viewer paths when available. Handoff changed pages/IDs/links, decisions, actual checks, unresolved questions, and missing export/viewer evidence.
