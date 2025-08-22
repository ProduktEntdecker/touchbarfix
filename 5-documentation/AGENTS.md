# AGENTS.md - TouchBarFix Project Instructions for AI Agents

## Project Overview
TouchBarFix is a macOS utility app that fixes frozen MacBook Pro Touch Bars with one click. Built by AI Product Manager Dr. Florian Steiner using Claude Code as primary development assistant.

## Current Architecture
- **Language**: Swift 5.9+
- **Framework**: SwiftUI for UI, Foundation for system interactions
- **Target**: macOS 11.0+ (Universal Binary: Intel + Apple Silicon)
- **Build System**: Swift Package Manager
- **Distribution**: Direct download (DMG) + future App Store

## Project Structure
```
touchbarfix/
├── App/                          # Main application
│   ├── Sources/                  # Swift source files
│   ├── Resources/               # Assets, Info.plist, entitlements
│   ├── Tests/                   # Unit tests
│   └── Package.swift           # SPM configuration
├── 1-business/                  # Business documentation  
├── 2-technology/               # Technical documentation
├── 3-operations/               # Deployment & monitoring
├── 4-project-management/       # Project tracking
├── 5-documentation/            # Knowledge base
├── index.html                  # Landing page
└── api/                        # Vercel serverless functions
```

## Key Development Constraints
1. **Security First**: Hardened runtime, minimal entitlements, process whitelisting
2. **Apple Compliance**: Code signing, notarization required for distribution
3. **User Experience**: One-click solution, no technical knowledge required
4. **Viral Growth**: In-app review requests, social sharing, usage analytics

## Build Commands
```bash
# Navigate to app directory
cd App

# Clean build
swift package clean

# Build for development
swift build

# Build production app bundle
./build-app.sh

# Create distribution DMG
./create-dmg.sh

# Run tests
swift test
```

## Testing Strategy
- **Mock hardware dependencies** (TouchBar detection in CI)
- **Test on GitHub Actions** (macOS-14 runners)
- **Verify security**: `spctl -a -vvv TouchBarFix.app`
- **UI testing**: Manual on actual TouchBar MacBooks

## Security Requirements
- **Never store admin credentials**
- **Whitelist allowed processes only** (TouchBarServer, ControlStrip, etc.)
- **Validate all process names** before system calls
- **Use least-privilege entitlements**

## Deployment Pipeline
1. **Code** → 2. **Build** → 3. **Sign** → 4. **Notarize** (2-4h) → 5. **Staple** → 6. **Deploy**

⚠️ **CRITICAL**: Every code change requires notarization. Plan accordingly.

## Marketing Context
- **Free Founders Edition** (48 hours) → €0.99 → €6.99
- **Target**: MacBook Pro users with TouchBar issues
- **Channels**: Reddit, HackerNews ("Show HN:" format), Twitter/X
- **Conversion**: 12.5% website visitors → downloads

## Documentation Standards
- **Update .md files immediately** after major changes
- **Use Euro (€) currency** in all pricing
- **Document lessons learned** in 5-documentation/
- **Keep CURRENT-STATUS.md updated** with build state

## AI Agent Guidelines
- **Ask for clarification** on Apple-specific processes (signing, notarization)
- **Mock hardware features** in tests (TouchBar detection)
- **Always verify changes** don't break security model
- **Update documentation** when implementing new features
- **Consider viral growth impact** of new features

## Emergency Contacts
- **Human**: Dr. Florian Steiner (AI Product Manager, Munich)
- **Apple Developer**: D3SM7HA325
- **Domain**: touchbarfix.com (hosted on Vercel)