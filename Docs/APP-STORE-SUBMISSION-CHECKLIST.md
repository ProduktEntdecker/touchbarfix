# 📱 APP STORE SUBMISSION CHECKLIST

**Date:** August 19, 2025  
**App:** TouchBarFix v1.2.1  
**Target:** Mac App Store + Gumroad Distribution

---

## 🍎 APPLE DEVELOPER REQUIREMENTS

### **Certificates Needed:**
- [ ] **Apple Development** (for testing)
- [ ] **Mac App Distribution** (for App Store)
- [ ] **Developer ID Application** (for Gumroad/direct sales)

### **Provisioning Profiles:**
- [ ] **Mac App Store** provisioning profile
- [ ] Bundle ID: `com.produktentdecker.touchbarfix`

### **App Store Connect Setup:**
- [ ] Create app record in App Store Connect
- [ ] Set up app metadata:
  - **Name:** TouchBarFix
  - **Subtitle:** MacBook Pro Touch Bar Fix
  - **Description:** One-click solution to fix frozen/black Touch Bar issues
  - **Keywords:** touch bar, macbook pro, fix, utility, repair
  - **Category:** Utilities
  - **Price:** €6.99

### **Screenshots Required (Mac):**
- [ ] 1280x800 (16:10 aspect ratio) - Main app window
- [ ] 1440x900 (16:10 aspect ratio) - Success dialog
- [ ] Optional: Additional feature screenshots

---

## 📋 APP METADATA

### **App Store Description:**
```
TouchBarFix - One-Click MacBook Pro Solution

Fix your frozen, black, or unresponsive MacBook Pro Touch Bar in seconds. No Terminal commands, no restarts required.

FEATURES:
• One-click Touch Bar restart
• Works on all Touch Bar MacBook Pro (2016-2021)
• Safe system process management
• Universal Binary (Intel + Apple Silicon)
• Secure, notarized application

COMPATIBLE MODELS:
• MacBook Pro 13" (2016-2021)
• MacBook Pro 15" (2016-2019)
• MacBook Pro 16" (2019-2021)
• All Intel and Apple Silicon variants

SAVES YOU TIME & MONEY:
• Avoid €700 Apple hardware repair
• Fix issues instantly vs days at service center
• No technical knowledge required

SECURITY & PRIVACY:
• Process whitelisting for safety
• No personal data collection
• Apple Developer Program certified
• Hardened runtime protection

Perfect for professionals, students, and anyone frustrated with Touch Bar issues after macOS updates.
```

### **Release Notes:**
```
Version 1.2.1 - Launch Release

NEW FEATURES:
• Complete Touch Bar process restart system
• Automatic Touch Bar detection for supported models
• Universal Binary support (Intel + Apple Silicon)
• Security-hardened architecture with process validation

IMPROVEMENTS:
• Enhanced UI with clear status feedback
• Comprehensive error handling and logging
• Single-instance protection
• 30-day satisfaction guarantee

COMPATIBILITY:
• macOS 13.0 (Ventura) or later
• All MacBook Pro models with Touch Bar (2016-2021)
• Intel and Apple Silicon processors

This initial release provides a reliable, one-click solution to the most common Touch Bar software issues affecting MacBook Pro users.
```

---

## 🔐 CODE SIGNING COMMANDS

### **Development Build:**
```bash
codesign --deep --force --verify --verbose \
  --sign "Apple Development: YOUR_NAME" \
  --entitlements Resources/TouchBarFix.entitlements \
  Release/TouchBarFix.app
```

### **App Store Distribution:**
```bash
codesign --deep --force --verify --verbose \
  --sign "3rd Party Mac Developer Application: YOUR_NAME" \
  --entitlements Resources/TouchBarFix.entitlements \
  --options runtime \
  Release/TouchBarFix.app
```

### **Direct Distribution (Gumroad):**
```bash
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: YOUR_NAME" \
  --entitlements Resources/TouchBarFix.entitlements \
  --options runtime \
  Release/TouchBarFix.app
```

### **Verification:**
```bash
codesign --verify --deep --strict --verbose=2 Release/TouchBarFix.app
spctl -a -t exec -vv Release/TouchBarFix.app
```

---

## 📦 NOTARIZATION PROCESS

### **Create Archive:**
```bash
ditto -c -k --keepParent Release/TouchBarFix.app TouchBarFix.zip
```

### **Submit for Notarization:**
```bash
xcrun notarytool submit TouchBarFix.zip \
  --apple-id YOUR_APPLE_ID \
  --password YOUR_APP_PASSWORD \
  --team-id YOUR_TEAM_ID \
  --wait
```

### **Check Status:**
```bash
xcrun notarytool history --apple-id YOUR_APPLE_ID --password YOUR_APP_PASSWORD
```

### **Staple Notarization:**
```bash
xcrun stapler staple Release/TouchBarFix.app
xcrun stapler validate Release/TouchBarFix.app
```

---

## 🚀 DISTRIBUTION CHANNELS

### **1. Gumroad (Primary - 90% revenue share):**
- [ ] Upload notarized DMG
- [ ] Set price: €6.99
- [ ] Configure instant download
- [ ] Add product description and images

### **2. Mac App Store (Secondary - 70% revenue share):**
- [ ] Submit signed app via Xcode or Transporter
- [ ] Complete App Store Connect metadata
- [ ] Add screenshots and preview videos
- [ ] Submit for review

---

## ✅ SUBMISSION CHECKLIST

### **Technical Requirements:**
- [ ] App builds without warnings
- [ ] All tests pass (6/7 - mock test expected to fail)
- [ ] Universal Binary created
- [ ] Code signed with valid certificates
- [ ] Notarized by Apple
- [ ] Hardened Runtime enabled
- [ ] Entitlements file configured

### **Content Requirements:**
- [ ] App icon (1024x1024 PNG)
- [ ] Screenshots (1280x800, 1440x900)
- [ ] App Store description
- [ ] Keywords and metadata
- [ ] Privacy policy URL
- [ ] Support URL

### **Business Requirements:**
- [ ] Apple Developer Program membership active
- [ ] Tax and banking info set up in App Store Connect
- [ ] Pricing tier selected (€6.99)
- [ ] Age rating completed
- [ ] Export compliance determined

---

## 📱 APP STORE REVIEW PREPARATION

### **Common Rejection Reasons to Avoid:**
- [ ] **Functionality:** App must work as described
- [ ] **UI Design:** Follow Apple Human Interface Guidelines
- [ ] **Metadata:** Accurate description and screenshots
- [ ] **Legal:** Proper privacy policy and terms
- [ ] **Safety:** No harmful or misleading functionality

### **TouchBarFix Specific Considerations:**
- [ ] Clearly explain system process management is safe
- [ ] Show benefit vs risk (€6.99 vs €700 repair)
- [ ] Demonstrate actual functionality in screenshots
- [ ] Explain macOS compatibility requirements

---

**Estimated Timeline:**
- Code signing setup: 1-2 hours
- Notarization: 15-30 minutes
- App Store submission: 1 hour
- Review process: 1-7 days

**Next Step:** Set up Apple Developer certificates and begin code signing process.