---
name: project-scaffolding
description: Use when creating, initializing, or bootstrapping applications, or creating and updating local development run scripts and restart launchers for Frappe, Flutter, Next.js, React, or other frameworks.
---

# Project Scaffolding & App Generation

Use this skill when starting a new application, bootstrapping a project, or initializing a codebase for Frappe, Flutter, Next.js, React, or other major frameworks. Always prefer using the official CLI tools rather than manual file creation.

## Platform Standards

### 1. Frappe Framework
When starting a new Frappe application, always use the Bench CLI tool:

*   **Create a new app:**
    ```bash
    bench new-app <app_name>
    ```
    Use `--no-git` if you do not want to initialize a git repository inside the app folder (useful for setups where the whole bench is managed differently or when nesting repos):
    ```bash
    bench new-app <app_name> --no-git
    ```
*   **Create a new site:**
    ```bash
    bench new-site <site_name> --admin-password '<password>' --mariadb-root-password '<db_password>'
    ```
*   **Install app on a site:**
    ```bash
    bench --site <site_name> install-app <app_name>
    ```

### 2. Flutter
When initializing a new Flutter application:

*   **Scaffold the project:**
    ```bash
    flutter create --org <org_domain> --platforms <comma_separated_platforms> <app_name>
    ```
    Example for mobile and web:
    ```bash
    flutter create --org com.coreaxis --platforms android,ios,web my_app
    ```
*   **Architecture Setup:** Immediately after generation, organize the code according to the feature-first modular structure specified in `flutter-architecture.md`.

### 3. Next.js
When initializing a Next.js application, use the official `create-next-app` CLI:

*   **Scaffold the project:**
    ```bash
    npx create-next-app@latest <project_name> --ts --tailwind --eslint --app --src-dir --use-npm --import-alias "@/*"
    ```
*   **Structure:** Organize the codebase using the App Router structure specified in `nextjs-architecture.md`.

### 4. React (Vite-backed)
Prefer Vite over standard Create React App (CRA) for modern React frontends:

*   **Scaffold with TypeScript:**
    ```bash
    npm create vite@latest <project_name> -- --template react-ts
    ```
*   Install dependencies and initialize standard configs (ESLint, Tailwind, etc.) if required.

## Guidelines & Best Practices

1.  **Always use CLI tools:** Never create project files manually from scratch when a generator/CLI is available. This ensures standard configuration, build setups, linter profiles, and dependencies are correctly initialized.
2.  **Environment Check:** Verify CLI tools are installed (e.g., run `flutter --version`, `bench --version`, or `npm --version`) before executing generation commands.
3.  **Non-Interactive Execution:** Since interactive prompts can cause hangs in automated environments, always supply flags/arguments to make CLI commands run non-interactively (e.g., `-y`, `--no-git`, or pre-configured flags for `create-next-app`).
4.  **Verification:** Immediately build the generated template or start the dev server to ensure the scaffold works successfully.

## Local Run Scripts

Apply these rules when creating or updating local development launchers such as `run_<app>.sh`, project `run.sh`, or package dev scripts. This is not a production restart or deployment policy.

- Re-running a launcher should stop the existing development instance for that same app, wait for it to exit, and then start a fresh instance. Do not merely report "already running" or silently select a different port.
- Resolve the canonical app directory relative to the script, not the caller's working directory. Quote paths and preserve supported user arguments through every wrapper to the underlying command.
- Identify the app's processes by framework lock ownership or validated process identity and canonical working directory. Port ownership alone is not proof that a process belongs to the app. Validate stored PIDs against the live process before signaling them; stale PID files may refer to unrelated processes.
- Discover the existing app instance even when it uses a different port. For Next.js, inspect the installed version's development lock mechanism, such as the owner of `.next/dev/lock`, and confirm the owner is a Next dev process for this app. Do not assume all Next versions use the same lock metadata format.
- Handle the app's launcher/child process lifecycle so an old parent cannot keep the lock or respawn the server. Never use broad commands such as `pkill node`, kill every Next process, or stop unrelated apps, shared Bench services, or production previews.
- Send a graceful termination signal, wait with a bounded timeout, and verify shutdown before starting again. If shutdown fails, exit nonzero with a clear PID/app message instead of starting a duplicate or automatically force-killing it. Do not delete an actively held lock to bypass framework protection.
- If the requested port is still occupied by an unrelated process, leave it running and fail with a clear explanation. Port checks must use the effective port after parsing supported overrides, not only the default port.
- Keep restart logic in one shared launcher. Root wrappers and package commands should delegate to it rather than duplicate process cleanup. Use `exec` for the final foreground command so signals and exit status propagate correctly.
- Check required process-inspection tools before doing cleanup. Use syntax compatible with the declared shell and host OS; do not assume macOS `/bin/sh` or Bash has GNU/Linux utilities or newer Bash features.
- For Flutter run flags, explicit web ports, and device selection, also read `flutter-utilities.md`. Mobile launchers should scope restart behavior to the selected app/device session, not kill shared Flutter daemons or unrelated device sessions.

## Verification

- Run syntax checks using each script's declared shell, then execute the actual launcher; syntax-only checks do not prove process cleanup works.
- Verify a clean start and a second invocation that stops and replaces the first instance with a new PID.
- Verify restarting this app when its existing dev server uses a different port or still owns its framework lock.
- Verify an unrelated process on the requested port is not stopped, and supported port/device/other arguments reach the underlying command unchanged.
- Check missing dependencies, stale process information, and shutdown timeout handling; failures must be clear and must not start duplicate instances.
- Confirm launching from a different directory works, paths with spaces remain quoted, and the final server responds at the intended URL without an "already running" warning.
