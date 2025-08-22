# HackerNews Submission - TouchBarFix

## Title
TouchBarFix – A simple GUI for MacBook Pro TouchBar restart commands

## URL
https://touchbarfix.com

## Text
I built this after getting frustrated with constantly re-googling TouchBar restart commands. As a consultant who uses MacBooks daily, I knew the terminal solutions existed but could never remember the exact syntax when I actually needed it.

What started as "I'll just create a simple GUI wrapper, should take 3 hours" became a week-long adventure. I thought it would be a quick AI prompt to Claude: "build me a TouchBar fix app." Reality hit hard.

The journey was a masterclass in underestimating complexity:
- First prototype worked in 30 minutes (I got cocky)
- Then security warnings everywhere - "unidentified developer" 
- Learned about code signing, notarization, hardened runtime
- GitHub Pages SSL mysteriously broke after repo rename
- Had to migrate to Vercel mid-launch
- CI/CD pipeline failed with deprecated GitHub Actions
- Tests worked locally but failed on GitHub runners
- Xcode created workspace files in wrong directories after rename
- Binary needed to be universal (Intel + Apple Silicon)
- App Store requirements vs direct distribution differences

Each "simple" fix revealed 3 new problems. But honestly? I learned more about macOS development in a week than I thought possible, thanks to Claude Code as my patient coding mentor.

Core functionality is straightforward - it runs the same `sudo killall ControlStrip` and related commands that fix TouchBar issues, but with proper error handling and user feedback.

Since I'm waiting for Apple Developer Program approval for code signing, I'm releasing it as a free Founders Edition for 48 hours. After that, it'll be a paid app ($0.99 initially, then $6.99).

Feedback welcome, especially from other non-developers who've tackled similar automation projects with AI assistance.