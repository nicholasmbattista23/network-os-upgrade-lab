# Management-Platform Rebuild Prerequisites

The management platform is treated as a parallel infrastructure migration track, not as a network-device upgrade population.

## Version and support

- Record the exact current product, version, build, and hotfixes in the private planning system.
- Approve the exact target application release.
- Confirm the exact application, operating-system release, kernel, and installer combination in the vendor support matrix.
- Keep application and operating-system version decisions separate until the supported pair is validated.

## Architecture and recovery

- Inventory VM/node roles, HA/GR design, database placement, storage, CPU, memory, and IOPS in private records.
- Verify a recoverable platform/database backup.
- Approve the vendor-supported export/import or migration method.
- Define cutover, rollback triggers, decision ownership, and the legacy-platform retention period.

## Dependencies

- Licensing and entitlement rehost
- Certificates and CA chains
- AAA and administrative fallback
- NTP and clock validation
- SMTP, syslog, SNMP, backup, monitoring, telemetry, and northbound integrations
- Southbound device connectivity and credential handling

Do not store passwords, private keys, license files, production exports, live customer inventory, or production-specific addressing in this repository.
