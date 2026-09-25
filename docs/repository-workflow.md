# Repository Server Workflow

## Build

1. Install the qualified Debian release, Nginx, and curl.
2. Create the directory layout under `/srv/network-os`.
3. Install the IP-independent Nginx site configuration.
4. Install the repository logging definitions under `/etc/nginx/conf.d/`.
5. Enable Nginx at boot and validate the effective configuration.
6. Limit host/network access to approved management sources.

## Qualify

1. Confirm GET and HEAD succeed.
2. Confirm PUT is rejected.
3. Download a representative image-sized test file from another management subnet.
4. Compare the source and downloaded SHA-256 values.
5. Confirm access, activity, transfer-success, and error logging.
6. Confirm byte-range support.
7. Reboot and repeat the service and download checks.

## Operational logging

The repository keeps the standard detailed access log and adds two simple operational logs:

- `/var/log/nginx/network-os-access.log` — full Nginx access history.
- `/var/log/nginx/network-os-activity.log` — one human-readable request line per HTTP request.
- `/var/log/nginx/network-os-success.log` — completed successful GET responses only.
- `/var/log/nginx/network-os-error.log` — Nginx errors.

Example activity entry using documentation address space:

```text
2026-09-25T12:00:00-04:00 REQUEST ip=192.0.2.20 method=GET uri="/vendor/os/platform/test-object.bin" status=200 bytes=18708 duration=0.002 connection=42
```

Example successful transfer entry:

```text
2026-09-25T12:00:00-04:00 TRANSFER_OK ip=192.0.2.20 file="/vendor/os/platform/test-object.bin" status=200 bytes=18708 duration=0.002 connection=42
```

`TRANSFER_OK` means Nginx completed a successful HTTP GET response. It does **not** prove that a network device accepted, verified, or installed an image. Device-side software-download completion must be captured separately during qualification and production execution.

During a device pull test, monitor successful transfers with:

```bash
tail -F /var/log/nginx/network-os-success.log
```

## Load software

1. Obtain packages directly from authorized vendor portals.
2. Record the original vendor filename, size, checksum, release notes, and support evidence in the private planning system.
3. Verify the local checksum before publishing the image.
4. Place the image only in its approved platform directory.
5. Update the private image manifest.
6. Test with one representative device without activation.

### Vendor package handling

Some network operating systems are delivered as multi-file package trees rather than a single image. Preserve vendor-required package structure exactly as delivered and follow the release-matched vendor installation procedure.

Before any device test:

1. Confirm the required entry-point file exists in the live repository tree.
2. Confirm an Nginx HEAD request returns HTTP 200.
3. Confirm a full GET succeeds locally.
4. Confirm a full GET succeeds from a management-network workstation.
5. Confirm the operational logs record the request and successful GET response.
6. Keep vendor binaries, checksums, signatures, license-controlled payloads, and restricted package contents out of Git.

Exact package internals, customer inventory, production addresses, and live qualification status are intentionally kept out of the public-facing repository.

## Production rule

Code distribution and upgrade execution are separate phases. Images should be staged and verified before the maintenance window whenever the platform supports it.
