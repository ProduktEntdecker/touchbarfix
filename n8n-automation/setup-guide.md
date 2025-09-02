# 🚀 N8N Setup Guide - TouchBarFix Content Engine

## Quick Start (30 Minutes to Full Automation)

### Prerequisites Checklist:
- [ ] N8N Cloud account (or self-hosted)
- [ ] OpenAI API key
- [ ] Reddit account (15+ days old, 50+ karma)
- [ ] Google Account for Sheets
- [ ] Email for notifications

## Step 1: Create Reddit App (5 minutes)

1. Go to: https://www.reddit.com/prefs/apps
2. Click "Create App" or "Create Another App"
3. Fill out:
   - **Name**: TouchBarFix Helper
   - **Type**: Script
   - **Description**: Helps Mac users with Touch Bar issues
   - **About URL**: https://touchbarfix.com
   - **Redirect URI**: http://localhost:8080
4. Save your `client_id` and `client_secret`

## Step 2: Set Up Google Sheets Database (5 minutes)

1. Create new Google Sheet: "TouchBarFix Content Database"
2. Add headers in row 1:
   ```
   A: timestamp | B: title | C: content | D: platform | E: subreddit | F: quality_score | G: status | H: reddit_url | I: upvotes | J: comments | K: engagement_rate | L: is_viral | M: last_checked
   ```
3. Share sheet with your N8N Google account
4. Copy the Sheet ID from URL

## Step 3: N8N Cloud Setup (10 minutes)

### 3.1 Create Account:
1. Go to https://n8n.cloud
2. Sign up for Starter plan (€20/month)
3. Complete email verification

### 3.2 Add Credentials:

#### OpenAI API:
1. N8N → Credentials → Add Credential
2. Select "OpenAI API"
3. Enter your API key
4. Name: "OpenAI TouchBarFix"

#### Google Sheets:
1. Credentials → Add Credential → "Google Sheets API"
2. Use OAuth2 flow
3. Grant permissions
4. Name: "Google Sheets TouchBarFix"

#### Reddit API:
1. Credentials → Add Credential → "Reddit API"
2. Enter client_id and client_secret from Step 1
3. Complete OAuth flow
4. Name: "Reddit TouchBarFix"

## Step 4: Import Workflows (5 minutes)

1. Go to N8N → Workflows → Import from File
2. Import these files in order:
   - `01-content-engine.json`
   - `02-reddit-publisher.json`  
   - `03-performance-monitor.json`

3. For each workflow:
   - Update credential references
   - Replace "YOUR_SHEET_ID" with actual Sheet ID
   - Replace "YOUR_EMAIL@domain.com" with your email

## Step 5: Configuration Updates (5 minutes)

### In Content Engine Workflow:
```javascript
// Update the OpenAI prompt for your brand voice
"You are a content creator for TouchBarFix, a €2.99 Mac utility that fixes Touch Bar freezing issues in MacBook Pro 2016-2021. Create helpful, authentic content that provides value first, product promotion second."
```

### In Reddit Publisher:
```javascript
// Update User-Agent
"User-Agent": "TouchBarFixBot/1.0 by u/YOUR_REDDIT_USERNAME"
```

### In Performance Monitor:
```javascript
// Update email addresses for alerts
"fromEmail": "alerts@yourdomain.com",
"toEmail": "your-email@domain.com"
```

## Step 6: Test Run (5 minutes)

1. **Manual Test Content Engine**:
   - Open `01-content-engine.json`
   - Click "Execute Workflow" 
   - Check Google Sheets for new content

2. **Test Reddit Publisher**:
   - Manual trigger with test data
   - Verify post appears on Reddit
   - Check for errors in execution log

3. **Test Performance Monitor**:
   - Run once manually
   - Verify metrics collection works

## Step 7: Go Live (1 minute)

1. Enable all workflows
2. Set to "Active" 
3. Check execution logs for first 24 hours
4. Monitor Google Sheets for content creation

## Daily Operations (15 minutes/day)

### Morning Check (9:30 AM):
1. **N8N Dashboard**: Check overnight executions
2. **Google Sheets**: Review generated content
3. **Reddit**: Engage with comments on recent posts
4. **Quality Control**: Approve/edit today's scheduled content

### Weekly Review (Fridays, 30 minutes):
1. Export performance data
2. Update successful content templates
3. Adjust OpenAI prompts if needed
4. Plan any manual high-effort posts

## Troubleshooting

### Common Issues:

**"Reddit API Rate Limit"**
- Solution: Increase delays between posts
- Check: Reddit API limits (1 request/second)

**"OpenAI API Error"**  
- Solution: Check API quota and billing
- Fallback: Use GPT-3.5 if GPT-4 fails

**"Google Sheets Permission Denied"**
- Solution: Re-authenticate Google credentials
- Check: Sheet sharing permissions

**"Low Quality Score"**
- Solution: Adjust OpenAI prompts
- Review: Rejected content patterns

### Success Indicators:
- [ ] Content generates daily without errors
- [ ] Reddit posts get 10+ upvotes consistently  
- [ ] No account warnings or bans
- [ ] Traffic to touchbarfix.com increases
- [ ] Email alerts for viral content (>50 upvotes)

## Scaling Options

### Month 1 - Optimization:
- A/B test content formats
- Add Twitter integration  
- Implement comment automation
- Refine targeting algorithms

### Month 2 - Expansion:
- Add Medium and Dev.to publishing
- Create video content pipeline
- Build email capture workflows
- Implement advanced analytics

### Month 3 - Full Scale:
- Multi-language content
- Influencer outreach automation
- Advanced SEO optimization
- Revenue attribution tracking

## Security & Compliance

### Reddit Rules:
- 9:1 ratio (helpful posts vs. promotion)
- No vote manipulation
- Authentic engagement only
- Respect subreddit rules

### Content Guidelines:
- Always provide value first
- Transparent about affiliation
- No false claims or promises
- Accurate technical information

### Privacy:
- No user data collection
- Anonymous analytics only
- GDPR compliant forms
- Secure API key storage

---

**Support**: Join N8N Community Discord for technical help
**Updates**: This system self-optimizes based on performance
**ROI**: Expected break-even within 30 days of operation