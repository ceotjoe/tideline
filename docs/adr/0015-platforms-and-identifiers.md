# 0015. Platforms, minimum versions and identifiers

- Status: accepted
- Date: 2026-10-01

## Decision

| Item | Value |
|---|---|
| Bundle / application ID | `com.ITWebService.tideline`, on all platforms |
| iOS / iPadOS | 16+ |
| Android | 7.0 (API 24)+; flutter_secure_storage 11 requires it |
| macOS | 12+ |
| Windows | 10 1903+; needed by the mDNS plugins |
| Linux | Scaffolded and built in CI, but **unofficial**: no support promise. Since ADR 0030 an experimental tarball is attached to GitHub releases. |
| iPad windows | Single window. Flutter does not yet support multiple scenes. All window sizes are supported. |

## Consequences
- Android's applicationId contains uppercase letters. Android allows this, but Kotlin package directories must match.
- Store listings will use "Tideline" as the display name.
