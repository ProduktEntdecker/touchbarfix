# TouchBarFix Deployment Guide

This guide provides step-by-step instructions for deploying TouchBarFix to production environments.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Landing Page Deployment (Vercel)](#landing-page-deployment-vercel)
3. [App Distribution](#app-distribution)
4. [CI/CD Pipeline](#cicd-pipeline)
5. [Monitoring and Maintenance](#monitoring-and-maintenance)

---

## Prerequisites

### Required Accounts
- [Vercel Account](https://vercel.com) - For landing page hosting
- [Apple Developer Account](https://developer.apple.com) - For code signing (optional)
- Domain registrar access - For DNS management

### Required Tools
- Xcode 14.0+ with Command Line Tools
- Swift 5.7+
- Git
- Domain access for DNS configuration

---

## Landing Page Deployment (Vercel)

### Step 1: Connect Repository to Vercel
1. Sign up/login to [Vercel](https://vercel.com)
2. Click "New Project" 
3. Import from GitHub: `ProduktEntdecker/touchbarfix`
4. Configure project:
   - **Framework Preset**: Other
   - **Root Directory**: Leave empty (uses repository root)
   - **Build Command**: Leave empty
   - **Output Directory**: Leave empty or set to `.`

### Step 2: Configure Domain
1. Go to **Settings > Domains** in Vercel
2. Add your domain: `touchbarfix.com`
3. Add www subdomain: `www.touchbarfix.com`
4. Vercel will provide DNS records to configure

### Step 3: DNS Configuration
Configure these records at your domain registrar:

```
Type    Name    Value
A       @       216.198.79.1
CNAME   www     cname.vercel-dns.com
```

### Step 4: Verify Deployment
- Visit your domain to ensure it loads correctly
- Check SSL certificate is provisioned (green lock icon)
- Test both `yourdomain.com` and `www.yourdomain.com`

### Vercel Configuration File
Ensure `vercel.json` in repository root contains:
```json
{
  "framework": null
}
```

---

## App Distribution

### Option 1: Direct Distribution (Current Method)

#### Build Universal Binary
```bash
cd App
./build-app.sh
```

#### Create DMG Installer
```bash
./create-dmg.sh
```

#### Manual Distribution
1. Upload DMG to GitHub Releases
2. Update landing page download links
3. Test download and installation process

### Option 2: Apple Developer Program (Recommended for Production)

#### Setup Code Signing
1. Enroll in Apple Developer Program ($99/year)
2. Create Developer ID Application certificate
3. Update build scripts with code signing:

```bash
# In build-app.sh, add:
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" TouchBarFix.app
```

#### Notarization (Required for macOS 10.15+)
```bash
# Notarize the app
xcrun notarytool submit TouchBarFix.app --keychain-profile "notary-profile" --wait
```

---

## CI/CD Pipeline

### GitHub Actions Configuration

The project uses `.github/workflows/build-test.yml` for CI/CD:

#### Key Components:
- **Trigger**: Push to main/develop branches, PRs to main
- **Platform**: macOS-14 runners
- **Swift**: Uses pre-installed Swift (no third-party actions)
- **Testing**: Runs unit tests with hardware mocking
- **Artifacts**: Uploads build artifacts for inspection

#### Workflow File Structure:
```yaml
name: Build and Test
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-14
    steps:
    - uses: actions/checkout@v4
    - name: Build TouchBarFix
      run: cd App && swift build -c release
    - name: Run Tests  
      run: cd App && swift test
    - uses: actions/upload-artifact@v4
```

#### Release Workflow
For tagged releases, use `.github/workflows/release.yml`:
- Builds universal binary
- Creates DMG installer  
- Uploads to GitHub Releases with auto-generated notes

### Triggering Releases
```bash
# Create and push a tag
git tag v1.2.2
git push origin v1.2.2
```

---

## Monitoring and Maintenance

### Health Checks

#### Landing Page
- Monitor Vercel deployment status
- Check SSL certificate validity
- Verify DNS resolution

```bash
# Test DNS resolution
dig touchbarfix.com A
dig www.touchbarfix.com CNAME

# Check SSL certificate
openssl s_client -connect touchbarfix.com:443 -servername touchbarfix.com
```

#### CI/CD Pipeline
- Monitor GitHub Actions status
- Check for deprecated action warnings
- Review security alerts

### Updates and Maintenance

#### Dependency Updates
```bash
# Check for Swift package updates
cd App
swift package update
```

#### GitHub Actions Updates
Use Dependabot to keep actions current:
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

#### Domain and SSL Renewal
- Vercel handles SSL certificate renewal automatically
- Monitor domain expiration date
- Keep DNS records current

### Website Favicons and Caching

- Favicons are stored in `Assets/` and served from root URLs via `vercel.json` rewrites:
  - `/favicon.ico` → `Assets/favicon.ico`
  - `/apple-touch-icon.png` → `Assets/apple-touch-icon.png`
- `index.html` includes minimal, Apple‑focused links only:
  - `<link rel="icon" href="/favicon.ico" sizes="any">`
  - `<link rel="apple-touch-icon" href="/apple-touch-icon.png">`
- Long‑lived caching is configured in `vercel.json` for these routes:
  - `Cache-Control: public, max-age=31536000, immutable`
- If icons change, bump a versioned filename or invalidate via redeploy. Ensure rewrites and headers are kept in sync.

---

## Troubleshooting

### Common Issues

#### Vercel 404 Errors
**Problem**: Site shows 404 NOT_FOUND
**Solution**: 
1. Ensure `index.html` is in repository root
2. Verify Output Directory is set correctly (`.` or empty)
3. Check vercel.json configuration

#### SSL Certificate Issues  
**Problem**: SSL certificate not provisioning
**Solution**:
1. Verify DNS records are correct
2. Wait for DNS propagation (up to 48 hours)
3. Use simple DNS setup (avoid CNAME chains)

#### CI/CD Failures
**Problem**: Tests failing on GitHub runners
**Solution**:
1. Check for hardware dependencies in tests
2. Update mock objects to avoid system dependencies
3. Verify GitHub Actions versions are current

#### Domain Not Working
**Problem**: Custom domain shows errors
**Solution**:
1. Check DNS propagation: `dig yourdomain.com`
2. Verify A record points to correct IP
3. Ensure CNAME uses `cname.vercel-dns.com`

### Emergency Rollback

If deployment issues occur:

#### Vercel Rollback
1. Go to Vercel Dashboard > Deployments
2. Find previous working deployment
3. Click "Promote to Production"

#### DNS Issues
1. Temporarily point domain to GitHub Pages or backup
2. Update A record to backup server
3. Fix issues, then switch back

---

## Security Considerations

### Best Practices
- Use HTTPS everywhere (automatic with Vercel)
- Keep dependencies updated  
- Monitor for security vulnerabilities
- Use signed releases for app distribution
- Implement CSP headers for landing page

### Code Signing
For production apps:
```bash
# Sign the app
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" TouchBarFix.app

# Verify signing
codesign --verify --deep TouchBarFix.app
spctl --assess --verbose TouchBarFix.app
```

---

## Performance Optimization

### Landing Page
- Use Vercel's built-in CDN
- Optimize images and assets
- Implement proper caching headers
- Monitor Core Web Vitals

### App Distribution
- Keep DMG size minimal
- Use universal binaries for best performance
- Test on both Intel and Apple Silicon

---

## Conclusion

This deployment setup provides:
✅ Automated CI/CD with GitHub Actions  
✅ Production-ready hosting on Vercel  
✅ Custom domain with automatic SSL  
✅ Reliable app distribution via GitHub Releases  

Follow this guide for consistent, reliable deployments of TouchBarFix.

---

*Last Updated: August 19, 2025*  
*Project: TouchBarFix*  
*Author: Dr. Florian Steiner*
