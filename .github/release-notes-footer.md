
---

## Downloads

| File | What it is |
|---|---|
| `Tideline-<version>-windows-x64-portable.zip` | Windows 10 (1903) or later. Unzip anywhere and run `tideline.exe`. Nothing is installed. |
| `Tideline-<version>-windows-x64.msix` | Windows installer package. Signed only if the release had a code-signing certificate; otherwise Windows refuses it, so use the zip. |
| `Tideline-<version>-linux-x64.tar.gz` | **Experimental** Linux build (x86-64). Needs GTK 3 and libsecret, and a running secret service such as GNOME Keyring or KWallet. Unzip and run `tideline`. |
| `SHA256SUMS.txt` | Checksums of every file here. Check with `sha256sum -c SHA256SUMS.txt`. |
| `Tideline-<version>-sbom.spdx.json` | Software bill of materials (SPDX). |

The Windows builds are not yet signed with a trusted certificate, so SmartScreen may warn on the first start ("More
info", then "Run anyway"). iOS, iPadOS, macOS and Android come through the app stores.
