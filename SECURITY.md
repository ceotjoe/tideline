# Security Policy

Tideline handles API tokens for your Wavelog server and your QSO log. We take security reports seriously.

## Supported versions

Until 1.0, only the latest release receives security fixes.

## Reporting a vulnerability

**Please do not open a public issue for security problems.**

Use GitHub's private vulnerability reporting:
**Security → Report a vulnerability** on <https://github.com/ceotjoe/tideline>.

Please include:
- affected version and platform;
- steps to reproduce or a proof of concept;
- the impact you expect (for example token disclosure or log tampering).

What to expect:
- an acknowledgement within 7 days;
- an assessment and planned fix timeline within 30 days;
- credit in the release notes if you wish.

Please give us reasonable time to release a fix before public disclosure (coordinated disclosure, 90 days by default).

## Scope

In scope:
- the Tideline app;
- its handling of tokens, certificates, local data, backups, ADIF/QR/peer input and reference packs.

Out of scope:
- Vulnerabilities in Wavelog itself. Report those to the [Wavelog project](https://github.com/wavelog/wavelog).

See [docs/security/threat-model.md](docs/security/threat-model.md) for the threat model.
