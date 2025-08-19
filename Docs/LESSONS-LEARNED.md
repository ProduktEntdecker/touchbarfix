# Lessons Learned - TouchBarFix Project

This document captures all issues encountered during the TouchBarFix project development and their solutions, serving as a reference for future projects.

## Table of Contents
1. [GitHub Pages SSL Certificate Issues](#github-pages-ssl-certificate-issues)
2. [CI/CD Pipeline Failures](#cicd-pipeline-failures)
3. [Vercel Deployment Issues](#vercel-deployment-issues)
4. [Repository and Branding Changes](#repository-and-branding-changes)
5. [Testing Challenges](#testing-challenges)
6. [Key Takeaways](#key-takeaways)

---

## GitHub Pages SSL Certificate Issues

### Problem
After renaming the repository from "touchbar-restarter" to "touchbarfix", GitHub Pages SSL certificate provisioning failed repeatedly. The custom domain (touchbarfix.com) would:
- Show as configured in GitHub settings
- Disappear after a few minutes
- Fail SSL certificate provisioning with "DNS check unsuccessful"
- Create a permanent 301 redirect from the old repository name

### Root Cause
GitHub creates a permanent 301 redirect when a repository is renamed. This redirect interferes with:
1. SSL certificate provisioning through Let's Encrypt
2. DNS validation process
3. Custom domain configuration persistence

### Solution
**Migrated from GitHub Pages to Vercel** for hosting the landing page:
1. Removed GitHub Pages configuration entirely
2. Set up Vercel account and connected GitHub repository
3. Configured custom domain in Vercel
4. Updated DNS records to point to Vercel's servers

### Prevention
- **Never rename a repository** that has GitHub Pages with a custom domain active
- If rebranding is needed, create a new repository instead
- Consider using external hosting (Vercel, Netlify) from the start for production sites

---

## CI/CD Pipeline Failures

### Problem 1: Deprecated GitHub Actions
**Error**: "This request has been automatically failed because it uses a deprecated version of actions/upload-artifact: v3"

### Solution
Updated `.github/workflows/build-test.yml`:
```yaml
# Before
- uses: actions/upload-artifact@v3

# After
- uses: actions/upload-artifact@v4
- uses: actions/checkout@v4
```

### Problem 2: Swift Setup Action Failures
**Error**: swift-actions/setup-swift failing on GitHub runners

### Solution
Removed the action entirely and used pre-installed Swift:
```yaml
- name: Verify Swift Installation
  run: |
    swift --version
    xcodebuild -version
```

### Problem 3: Test Failures on CI Environment
**Error**: Tests failing because GitHub runners had Touch Bar processes running (even without Touch Bar hardware)

### Solution
Created proper mock classes for testing:
```swift
class MockTouchBarManager: TouchBarManager {
    var mockHasTouchBar: Bool = false
    
    func detectTouchBar() {
        hasTouchBar = mockHasTouchBar
    }
}
```

### Prevention
- Always use latest stable versions of GitHub Actions
- Mock hardware-dependent features in tests
- Test CI pipeline changes in a separate branch first

---

## Vercel Deployment Issues

### Problem 1: 404 NOT_FOUND Errors
Despite successful deployment, the site showed 404 errors.

### Root Cause Analysis
1. Multiple `index.html` files in different directories (`/`, `/docs/`, `/LandingPage/`)
2. Incorrect Output Directory configuration in Vercel
3. Conflicting `vercel.json` configurations

### Solution Process (Multiple Attempts)
1. **Attempt 1**: Used `rewrites` in vercel.json - Failed
2. **Attempt 2**: Set `outputDirectory: "docs"` - Failed
3. **Attempt 3**: Removed vercel.json entirely - Failed
4. **Final Solution**: 
   - Moved `index.html` to repository root
   - Set Output Directory to `.` (root) in Vercel settings
   - Used minimal `vercel.json`:
   ```json
   {
     "framework": null
   }
   ```

### Problem 2: DNS Configuration
CNAME records pointing to old Vercel subdomains caused issues.

### Solution
Updated DNS records at domain registrar:
- A record: `@` → `216.198.79.1` (Vercel's IP)
- CNAME: `www` → `cname.vercel-dns.com`

### Prevention
- Keep single source of truth for static files
- Start with minimal configuration and add complexity as needed
- Document DNS changes immediately

---

## Repository and Branding Changes

### Problem
Inconsistent naming across the project after rebrand from "Touch Bar Restarter" to "TouchBarFix":
- Repository name mismatch
- Old references in code
- Asset naming inconsistencies

### Solution
1. Systematic search and replace across all files
2. Renamed assets (e.g., `TouchBarRestartIcon.png` → `TouchBarIcon.png`)
3. Updated all documentation and configuration files
4. Cleaned up old directories and files

### Prevention
- Plan branding carefully before initial release
- Use configuration files for brand-specific values
- Maintain a branding checklist for consistency

---

## Testing Challenges

### Problem
Mock testing for hardware-specific features (Touch Bar detection) failed in CI environment.

### Issues Encountered
1. `override` keyword used for non-existent parent methods
2. Unused variable warnings in tests
3. Hardware detection in environments without hardware

### Solution
```swift
// Removed override keyword
func detectTouchBar() {
    hasTouchBar = mockHasTouchBar
}

// Fixed unused variable warning
let _ = touchBarManager.checkIfProcessRunning("TouchBarServer")
```

### Prevention
- Design testable code from the start with dependency injection
- Create comprehensive mock objects for hardware features
- Run tests locally in CI-like environment before pushing

---

## Key Takeaways

### 1. Infrastructure Decisions
- **Choose hosting platform carefully**: GitHub Pages has limitations with custom domains and SSL
- **Vercel/Netlify are better for production**: More control over deployments and SSL
- **Don't rename repositories with active services**: Creates permanent redirects that break things

### 2. CI/CD Best Practices
- **Keep GitHub Actions updated**: Use Dependabot to track action updates
- **Test pipeline changes separately**: Use feature branches for CI/CD modifications
- **Mock everything external**: Don't rely on system state in tests

### 3. Project Organization
- **Single source of truth**: One location for each type of file
- **Clean as you go**: Don't accumulate technical debt
- **Document immediately**: Write documentation while context is fresh

### 4. DNS and SSL
- **Understand DNS propagation**: Changes take time (5-48 hours)
- **Keep DNS records simple**: Minimize CNAME chains
- **Document DNS changes**: Track what was changed and why

### 5. Testing Strategy
- **Design for testability**: Use dependency injection and protocols
- **Mock external dependencies**: Hardware, network, file system
- **Test in CI-like environment locally**: Use same OS version and tools

### 6. Version Control
- **Commit atomic changes**: One logical change per commit
- **Write descriptive commit messages**: Include the "why"
- **Use conventional commits**: feat:, fix:, docs:, refactor:

### 7. Documentation
- **Keep README current**: First thing people see
- **Archive don't delete**: Move old docs to archive folder
- **Document failures**: Learn from mistakes

---

## Specific Commands and Configurations

### Successful Vercel Configuration
```json
{
  "framework": null
}
```

### DNS Configuration for Vercel
```
A     @     216.198.79.1
CNAME www   cname.vercel-dns.com
```

### GitHub Actions Configuration
```yaml
runs-on: macos-14  # Use specific version, not latest
uses: actions/checkout@v4  # Use v4, not v3
uses: actions/upload-artifact@v4  # Use v4, not v3
```

### Project Structure Best Practice
```
project/
├── App/           # Application code
├── docs/          # Documentation
│   └── archive/   # Historical docs
├── Assets/        # Media and resources
├── .github/       # GitHub specific
├── index.html     # Landing page (if needed)
└── README.md      # Current documentation
```

---

## Conclusion

The TouchBarFix project encountered multiple infrastructure and deployment challenges, primarily stemming from:
1. Repository renaming with active GitHub Pages
2. Outdated CI/CD configurations
3. Multiple deployment attempts with different configurations

The key lesson is to **plan infrastructure carefully** from the start and **avoid renaming repositories** with active services. When issues arise, **document solutions immediately** for future reference.

---

*Last Updated: August 19, 2025*
*Project: TouchBarFix*
*Author: Dr. Florian Steiner*