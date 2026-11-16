# Cloudflare Tunnel SSH

Read when a deployment's SSH endpoint is behind Cloudflare Tunnel, or CI fails
at direct `ssh-keyscan` for such an endpoint. This is SSH transport guidance,
not permission to deploy, edit Access policies, or update other environments.
Use `project-connections.md` for project hosts, users, and runtime paths.

## Configure the runner

1. Confirm the existing connection uses
   `ProxyCommand cloudflared access ssh --hostname %h`. An HTTPS hostname does
   not imply its port 22 accepts raw SSH; identify the actual SSH tunnel host.
2. Install cloudflared before the first SSH connection. Pin the release and
   verify its download against a trusted SHA-256 digest; add its directory to
   `GITHUB_PATH` for later steps. Keep download and connection timeouts finite.
3. Obtain the server's public host key through an already trusted, strictly
   checked SSH connection or the operator's trusted server console. Track it
   in the application repository, for example `.github/ssh_known_hosts.production`.
   Record only the public host key. Verify replacements through the same trust
   process rather than accepting a changed key automatically.
4. Generate one SSH configuration shared by every SSH and rsync invocation.
   Keep the deployment private key in the selected environment's GitHub Secret,
   write it with mode 600, and remove generated credentials on success or failure.

Example configuration (replace placeholders with the selected target):

```sshconfig
Host app-production
  HostName <ssh-tunnel-host>
  User <deployment-user>
  Port 22
  ProxyCommand cloudflared access ssh --hostname %h
  HostKeyAlias app-production
  UserKnownHostsFile <runner-known-hosts-file>
  StrictHostKeyChecking yes
  IdentityFile <runner-private-key-file>
  IdentitiesOnly yes
  BatchMode yes
  ConnectTimeout 15
  ServerAliveInterval 15
  ServerAliveCountMax 3
```

The pinned file's entry must match `HostKeyAlias`, for example
`app-production ssh-ed25519 <verified-public-key>`. Copy it to the configured
runner known-hosts path. Use `ssh -F <config> app-production ...` and
`rsync -e "ssh -F <config>" ... app-production:<path>` so both use the proxy.
Retain each environment's existing host, credentials, and transport unless its
change is authorized. Tunnel SSH does not change nginx's loopback app port.

## Access authentication

- Test unattended access with batch mode; a developer's successful browser login
  is not evidence that a fresh GitHub runner can connect.
- If no interactive Access login is required, use the existing SSH deployment
  key through the proxy. Do not invent a service-token requirement.
- If Access authentication is required, obtain an authorized non-interactive
  method supported by the pinned cloudflared version and the tunnel's policy.
  Store service credentials in environment-scoped secrets. Verify that policy
  permits that method; do not bypass Access or weaken SSH host-key checks.

## Verification

- Parse workflow YAML and run `bash -n` on each inline shell script.
- Check cloudflared installation precedes SSH and has a verified download digest.
- Check proxy, alias, and pinned public key match; strict checking stays enabled.
- With permission for a read-only connection, test batch-mode SSH using the pin.
  Do not use migration, restart, or artifact upload as a connection test.
- Separate local connection evidence from a successful GitHub runner connection,
  artifact upload, application restart, and public health verification.
