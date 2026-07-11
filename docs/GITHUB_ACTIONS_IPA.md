# Build IPA without a Mac (GitHub Actions)

Repo target: `https://github.com/Krayyd/Cashflare` (or your fork under that account).

## Quick start (unsigned IPA)

1. Push this project to GitHub.
2. Actions → **Build IPA** → Run workflow.
3. Download artifact **Cashflare-IPA** (`Cashflare-unsigned.ipa`).

Unsigned IPA is for CI verification. To install on a real iPhone you need Apple signing (below).

## Signed IPA (install on device / TestFlight)

Apple Developer account ($99/year) required for distribution.

Create in [developer.apple.com](https://developer.apple.com):

1. App ID: `com.krayd.cashflare`
2. Distribution certificate → export `.p12`
3. Provisioning profile (Ad Hoc or App Store) for that App ID → `.mobileprovision`

### GitHub Secrets

Repo → Settings → Secrets and variables → Actions:

| Secret | Value |
|--------|--------|
| `BUILD_CERTIFICATE_BASE64` | `base64` of your `.p12` |
| `P12_PASSWORD` | password for the `.p12` |
| `BUILD_PROVISION_PROFILE_BASE64` | `base64` of `.mobileprovision` |
| `KEYCHAIN_PASSWORD` | any random string |
| `EXPORT_METHOD` | `ad-hoc` or `app-store` (optional, default `ad-hoc`) |

### Encode files (Windows PowerShell)

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\dist.p12")) | Set-Clipboard
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\Cashflare.mobileprovision")) | Set-Clipboard
```

### Encode files (Mac/Linux)

```bash
base64 -i dist.p12 | pbcopy
base64 -i Cashflare.mobileprovision | pbcopy
```

After secrets are set, re-run **Build IPA** — artifact will be `Cashflare.ipa`.

## Notes

- Runner: `macos-14` + Xcode
- Bundle ID: `com.krayd.cashflare`
- Developer: **krayd**
- Without secrets the workflow still succeeds and uploads an unsigned IPA
