# Management-Platform Validation and Backout

## Required validation domains

- Local administrative access
- Production AAA and fallback access
- NTP synchronization and clock offset
- TLS identity and trust
- Representative device connectivity
- Discovery and inventory reconciliation
- Topology
- Alarm and event lifecycle
- Approved low-risk management action
- Scheduled and on-demand jobs
- Platform backup and retrieval
- SMTP, syslog, and SNMP notifications
- Northbound/API integrations
- Infrastructure monitoring
- Performance baselines
- HA/GR behavior when applicable

## Hard rollback examples

- Required administrative access fails
- Managed-device communication materially fails
- Inventory, topology, or alarms are materially incomplete
- Required integrations cannot authenticate or exchange data
- Platform backup fails
- Performance or stability cannot support production use
- A critical defect lacks an accepted workaround

The legacy platform remains available until cutover acceptance, burn-in completion, and the rollback-retention gate have all passed.

Public documentation intentionally omits real system names, addresses, customer inventory, credentials, and integration endpoints.
