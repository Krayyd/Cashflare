# Cashflare
iOS idle cash-thrower by **krayd**. Same core loop (throw bills → upgrades → passive income), new brand for multiple countries.

## Open on Mac

```bash
cd ~/path/to/Cashflare
brew install xcodegen   # once
xcodegen generate
open Cashflare.xcodeproj
```

Select an iPhone simulator → Run.

Bundle ID: `com.krayd.cashflare`

## MVP controls

- **Tap** — throw cash
- **Currency flag** (top right) — cycle USD / EUR / GBP / BRL / INR / TRY / RUB
- **Bill value** — more cash per throw
- **Business** — offline/passive income

## Stack

SwiftUI + SpriteKit, iOS 17+

## Build IPA without a Mac

Use GitHub Actions — see [docs/GITHUB_ACTIONS_IPA.md](docs/GITHUB_ACTIONS_IPA.md).

## Notes

Bills are drawn procedurally (no third-party art). Swap in your own textures later in `BillFactory`.
