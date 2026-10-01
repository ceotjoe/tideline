# 0009. TLS: platform trust plus explicit trust-on-first-use pinning

- Status: accepted
- Date: 2026-10-01

## Context
- Many Wavelog instances are self-hosted, some with self-signed certificates or on a LAN.
- Requirements:
  - Users must never be able to disable TLS validation.
  - Plain HTTP is allowed only for private LAN addresses, behind a warned opt-in.

## Decision
- **Default:** platform root certificates.
- **If validation fails:** the app shows the certificate's SHA-256 fingerprint, subject and validity, and explains how to compare
  the fingerprint with the server. Only after explicit confirmation is that fingerprint pinned to the account.
- **Pinned accounts:** the HTTP client accepts **only** the pinned leaf fingerprint in `badCertificateCallback`, and only for the
  account's host and port.
- **When the pinned certificate changes:** the connection is blocked with a clear warning, and the user must re-confirm.
- **Plain HTTP:** only for RFC 1918, link-local, loopback and `.local` hosts, after a warned opt-in stored per account.

## Consequences
- Works with self-signed LAN servers without weakening TLS for anyone else.
- Certificate renewals on self-signed servers require re-confirmation, which is documented.
