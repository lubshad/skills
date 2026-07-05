---
name: pipecat-docker-self-hosting
description: Use when creating, fixing, or explaining self-hosted Docker deployment for Pipecat apps, especially Docker Compose, ngrok/Twilio webhooks, MCP/Frappe URLs, localhost binding, or container port issues.
---

# Pipecat Docker Self-Hosting

Use this skill for Pipecat apps that are deployed with normal Docker or Docker Compose instead of Pipecat Cloud.

## When To Apply

- The user asks whether Pipecat CLI supports self-hosted Docker deployment.
- A Pipecat app runs with `uv run bot.py` locally but cannot be reached through Docker, ngrok, Twilio, or a browser.
- Docker logs show Pipecat/Uvicorn ready, but host `curl`, ngrok, or Twilio cannot connect.
- A containerized Pipecat app must call a local Frappe/MCP endpoint such as `http://xealth.localhost:8000/...`.
- Docker builds are slow because `.venv`, cache folders, or local artifacts are being copied into the image.

## Core Facts

- Pipecat CLI's deploy command targets Pipecat Cloud. For self-hosting, use the generated or custom `Dockerfile` with standard Docker commands.
- Pipecat's runner defaults to `--host localhost`. Inside Docker, that binds only to the container loopback interface and is not reachable through `ports: "7860:7860"`.
- In containers, `localhost` means the container itself, not the developer's Mac/Linux host. Local Frappe/MCP hostnames need explicit routing.
- Never copy a host `.venv` into a Linux image. Build a clean container environment from `pyproject.toml` and `uv.lock`.

## Required Docker Fixes

### Bind Pipecat To All Container Interfaces

In the Dockerfile, run Pipecat with `--host 0.0.0.0`:

```dockerfile
CMD ["uv", "run", "--no-sync", "bot.py", "--host", "0.0.0.0"]
```

Use `--no-sync` only when dependencies are already installed at build time with `uv sync --frozen --no-dev`.

Expected healthy log:

```text
Uvicorn running on http://0.0.0.0:7860
```

If the log says `http://localhost:7860`, Docker port publishing may not work from the host.

### Keep Local Artifacts Out Of The Image

Add `server/.dockerignore` when the Docker build context is `./server`:

```gitignore
.venv
__pycache__
.ruff_cache
*.pyc
*.pyo
.env
```

This prevents slow builds and warnings like:

```text
Ignoring existing virtual environment linked to non-existent Python interpreter
```

### Route Local Frappe/MCP Hostnames Back To The Host

When `.env` uses local Frappe/MCP URLs such as `http://xealth.localhost:8000/...`, add host-gateway mappings in `docker-compose.yml`:

```yaml
services:
  pipecat-app:
    ports:
      - "7860:7860"
    env_file:
      - ./server/.env
    extra_hosts:
      - "xealth.localhost:host-gateway"
```

Add every local Frappe site hostname the container must reach, for example `masar.localhost`, `mcal.localhost`, or `luxeo.localhost`.

On Linux hosts, confirm Docker supports `host-gateway`; otherwise use the host bridge IP.

## Verification Workflow

1. Rebuild after Dockerfile or `.dockerignore` changes:

```bash
docker compose up -d --build
```

2. Confirm the container is running and port is published:

```bash
docker compose ps
docker ps --filter name=<container-name>
```

3. Confirm the host can reach Pipecat before involving ngrok or Twilio:

```bash
curl -i http://localhost:7860/
```

Expected result can be `200 OK` or a redirect such as `307 Temporary Redirect` to `/client/`. Connection refused means the container is stopped, the port is not published, or Pipecat is still bound to container-local `localhost`.

4. Check logs for the bind address and startup errors:

```bash
docker compose logs -f
```

5. Only after local `curl` works, expose the app:

```bash
ngrok http 7860
```

Then point Twilio to the ngrok URL. For Pipecat telephony streams, the websocket route is usually `/ws`, while the root `/` route may return TwiML that points Twilio to `/ws`.

## Diagnosis Cheatsheet

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `ngrok` shows requests but bot logs show nothing | Host cannot reach Docker app | Check `curl http://localhost:7860`, container status, port mapping, and `--host 0.0.0.0` |
| Docker logs show `Uvicorn running on http://localhost:7860` | App bound to loopback inside container | Add `--host 0.0.0.0` to Docker CMD |
| Bot receives Twilio websocket then crashes with `httpx.ConnectError` | Container cannot reach local Frappe/MCP URL | Add `extra_hosts` mapping for the local site hostname |
| Build context is hundreds of MB | `.venv` or caches copied into image | Add `.dockerignore` |
| Container exits with code `137` or `143` after `docker compose up` | User interrupted foreground compose or container was killed | Use `docker compose up -d --build` and inspect logs |

## Safety Notes

- Do not print `docker compose config` casually when `env_file` contains secrets; it expands `.env` values into terminal output.
- Do not commit real `.env` values. Keep `.env.example` updated with required variable names only.
- If secrets were pasted into shared logs, tell the user to rotate API keys and tokens.
- Keep provider names like `GeminiLiveLLMService` and model IDs unchanged when renaming the app; they are service identifiers, not project identity.
