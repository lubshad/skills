---
name: github-actions-deployment
description: Use when configuring or explaining GitHub build/release/deployment workflows, promotion helpers, environment files, or direct/tunnel SSH.
---

# GitHub Deployments

Read [the deployment contract](DEPLOYMENT-CONTRACT.md) before workflow/promotion/credential changes. It owns exact target rules, GitHub env serialization, SSH verification, platform templates, and exceptions. Read the matching platform deployment adapter and `project-connections.md` for actual targets.

## Invariants

- Verify actual Git root; workflows belong in the deployable repo, not Bench. Finite timeout, least privilege, guarded manual refs, and non-overlapping release concurrency.
- Preserve each app's approved target interface. Dual environments have isolated credentials/config/backup refs and expected-OID leases. A missing value fails before host contact; no cross-environment fallback.
- Environment-scoped secrets/variables provide isolation; a workflow environment label does not isolate repository-wide secrets. Preserve unrelated entries; write-only secrets need authorized source material, never guessed/reused values. Code changes alone authorize no GitHub mutations or deployment.
- Build in CI with the exact declared package-manager version; deploy artifacts except platform-approved remote/source builds. Generate needed env files from selected GitHub configuration, validate before build/SSH, serialize safely, keep private, atomically install before restart, and clean on every exit. Never expose secrets in public build variables.
- Use verified host keys/strict checking, step-scoped private keys, and the correct direct or Cloudflare SSH transport for both SSH/rsync. Bound operations and verify local plus public health.
- Separate nginx/TLS/boot provisioning from routine release. New long-running services are deployment-user-owned under resolved remote `$HOME`; preserve approved legacy/server-managed exceptions.
- New Flutter Utils mobile pipelines include `flutter-app-release-gates.md`; upload success is not store availability or authorization for mandatory policy.

## Verification

Use the contract's offline YAML/script, disposable-remote lease/branch, env-generation, build, and platform checks. Publishing, retention, promotion, deployment, and live health are distinct outcomes. Never push real release refs as routine verification.
