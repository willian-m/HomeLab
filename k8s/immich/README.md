# Immich

Self-hosted photo/video library. Deployed from the manifests in this folder
(`kustomization.yml`), with secrets via Sealed Secrets and storage on NFS.

## Public access (family sharing)

Immich is reachable over the internet through the shared Cloudflare Tunnel so
non-technical family can use it without joining the Tailnet. The tunnel plumbing
(connector, routing, Access, service tokens) is generic and documented in
[`../cloudflared/README.md`](../cloudflared/README.md). This section covers only
the Immich-specific pieces.

- **Route:** the tunnel's `ingress:` sends the Immich hostname (e.g.
  `immich.example.com`) to `immich-server.immich.svc.cluster.local:2283`.
- **Edge auth:** an Access application protects that hostname (One-time PIN for
  browsers; a service token for the mobile app).

### Mobile app setup

Because Access uses an interactive browser login, the Immich app must
authenticate with a service token instead (create/manage tokens with
`../cloudflared/access-token.sh` — see the cloudflared README).

On the Immich app login screen, **before logging in**, tap the **gear icon ->
Custom Proxy Headers** and add:

```
CF-Access-Client-Id      = <Client ID>
CF-Access-Client-Secret  = <Client Secret>
```

Then enter the server URL (`https://immich.example.com`) and log in with the
Immich account. Keep the app updated — custom-header support has had bugs in old
versions.

## Hardening

- **Disable public registration** (Admin -> Settings) and give the admin account
  a strong password. With the app exposed publicly this matters.
- **Family = one Immich user each, with a tiny storage quota** set at user
  creation. The quota is the real "they can't upload" lock (there is no built-in
  read-only role); without it they could fill your disk from their own library.
- **Share albums to them as viewers** (not editors) so they can't modify your
  albums.
- Set **Server Settings -> External Domain** to `https://immich.example.com` so
  shared-link URLs generate correctly.

## Storage / GPU notes

- Photos and DB live on NFS PVCs (see `01-pv.yml` / `02-pvc.yml`).
- `immich-machine-learning` runs on the GPU worker via
  `nodeSelector: nvidia.com/gpu.present: "true"`.
