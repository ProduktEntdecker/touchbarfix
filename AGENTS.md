# Repository Guidelines

## Project Structure & Module Organization
- macOS sources sit in `App/`: production code (`Sources/`), configuration (`Resources/`), and tests (`Tests/`).
- Build outputs stay in `App/Release/`; keep DMGs and zips out of long-lived branches.
- Static web assets live at the repo root (`index.html`, `Assets/`, `components/`, `tailwind.css`) with helper scripts in `scripts/`.
- New reference material belongs near the touched module or inside `docs/`, dated in the filename or header.

## Build, Test, and Development Commands
- `cd App && swift build` (add `-c release` for optimized binaries) and `swift run` for local smoke checks.
- `cd App && ./build-app.sh` creates a signed `.app`; chain `./create-dmg.sh` when preparing a distributable DMG.
- `cd App && swift test` runs `TouchBarFixTests`; always pair with a manual restart on hardware that has a Touch Bar.

## Coding Style & Naming Conventions
- Use Swift 5.9 defaults: four-space indentation, `PascalCase` for types, `camelCase` for members, and explicit `public/internal/private`.
- Extend existing types (`TouchBarManager`, `ContentView`) instead of adding globals or singletons.
- Keep `components/*.html|js` filenames lowercase-kebab and reuse Tailwind utilities already present.
- Reindent via Xcode or your configured `swift-format` before committing to avoid noisy diffs.

## Testing Guidelines
- Place new unit coverage in `App/Tests`, mirroring production filenames (`TouchBarManagerTests.swift`).
- Name cases after intent (`test_processRestart_succeedsOnTouchBarMac`) and assert process control plus user-facing messaging.
- Update the manual checklist in `App/DEVELOPMENT.md` whenever behaviour shifts and link console output in the PR when diagnosing bugs.
- Note any ad-hoc validation for web or script work (e.g., `npx tailwindcss -i tailwind.css -o dist/tailwind.css`) inside the PR body.

## Commit & Pull Request Guidelines
- Follow the observed conventional prefixes (`feat:`, `fix:`, `docs:`, `refactor:`) and append ticket IDs such as `(TOU-22)` or `#123`.
- Work from feature branches (`feature/...`, `fix/...`, `docs/...`) and open PRs against `main`; mention `@coderabbitai` to trigger the automated review.
- PR descriptions must cover intent, local verification (`swift test`, manual steps), and any documentation or asset updates.
- Keep large binaries out of commits—attach deliverables to GitHub Releases or shared storage instead.

## Security & Configuration Tips
- Changes to `App/Resources/TouchBarFix.entitlements` require corresponding signing updates; keep permissions minimal and documented.
- Modify the process whitelist in `TouchBarManager.swift` only with accompanying tests and threat-model notes.
- Confirm notarization before publishing via `notarize.sh` or the `xcrun notarytool` command in `App/DEVELOPMENT.md`.
