# 🗂️ Project Plan – TouchBarFix MVP Launch

This document outlines the structured work packages and tools used to bring the TouchBarFix app from idea to public beta. The goal is to launch a stable, functional, monetizable 1.0 version targeted at users with unresponsive or black Touch Bars on Intel and Apple Silicon MacBook Pros (2016–2020).

---

## ✅ Phase 1: Research & Market Validation

**Objective:** Confirm user pain, demand, and product viability.

| Task | Description | Tools |
|------|-------------|-------|
| Market research | Analyze Reddit, Apple Support, Google Trends, and forums | Google, Reddit, Apple Discussions |
| Keyword validation | Research search intent and SEO volume | Google Trends, Ahrefs (trial), Reddit search |
| Problem synthesis | Define exact user frustrations and mental models | Notion, ChatGPT |
| Initial TAM estimate | Size the addressable market | Spreadsheet, assumptions based on Apple sales data |

---

## ✅ Phase 2: MVP Development

**Objective:** Build a simple, functional macOS menu bar app to restart Touch Bar without a reboot or Terminal.

| Task | Description | Tools |
|------|-------------|-------|
| Repo setup | GitHub project with modular folder structure | GitHub |
| Swift Package | SwiftPM-based macOS app | Xcode, Swift |
| Process logic | Touch Bar process restart (TouchBarServer, ControlStrip) | Swift `Process`, async/await |
| Error handling | Graceful fallback and logging | Swift, console logging |
| Single instance check | Prevent double app instances | NSRunningApplication, PID match |
| Icon generation | Create .icns icon based on a glowing Touch Bar | PNG → `.icns` via `iconutil` |
| Status feedback | Log restart result to console + show success/failure UI | SwiftUI |
| Code signing | Prepare app for notarization | Apple Developer Program |

---

## ✅ Phase 3: Packaging & Distribution

**Objective:** Build a signed universal binary and deliver it to beta users.

| Task | Description | Tools |
|------|-------------|-------|
| Build universal app | Support both Intel and Apple Silicon (Universal Binary) | `swift build --arch`, Xcode |
| Create DMG | Package app into DMG with custom icon | DMGCanvas, create-dmg, bash |
| Notarization | Sign and notarize app for Gatekeeper | Apple Developer Tools, `xcrun`, `altool` |
| Upload beta | Host DMG + version on site or Gumroad | Gumroad, GitHub Releases, Website |
| Internal QA | Test on own Mac, multiple user accounts, safe mode | Local testing |
| External beta | Distribute to 2–5 users with affected MacBook Pro | Email, DMs, Reddit outreach |

---

## ✅ Phase 4: Launch Preparation

**Objective:** Create the web presence and tracking foundation.

| Task | Description | Tools |
|------|-------------|-------|
| Domain | Register and connect `www.touchbarfix.com` | Domain provider |
| Landing page | SEO-first, responsive site | Astro, Vercel, GitHub Pages |
| CTA | Add “Join Beta” / “Download Now” button | Tailwind, markdown/HTML |
| Analytics | Simple privacy-compliant tracking | Plausible, Umami |
| Support form | Allow users to report bugs or success | Tally.so, SimpleForm |
| License protection | Optional license key or IP limit | Gumroad, Paddle (later) |

---

## ✅ Phase 5: Marketing & Launch

**Objective:** Generate traffic, drive installs, gather social proof.

| Task | Description | Tools |
|------|-------------|-------|
| Social proof | Share early feedback screenshots | X, Reddit |
| SEO | Optimize page title, meta, alt tags | On-page |
| Reddit strategy | Participate in r/mac, r/MacBookPro | Reddit |
| X strategy | Short tweet threads and replies with screenshots | X / Threads |
| Micro-influencer outreach | Send pitch to 10–20 tech influencers | Email, DMs |
| Product Hunt (optional) | Launch for visibility | producthunt.com |

---

## ✅ Phase 6: Feedback & Iteration

**Objective:** Improve app based on early feedback.

| Task | Description | Tools |
|------|-------------|-------|
| In-app feedback | Add simple link to contact | Mailto:, Form |
| Usage logging | Optional logging of restart events | JSON + local storage (no tracking) |
| Changelog | Track updates on landing page or repo | Markdown changelog |
| Referrals (later) | Add referral system to spread virally | Viral Loops, DIY |

---

## 📦 Milestone Summary

| Milestone | Goal | ETA |
|-----------|------|-----|
| ✅ MVP running locally | Touch Bar restarts via menu bar | DONE |
| ✅ Beta DMG shipped | Signed, universal, delivered | DONE |
| ⏳ Landing page live | www.touchbarfix.com online | In progress |
| ⏳ First public feedback | 1–3 users confirm fix works | Week 1 post-launch |
| 🔜 App Store launch | Optional if traction confirms | TBD |

---

## 🚀 Next ONE Thing

> 🎯 Publish the landing page with “Download” CTA and support contact.  
> Start collecting feedback, traffic and early testimonials.