---
name: project-connections
description: Use when locating connected apps, sites, URLs, reserved ports, environments, or deployment targets.
---

# Project Connections

Read [the connection registry](CONNECTIONS.md) before locating connected applications or using project hosts, ports, environments, or deployment targets. Use its Sites, local URL registry, and relevant project section; it owns all exact values and project exceptions.

## Connection rules

- Browser frontends use their reserved hostname **and** port for runs, previews, manual tests, and automation. No localhost/framework-default/temporary fallback. Verify process ownership before stopping conflicts; otherwise report them. Register new frontends with a unique port before launch.
- Same-hostname local Frappe/frontend routing is the default; COREAXIS LMS's separate admin/student origins explicitly override it. Native apps use assigned devices and configured API endpoints, not browser URLs.
- Read actual environment config instead of hardcoding URLs. Keep HTTP API host, socket base, Frappe namespace, public site, and SSH transport distinct.
- Registry/project release contracts override generic deploy examples: Sync's production-default interface and closed Android testing, Zeronic's development-only hosting, and tenant-neutral LMS mappings grant no extra deployment authority.
- Documented workflow/host configuration is not evidence of provisioning, credentials, deployment, or live health.
- Shared asset helpers resolve relative files/assets against backend config and preserve HTTP(S) URLs. Never put secrets in committed or browser-visible configuration.

## Verification

Check intended-environment resolution, reserved URLs/no port fallback, unique registry ports, correct public/private/asset normalization, and credential boundaries. Update exact connections in the registry, not duplicated skill text.
