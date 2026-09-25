# Public-Release Checklist

Use this checklist before changing repository visibility or publishing a sanitized copy.

## Current tree

- [ ] No credentials, passwords, API tokens, private keys, license files, or private certificates.
- [ ] No vendor software binaries or restricted package contents.
- [ ] No customer names, circuit IDs, site identifiers, production hostnames, or live inventory.
- [ ] No production or lab RFC1918 addresses in public-facing evidence; use placeholders or RFC 5737 documentation ranges.
- [ ] No internal security-hold, approval-state, or customer-specific campaign details.
- [ ] Templates contain placeholders rather than live target versions, inventory, or approval status.
- [ ] Console output is sanitized before commit.

## Git history

Sanitizing the current tree is not sufficient if earlier commits contain internal addresses, customer data, restricted vendor details, or personal information. Git history is persistent and becomes visible when a repository is made public.

Before public release, use one of these approaches:

1. **Preferred:** publish the sanitized current tree into a new public repository with a clean initial commit.
2. **Alternative:** intentionally rewrite/squash the existing repository history, verify the resulting history, and force-push only after preserving the private original elsewhere.

## Commit identity

If personal email exposure is not desired, configure Git to use the GitHub-provided no-reply address before creating the public history.

```bash
git config user.email "<github-noreply-address>"
```

Existing commits keep their original author/committer metadata unless history is rewritten.

## Verification before publication

Run a history-aware secret scan in addition to reviewing the current tree. Examples include Gitleaks or TruffleHog. Also inspect the complete file list and commit log manually for organization-specific names, addresses, and vendor-controlled material.

The public repository should contain reusable engineering method, configuration, scripts, templates, and sanitized lab evidence only.
