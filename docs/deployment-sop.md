# Network OS Repository Deployment and Operations SOP

## 1. Purpose

This SOP describes how to deploy, configure, load, validate, and operate the Network OS Repository service used by this lab project.

The repository service provides a controlled HTTP distribution point for network operating-system software. It supports device-initiated retrieval, repeatable validation, transfer logging, and platform-oriented staging while keeping vendor binaries out of Git.

This SOP covers the repository server and its Git-managed configuration. It does **not** replace vendor-specific upgrade procedures, release qualification, change control, or device-side activation steps.

## 2. Scope

The deployment consists of:

- Debian Linux host
- Nginx HTTP service on TCP/80
- Repository root at `/srv/network-os`
- Version-controlled Nginx configuration and helper scripts
- Platform-oriented software directories
- Operational request and successful-transfer logging
- Manual or controlled loading of vendor software packages

A generic repository layout is:

```text
/srv/network-os/
├── <vendor>/
│   └── <os-family>/
│       └── <platform>/
└── manifests/
```

The tracked build script creates the example Ciena and Juniper platform directories used by this project.

## 3. Design and security principles

The repository is intentionally simple and read-only from the HTTP client perspective.

- Nginx serves files with `GET` and `HEAD`.
- HTTP modification methods are denied.
- Vendor software is stored only on the repository server, not in Git.
- Credentials, private keys, license material, device backups, and sensitive operational data must not be committed to Git.
- Access to TCP/80 should be restricted by host/network policy to intended management and device source networks.
- The repository should not be directly exposed to the public Internet.
- Software distribution and software activation are separate operational phases.
- A successful HTTP response does not by itself prove that a device accepted, validated, or installed an image.

## 4. Prerequisites

Before deployment, confirm:

- Debian host is provisioned and reachable by SSH.
- Hostname and management addressing are assigned.
- Default gateway and required routing are working.
- DNS is available if required by the environment.
- Time synchronization is working.
- The host can reach the Git repository containing the configuration.
- Administrators can obtain software from authorized vendor sources.
- Required firewall policy allows intended clients to reach TCP/80.
- Sufficient storage exists for planned software packages plus staging/validation overhead.

Install the base packages:

```bash
sudo apt update
sudo apt install -y nginx curl git ca-certificates
```

## 5. Obtain the repository configuration

Clone the project repository using an appropriate Git credential:

```bash
cd /opt
git clone <REPOSITORY_URL> network-os-upgrade-lab
cd network-os-upgrade-lab
```

Validate the checkout:

```bash
git status
git log -1 --oneline
```

The working tree should be clean before deployment.

## 6. Build the repository directory structure

From the cloned repository:

```bash
sudo ./repository-server/scripts/build-repository.sh
```

Default repository root:

```text
/srv/network-os
```

Validate:

```bash
find /srv/network-os -type d | sort
```

The build script creates the tracked platform directories, assigns `root:root`, and applies directory mode `0755`.

## 7. Install the Nginx configuration

Install the repository site configuration:

```bash
sudo cp repository-server/nginx/network-os-repo.conf \
  /etc/nginx/sites-available/network-os-repo
```

Install the operational logging definitions:

```bash
sudo cp repository-server/nginx/network-os-logging.conf \
  /etc/nginx/conf.d/network-os-logging.conf
```

Enable the repository site:

```bash
sudo ln -sfn \
  /etc/nginx/sites-available/network-os-repo \
  /etc/nginx/sites-enabled/network-os-repo
```

Disable the Debian default site:

```bash
sudo rm -f /etc/nginx/sites-enabled/default
```

Validate before applying:

```bash
sudo nginx -t
```

Enable and start Nginx:

```bash
sudo systemctl enable --now nginx
sudo systemctl status nginx --no-pager
```

Confirm the listener:

```bash
ss -lntp | grep ':80'
```

## 8. Validate the empty repository service

Run the included validation script:

```bash
sudo ./repository-server/scripts/validate-repository.sh
```

Expected checks include:

```text
Directory structure: PASS
HTTP HEAD: PASS
Read-only PUT rejection: PASS
```

Additional manual validation:

```bash
curl -I http://127.0.0.1/
curl -s http://127.0.0.1/ | head
```

Repeat from another permitted client using the repository server address.

## 9. Repository logging

The service maintains four Nginx logs:

```text
/var/log/nginx/network-os-access.log
/var/log/nginx/network-os-activity.log
/var/log/nginx/network-os-success.log
/var/log/nginx/network-os-error.log
```

Monitor request activity:

```bash
tail -F /var/log/nginx/network-os-activity.log
```

Monitor completed successful GET responses:

```bash
tail -F /var/log/nginx/network-os-success.log
```

Monitor failures:

```bash
tail -F /var/log/nginx/network-os-error.log
```

A typical successful-transfer record is:

```text
TRANSFER_OK ip=<CLIENT_IP> file="/<REPOSITORY_OBJECT>" status=200 bytes=<BYTE_COUNT> duration=<SECONDS> connection=<ID>
```

`TRANSFER_OK` means Nginx completed a successful HTTP GET response. It does not prove that the requesting network device accepted or validated the software package.

## 10. Acquire and verify vendor software

Obtain vendor software from an authorized vendor portal or other approved source.

Before publishing software to the repository, record at minimum:

- Vendor
- Platform
- OS family
- Release/version
- Original filename or package name
- Source/reference
- Published vendor checksum
- File/package size
- Required intermediate releases, if any
- Supported upgrade path
- Rollback/recovery method

Verify the downloaded artifact against the vendor-published checksum before staging it for device access.

Example:

```bash
sha256sum <DOWNLOADED_FILE>
```

Do not treat an internally generated checksum as a substitute for the original vendor checksum.

## 11. Stage software into the repository

### 11.1 Single-file image

For a single image file:

```bash
sudo cp -a <SOURCE_FILE> \
  /srv/network-os/<vendor>/<os-family>/<platform>/
```

Confirm:

```bash
ls -lh /srv/network-os/<vendor>/<os-family>/<platform>/
```

### 11.2 Multi-file vendor package

Some platforms require a complete multi-file package tree and a manifest or entry-point file.

Preserve vendor-required package structure exactly as delivered. Do not flatten directories, selectively move components, rename package content, or remove checksum/signature files unless the release-matched vendor procedure explicitly requires it.

Generic example:

```bash
sudo mkdir -p /srv/network-os/<vendor>/<os-family>/<platform>/<RELEASE>

sudo cp -a <STAGING_SOURCE>/<RELEASE>/. \
  /srv/network-os/<vendor>/<os-family>/<platform>/<RELEASE>/
```

If Nginx read permissions require correction:

```bash
sudo chmod -R a+rX \
  /srv/network-os/<vendor>/<os-family>/<platform>/<RELEASE>
```

Do not use broad write permissions such as `chmod 777`.

## 12. Validate staged software before device use

### 12.1 Confirm filesystem presence

```bash
find /srv/network-os/<PATH_TO_RELEASE> -maxdepth 2 -type f | sort | head -50
```

For content copied from a staging area, compare source and destination size/file count:

```bash
du -sh <SOURCE_RELEASE_DIR>
du -sh /srv/network-os/<PATH_TO_RELEASE>

find <SOURCE_RELEASE_DIR> -type f | wc -l
find /srv/network-os/<PATH_TO_RELEASE> -type f | wc -l
```

### 12.2 Verify checksums

Inspect checksum-file format before running bulk verification:

```bash
find /srv/network-os/<PATH_TO_RELEASE> \
  -maxdepth 1 -type f -name '*.sha256' -printf '%f\n' | sort
```

Review the checksum file before using `sha256sum -c`:

```bash
head -20 <CHECKSUM_FILE>
```

Run bulk verification only after confirming that the paths and format match the deployed package tree.

### 12.3 Validate HTTP locally

For the required image or package entry point:

```bash
curl -I http://127.0.0.1/<HTTP_PATH>
```

Perform a complete local GET:

```bash
curl -f -o /tmp/repository-test-object \
  http://127.0.0.1/<HTTP_PATH>
```

### 12.4 Validate HTTP remotely

From another permitted client:

```bash
curl -f -O http://<REPOSITORY_ADDRESS>/<HTTP_PATH>
```

Confirm expected object size and checksum where appropriate.

### 12.5 Confirm logging

During the remote GET:

```bash
tail -F /var/log/nginx/network-os-success.log
```

Confirm the log contains the expected source address, object path, status, and byte count.

## 13. Device-side utilization

The repository publishes software over HTTP. Device-specific retrieval commands depend on vendor, OS, release, and platform.

### Juniper validation pattern

Where supported by the installed Junos release, HTTP can be used as a source for file retrieval:

```text
file copy http://<REPOSITORY_ADDRESS>/<HTTP_PATH> /var/tmp/<LOCAL_FILENAME>
```

After retrieval, verify the local file and checksum using the platform-supported commands.

A successful repository GET plus matching device-side checksum provides evidence that the file was transferred intact.

### Multi-file package validation pattern

For platforms that use a manifest or package entry point:

1. Confirm the complete package is staged.
2. Confirm vendor checksum/integrity evidence.
3. Confirm the entry point returns HTTP 200.
4. Start repository success-log monitoring.
5. Initiate the device-native software download **without activation**.
6. Observe which package components the device requests.
7. Confirm required transfers complete.
8. Confirm device-side download/validation state.
9. Only after qualification and appropriate approval should activation be considered.

Do not infer device CLI. Use release-matched vendor documentation or verified device help output.

## 14. Operational software-loading workflow

Use this sequence for each release:

```text
Acquire
  -> Verify vendor source/checksum
  -> Record release metadata
  -> Stage into platform path
  -> Verify filesystem/package integrity
  -> Local HTTP HEAD/GET
  -> Remote client GET
  -> Confirm operational logs
  -> Representative device pull without activation
  -> Device-side integrity/validation
  -> Record evidence
```

A release is not considered qualified merely because it is the newest published version or because the repository can serve the file.

## 15. Updating repository-server configuration

When tracked configuration or scripts change:

```bash
cd /opt/network-os-upgrade-lab
git pull --ff-only
```

Review before deployment:

```bash
git log -1 --stat
git status
```

Reinstall changed Nginx files as required, then validate:

```bash
sudo cp repository-server/nginx/network-os-repo.conf \
  /etc/nginx/sites-available/network-os-repo

sudo cp repository-server/nginx/network-os-logging.conf \
  /etc/nginx/conf.d/network-os-logging.conf

sudo nginx -t
```

If validation passes:

```bash
sudo systemctl reload nginx
sudo ./repository-server/scripts/validate-repository.sh
```

Never reload Nginx after a failed `nginx -t`.

## 16. Configuration backup / portability bundle

The included packaging script creates a portable configuration evidence bundle without intentionally copying vendor image payloads.

Run:

```bash
cd /opt/network-os-upgrade-lab
sudo ./repository-server/scripts/package-config.sh
```

The script creates:

```text
network-os-repo-config-YYYY-MM-DD.tar.gz
network-os-repo-config-YYYY-MM-DD.tar.gz.sha256
```

The bundle includes repository Nginx configuration, operational logging configuration, effective Nginx configuration, host baseline information, and repository directory layout.

Verify the bundle:

```bash
sha256sum -c network-os-repo-config-YYYY-MM-DD.tar.gz.sha256
```

## 17. Common troubleshooting

### HTTP 404

Check the requested URL against the filesystem path:

```bash
ls -l /srv/network-os/<EXPECTED_PATH>
nginx -T | grep -n 'root /srv/network-os'
tail -n 50 /var/log/nginx/network-os-access.log
```

### HTTP 403

Check path permissions:

```bash
namei -l /srv/network-os/<EXPECTED_PATH>
```

Directories normally require execute permission and files require read permission for the Nginx worker process.

### Device cannot connect

Check the listener and service state:

```bash
ss -lntp | grep ':80'
systemctl status nginx --no-pager
nginx -t
```

Then check routing and firewall policy from both sides.

### Transfer appears successful but the device reports failure

A `TRANSFER_OK` record only proves Nginx completed a successful GET response.

Check:

- Device-side checksum/integrity result
- Required package components
- Vendor manifest/package structure
- Free local device storage
- Required intermediate software releases
- Vendor-specific validation state
- Device logs/error messages

### Partial/range requests

HTTP 206 is a successful partial-content response and can be expected when clients use range requests.

Confirm the complete vendor/device workflow rather than treating an individual 206 response as proof of a complete software download.

## 18. Readiness checklist

Before using a repository instance for an upgrade workflow, confirm:

- [ ] Debian/Nginx build deployed
- [ ] Repository path structure present
- [ ] Git-managed configuration matches deployed configuration
- [ ] Nginx syntax validation passes
- [ ] Service enabled and active
- [ ] TCP/80 access restricted to intended sources
- [ ] Routing and firewall policy validated
- [ ] Time synchronization validated
- [ ] Vendor software acquired from an authorized source
- [ ] Original vendor checksum recorded and validated
- [ ] Correct platform/version path used
- [ ] Package tree preserved where required
- [ ] Local HEAD/GET successful
- [ ] Remote client GET successful
- [ ] Operational logs validated
- [ ] Representative device pull completed without activation
- [ ] Device-side integrity/validation completed
- [ ] Rollback/recovery method documented

## 19. Evidence to retain

For each qualified release, retain:

- Release/source record
- Vendor checksum evidence
- Repository path and HTTP entry point
- Package/file size
- Local and remote HTTP validation
- Relevant repository log excerpts
- Representative device download evidence
- Device-side checksum or validation result
- Upgrade-path qualification
- Rollback/recovery procedure

Do not store credentials, private keys, license files, vendor software payloads, or unsanitized device backups in Git.

## 20. Operating boundary

The Network OS Repository is a distribution and validation component. It does not make an image safe to install and does not authorize activation.

The final deployment decision still depends on:

- Exact target platform
- Supported source-to-target upgrade path
- Vendor requirements
- Integrity verification
- Representative device qualification
- Change approval where applicable
- Backout readiness

Use the repository to make software distribution repeatable, observable, and verifiable; keep device upgrade execution controlled by the release-matched vendor procedure.
