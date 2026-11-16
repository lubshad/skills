---
name: project-scaffolding
description: Use when bootstrapping applications or creating/updating local development launchers and restart scripts.
---

# Project Scaffolding

**Generate, then organize.** Verify installed CLI versions and use official noninteractive generators rather than manual boilerplate:

- Frappe: `bench new-app <app> [--no-git]`, authorized `bench new-site` with required admin/database settings, then site `install-app`.
- Flutter: `flutter create --org <domain> --platforms <list> <app>` (example com.coreaxis/android,ios,web), then `flutter-architecture.md`.
- Next.js: `npx create-next-app@latest <name> --ts --tailwind --eslint --app --src-dir --use-npm --import-alias "@/*"`, then `nextjs-architecture.md`.
- React: Vite `npm create vite@latest <name> -- --template react-ts`, not CRA; install/configure needed lint/Tailwind tooling.

Build the generated template or start its dev server to verify a new scaffold; this exception does not justify running unrelated existing apps.

## Safe local restart

Launchers restart **only their app**, not production or shared services. Canonicalize app paths relative to the script, quote paths, and forward supported arguments through wrappers. Reuse one shared launcher and `exec` the final foreground command.

Verify process identity/cwd and framework lock ownership, including an existing instance on another port. Stored PIDs may be stale; port ownership alone proves nothing. Next.js lock formats vary by installed version (`.next/dev/lock` is one example). Handle parent/child respawn/lock lifetime; no broad node/Next kills, unrelated Flutter daemons/device sessions, or deleting held locks.

Gracefully stop, wait with a bound, and verify exit before replacement. Timeout fails nonzero with PID/app details rather than force-killing or starting duplicates. An unrelated effective-port owner stays running; report conflict, never silently switch ports. Check inspection tools and declared-shell/OS compatibility before cleanup.

Flutter flags/ports/device behavior also follow `flutter-utilities.md`; mobile restart scope is selected app/device. This is local development policy, not production restart authority.

## Verification

Syntax-check declared shells **and run changed launchers**. Test clean/repeated start with new PID, existing different-port/held-lock instance, unrelated port owner, forwarded overrides, missing tools, stale PID, bounded shutdown failure, alternate cwd/spaced paths, and intended responding URL without already-running warnings.
