# TOUCHBARFIX PROJECT - ESSENTIAL INFORMATION FOR CLAUDE

**Last Updated: August 19, 2025 - 10:50 CET**

## 🚨 CRITICAL PROJECT INFORMATION

### PROJECT REBRAND COMPLETED
**Renamed on August 16, 2024 at 18:00 CET**

## ❌ OLD NAMES (NEVER USE):
- Touch Bar Restarter
- touchbar-restarter 
- TouchBarRestarter
- Any variation with "restarter"

## ✅ CURRENT NAMES (ALWAYS USE):
- **Product Name**: TouchBarFix
- **Repository**: touchbarfix  
- **Domain**: touchbarfix.com
- **GitHub**: https://github.com/ProduktEntdecker/touchbarfix
- **Bundle ID**: com.produktentdecker.touchbarfix

## 📁 PROJECT STRUCTURE:
```
touchbarfix/
├── App/              # Main application code
│   ├── Sources/      # Swift source files
│   ├── Tests/        # Unit tests
│   └── Release/      # Built app and DMG
├── Assets/           # TouchBarIcon.png, AppIcon.icns
├── docs/             
│   ├── archive/      # Historical documentation
│   └── LESSONS-LEARNED.md  # Issues and solutions
├── .github/          # CI/CD workflows
├── index.html        # Landing page
├── vercel.json       # Vercel configuration
├── README.md         # Main documentation
└── CLAUDE.md         # This file
```

## 🚀 CURRENT STATUS (v1.2.1):

### ✅ COMPLETED:
- **App**: TouchBarFix.app (Universal Binary - 298KB)
- **Security**: Process whitelisting, input validation, hardened runtime
- **Distribution**: TouchBarFix-1.2.1.dmg ready (2.2MB)
- **Website**: touchbarfix.com (Hosted on Vercel with SSL)
- **Landing Page**: SEO-optimized, high-converting design
- **CI/CD**: GitHub Actions for automated builds and tests
- **Testing**: Unit tests with proper mocking for CI environment
- **Repository**: Cleaned and organized structure
- **Documentation**: Comprehensive docs with lessons learned

### 🌐 HOSTING MIGRATION (COMPLETED):
- **From**: GitHub Pages (SSL issues due to repository rename)
- **To**: Vercel (successful deployment with custom domain)
- **Domain**: touchbarfix.com pointing to Vercel
- **SSL**: Automatic provisioning via Vercel

### 📋 RECENT CHANGES (August 20, 2025):
1. **Production CSS optimization (August 20)**
   - Replaced Tailwind CDN with production build (3MB → 77KB)
   - Added npm package management for Tailwind CSS v4
   - Eliminated console warnings for production deployment
   - Maintained all custom animations and styling
2. **Previous changes (August 19)**:
   - Migrated hosting from GitHub Pages to Vercel
   - Fixed CI/CD pipeline with updated GitHub Actions
   - Major project cleanup and documentation organization
   - Founders Edition launch with email capture system

## 🛠 DEVELOPMENT COMMANDS:

### ⚠️ CRITICAL: NEVER PUSH DIRECTLY TO MAIN!
**All changes must go through pull requests for CodeRabbit review**

```bash
# Navigate to project
cd /Users/floriansteiner/Documents/GitHub/touchbarfix

# ALWAYS CREATE FEATURE BRANCH FIRST
git checkout -b feature/your-feature-name
# or for fixes:
git checkout -b fix/issue-description

# Build app
cd App && swift build -c release

# Create release app with universal binary
./build-app.sh

# Create DMG installer
./create-dmg.sh

# Run tests
swift test

# Git operations (FEATURE BRANCH WORKFLOW)
git add -A
git commit -m "type: description"
git push -u origin feature/your-branch-name

# Create Pull Request
# Go to: https://github.com/ProduktEntdecker/touchbarfix
# Create PR and add @coderabbitai in description

# After CodeRabbit approval, merge via GitHub interface
# Then update local main:
git checkout main
git pull origin main

# Check CI/CD status
# Visit: https://github.com/ProduktEntdecker/touchbarfix/actions
```

### 📚 REQUIRED READING:
- **[DEVELOPMENT-WORKFLOW.md](DEVELOPMENT-WORKFLOW.md)** - Complete feature branch workflow
- **[3-operations/DEPLOYMENT-GUIDE.md](3-operations/DEPLOYMENT-GUIDE.md)** - Deployment procedures

## 🔗 IMPORTANT LINKS:
- **Website**: https://touchbarfix.com
- **Repository**: https://github.com/ProduktEntdecker/touchbarfix
- **Issues**: https://github.com/ProduktEntdecker/touchbarfix/issues
- **Releases**: https://github.com/ProduktEntdecker/touchbarfix/releases
- **Vercel Dashboard**: https://vercel.com/dashboard (for deployment management)

## ⚠️ CRITICAL REMINDERS:

### 🚨 NEVER DO:
- **PUSH DIRECTLY TO MAIN BRANCH** (breaks CodeRabbit review)
- Rename repository with active GitHub Pages
- Use deprecated GitHub Actions versions
- Create multiple index.html files in different directories
- Mix old branding ("restarter") with new branding ("fix")
- Make false claims (e.g., "requires admin password" - it doesn't!)

### ✅ ALWAYS DO:
- **USE FEATURE BRANCHES AND PULL REQUESTS** (for CodeRabbit review)
- Use TouchBarFix naming consistently
- Test CI/CD changes in feature branches
- Mock hardware dependencies in tests
- Keep single source of truth for files
- Document issues and solutions immediately
- Verify all marketing claims with actual code behavior

### 🔍 KEY FILES TO MONITOR:
- `Package.swift` - Executable name and dependencies
- `Info.plist` - Bundle identifiers and app metadata
- `.github/workflows/` - CI/CD pipeline configuration
- `vercel.json` - Deployment configuration
- `index.html` - Landing page (single location in root)

## 📊 PROJECT METRICS:
- **App Size**: 298KB (Universal Binary)
- **DMG Size**: 2.2MB
- **Test Coverage**: 6/7 tests passing
- **Security Rating**: Hardened with process validation
- **Deployment**: Automated via GitHub Actions + Vercel
- **Domain Status**: Active with SSL on touchbarfix.com

## 🎯 CURRENT STATUS: GUMROAD STORE LIVE (August 22, 2025 - Evening)

### **✅ COMPLETED AUGUST 22, 2025:**
1. ✅ **Gumroad Store Integration** - Live at produktentdecker.gumroad.com/l/touchbarfix
2. ✅ **CodeRabbit Integration** - Full MCP workflow documented and working
3. ✅ **System Requirements Standardized** - Consistent across all files
4. ✅ **URL Consistency Achieved** - All legacy URLs updated to canonical domain
5. ✅ **Documentation Cleanup** - Removed hardcoded file sizes and versions
6. ✅ **Landing Page Optimized** - Analytics, UTM tracking, external link security
7. ✅ **Deployment Issues Resolved** - Vercel configuration fixed

### **🚀 CURRENT PRODUCT STATUS:**
- **Price**: €2.99 on Gumroad (live and working)
- **Product**: TouchBarFix-1.2.1.dmg (notarized, 2.3MB)
- **Compatibility**: MacBook Pro 2016–2021, macOS 11 (Big Sur) through 14 (Sonoma)
- **Security**: No administrator privileges required
- **Revenue**: Ready to generate immediate sales

### **✅ INFRASTRUCTURE COMPLETE:**
- App signing and notarization (TouchBarFix-1.2.1.dmg)
- Gumroad store live and operational
- Landing page with proper analytics and conversion tracking
- CodeRabbit AI review integration via MCP
- Comprehensive documentation system
- CI/CD pipeline working correctly

### **🔄 NEXT PRIORITY (August 23, 2025):**
- **PRIMARY**: Launch marketing campaign to drive traffic to Gumroad store
- **SECONDARY**: App Store submission preparation
- **ONGOING**: Monitor sales and gather user feedback

## 💳 ZAPIER PROFESSIONAL TRIAL (August 20, 2025):
- **Trial Started**: August 20, 2025
- **Trial Expires**: August 27, 2025
- **Features**: Multi-step automation, 1,000 tasks/month, unlimited Zaps
- **Cost**: $29.99/month after trial
- **Current Use**: Email capture → Google Sheets → Gmail automation
- **Strategy**: Use for 48h Founders Edition campaign only
- **UX Issues**: Not entirely satisfied with user experience
- **Plan**: Research alternatives after campaign, cancel before August 27th
- **Alternatives to Research**: Make.com, n8n, custom solution

## 🎯 NEXT STEPS:
1. **IMMEDIATE**: Complete notarization and launch marketing campaign
2. **Short-term**: Create automated CI/CD pipeline for releases
3. **After 48h Campaign**: Research Zapier alternatives (Make.com, n8n, custom)
4. **By August 27th**: Cancel Zapier trial before auto-charge
5. **Week 1**: Convert founders to paid customers (€0.99)
6. **Long-term**: App Store submission and Version 2.0 planning

## 🏗️ AUTOMATION ROADMAP (August 20, 2025):
- **Goal**: Fully automated release pipeline
- **Trigger**: Git tag push (e.g., `git tag v1.2.2 && git push --tags`)
- **Process**: Build → Sign → Notarize → Deploy → Distribute
- **Platforms**: Website, Gumroad, App Store
- **Status**: Manual process documented, automation pending

---

**This project is PRODUCTION READY as of August 20, 2025**
**Landing page is LIVE at touchbarfix.com**
- ground product copy in validated facts, if in doubt double check in the documentation or the code base