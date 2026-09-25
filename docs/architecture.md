# Logical Architecture

```mermaid
flowchart TD
    A[Approved vendor portals] --> B[Controlled acquisition]
    B --> C[Internal HTTP repository]
    C --> D[Ciena SAOS device pull]
    C --> E[Juniper local staging]
    F[Git repository] --> G[Configuration and scripts]
    F --> H[Sanitized manifests and workflows]
    I[Private planning system] --> J[Live inventory and punch lists]
```

## Responsibility boundaries

- Git versions the build logic, configuration, templates, sanitized engineering documentation, and lab evidence.
- A private planning system remains the system of record for live inventory, readiness, approvals, and production-specific data.
- The internal HTTP server stores approved vendor images and their verification data.
- Network devices only enter an upgrade wave after the target, path, storage, backup, staging, checksum, and rollback gates pass.
- Management-platform migration work is tracked separately from device software populations.

Public-facing documentation intentionally omits customer identifiers, production addresses, live inventory, credentials, and restricted vendor payload details.
