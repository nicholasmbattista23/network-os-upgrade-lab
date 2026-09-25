# Ciena SAOS 10 Package Staging Checkpoint — 2026-09-17

## Scope

This checkpoint records a real-vendor SAOS 10 package staged on the repository POC. Vendor software payloads, signatures, checksums, restricted package contents, and customer-specific deployment data are intentionally **not** committed to Git.

## Package handling

- Vendor: Ciena
- OS family: SAOS 10
- Initial representative platform: CN3924
- Repository filesystem root: `/srv/network-os`
- Distribution method under test: device-initiated HTTP retrieval

The extracted vendor package tree was preserved as required by the supported distribution method. Package internals and vendor-restricted metadata are intentionally omitted from the public-facing record.

## Repository validation completed

- Required entry-point object exists in the live repository tree.
- Local Nginx `HEAD` request returned HTTP 200.
- Local Nginx `GET` downloaded the object successfully.
- Remote workstation `GET` downloaded the same object successfully.
- Nginx served the package through the existing repository configuration; no second web service was required.
- Operational logging was later validated for local, workstation, and real network-device clients.

## Current status

**POC staging: PASS**

The repository is ready for the next qualification step: production-environment deployment followed by a representative CN3924 device-native SAOS 10 pull **without activation**.

## Remaining work

- Verify the original vendor package checksum in the private image manifest.
- Move/reproduce the repository service in the production environment.
- Validate production routing, host/network policy, NTP, and repository reachability.
- Run the CN3924 software-download test while monitoring Nginx access and transfer-success logs.
- Confirm device-side software-download completion before activation is considered.
- Qualify each hardware family separately according to vendor support documentation.

See `docs/lab-test-output-2026-09-25.md` for sanitized HTTP transfer evidence from the lab.
