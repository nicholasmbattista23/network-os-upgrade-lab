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
- Generic network-device HTTP retrieval and matching source/device SHA-256 were validated with a Juniper EX2200 on 2026-09-25.

## Current status — 2026-09-25

**POC staging: PASS**

The package-hosting and generic HTTP-distribution portions of the POC are complete. The remaining SAOS 10 qualification is the vendor integrity check plus a representative CN3924 device-native software download **without activation**.

The next clean deployment may occur in an engineering lab before the final environment is ready. Environment-specific routing, access policy, time synchronization, monitoring and recovery checks should be repeated wherever the service is ultimately deployed.

## Remaining work

- Verify the original vendor package checksum/integrity evidence.
- Deploy a fresh repository instance in the next available qualified environment.
- Validate target-environment routing, access policy, time state and repository reachability.
- Run the CN3924 software-download test while monitoring Nginx access and transfer-success logs.
- Confirm device-side software-download completion before activation is considered.
- Qualify CN8114 separately.
- Qualify each additional hardware family according to release-matched vendor support documentation.

See `docs/project-status-2026-09-25.md` for the current sanitized checkpoint and `docs/lab-test-output-2026-09-25.md` for HTTP transfer evidence from the POC lab.
