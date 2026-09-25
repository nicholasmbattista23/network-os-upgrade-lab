# Decision 0001: Storage Boundaries

- **Status:** Approved
- **Decision:** Separate version-controlled engineering assets from live planning data and vendor binaries.

## Rationale

Git is appropriate for text configuration, scripts, templates, sanitized lab evidence, and decision history. It is not the authoritative store for vendor software, secrets, licenses, production backups, live operational inventory, or customer-specific production data.

## Placement

- Git repository: reusable configuration, scripts, templates, sanitized documentation, and sanitized lab evidence.
- Private planning system: live inventory, readiness tracking, diagrams, approvals, and collaborative planning.
- Internal HTTP repository: approved vendor images, checksums, and associated release documents.

## Security constraint

Repository visibility does not authorize committing secrets or restricted vendor software. Repository history must be treated as persistent. Before public release, review both the current tree and commit history for credentials, customer data, internal addressing, restricted vendor material, and personal information.
