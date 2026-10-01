# OWASP MASVS mapping (L1 baseline)

_Maps the MASVS v2 control groups to Tideline's measures. Status: ✅ in place · 🛠 planned for the named milestone._

| Control | Requirement (summary) | Tideline measure | Status |
|---|---|---|---|
| **MASVS-STORAGE-1** | Sensitive data is stored securely | Tokens and the DB key in the OS secure store; DB encrypted with SQLite3MultipleCiphers (ADR 0005, 0006) | 🛠 M1/M2 |
| **MASVS-STORAGE-2** | No sensitive data leaks (logs, backups, clipboard, keyboard cache) | Log redaction; Android backup exclusions; no tokens in exports or backups; token fields marked as secure input (`obscureText`, no autocorrect) | 🛠 M2 |
| **MASVS-CRYPTO-1** | Strong, current cryptography | ChaCha20-Poly1305 for the DB; Argon2id + AEAD for backups; no custom crypto primitives | 🛠 M1/M2 |
| **MASVS-CRYPTO-2** | Keys are managed securely | 256-bit random key from a CSPRNG, held only in the secure store; backup keys derived from the user's passphrase | 🛠 M1 |
| **MASVS-AUTH-1** | Secure authentication to remote services | Wavelog v2 bearer tokens with least-privilege scopes; expiry shown; revocation handled (blocked state) | 🛠 M2 |
| **MASVS-AUTH-2** | Local authentication done right | Optional app lock via `local_auth` (biometrics/device PIN), with the DB key not released until unlocked | 🛠 M2 |
| **MASVS-AUTH-3** | Sensitive operations need extra authentication | Re-authentication before revealing or replacing tokens and before exporting backups | 🛠 M2 |
| **MASVS-NETWORK-1** | Secure traffic | HTTPS by default; HTTP only on private LANs after a warned opt-in (ADR 0009) | 🛠 M2 |
| **MASVS-NETWORK-2** | Identity pinning where needed | Explicit TOFU leaf-certificate pinning for self-signed servers | 🛠 M2 |
| **MASVS-PLATFORM-1** | Secure IPC | No exported Android components beyond the launcher and file-open intents; incoming files validated | 🛠 M2 |
| **MASVS-PLATFORM-2** | Secure WebViews | No WebViews used | ✅ |
| **MASVS-PLATFORM-3** | Secure UI (sensitive data in screenshots) | Token screens excluded from app-switcher snapshots | 🛠 M2 |
| **MASVS-CODE-1** | Up-to-date platform | Minimum iOS 16, Android API 24, macOS 12, Windows 10 1903 (ADR 0015) | ✅ |
| **MASVS-CODE-2** | Update mechanism | Distributed through stores, which provide the update mechanism | 🛠 v1.0 |
| **MASVS-CODE-3** | No known-vulnerable dependencies | Lockfile, Dependabot, `pub outdated` in CI, SBOM per release | ✅ / 🛠 |
| **MASVS-CODE-4** | Input validation | Strict ADIF/API/QR/pack parsing; fuzzing of the ADIF parser | 🛠 M2 |
| **MASVS-PRIVACY-1** | Minimise data access | Location only on demand and only as a grid; no contacts or photos; camera only for QR (later) | ✅ by design |
| **MASVS-PRIVACY-2** | Prevent identification | No telemetry, analytics or ads | ✅ |
| **MASVS-PRIVACY-3** | Transparency | `PRIVACY.md`, onboarding explanations of scopes and network destinations | ✅ / 🛠 M2 |
| **MASVS-PRIVACY-4** | User control | Export, backup and delete-account features; no lock-in | 🛠 M2 |

MASVS-RESILIENCE (L2/R) controls are out of scope for an open-source app.
