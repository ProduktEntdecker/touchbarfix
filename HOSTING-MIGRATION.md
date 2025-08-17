# 🔄 Hosting Migration: GitHub Pages → Vercel

**Date:** August 17, 2024  
**Decision:** Migrate landing page hosting from GitHub Pages to Vercel  
**Reason:** GitHub repository redirect causing persistent SSL and domain issues

---

## 🚨 **Root Cause Analysis**

### **The Problem:**
When we renamed the repository from `touchbar-restarter` to `touchbarfix`, GitHub created an automatic 301 redirect. This redirect fundamentally broke GitHub Pages functionality:

1. **SSL Certificate Provisioning Failed**
   - GitHub Pages couldn't verify domain ownership due to redirect confusion
   - Custom domain settings wouldn't persist in repository settings
   - HTTPS enforcement remained disabled despite multiple attempts

2. **Intermittent 404 Errors**
   - Site worked on Day 1, failed on Day 2
   - GitHub's CDN was confused about which repository to serve from
   - CNAME file conflicts with redirect mechanism

3. **Domain Verification Issues**
   - DNS check would succeed but immediately fail
   - Custom domain setting would vanish from repository settings
   - Old repository name appeared in build artifacts and error messages

### **Technical Evidence:**
- Path references to `/Users/floriansteiner/Documents/GitHub/touchbar-restarter` in build artifacts
- HTTP redirects from `touchbarfix.com` to `www.touchbarfix.com`
- GitHub Pages serving 404 despite correct CNAME file in `/docs/CNAME`
- DNS verification succeeding but SSL remaining unavailable

---

## 📚 **Key Learnings**

### **Repository Renaming Impact:**
1. **GitHub's 301 redirects are permanent** and can interfere with services like GitHub Pages
2. **Domain-based services** (SSL, CDN, Pages) may not properly handle redirected repositories
3. **Build systems retain old paths** in compiled artifacts and dependency files
4. **CI/CD systems** can be confused by repository identity changes

### **GitHub Pages Limitations:**
1. **Not resilient to repository redirects** - unlike regular web services
2. **SSL certificate provisioning is fragile** - breaks easily with DNS/redirect issues
3. **Custom domain persistence problems** when repository identity is ambiguous
4. **Limited debugging capabilities** - errors are not descriptive

### **Best Practices Identified:**
1. **Choose repository names carefully** - renaming has hidden costs
2. **Use dedicated hosting for production sites** - GitHub Pages is better for documentation
3. **Separate development infrastructure from production hosting**
4. **Test hosting setups early** in development cycle

---

## 🎯 **Migration Decision**

### **Why Vercel:**
1. **Clean Slate**: No repository redirect issues
2. **Superior SSL**: Automatic certificates with zero configuration
3. **Better Performance**: Global edge network vs GitHub's CDN
4. **Developer Experience**: Better deployment pipeline and debugging
5. **Reliability**: Production-grade hosting for professional sites

### **Migration Scope:**
- **Moving**: Landing page hosting (`docs/index.html` → Vercel)
- **Staying**: Repository, CI/CD, app builds, documentation (GitHub)
- **Workflow**: GitHub commits → Vercel auto-deploys (same developer experience)

### **Business Impact:**
- **Positive**: Faster, more reliable site with immediate SSL
- **Neutral**: Same development workflow, same repository
- **Cost**: $0 (Vercel free tier sufficient for our traffic)

---

## 📋 **Action Items**

### **Immediate (Next 2 hours):**
- [ ] Set up Vercel account and connect to GitHub
- [ ] Configure custom domain (touchbarfix.com)
- [ ] Update DNS records to point to Vercel
- [ ] Test SSL certificate automatic provisioning
- [ ] Verify site loads correctly with all assets

### **Follow-up (Next 24 hours):**
- [ ] Update documentation to reflect Vercel hosting
- [ ] Remove GitHub Pages configuration
- [ ] Update any hardcoded GitHub Pages URLs
- [ ] Test analytics integration (Plausible)
- [ ] Monitor site performance and uptime

### **Documentation Updates:**
- [ ] Update README.md with new hosting information
- [ ] Modify DevOps setup guide
- [ ] Update Business Plan deployment strategy
- [ ] Add this migration document to repository

---

## 🔄 **Rollback Plan**

If Vercel migration fails:

1. **Option A**: Create fresh GitHub repository without redirects
2. **Option B**: Use Google Workspace hosting (user has subscription)
3. **Option C**: AWS S3 + CloudFront setup
4. **Option D**: Netlify as Vercel alternative

---

## 📊 **Success Metrics**

- [ ] touchbarfix.com loads with HTTPS enabled
- [ ] SSL certificate automatically provisioned
- [ ] Plausible analytics working
- [ ] Page load time < 2 seconds
- [ ] 100% uptime for 48 hours post-migration

---

## 💡 **Future Recommendations**

1. **Repository Management**:
   - Never rename repositories with active GitHub Pages sites
   - Use organization repositories for production services
   - Plan repository structure before public launch

2. **Hosting Strategy**:
   - Use dedicated hosting for production websites
   - Reserve GitHub Pages for documentation and development
   - Implement proper DNS management from day one

3. **Infrastructure**:
   - Separate development tooling from production services
   - Use infrastructure-as-code for reproducible setups
   - Monitor hosting service health independently

---

**Decision Maker:** CTO (Claude)  
**Approved By:** Product Owner  
**Implementation Date:** August 17, 2024  
**Review Date:** August 24, 2024