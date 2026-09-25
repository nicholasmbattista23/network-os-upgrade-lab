# Ciena Staging Notes

## SAOS 10

- Treat device-initiated HTTP pull as the standard distribution model when supported by the qualified platform/release combination.
- Host the exact approved image in the platform directory.
- Record filename, size, SHA-256, source, and approval evidence in the private planning system.
- Verify image transfer and local integrity before activation.
- Keep the prior software/recovery path available.
- Preserve vendor package structure as required by the supported installation method, but do not commit vendor payloads or restricted package contents to this repository.

## SAOS 6

- Qualify the supported distribution method by platform.
- Keep patching separate from major-version migration decisions.
- Populations subject to separate security or change-control approval should remain on their own approval track until formally released for coordinated work.

Public documentation should describe the reusable process, not live customer inventory, security holds, or production-specific device populations.
