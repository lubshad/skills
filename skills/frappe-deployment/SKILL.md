---
name: frappe-deployment
description: Use when creating, changing, or explaining GitHub Actions development or production deployment for Frappe apps, including deploy branch promotion and the remote Bench lifecycle.
---

# Frappe Deployment

Use this skill for the Frappe-specific lifecycle inside GitHub Actions development and production deployments and for the `deploy` branch-promotion flow that triggers them.

## When To Apply

- Creating or updating a GitHub Actions workflow that deploys a Frappe app
- Creating or updating a Frappe app's `deploy` helper
- Migrating an existing manual Frappe deployment to GitHub Actions
- Explaining a Frappe production deployment or legacy sync script
- Adjusting remote host, site, SSH key, app path, or migrate/restart flow

## Required Deployment Artifacts

### Dual-environment deployment contract

- For explicitly requested two-environment deployments, including Xealth, `./deploy` promotes to `development` and backs up to `development-backup`; `./deploy --prod` promotes to `production` and backs up to `production-backup`.
- Use `.github/workflows/deploy-development.yml` and `.github/workflows/deploy-production.yml`, with separate environments, credentials, and concurrency groups. Manual retries must reject any ref other than their matching deployment branch.
- The dual-environment reference is `github-actions-deployment/reference/frappe-deploy`. Reject unknown flags, dirty worktrees, detached HEAD, and all four deployment/backup source branches.
- Capture the target and backup OIDs after fetching. Use explicit `--force-with-lease=<ref>:<expected-oid>` for both pushes so a later fetch cannot weaken the target lease. An absent backup uses an empty expected OID; a missing target fails with initialization guidance.
- Back up only the selected target's previous commit. Never initialize or push release branches as routine verification; initialization can trigger deployment.
- Preserve existing production-only helpers and unrelated target modes unless the user explicitly requests migration. The legacy production-only defaults below apply to those apps, not to Xealth's dual-environment contract.

- Keep `.github/workflows/deploy-production.yml` in the Frappe app's actual Git repository.
- Keep `deploy` in that repository root and make it executable.
- Existing production-only apps use `./deploy` to promote to `production` and back up to `production-backup`; when using the current dual-environment reference, provide both workflows or deliberately adapt it to that app's existing contract.
- Planned interface: `./deploy --internaltest` will promote to `internaltest` after backing up that branch's previous ref to `internaltest-backup`. The flag is not currently implemented; add support only when requested, with a matching workflow and target-specific safety guards, while retaining the default production behavior.
- Use a dedicated remote `production` branch as the deployment trigger.
- Maintain a remote `production-backup` branch containing the production ref that existed before the latest promotion.
- Initialize both remote branches from the intended baseline before the first normal promotion.
- Do not create a new app-level `sync.sh`; production source sync belongs inside the GitHub Actions workflow.

## Current Project Defaults

- Masar backend app path: `apps/masar/`
- Masar remote host/site: `masarbackend.conceptiqs.com`
- Exam remote host/site: `mcalfrappe.coreaxissolutions.in`
- Xealth backend app path: `apps/xealth/`
- Xealth remote host/site: `backend.xealth.ca`
- Common remote bench path: `/home/frappe/frappe-bench`
- Common SSH user: `frappe`
- Local legacy scripts may refer to an SSH key named `personal`; never commit that key or any other private key
- Server setup unlocks the `frappe` account when needed and copies the initial root/login user's `authorized_keys` to `/home/frappe/.ssh/authorized_keys`, so deployment scripts can use `ssh frappe@<host>` after setup.

## Production Promotion

- Start from `.agents/skills/github-actions-deployment/reference/frappe-deploy`.
- Require a clean worktree and a named source branch.
- Refuse promotion from `production` or `production-backup`.
- Fetch and prune `origin` before comparing or updating refs.
- Require `origin/production` so every normal promotion has a recoverable predecessor.
- Back up `origin/production` to `production-backup` before changing production.
- Use `--force-with-lease` for both protected ref updates; never use an unguarded force push.
- Refresh local `production` and `production-backup` refs after successful pushes.
- The helper promotes Git refs only. It must not SSH, rsync, migrate, restart, or duplicate workflow deployment logic.

## Workflow Lifecycle

- Start from `.agents/skills/github-actions-deployment/reference/frappe-production.yml`.
- Check out the pushed target commit and validate all required variables and secrets.
- Configure a temporary step-scoped SSH private key and seed `known_hosts`.
- Validate the remote Bench before syncing.
- Rsync only the app repository into `<bench-dir>/apps/<app-name>` and exclude repository metadata, workflows, local environments, caches, and credential files.
- Install the package with `env/bin/pip install -e apps/<app-name>`.
- Normalize and safely register the app in `sites/apps.txt`; never append with plain `echo` because a missing trailing newline can create malformed app names.
- Run `bench --site <site> install-app <app-name>` only when the app is absent.
- If first-time installation needs Node.js, load NVM when present and add `$HOME/.local/bin` before validating `node` inside that branch only.
- Run `bench --site <site> migrate`, optionally `bench build --app <app-name>`, then `bench restart`.
- Before migration, retain any required backup and migration preflight. On Frappe versions where `bench execute` evaluates `--kwargs` as Python, use Python literals (for example `--kwargs '{"fail_on_duplicates": True}'`), not JSON `true`, `false`, or `null`. Verify the installed CLI parser and validate the literal without contacting a shared site; a parsing failure is not a successful preflight.
- Finish with an HTTPS health check and let failure fail the workflow. For Frappe, check `/api/method/frappe.ping` and require `message=pong` rather than only a successful homepage response.
- Do not add frontend deployment steps unless explicitly requested.

## Building The Paired Development Workflow

- When adding `deploy-development.yml` alongside an existing production workflow, copy the production file rather than writing a fresh workflow, then change only the environment name, concurrency group, branch trigger, `if: github.ref` guard, credential prefix, and user-facing message strings.
- Verify the result with `diff` against the production workflow and confirm every difference is an intentional dev/prod rename. Watch for silent damage while editing: dropping the dot in `$HOME/.nvm/nvm.sh`, and changing a glob comparison `== https://*` into a regex match `=~ https://*`.
- Derive the development host, site, bench directory, Python version, and whether the app is already installed by checking the server directly rather than assuming them; confirm the SSH key authenticates before wiring CI.
- Create the development environment's credentials even when the current server is the one being used for development. Give the new workflow a separate credential prefix so production and development never share a value.
- Require the development site and public URL explicitly instead of defaulting them, so the workflow fails loudly before any SSH when the environment is unconfigured.
- A promotion helper only triggers CI when the promoted commit is new. If the target branch already equals `HEAD`, the push is a no-op; trigger a manual run with `gh workflow run <workflow>.yml --ref <branch>` and confirm the run reaches the health check.

## GitHub Actions Deployment

- Read `github-actions-deployment.md` alongside this skill for workflow triggers, permissions, concurrency, GitHub environments, secrets, SSH setup, and branch promotion.
- Start from `.agents/skills/github-actions-deployment/reference/frappe-production.yml` when adding a standard production deployment.
- Keep the workflow in the Frappe app's actual Git repository under `.github/workflows/`, including when the app is nested inside a Bench checkout.
- Prefer a `production` branch push trigger and a guarded `workflow_dispatch` retry path.
- Use GitHub secrets for SSH host, user, port, and private key. Never commit the private key or expose it as a job-wide environment variable.
- Rsync only the app repository into `<bench-dir>/apps/<app-name>` and exclude `.git`, `.github`, local environments, caches, and credential files.
- Preserve the standard remote lifecycle: editable package install, safe `sites/apps.txt` registration, conditional first-time app installation, migration, optional build, restart, then an HTTPS health check.
- Use `concurrency` with cancellation disabled so production migrations cannot overlap.
- Use a finite timeout and least-privilege `contents: read` permissions.
- Add the standard `deploy` helper with every new Frappe production workflow.

## Legacy Manual Sync

- The shared single-app sync helper has been removed. Zeronic's `sync.sh` exits with migration guidance; use its `deploy` helper for development releases. Other existing app-level `sync.sh` scripts are retained only for legacy maintenance.
- Do not create new wrappers, advertise them as the normal production path, or use them when setting up a new Frappe deployment.
- Do not delete or rewrite an existing legacy sync script unless the user explicitly requests that app's migration or cleanup.
- When asked to explain an existing wrapper, state that GitHub Actions plus `deploy` is the current production standard.

## Dependency Source Of Truth

- Prefer declaring Python runtime dependencies in the app root `pyproject.toml` under `[project].dependencies`
- Do not add or depend on app-level `requirements.txt` for normal Frappe app deploy flow unless the user explicitly needs a separate legacy or external-tooling requirements file
- When updating an existing deploy script that still uses `pip install -r apps/<app>/requirements.txt`, migrate it to `pip install -e apps/<app>` if the app already has modern packaging metadata

## Safety Rules

- Preserve the existing workflow style when updating an established deployment unless it conflicts with the workflow-only standard
- Prefer safer shell behavior over silent failure
- Do not use `|| true` unless the user explicitly wants best-effort behavior
- Fail clearly if required GitHub secrets, remote branches, or Bench directories are missing
- Keep private keys outside Git, including private repositories; add legacy local key filenames to `.gitignore`
- For freshly provisioned hosts, expect direct `frappe` SSH access to work after `apps/xealth/setup_server.sh` or `.agents/scripts/setup_frappe_server.sh` has completed. If it does not, check whether the account is locked and then check `/home/frappe/.ssh/authorized_keys` ownership and permissions before changing deploy flow.
- Avoid destructive remote commands beyond the intended deploy flow

## Masar-Specific Notes

- `apps/masar/sync.sh` is a legacy backend-only deployment path; do not extend it or include `masarnext` in it.

## Environment-Scoped Credentials

- Store each environment's credentials as **environment-scoped** secrets and variables, not repository-scoped. `gh secret set <NAME> --env <environment>` and `gh variable set <NAME> --env <environment>`; list and delete with the same `--env` flag.
- Repository-scoped secrets are readable by every workflow in the repository regardless of its declared `environment`. A workflow declaring `environment: production` can still read a development secret. Environment scope is what prevents a production deployment from receiving development credentials.
- Migrate by copying each value into the target environment first, verifying a deployment run succeeds against the environment-scoped copy, and only then deleting the repository-scoped duplicate. Delete the duplicate last so the repository is never left with no copy of a working credential.
- GitHub secrets are write-only and cannot be read back through the API. Migrating a private key requires the original key material from the operator. Never substitute another environment's key or guess a value; fail and ask instead. Upload key material by piping a local file, never by echoing or printing it.
- Keep production credentials in the `production` environment only, and development credentials in `development` only. Never give both environments a fallback to the other's variables.

### Plan-gated protection rules

- Environment protection rules are billing-plan dependent. On a plan without them, required reviewers, wait timers, and custom deployment branch policies fail with HTTP 422 stating the plan does not support the rule, and branch-policy creation returns 404.
- Do not claim an environment is protected when the rule was rejected. Verify with `gh api repos/<owner>/<repo>/environments` and check that `protection_rules` is non-empty.
- When protection rules are unavailable, keep branch restrictions in the workflow with `if: github.ref == 'refs/heads/<branch>'`, validate configuration at the start of the job so missing credentials fail before any SSH or rsync, and tell the user which platform-level gates are missing rather than implying the environment is protected.

## Sync Dating-Specific Notes

- App repository: `apps/sync_dating/`, GitHub repository: `lubshad/sync-dating`; its promotion helper uses the existing `upstream` remote rather than adding or renaming `origin`.
- The current host `sync-backend.coreaxissolutions.in` is the **development** target, not production. Bench: `/home/frappe/frappe-bench`; SSH user: `frappe`; SSH key: the local bench-root `personal` key, shared with other apps and uploaded to GitHub through a pipe.
- Development uses the `development` environment with `FRAPPE_DEV_*` credentials and the `development` branch. When a real production host is provisioned, `FRAPPE_*` must be repointed at it inside the `production` environment, and `FRAPPE_DEV_*` must stay on the current host.
- `deploy-production.yml` deliberately has no host or site fallbacks. Do not reintroduce them: a hardcoded fallback to the development host would let a production promotion deploy to development silently. Production `FRAPPE_SITE` and `FRAPPE_PUBLIC_URL` are required at validation time.
- The user has explicitly enabled asset builds: set the repository variable `FRAPPE_RUN_BUILD` to `true` and keep this app's workflow fallback at `true`. Run `bench build --app sync_dating` after migration and before restart, loading NVM when present. An explicit `false` variable may disable the build; do not silently revert the default to `false`.
- Keep this build default specific to Sync Dating; other apps retain their configured build policy.
- Verify public HTTPS using `/api/method/frappe.ping` and require `message=pong`, not a successful homepage response.
- Both workflows keep identical hardening; only the environment name, concurrency group, branch guard, credential prefix, and message strings differ. When changing one, diff against the other and confirm every difference is an intended dev/prod rename.
- `./deploy` only triggers CI when the promoted commit is new. When `development` already equals `HEAD`, the push is a no-op; trigger the run with `gh workflow run deploy-development.yml --ref development` instead.

## Xealth-Specific Notes

- Xealth uses `./deploy` for development (`backend-dev.xealth.ca`) and `./deploy --prod` for production (`backend.xealth.ca`); `goproduction` is renamed to `deploy`, and `--dev` is not supported.
- Development repository variables: `XEALTH_DEV_DEPLOY_HOST`, `XEALTH_DEV_DEPLOY_USER`, optional `XEALTH_DEV_DEPLOY_PORT` (22), `XEALTH_DEV_BENCH_DIR`, `XEALTH_DEV_SITE`, and absolute HTTPS `XEALTH_DEV_PUBLIC_URL`. Its separate SSH key secret is `XEALTH_DEV_DEPLOY_KEY`.
- Keep existing production `XEALTH_DEPLOY_HOST`, `XEALTH_DEPLOY_USER`, `XEALTH_DEPLOY_KEY`, and optional `XEALTH_DEPLOY_PORT` secrets unchanged. Do not guess a development key or reuse production credentials without verifying authorization; upload private key material securely without printing or committing it.
- Move both environments' credentials to environment scope and leave `XEALTH_DEPLOY_*` pointing only at the `production` environment.
- Development health verification uses `/api/method/frappe.ping` and requires `message=pong`. Servers/sites are provisioned separately; the promotion helper must not SSH or provision them.

- `apps/xealth/setup_server.sh` is a local server-provisioning wrapper, not just an app deploy script.
- Xealth setup must preserve direct `frappe` SSH access by unlocking the account if needed and copying the root/login user's `authorized_keys` to `/home/frappe/.ssh/authorized_keys` during provisioning.
- The Xealth GitHub repo is private; do not rely on remote `bench get-app git@github.com:pentaverse-sa/xealth-backend.git` unless the server has explicit GitHub SSH credentials for the bench user.
- For initial Xealth setup, provision the server/site first, then create a new remote `xealth` app with `bench new-app xealth --no-git` only if `/home/frappe/frappe-bench/apps/xealth` is missing. Do not clone from GitHub or rsync the local checkout as part of server setup.
- After app creation is skipped or completed, install it with `env/bin/pip install -e apps/xealth` only when the package is not already visible to pip, install the app on the site if not already installed, start/reload Bench Redis supervisor services, and run migrate/restart only when package or site app installation changed state.
- Finish Xealth setup by enabling/starting supervisor and nginx, validating/reloading nginx, setting up SSL with Bench/certbot unless `--skip-ssl` is passed, and checking the site through nginx with `Host: backend.xealth.ca` and HTTPS. The SSL step should skip only when both certificate files exist and the bench nginx config already references the certificate; otherwise pipe `y` into `bench setup lets-encrypt` so Bench can overwrite its generated nginx config after cert issuance. Prefer `--ssl-email EMAIL` for Let's Encrypt registration.
- Xealth setup must ensure `/home/frappe/frappe-bench/config/supervisor.conf` is linked into `/etc/supervisor/conf.d/frappe-bench.conf` before `supervisorctl reread/update`; otherwise Bench Redis and worker programs are not loaded even when `supervisor` itself is active.
- Keep reruns idempotent: if `/home/frappe/frappe-bench/apps/xealth` already exists, skip app creation but still check package/site installation status. For future deploy/setup actions, add remote existence or status checks before mutating server state.

## Masar and MCAL-Specific Notes

- `apps/masar/` is a dual-environment app using the `upstream` remote: development deploys from the `development` branch and production from the `production` branch.
- Masar development currently reads `MASAR_BACKEND_SSH_*` and `MASAR_BACKEND_BENCH_DIR`/`RUN_BUILD`, which have no environment marker, while production reads `MASAR_BACKEND_PROD_*`. The missing `DEV` suffix in the development names is an inconsistency: add `MASAR_BACKEND_DEV_*` when normalizing so dev and prod names are visibly distinct, and keep the production `MASAR_BACKEND_PROD_*` names working throughout the migration.
- Masar development hardcodes `https://masarbackend.conceptiqs.com` in the workflow `environment.url`. Move it to a variable so the deployed target is configuration, not code.
- `apps/lms_custom/` deploys through the reusable `deploy-mcal-reusable.yml`, parameterized by an `inputs.target` of `development` or `production`. Its environments are named `development-mcal` and `production-mcal`; keep the `-mcal` suffix when normalizing to avoid colliding with another app's environments in the same repository.
- `deploy-mcal-reusable.yml` uses one shared `MCAL_SSH_PRIVATE_KEY` and `MCAL_SSH_USER` for both targets, and hardcodes the development host, site, bench directory, and public URL inline with a conditional fallback to `MCAL_PROD_*`. Separate the development credentials from the production ones and move all host values into environment-scoped variables before treating the two targets as isolated.
- When `inputs.target` selects a target, validate that the resolved environment and branch match the target before any SSH or rsync step, so a mismatched dispatch fails before contacting a host.

## Verification

- Validate workflow and promotion scripts without pushing `production` or contacting the production host as routine verification.
- Run `bash -n deploy` and verify its clean-worktree and branch guards.
- Verify application package state, site installation, migrations, worker services, and nginx status.
- Verify the target site responds through its intended host and HTTPS configuration.
- Parse or lint GitHub workflow YAML and verify every secret and variable is documented.
- Confirm every environment's credentials are environment-scoped, and confirm no environment still depends on a repository-scoped secret or variable.
- Confirm the environment's `protection_rules` are actually populated; when plan-gated rules were rejected, report the missing gate instead of claiming protection.
- Diff a paired development and production workflow and confirm every difference is an intended rename rather than an accidental edit.
- Confirm no private-key files are tracked or included by rsync.
- Confirm no updated guidance recommends creating or using `sync.sh` as the standard production path.
- After fixing a failed deployment workflow, trigger a new development run at the corrected commit rather than rerunning the old commit. Verify migration, restart, and health before unblocking dependent releases. Preserve historical failed-run evidence, record the successful superseding SHA/run, and reconcile all dependent pending releases without repeating version bumps or deploying unrelated changes.
