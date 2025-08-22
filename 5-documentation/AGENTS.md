# AGENTS.md - TouchBarFix Project Instructions for AI Agents

## Project Overview
TouchBarFix is a macOS utility app that fixes frozen MacBook Pro Touch Bars with one click. 

## 👥 Team Structure
- **AI Product Manager & Creator:** Dr. Florian Steiner (solopreneur, freelance consultant)
- **CTO & Technical Co-Founder:** Claude Code (technical implementation)
- **Specialist Agent Team:** Our Avengers-level agent specialists supporting our quest to make life easier for TouchBar users

### ⚠️ CRITICAL: Role References
**NEVER refer to Dr. Florian Steiner as:**
- ❌ Developer
- ❌ Software Engineer  
- ❌ Independent Developer

**ALWAYS use these titles:**
- ✅ AI Product Manager
- ✅ Creator
- ✅ Founder
- ✅ Owner
- ✅ Product Manager
- ✅ Solopreneur
- ✅ Freelance Consultant

## 🎨 CRITICAL: Design System & Brand Guidelines
**ALWAYS REFERENCE FIRST:** `/TOUCHBARFIX-DESIGN-SYSTEM.md`

### Key Brand Rules:
- **App Icon:** Always use `Assets/TouchBarIcon.png` (exact file)
- **Colors:** CTA buttons #007AFF (blue), prices #FF9500 (orange)
- **Attribution:** "Created by Dr. Florian Steiner, AI Product Manager • Co-created with Claude Code"
- **Architecture:** TouchBarFix is NOT a menu bar app - it's a simple utility app
- **Messaging:** Never say "honest" - act honest through transparency
- **Pricing:** €2.99 (can use strike-through pricing for higher original prices)

### 🚨 CRITICAL RULE: Dr. Florian Steiner's Professional Identity

**Dr. Florian Steiner is:**
- AI Product Manager specializing in Mac utilities
- Solopreneur and freelance consultant
- Product creator and business owner
- **CV Background:** Professional background in product management and AI consulting

**NEVER describe Dr. Florian Steiner as:**
- ❌ "Developer" - he does not write code
- ❌ "Software Engineer" - not his profession
- ❌ "Independent Developer" - completely incorrect
- ❌ "Mac Developer" - he manages products, doesn't develop them

**ALWAYS use appropriate titles:**
- ✅ "AI Product Manager" 
- ✅ "Product Creator"
- ✅ "Solopreneur"
- ✅ "Freelance Consultant" 
- ✅ "Founder"
- ✅ "Product Owner"

**When describing the team:**
- Dr. Florian Steiner: AI Product Manager & Creator
- Claude Code: CTO & Technical Co-Founder (handles all coding)
- Agent specialists: Supporting team for design, growth, content, etc.

**This is a fundamental respect issue** - using correct professional titles shows respect for Dr. Steiner's actual expertise and role.

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