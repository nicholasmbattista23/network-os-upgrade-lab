# Network OS Upgrade Program

Version-controlled engineering assets for a network operating-system upgrade program and related management-platform rebuild work.

## Purpose

This repository holds reusable configuration, scripts, sanitized manifests, workflows, decision records, and lab validation evidence. It is intentionally separated from live inventory, customer data, credentials, vendor binaries, and production exports.

## Storage boundaries

| Location | Content |
|---|---|
| This repository | Configuration, scripts, templates, sanitized workflows, lab evidence, and decision records |
| Private planning system | Live inventory, punch lists, editable planning sheets, and diagrams |
| Internal HTTP repository | Vendor software images, checksums, release documents, and production staging artifacts |

Never commit vendor software, credentials, private keys, license files, certificates containing private keys, production device backups, public-routable production addressing, or unsanitized customer data.

Lab evidence intended for public viewing uses placeholders or documentation address space rather than live internal addresses.

## Repository layout

- `docs/` — architecture, operating workflow, deployment SOP, validation evidence, and decision records
- `repository-server/` — Nginx configuration, build/validation scripts, and manifest templates
- `network-devices/` — vendor-specific staging notes
- `mcp-platform/` — management-platform rebuild prerequisites, package manifest, migration workflow, and validation

## Current proof of concept

The repository-server POC has validated:

- Debian 13 guest VM
- Nginx HTTP service on TCP/80
- Read-only GET and HEAD behavior
- Rejected PUT requests
- Platform-oriented directory layout under `/srv/network-os`
- 512 MiB cross-network download
- Matching SHA-256 checksum after transfer
- HTTP access and operational transfer logging
- HTTP byte-range support
- Real network-device HTTP retrieval with matching source/device SHA-256

See the [deployment and operations SOP](docs/deployment-sop.md), [POC validation record](docs/poc-validation-2026-09-16.md), and [sanitized lab test output](docs/lab-test-output-2026-09-25.md).

## Quick start

On a clean Debian server:

```bash
sudo apt update
sudo apt install -y nginx curl
sudo ./repository-server/scripts/build-repository.sh
sudo cp repository-server/nginx/network-os-repo.conf \
  /etc/nginx/sites-available/network-os-repo
sudo cp repository-server/nginx/network-os-logging.conf \
  /etc/nginx/conf.d/network-os-logging.conf
sudo ln -s /etc/nginx/sites-available/network-os-repo \
  /etc/nginx/sites-enabled/network-os-repo
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl enable --now nginx
./repository-server/scripts/validate-repository.sh
```

## Version qualification rule

A target is not qualified merely because it is the newest release. Record and approve the exact platform, software release, installation path, required intermediate releases, dependencies, and rollback method before staging.
