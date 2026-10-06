# OWASP MASVS mapping (L1 baseline)

_Maps the MASVS v2 control groups to Tideline's measures. Status: ✅ in place · 🛠 planned for the named milestone._

| Control | Requirement (summary) | Tideline measure | Status |
|---|---|---|---|
| **MASVS-STORAGE-1** | Sensitive data is stored securely | Tokens in the OS secure store. The DB and backups are plain files protected by the OS and kept out of cloud backups (ADR 0034, 0006); the app encrypts nothing itself | ⚠ accepted (ADR 0034) |
| **MASVS-STORAGE-2** | No sensitive data leaks (logs, backups, clipboard, keyboard cache) | Log redaction; Android backup exclusions; no tokens in exports or backups; token fields marked as secure input (`obscureText`, no autocorrect) | 🛠 M2 |
| **MASVS-CRYPTO-1** | Strong, current cryptography | The app uses no cryptography of its own: TLS and the secure store are the OS's, SHA-256 is only used for hashes (ADR 0034) | ✅ (n/a) |
| **MASVS-CRYPTO-2** | Keys are managed securely | No app-managed keys; API tokens are held only in the secure store | ✅ (n/a) |
| **MASVS-AUTH-1** | Secure authentication to remote services | Wavelog v2 bearer tokens with least-privilege scopes; expiry shown; revocation handled (blocked state) | 🛠 M2 |
| **MASVS-AUTH-2** | Local authentication done right | Optional app lock via `local_auth` (biometrics/device PIN), evaluated by the OS. It covers the UI at start and whenever the app returns from the background. **Limitation:** the lock covers the screen, not the data at rest: the database is a plain file and stays open so sync keeps working while locked (ADR 0034) | ✅ (UI lock only) |
| **MASVS-AUTH-3** | Sensitive operations need extra authentication | Re-authentication before revealing or replacing tokens and before exporting backups | 🛠 M2 |
| **MASVS-NETWORK-1** | Secure traffic | HTTPS by default; HTTP only on private LANs after a warned opt-in (ADR 0009) | ✅ |
| **MASVS-NETWORK-2** | Identity pinning where needed | Explicit TOFU leaf-certificate pinning for self-signed servers, fingerprint shown before trusting | ✅ |
| **MASVS-PLATFORM-1** | Secure IPC | No exported Android components beyond the launcher and file-open intents; incoming files validated | 🛠 M2 |
| **MASVS-PLATFORM-2** | Secure WebViews | No WebViews used | ✅ |
| **MASVS-PLATFORM-3** | Secure UI (sensitive data in screenshots) | Token screens excluded from app-switcher snapshots | 🛠 M2 |
| **MASVS-CODE-1** | Up-to-date platform | Minimum iOS 16, Android API 24, macOS 12, Windows 10 1903 (ADR 0015) | ✅ |
| **MASVS-CODE-2** | Update mechanism | Distributed through stores, which provide the update mechanism | 🛠 v1.0 |
| **MASVS-CODE-3** | No known-vulnerable dependencies | Lockfile, Dependabot, `pub outdated` in CI, SBOM per release | ✅ / 🛠 |
| **MASVS-CODE-4** | Input validation | Strict ADIF parser (fuzz-tested, size limits, import off the UI thread), typed API decoding with size limits, backup KDF parameter caps | ✅ (ADIF, API, backups) / 🛠 later (QR, packs) |
| **MASVS-PRIVACY-1** | Minimise data access | Location only on demand and only as a grid; no contacts or photos; camera only for QR (later) | ✅ by design |
| **MASVS-PRIVACY-2** | Prevent identification | No telemetry, analytics or ads | ✅ |
| **MASVS-PRIVACY-3** | Transparency | `PRIVACY.md`, onboarding explanations of scopes and network destinations | ✅ / 🛠 M2 |
| **MASVS-PRIVACY-4** | User control | ADIF export, plain backup/restore, remove-account; no lock-in | ✅ |

MASVS-RESILIENCE (L2/R) controls are out of scope for an open-source app.
