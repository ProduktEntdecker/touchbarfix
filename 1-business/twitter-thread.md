# Twitter/X Thread - TouchBarFix Launch

## Thread Structure (7 tweets)

**Tweet 1/7 (Hook):**
🧵 Thread: How a 3-hour "quick fix" became a 7-day deep dive into macOS development

My MacBook Pro's TouchBar occasionally goes black. The fix? Google "TouchBar restart terminal command" → copy/paste → forget it exists until next time.

Got tired of this cycle...

**Tweet 2/7 (The Plan):**
Thought "I'll just make a simple button that runs the command. Should take 3 hours max."

Me to Claude: "build me a TouchBar fix app"
Claude: "Sure! Here's a basic Swift app..."

*Narrator: It did not take 3 hours.*

**Tweet 3/7 (Reality Hits):**
What I learned building TouchBarFix:
• First prototype: 30 minutes ✅
• Security warnings: "unidentified developer" ❌
• Code signing is... complex 😅
• Hardened runtime has opinions
• Universal binaries aren't automatic
• GitHub Pages SSL broke mysteriously

**Tweet 4/7 (The Cascade):**
Each "simple" fix revealed 3 new problems:
• CI/CD pipeline failed (deprecated Actions)
• Tests passed locally, failed on GitHub runners  
• Xcode created files in wrong directories after repo rename
• Had to migrate hosting from GitHub Pages to Vercel mid-launch

Classic developer move: spend a week automating something that takes 30 seconds manually.

**Tweet 5/7 (The Learning):**
But honestly? I learned more about macOS development in a week than I thought possible, thanks to Claude Code as my patient coding mentor.

The actual fix (`sudo killall ControlStrip` + related commands) works great. The challenge was packaging it properly for macOS distribution.

**Tweet 6/7 (The Product):**
TouchBarFix is now live: one-click solution instead of googling terminal commands.

FREE Founders Edition for 48h while waiting for Apple Developer approval. After that: €0.99 → €6.99.

https://touchbarfix.com

Not trying to get rich, just want to cover costs and validate demand.

**Tweet 7/7 (Engagement Hook):**
Sometimes the best projects come from scratching your own itch, even when that "itch" becomes a week-long development adventure.

What "simple" projects have surprised you with their complexity?

#MacBookPro #TouchBar #macOS #IndieApp #AIAssistedDevelopment

## Posting Strategy:
- Post tweets 30 seconds apart
- Engage with replies quickly
- Pin the thread to profile
- Share in relevant communities after initial posting
- Monitor for retweets and engagement