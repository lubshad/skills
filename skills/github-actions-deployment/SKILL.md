---
name: github-actions-deployment
description: Use when changing GitHub Actions workflows for builds, releases, deployments, or nested-repo deployment flows.
---

# GitHub Actions Deployment

Use this skill when creating or updating GitHub Actions workflows that build, release, or deploy code from this bench or its nested repositories.

## When To Apply

- Adding or editing workflow files under `.github/workflows/`
- Setting up CI/CD for `masarnext` or another deployable project in this workspace
- Creating branch-promotion scripts that trigger GitHub Actions deployments
- Explaining how a GitHub Actions deployment flow should work in this repo

## Repo Boundary Rule

- Identify the actual Git repository before adding a workflow
- If the target project is a nested repo, place `.github/workflows/` inside that nested repo, not at the bench root
- For `next_apps/masarnext`, treat `next_apps/masarnext/` as the Git repo root unless repo inspection shows otherwise

## Workflow Pattern

- Prefer `on.push.branches` for deployment branches and add `workflow_dispatch` for manual retries
- Scope deploy workflows with `paths` filters so unrelated changes do not trigger production deploys
- Use `concurrency` for production deploys to prevent overlapping releases
- Use GitHub `environment` for production workflows when the deploy has a stable public URL
- Fail fast on missing required secrets before the deploy step starts

## Deployment Rules

- Build in GitHub Actions, not on a developer machine
- Deploy built artifacts, not an unbuilt source tree, unless the platform explicitly requires remote builds
- Prefer `actions/setup-node` with the project’s required Node version and npm cache
- For standalone Next.js deploys, sync only runtime artifacts such as `.next/standalone`, `.next/static`, `public/`, and the runtime launcher
- Keep production environment values server-managed unless the user explicitly asks for a GitHub-managed env strategy
- Do not copy repo `.env.production` to the server when the chosen contract is server-managed env

## SSH Deploy Rules

- Read SSH host, user, key, and optional port from GitHub Secrets
- Write the private key to a temporary file in the runner and lock its permissions
- Seed `known_hosts` with `ssh-keyscan` before `ssh` or `rsync`
- Verify required remote directories and runtime prerequisites before syncing files
- Restart the process manager only after a successful artifact sync
- Run a local remote health check after restart so the workflow fails on a broken deployment

## MasarNext Defaults

- Deployment branch: `production`
- Promotion helper: `next_apps/masarnext/goproduction`
- Workflow location: `next_apps/masarnext/.github/workflows/`
- Host: `masardevelopment.conceptiqs.com`
- Remote dir: `/var/www/masarnext`
- PM2 app: `masarnext`
- Runtime bind: `127.0.0.1:3000`
- Production env file stays on the server at `/var/www/masarnext/.env.production`

## Coordination

- Use `nextjs-deployment.md` together with this skill for `masarnext` deployment work
- Use `app-connections.md` when hostnames, site URLs, or backend/frontend mappings matter
- If a deploy flow also changes backend deploy behavior, read `frappe-deployment.md` separately rather than mixing the two models
