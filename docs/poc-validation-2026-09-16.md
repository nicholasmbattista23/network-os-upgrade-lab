# Repository Server POC Validation — 2026-09-16

## Test platform

- Operating system: Debian GNU/Linux 13 (trixie)
- Virtualization: KVM guest
- Web server: Nginx
- Repository root: `/srv/network-os`
- Transport: HTTP on TCP/80
- Intended source network: management-routed networks

## Results

| Test | Expected | Result |
|---|---|---|
| HTTP directory index | Vendor and manifest directories visible | PASS |
| Local GET | HTTP 200 | PASS |
| Cross-network GET | HTTP 200 | PASS |
| HEAD request | HTTP 200 with correct content length | PASS |
| Upload attempt | PUT rejected | PASS — HTTP 403 |
| Representative transfer | 512 MiB file downloads successfully | PASS |
| Integrity | Downloaded SHA-256 matches source | PASS |
| Access logging | Client, object, status, and byte count recorded | PASS |
| Enhanced operational logging | Human-readable REQUEST and successful-transfer records generated for local and remote clients | PASS — 2026-09-25 |
| Network-device HTTP pull | Juniper EX2200 retrieves repository object into `/var/tmp`, repository logs the transfer, and SHA-256 matches source | PASS — 2026-09-25 |
| Byte ranges | Server advertises range support | PASS |
| Listening services | SSH and HTTP only | PASS |
| Repository deploy-key access | Read-only repository-scoped authentication and clone | PASS |
| Tracked/live config parity | No difference between Git and deployed Nginx site | PASS |
| Automated validation | Directory, HEAD, and PUT-rejection checks | PASS |
| Portable configuration | Bundle created and checksum verified | PASS |
| Real vendor package staging | Required vendor package present and entry-point object retrievable by HTTP | PASS — 2026-09-17 |

## Transfer-integrity evidence

- Test object: `repo-test-512M.bin`
- Size: `536870912` bytes
- SHA-256: `9acca8e8c22201155389f65abbf6bc9723edc7384ead80503839f49dcc56d767`
- Observed workstation transfer rate: approximately 31 MiB/s

The test object contains zero-filled synthetic data and is intentionally excluded from Git.

## Portability evidence

- Bundle: `network-os-repo-config-2026-09-16.tar.gz`
- Bundle size: approximately 3.1 KiB
- Contents: deployed Nginx configuration, effective configuration evidence, system baseline, and clean repository directory structure
- Verification: `sha256sum -c` returned `OK`
- Vendor images and the synthetic transfer-test object are intentionally excluded

## Configuration behavior

- Nginx listens without binding to a lab-specific IPv4 address.
- GET and HEAD are allowed.
- Modification methods are denied.
- Directory browsing is enabled for controlled repository use.
- Access and error logs are separated from the default site logs.
- Nginx version disclosure is suppressed.
- The Debian POC pulls version-controlled configuration through a repository-scoped, read-only deploy key.

## Enhanced logging validation — 2026-09-25

The version-controlled enhanced Nginx logging configuration was deployed to the POC and validated with both local and remote HTTP GET requests.

Public-facing evidence uses documentation addresses and generic paths rather than the lab's real RFC1918 addressing. Representative sanitized output is captured in `docs/lab-test-output-2026-09-25.md`.

`TRANSFER_OK` means the repository completed a successful HTTP response; it does not by itself prove that a network device completed or accepted an entire software-download workflow.

## Network-device transfer validation — 2026-09-25

A Juniper EX2200 running Junos 12.3R12-S21 was used as a real network-device HTTP client. The switch successfully reached the repository, retrieved a staged test object with Junos `file copy`, and stored it under `/var/tmp`.

Device-side evidence:

- Destination size: `18708` bytes
- Reported transfer rate: approximately `908 kB/s`
- Device SHA-256: `b1644006948f2ddab3fd6e853bef269611b57bebcfbf9e6f3b5d275964103aac`

Repository-side evidence recorded the same object size and the same SHA-256. The matching hashes prove that the repository object was transferred intact to a real network device.

This validates generic device-side HTTP retrieval and repository logging behavior; it does not replace vendor-specific software-download qualification on the actual target platform.

See `docs/lab-test-output-2026-09-25.md` for sanitized command and log output.

## Vendor package staging update — 2026-09-17

A real vendor package was loaded into the POC repository and its required entry-point object returned HTTP 200 to local and remote requests. Restricted package internals and vendor-controlled payload details are intentionally omitted from the public-facing record.

The representative target platform remains subject to a device-native software-download test before production use.

## Remaining qualification work

- Verify and record the original vendor package checksum in the private image manifest.
- Test device-native software pull on the representative target platform without activation.
- Test the qualified legacy-platform distribution method.
- Test Junos HTTP staging on representative production-class Juniper platforms.
- Validate interrupted-transfer cleanup and retry behavior.
- Validate representative concurrent transfers.
- Apply production addressing and network-access policy.
- Integrate the production NTP source.
- Establish capacity and service monitoring.
- Reproduce the repository in the production environment and repeat reachability tests.
