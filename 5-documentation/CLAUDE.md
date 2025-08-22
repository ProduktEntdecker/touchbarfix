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

## 🚨 CRITICAL TERMINAL PERMISSIONS:
**IMPORTANT**: Terminal needs Full Disk Access for DMG creation and app signing
- System Settings → Privacy & Security → Full Disk Access → Enable Terminal.app
- Restart Terminal after granting permissions for changes to take effect

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

```bash
# Navigate to project
cd /Users/floriansteiner/Documents/GitHub/touchbarfix

# Build app
cd App && swift build -c release

# Create release app with universal binary
./build-app.sh

# Create DMG installer
./create-dmg.sh

# Run tests
swift test

# Git operations
git add . && git commit -m "message" && git push origin main

# Check CI/CD status
# Visit: https://github.com/ProduktEntdecker/touchbarfix/actions
```

## 🔗 IMPORTANT LINKS:
- **Website**: https://touchbarfix.com
- **Repository**: https://github.com/ProduktEntdecker/touchbarfix
- **Issues**: https://github.com/ProduktEntdecker/touchbarfix/issues
- **Releases**: https://github.com/ProduktEntdecker/touchbarfix/releases
- **Vercel Dashboard**: https://vercel.com/dashboard (for deployment management)

## ⚠️ CRITICAL REMINDERS:

### 🚨 NEVER DO:
- Rename repository with active GitHub Pages
- Use deprecated GitHub Actions versions
- Create multiple index.html files in different directories
- Mix old branding ("restarter") with new branding ("fix")
- **❌ NEVER RELEASE WITHOUT NOTARIZATION** - App changes break notarization
- **❌ NEVER CODE CHANGES ON LAUNCH DAY** - Notarization takes 2-4 hours minimum

### ✅ ALWAYS DO:
- Use TouchBarFix naming consistently
- Test CI/CD changes in feature branches
- Mock hardware dependencies in tests
- Keep single source of truth for files
- Document issues and solutions immediately
- **✅ VERIFY NOTARIZATION** - Run `spctl -a -vvv app.app` before any release
- **✅ FEATURE FREEZE 24H BEFORE LAUNCH** - No code changes near planned launches
- **✅ MAINTAIN ROLLBACK APP** - Keep last notarized version as emergency backup

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

## 🎯 CURRENT STATUS: FOUNDERS EDITION LIVE (August 19, 2025 - Evening)

### **✅ COMPLETED TODAY:**
1. ✅ Landing page conversion optimization (Peep Laja treatment)
2. ✅ FREE Founders Edition launch (48-hour limited offer)
3. ✅ Email capture system with modal and analytics
4. ✅ Direct DMG download functionality
5. ✅ CI/CD pipeline fixes (all tests passing)
6. ✅ Vercel deployment configuration secured

### **🚀 FOUNDERS EDITION STRATEGY:**
- **Phase 1**: FREE for 48 hours (during Apple Developer wait)
- **Phase 2**: €0.99 for first 100 customers  
- **Phase 3**: €6.99 regular pricing
- **Goal**: Build email list + testimonials before paid launch

### **📊 SUCCESS METRICS (Next 48 Hours):**
- **Target**: 100+ email signups
- **Conversion**: Email capture rate from visitors
- **Validation**: User feedback and testimonials
- **Preparation**: Ready for €0.99 paid launch when Apple Developer activates

### **✅ PRODUCTION READY:**
- ✅ Apple Developer Program ACTIVE (notarization working)
- ✅ App signed and notarized 
- ✅ DMG created with review-enabled app
- ✅ In-app review request system implemented
- ✅ Review landing page at /review.html

### **📈 MARKETING READY:**
- Reddit launch posts prepared
- HackerNews submission ready
- "FREE for 48 hours" messaging
- Email list building phase active

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

## 🚀 LAUNCH STRATEGY - 100 Downloads & Reviews:

### **IMMEDIATE (Next 2 Hours):**
1. ✅ **Phase 1**: Launch Reddit r/MacBookPro campaign  
2. ✅ **Phase 2**: Submit to HackerNews
3. ✅ **Phase 3**: Twitter/X thread launch
4. ✅ **Monitor**: In-app review conversions via /review.html

### **SUCCESS METRICS:**
- **6 Hours**: 50 downloads, 5 reviews
- **24 Hours**: 100 downloads, 15 reviews  
- **48 Hours**: 150+ downloads, 25+ reviews

### **REVIEW CONVERSION SYSTEM:**
- ✅ In-app prompt after successful Touch Bar fix
- ✅ Review landing page with social sharing
- ✅ Email follow-up campaign (24h delay)
- ✅ Social proof amplification

### **MEDIUM-TERM:**
- Research Zapier alternatives (Make.com, n8n)
- Cancel Zapier trial before August 27th
- Convert founders to €0.99 paid customers
- App Store submission planning

## 🏗️ AUTOMATION ROADMAP (August 20, 2025):
- **Goal**: Fully automated release pipeline
- **Trigger**: Git tag push (e.g., `git tag v1.2.2 && git push --tags`)
- **Process**: Build → Sign → Notarize → Deploy → Distribute
- **Platforms**: Website, Gumroad, App Store
- **Status**: Manual process documented, automation pending

---

**This project is PRODUCTION READY as of August 20, 2025**
**Landing page is LIVE at touchbarfix.com**
- Always use Euro as a currency.