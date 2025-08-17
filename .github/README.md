# GitHub Configuration for TouchBarFix

## Branch Protection Rules

### Main Branch Protection
1. Go to Settings → Branches
2. Add rule for `main`
3. Enable these settings:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1)
   - ✅ Dismiss stale pull request approvals
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date
   - ✅ Require conversation resolution
   - ✅ Include administrators
   - ✅ Restrict who can push (only CI/CD)

### Develop Branch Protection
1. Add rule for `develop`
2. Enable:
   - ✅ Require pull request reviews
   - ✅ Require status checks
   - ⬜ Allow force pushes (for maintainers only)

## GitHub Actions Secrets

Add these secrets in Settings → Secrets and variables → Actions:

- `APPLE_DEVELOPER_ID`: Your Apple Developer certificate ID
- `APPLE_DEVELOPER_PASSWORD`: Certificate password
- `NOTARIZATION_USERNAME`: Apple ID for notarization
- `NOTARIZATION_PASSWORD`: App-specific password

## Workflows

### Configured Workflows:
1. **build-test.yml** - Runs on every push and PR
2. **release.yml** - Creates releases on version tags
3. **deploy-pages.yml** - Deploys website updates (coming soon)

## Labels

Create these labels for issues and PRs:

- `bug` (red) - Something isn't working
- `enhancement` (blue) - New feature or request
- `documentation` (light blue) - Documentation improvements
- `security` (dark red) - Security vulnerabilities
- `ci/cd` (purple) - CI/CD pipeline changes
- `hotfix` (orange) - Critical production fixes
- `wontfix` (white) - This will not be worked on
- `duplicate` (gray) - This issue or PR already exists

## Milestones

Current milestones:
- v1.3.0 - Auto-update feature
- v1.4.0 - Analytics integration
- v2.0.0 - App Store release

## Team Access

Recommended team structure:
- **Maintainers**: Full access
- **Developers**: Write access, no admin
- **Contributors**: Read access, fork workflow