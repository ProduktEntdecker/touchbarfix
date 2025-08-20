# TouchBarFix

Fix your unresponsive MacBook Touch Bar with one click — no Terminal commands or restart required.

🌐 **Website**: [touchbarfix.com](https://touchbarfix.com)  
📦 **Download**: [Latest Release (v1.2.1)](https://github.com/ProduktEntdecker/touchbarfix/releases)

## Why?

Many MacBook Pros (2016–2021) experience flickering or non-responsive Touch Bars. The usual fix requires either Terminal commands or a full system reboot. TouchBarFix does it with a single click.

## Features

- **One-click Touch Bar restart** — Fix frozen or unresponsive Touch Bar instantly
- **Menu bar interface** — Clean, minimal design that stays out of your way  
- **Security hardened** — Process whitelisting and input validation
- **Enhanced logging** — Detailed console output for verification
- **Universal binary** — Supports both Intel and Apple Silicon Macs
- **No subscription** — One-time purchase of €7 (free during beta)

## Supported Models

- MacBook Pro 2016-2021 (all Touch Bar models)
- macOS 11.0 (Big Sur) or later (including Sonoma and Ventura)
- Specifically tested on MacBookPro17,1 (M1, 2020)

## Installation

1. **Download** the latest DMG from [Releases](https://github.com/ProduktEntdecker/touchbarfix/releases)
2. **Mount** the DMG and drag TouchBarFix to Applications
3. **Launch** TouchBarFix (first time: right-click → Open → Open)
4. **Use** the app to restart your Touch Bar when needed

## Project Structure

```
touchbarfix/
├── App/              # Main application code
│   ├── Sources/      # Swift source files
│   ├── Tests/        # Unit tests
│   └── Release/      # Built app and DMG
├── Assets/           # App icons and assets
├── docs/archive/     # Historical documentation
├── index.html        # Landing page (hosted on Vercel)
└── .github/          # CI/CD workflows
```

## Building from Source

```bash
# Clone the repository
git clone https://github.com/ProduktEntdecker/touchbarfix.git
cd touchbarfix/App

# Build the app
./build-app.sh

# Create DMG installer (optional)
./create-dmg.sh

# Run tests
swift test
```

## Tech Stack

- **Swift + SwiftUI** — Native macOS performance
- **Vercel** — Landing page hosting at [touchbarfix.com](https://touchbarfix.com)
- **GitHub Actions** — Automated CI/CD pipeline
- **Security focused** — Process whitelisting, input validation, secure APIs

## Repository

- **Repository**: [github.com/ProduktEntdecker/touchbarfix](https://github.com/ProduktEntdecker/touchbarfix)
- **Website**: [touchbarfix.com](https://touchbarfix.com)
- **Issues**: [Report bugs or request features](https://github.com/ProduktEntdecker/touchbarfix/issues)

## 📚 Documentation

- [Lessons Learned](docs/LESSONS-LEARNED.md) - Issues encountered and solutions
- [Development Guide](App/DEVELOPMENT.md) - Setup and development instructions
- [Archived Docs](docs/archive/) - Historical project documentation
- [Security Audit Report](docs/SECURITY-AUDIT-REPORT.md) - Current findings and pre‑launch remediation plan

## Website Favicons (Deployment)

- Files live in `Assets/` and are served from root URLs via `vercel.json` rewrites:
  - `/favicon.ico` → `Assets/favicon.ico`
  - `/apple-touch-icon.png` → `Assets/apple-touch-icon.png`
- Long‑lived caching headers are configured for these routes (`Cache-Control: public, max-age=31536000, immutable`).
- `index.html` includes the minimal, Apple‑focused links:
  - `<link rel="icon" href="/favicon.ico" sizes="any">`
  - `<link rel="apple-touch-icon" href="/apple-touch-icon.png">`

## Support

- **Email**: florian.steiner@mac.com
- **GitHub Issues**: [Report issues](https://github.com/ProduktEntdecker/touchbarfix/issues)

---

*Built with ❤️ by [Dr. Florian Steiner](https://github.com/ProduktEntdecker)*
