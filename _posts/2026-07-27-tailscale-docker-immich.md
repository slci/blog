---
layout: post
title: "Docker on Tailscale: when LAN works and the phone does not"
date: 2026-07-27
tags: [tailscale, docker, ufw, networking, immich]
excerpt: >-
  Immich was fine on the home network. From the phone over Tailscale it was
  dead. The hole was ufw-docker: it trusts 192.168.x and quietly drops
  Tailscale's 100.64.0.0/10 range after DNAT into the container.
---

## Introduction

I wanted Immich on a home Linux box, reachable from the phone when I was away, without putting port 2283 on the public internet. Tailscale was already on the machine. Immich ran in Docker with the usual publish:

```yaml
ports:
  - "2283:2283"
```

The app speaks plain HTTP. That sounds wrong until you remember what Tailscale is: a WireGuard mesh between *your* devices. Packets between phone and host are already encrypted on the wire. The browser or Immich app may show `http://`, but that HTTP rides inside the tunnel. Random hosts on the internet never see port 2283 unless you also enable Funnel, open a router forward, or bind the service on a public interface and leave it open.

So is plain HTTP on the tailnet "safe"? Safe enough for a home lab if you trust the model: only enrolled nodes join the mesh, ACLs can restrict who talks to what, and you are not advertising the port to the world. It is not a substitute for app-level HTTPS when the service must be public, shared with untrusted clients, or when you need browser security features that assume TLS end-to-end. For a private photo library between my own phone and my own server, HTTP over Tailscale is a deliberate trade: less cert plumbing, still encrypted in transit between peers.

(I also set the box up as an exit node. That is a separate concern from opening Immich; it needs IP forwarding and, with UFW, forward rules between `tailscale0` and the uplink. It does not fix Docker published ports.)

## Problem

On the LAN, `http://192.168.x.x:2283` worked. From the phone, `http://100.x.x.x:2283` did not. `tailscale ping` to the host worked. ACLs were open. Curl on the host to its own Tailscale address returned 200. Immich was fine; the path from a remote tailnet peer into the container was not.

Out of the box, "Docker + published port + Tailscale" looks like it should just work. On a host that also runs UFW with the common ufw-docker rules, it often does not.

![LAN reaches Immich; Tailscale is dropped in DOCKER-USER]({{ '/assets/images/tailscale-docker-docker-user.svg' | relative_url }})

*Two sources, same container. After DNAT the destination is `172.18.x`. LAN is in the allow list. Tailscale CGNAT is not.*

## Troubleshooting

Reuse this split when any service is up locally and dead over the overlay:

1. **Prove the process.** On the host: `curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:2283/`. If that fails, stop blaming Tailscale.
2. **Prove the mesh.** `tailscale ping <peer>` and status both online. If ping dies, fix connectivity first.
3. **Prove host reachability on the Tailscale IP.** From the host: `curl http://100.x.x.x:2283/`. From another tailnet node if you have one. Success here and failure only from the phone narrows the path; failure from every peer points at host firewall or Docker.
4. **Watch the firewall counters while the client retries.** On hosts with ufw-docker:

```bash
sudo iptables -L DOCKER-USER -n -v
```

The smoking gun was packets climbing on `ufw-docker-logging-deny` for destination `172.16.0.0/12` while the phone kept trying. LAN sources never hit that rule.

What those rules mean: ufw-docker rewires `DOCKER-USER` so published containers are not open to the whole internet. Typical IPv4 shape:

```text
RETURN   from 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
DENY NEW to those private nets (after DNAT into the bridge)
```

| Source | Result |
|--------|--------|
| `192.168.x.x` (LAN) | RETURN, allowed |
| `100.x.x.x` (Tailscale CGNAT) | Not in the list → DENY to `172.18.x` |
| Random internet | DENY (intended) |

Tailscale peers use **`100.64.0.0/10`**. That is not RFC1918, so ufw-docker treats them like untrusted internet. Opening the port on UFW INPUT alone is not enough; published Docker traffic often goes through forward and `DOCKER-USER`.

Also check that a reload actually applied. If `ufw reload` prints `Firewall not enabled (skipping reload)`, the file on disk can look correct while the live chain is still the old one.

## Solution

Allow Tailscale sources in `DOCKER-USER`, then make sure the live rules match the files.

**IPv4** (`/etc/ufw/after.rules`), after the RFC1918 RETURN lines and before the deny lines:

```text
-A DOCKER-USER -j RETURN -s 100.64.0.0/10
```

**IPv6** (`/etc/ufw/after6.rules`), not in the IPv4 file (a `/48` there breaks `iptables-restore` with `invalid mask '48'`):

```text
-A DOCKER-USER -j RETURN -s fd7a:115c:a1e0::/48
```

INPUT rules for clarity (still useful):

```bash
sudo ufw allow from 100.64.0.0/10 to any port 2283 proto tcp
sudo ufw allow from fd7a:115c:a1e0::/48 to any port 2283 proto tcp
```

Apply and verify the *live* chain:

```bash
sudo ufw --force enable   # if reload was previously skipped
sudo ufw reload
sudo iptables -L DOCKER-USER -n -v
```

You want a line like `RETURN ... 100.64.0.0/10`. If the file has it and the chain does not, inject for an immediate test:

```bash
sudo iptables -I DOCKER-USER -s 100.64.0.0/10 -j RETURN
```

Then on the phone: `http://<tailscale-ip>:2283` or MagicDNS, with `http://` (not accidental `https://`).

Optional: `tailscale serve --bg --http=80 http://127.0.0.1:2283` gives `http://hostname.tailnet.ts.net` on the tailnet only (not Funnel). Direct `:2283` is enough once CGNAT is allowed.

Tailscale does not unbind `0.0.0.0:2283` from the LAN. If you want Immich only on the mesh, publish as `"100.x.x.x:2283:2283"`.

The short version: ufw-docker trusts home ranges and drops everything else into the container network. Add `100.64.0.0/10` (and the Tailscale IPv6 ULA), reload for real, and the Docker service becomes a normal tailnet endpoint without opening it to the world.
