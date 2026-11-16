# Visual Explainer

Turn a topic into a visual explanation that answers **“What happens, why, and what changes?”**

**Primary rule: show the behavior, not a wall of text.** Diagrams are the explanation; paragraphs are supporting material. Do not produce a report with a few decorative arrows.

## 1. Establish mode and scope

Infer from the request when clear. Ask only when ambiguity would materially change the result.

| Mode | Basis | Required distinctions |
| --- | --- | --- |
| Planning | User requirements, constraints, existing architecture where relevant | Proposed, assumed, undecided; alternatives and failure paths |
| Implementation | Actual source/configuration/contracts | Observed behavior versus inference; frontend versus backend support |
| Current → proposed | Current evidence plus the requested design | Unchanged, changed, added, removed; migration/compatibility effects |

This skill also works without a codebase: product ideas, operational workflows, architecture choices, and conceptual explanations are valid inputs. Never invent implementation evidence for a plan.

- Identify audience, central question, and output location from context.
- Read applicable `AGENTS.md` and project instructions before working in a codebase.
- Honor Plan mode and other write restrictions. If writing HTML is prohibited, discuss the visual structure in the conversation and wait for a mode change. This skill does not authorize writes.
- Summarize intended files and changes before editing.
- Default to a clearly named HTML file in the target project's `docs/` directory when authorized and appropriate. Reuse its conventions and the document for the same feature; otherwise prefer `docs/features/<feature-name>.html`. If no `docs/` exists, state that creating it is part of the requested artifact, subject to active write permissions. Do not modify application code merely to explain it.

### Planning with default Plan and Build agents

- This skill remains reusable for plans, implementation explanations, and current/proposed comparisons. It does not require a custom agent or authorize any write by itself.
- Use default Plan for requirements discovery, focused source inspection, recommendations, alternatives, and decision tracking in the conversation. Use default Build to create or update project HTML documentation when requested; switching agents does not itself authorize application changes.
- Read relevant product and platform skills when their behavior is being designed, following shared frontend guidance before platform adapters. Do not load unrelated implementation skills merely because their files exist.
- Reuse the brief, evidence, decisions, assumptions, and open questions already established in the conversation. Do not repeat answered questions; ask only when new ambiguity changes the explanation.
- Discussion-only planning stays in the conversation. Create or update HTML when requested, not automatically after every reply. Summarize the intended path and changes first.
- Choose the target project's documentation folder, not another project's merely because it is writable. Root documentation is for workspace-wide topics. Ask when ownership is unclear.
- Mark observed facts, proposals, assumptions, undecided choices, and explicitly approved decisions separately. Approval does not mean implemented or authorize application changes.
- Iterate on the same feature document, preserve explicitly approved decisions, and surface conflicts with later requests. Inspect existing files before editing and preserve unrelated user work.
- Follow the active agent's restrictions even when a suggested browser or shell validation step is unavailable; report the limitation and hand off stronger checks if needed. Do not bypass restrictions through alternative tools or generated scripts.

## 2. Build a small behavioral model

Before designing the page, determine:

1. **Actors:** who clicks, decides, processes, stores, or receives?
2. **Trigger:** what starts the flow?
3. **Path:** what requests, decisions, and state changes follow?
4. **Outcome:** what does the user see and what persists?
5. **Exceptions:** what changes on failure, cancellation, expiry, or denial?

For implementations, inspect focused source files and contracts rather than relying only on old documentation. Check conditions that hide controls, actual defaults, lifetimes, and async updates. Do not claim a backend capability is exposed in the UI unless the UI actually exposes it.

For plans, show enough detail to support a decision without pretending decisions have already been made. Use short, explicit assumption/open-question labels. Separate recommended and alternative designs.

For comparisons, align matching actors and steps so the differences are visible at a glance.

## 3. Choose visuals to fit the explanation

Use only the visual forms that help; do not force every page into the same sections.

| Question | Useful visual |
| --- | --- |
| What happens after this action? | Click-through stages with highlighted actors and state |
| Who calls whom? | Sequence diagram or swimlanes |
| What changes? | Before → action → after; current/proposed side-by-side |
| What can be accessed? | Boundary box, folder tree, permission gates |
| How does state evolve? | Labeled state machine with transition arrows |
| What happens over time? | Timeline with distinct events and expiry windows |
| Which approach should we choose? | Aligned option diagrams plus compact tradeoff matrix |
| What happens on failure? | Decision branch and visible recovery path |
| How will we roll it out? | Phased rollout with dependencies and rollback point |

### Diagram quality

- Label arrows with the action or data that moves, not just generic “next.”
- Show direction, ordering, and branch outcomes unambiguously.
- Use concrete short examples where they help, but no live tokens, personal data, or secrets.
- Separate metadata/control flow from file/data delivery when relevant.
- Show visible results, not just component names.
- Do not confuse request-time refresh with live updates, signed URL expiry with link expiry, or permission revocation with recalling downloaded bytes.
- Use consistent actor placement and visual vocabulary throughout.
- Use labels/icons as well as color for success, denial, proposed changes, and uncertainty.
- Keep the main canvas dominant: short labels, short captions, minimal prose. Move long rationale, API tables, and source references into collapsed details.

## 4. Create the artifact

Read `templates/visual-explanation.html` relative to this skill directory as a starting point. Adapt the layout and diagrams to the topic; it is not a mandatory page structure.

### Minimal visual standard

The approved workspace reference is `docs/git-worktrees.html` (relative to the workspace root). Use its calm, focused presentation—not its Git-specific content—as the default. Explicit user direction and an established target project's documentation style take precedence. Keep the reusable rules and starter template here; do not depend on the example remaining available forever.

- **Focus:** one central question, one dominant diagram, and only the supporting visuals the topic needs. Use open space and subtle dividers between sections, not a stack of outer cards containing inner cards. Reserve surfaces for meaningful nodes, state, and the selected detail panel.
- **Copy:** short headings, plain words, one idea per caption. Prefer labels such as “Create”, “Save”, “Merge”, and “Next”. Cut repeated badges, explanations, and decorative metadata. Do not shorten away permissions, failure paths, evidence status, or data-integrity caveats. Put long rationale, source links, assumptions, and command references in collapsed details.
- **Palette:** warm white `#FAFAF7`, white surfaces, dark slate `#303746`, muted text `#596373`, and quiet borders `#DCE0E6`. Use lavender `#EDE7F6` for shared context, pale blue `#E8F0FA` for selected/active state, mint `#E7F3EC` for completed/safe state, and peach/cream only for a meaningful distinction or warning. Pair pastel fills with dark labels; avoid saturated primary buttons, large dark panels, gradients, and decorative shadows by default.
- **Type:** Kanit for headings, body, and controls; regular 400 and medium 500, with 700 used sparingly. Use `Kanit, Arial, Helvetica, sans-serif` fallbacks and `Consolas, "Liberation Mono", "Courier New", monospace` for code. Aim for a small scale: 14px captions/controls, 16px body, 22px section headings, and a responsive 30–40px title. Use comfortable line height, not widely tracked text or oversized headlines.
- **Layout:** for a compact explanation, use a centered reading width around 900–960px; for a multi-page review, use the dashboard shell below. Keep generous space around the main visual and consistent 8/16/24/32px spacing. Use thin, purposeful SVG/CSS connectors with clear direction or relationship labels. Limit rounded surfaces to a consistent 8–16px range. Reflow nodes on narrow screens without clipping or shrinking text.
- **Interaction:** one clickable stepper, not step buttons plus duplicate step cards. Selecting a stage must update the diagram's actors, connections, or state as well as a short caption/detail panel. Keep actor positions stable; show removed nodes as labeled placeholders when that preserves orientation. Include next/restart only when useful.
- **Commands:** one light command panel for the selected stage. If commands are present, a quiet “Copy” action may write only the shown text to the clipboard; it must not execute it. Report success only after the write succeeds, and provide a selectable-text fallback with Ctrl+C/⌘C guidance when clipboard access fails. No copy button is needed on explanations without commands.
- **Polish:** visible keyboard focus, clear selected state beyond color alone, stable controls of at least 44px height, polite status feedback, and brief optional transitions (roughly 150–200ms). Respect reduced motion. Premium means less noise and clearer meaning—not more effects.

### Mobile app visuals and device frames

- When presenting mobile app screens or an interactive mobile journey, show the app inside a realistic device frame on desktop—not a plain rounded rectangle. A mobile actor in an architecture diagram does not require a full device preview.
- Read `frontend-device-layout.md`, then `frontend-mobile-app-prototyping.md` for frame profiles, proportional fitting, simulated chrome, and actual-mobile behavior. Read `frontend-design-consistency.md` when designing or changing the app UI itself.
- Include the complete chassis, bezel, appropriate cutout/notch or Dynamic Island, visible side buttons, and home indicator where applicable. Use a generic label such as “iPhone-style concept” unless the exact model and specifications are verified.
- Fit the entire device proportionally to the remaining workspace width and height, reserving space for its label and navigation. Do not crop the chassis, stretch the app, shrink text, or require browser zoom-out. Refit on resize, fonts loading, and navigation without resetting the demo.
- On actual narrow/mobile views, remove the simulated chassis, OS status bar, cutout, and home indicator. Use native safe-area clearance once, not desktop preview offsets.
- When showing a device or controller beside the app, synchronize the relevant simulated states. Label unverified hardware illustrations as concepts, not schematics or evidence of real hardware capabilities.

### Dashboard shell when content outgrows one page

- Use a full-window, admin-style review dashboard when distinct tasks, screens, diagrams, or controls cannot fit comfortably in one desktop view. Also use it when the user explicitly requests persistent navigation. Do not solve crowding by shrinking text, clipping controls, or stacking every section into one long document.
- Read `frontend-admin-panels.md` and `frontend-device-layout.md` for the shell. This is the explanation's presentation layer, not automatically the product's UI or an authorization to build an admin app.
- Keep a persistent desktop sidebar, compact page-title/status top bar, and a bounded main workspace. Avoid a large introductory hero above the workspace. Put shared scenario selection, reconnect/recovery, and reset controls in stable, reachable sidebar utility areas.
- Split content into focused, directly addressable pages with an active navigation indicator. Use only pages the topic needs; examples include Controls, Activity, Device, How it works, and Safety & notes. Do not add fictional product features to fill the navigation.
- Preserve shared simulation state, activity, selected scenario, and pending work across page navigation. Reset only through the explicit reset action. Changing the workspace page must not silently change the app preview's screen or conflate the two navigation layers.
- Keep sidebar and top bar in place; scroll only the relevant content pane or sidebar region when necessary. Bounded does not mean every content page must be scroll-free. Keep important actions reachable on short screens and at increased text size.
- On narrow screens, replace persistent review navigation with an accessible drawer or menu when those review pages still need access. Support focus management, Escape closing, and focus return. Do not squeeze desktop columns or a simulated phone frame into the mobile viewport.
- For mobile reviews with extensive settings and a long ordered journey, retain the separate settings and journey columns from `frontend-mobile-app-prototyping.md`; a single dashboard sidebar is appropriate for compact page navigation with a small shared control set.
- Simple diagrams and short explanations that already fit remain lightweight reading pages. A little supporting prose or one collapsed detail section alone is not a dashboard trigger. Static print/no-JavaScript fallbacks must keep essential explanation and navigation accessible.

### Offline assets and permissions

- Produce self-contained HTML with inline CSS and small vanilla JavaScript where needed. A small bundled font folder is allowed; describe that dependency accurately instead of calling the HTML a standalone file.
- No CDN dependencies, remote font services, analytics, or runtime network calls by default. Use HTML/CSS or inline SVG for diagrams.
- Prefer existing local Kanit files or bundle licensed regular/medium weights beside the HTML, preserving the font license. The starter template uses locally installed Kanit with standard fallbacks; it does not download fonts or assume any font file exists. An authorized implementation agent may add local `@font-face` URLs after verifying the paths.
- Font setup does not expand permissions. A restricted planner must not run shell, fetch fonts, copy binary files through an alternate tool, or use a remote stylesheet to force Kanit. If suitable local assets cannot be referenced with permitted tools, keep the fallback and report font bundling as a handoff item. Do not claim Kanit rendered merely because it is listed in CSS.

### Content and accessibility

- Use a clear mode/evidence legend near the top: implemented, proposed, assumed, or undecided. Do not label the entire page implemented when only part is verified.
- Include an interactive walkthrough when useful: step buttons, next/restart, updated actor states, and a short outcome caption. Controls must actually change the visual, not merely a text paragraph.
- Keep core diagrams readable without JavaScript. Add a concise `noscript` note if interactive content has a static fallback.
- Simulations must be labeled. Never call production services or modify user data as part of an explanatory demo.
- Support narrow screens, keyboard navigation, visible focus, `aria-pressed`/`aria-live` where appropriate, reduced motion, and printable static diagrams.
- Do not rely on emoji alone for meaning; all important nodes need text labels.
- Escape source/user content inserted into HTML. Prefer `textContent` over `innerHTML` in interactions.
- Keep sources and dates tied to actual evidence. Use the real review date, not a template date. Do not claim proposed workflows are tested implementations.

### Suggested page shape

1. Short title, one-line purpose, and a compact mode/evidence label.
2. Main visual answering the central question.
3. One stepper and a short selected-state panel when interaction helps.
4. Only necessary guardrails or supporting visuals; collapsed assumptions, references, and open decisions.

For a simple question, fewer sections are better. Avoid expanding scope just to fill a template.

## 5. Serve and validate in the browser

For every created or updated HTML explanation, serve it over HTTP and use the browser tool to open and validate the served URL. Do not open the HTML directly with `file://`, a file-preview tool, or an OS file opener as a substitute.

### Required serving and browser workflow

1. Reuse an existing local static server only after verifying that it serves the intended documentation directory. Otherwise start a background static server scoped to the smallest directory containing the HTML and its required assets, for example `python3 -m http.server <available-port> --bind 127.0.0.1 --directory <docs-directory>`. Do not serve the workspace root or expose secrets, and do not stop or replace unrelated services to free a port.
2. Verify that the actual HTML URL responds successfully. Use the browser tool to navigate to that HTTP URL with an explicit tab ID, then inspect the rendered page and exercise its controls. Discover the available browser tools rather than assuming their names. If the browser runs on another machine, use the environment's supported forwarding/reachable URL; do not assume its localhost is the server's localhost or expose the server publicly without authorization.
3. Keep the server running for the user's review and report the served URL and server lifecycle details available from the tool (such as the background task ID). Lead delivery with the served URL; include the source HTML path separately. Do not claim the URL remains available after the server or session stops.
4. Active permission and Plan-mode restrictions still apply. If starting a server or using the browser tool is prohibited or unavailable, report the blocker and mark browser validation incomplete. Do not silently fall back to direct-file opening or claim structural checks satisfy browser review. Discussion-only requests and skill-text edits do not require creating or serving an HTML artifact.

Check the following, reporting any checks that cannot be completed:

- HTML nesting, unique IDs, internal anchors, relative source links, and JavaScript syntax.
- Walkthrough next/restart, all selectable stages, and any branching interactions.
- Copy success and failure/fallback paths when a copy action is present; it must copy the displayed stage, not stale text.
- Offline font references and license when bundled; no broken asset paths or false standalone/offline claims.
- Use the browser tool on the served HTTP page to inspect desktop and mobile rendering, overflow, focus, and console errors. Review print styling when practical.
- For mobile previews, check the full device chassis, aspect ratio, fit after resizing, and removal of simulated chrome on narrow screens. Follow the companion's short-height and zoom checks where feasible.
- For dashboard reviews, check direct page links, active navigation, shared-state preservation during pending work, explicit reset, persistent controls, and independent scrolling. Check desktop/short-height and narrow-screen bounds, plus drawer keyboard focus, Escape, and focus return. Do not claim real-device or browser-zoom verification from embedded viewport tests alone.
- Confirm diagram semantics against the evidence/model: transition order, conditions, scope, timing, and claimed results.
- Confirm no secrets or accidental backend/network actions.

Do not claim browser/rendering validation if only structural or simulated DOM tests ran. Do not call a documentation simulation an end-to-end product test.

## 6. Deliver concisely

Lead with the served HTTP URL opened through the browser tool, then include the source HTML file link. Mention the important visual features, what was actually validated, and how long the preview is expected to remain available. If serving or browser access was blocked, lead with the source file link and explicitly state that the required browser review is incomplete. Clearly state remaining assumptions or validation limits only when material.

## Example requests

- “Visually explain our planned offline sync.”
- “Show what happens when a guest opens a shared link.”
- “Compare current storage with the proposed migration.”
- “Make an interactive HTML to understand these architecture options.”
- “More diagrams, less text.” → simplify prose and improve diagrams; do not append more explanation.

## Verification

- Verify that diagrams distinguish observed behavior, proposals, and assumptions.
- Verify that the HTML is served over HTTP and opened with the browser tool, not directly as a file. Check diagram readability, interactions, and responsive layout on that served page; report serving/browser blockers explicitly.
- Confirm that the explanation is self-contained and that implementation claims match inspected evidence.
- Check the minimal visual standard: one focal diagram, short copy, restrained pastel fills, consistent typography, no duplicate stage controls, and no unnecessary nested cards.
- Verify visible focus, narrow-screen reflow, readable contrast, and reduced-motion behavior when tooling permits; otherwise state the validation limits.
- Where applicable, verify realistic mobile framing and viewport fitting, or the dashboard shell's persistent navigation, shared controls, state preservation, and narrow-screen drawer. Do not add a dashboard to an otherwise compact explanation just to satisfy this checklist.
