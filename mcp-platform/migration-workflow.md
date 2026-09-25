# Management-Platform Migration Workflow

1. **Baseline current system** — capture application, OS, topology, resources, integrations, licensing, certificates, jobs, backups, and health in private records.
2. **Qualify the target pair** — approve the exact application release, operating-system release, kernel, installer, and migration path.
3. **Acquire packages** — obtain controlled OS media, vendor installer, dependencies, release documentation, and vendor checksums.
4. **Build infrastructure** — create clean target VM(s) using qualified sizing and storage.
5. **Prepare the OS** — apply the approved patch level, accounts, time, logging, hardening, and repositories.
6. **Install the platform** — follow the release-matched vendor installation procedure.
7. **Migrate data and configuration** — use the approved export/import or migration method.
8. **Integrate services** — configure AAA, certificates, NTP, notifications, backups, monitoring, and external integrations.
9. **Validate functionality** — execute the validation matrix.
10. **Burn in** — run a parallel observation period while retaining the legacy platform.
11. **Cut over** — freeze changes, take the final recovery point, move operations, and validate.
12. **Back out when required** — return operations to the legacy platform if a hard rollback trigger is reached.
13. **Retire legacy** — decommission the prior platform only after acceptance and the approved retention period.

Production-specific topology, inventory, addresses, credentials, licenses, and integration endpoints are intentionally excluded from this repository.
