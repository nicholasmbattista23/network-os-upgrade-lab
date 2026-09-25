# Juniper Staging Notes

- Pull the approved Junos package from the internal HTTP repository into the platform-recommended local staging directory.
- Verify free storage, including temporary transfer/install requirements.
- Record the exact package filename, size, checksum, target release, and supported installation path in the private planning system.
- Do not equate the newest published release with the newest supported release for the hardware.
- Retain the previous/recovery software and a documented rollback procedure.
- Validate HTTP retrieval and checksum integrity on representative hardware before using the workflow in production.

## Qualification rule

Exact production targets, hop paths, customer inventory, and approval state are intentionally kept out of the public-facing repository. Those values belong in the private planning system; this repository documents the reusable staging and validation method.
