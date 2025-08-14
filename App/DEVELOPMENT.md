# Touch Bar Restarter - Development Guide

## 🚀 Quick Start

### Building the App

```bash
# Basic build (for development)
swift build

# Run the app directly
swift run

# Build release version
swift build -c release

# Build full app bundle (recommended)
./build-app.sh

# Create DMG for distribution
./create-dmg.sh
```

### Running Tests

```bash
swift test
```

## 📁 Project Structure

```
App/
├── Sources/
│   ├── main.swift              # App entry point, menu bar setup
│   ├── ContentView.swift       # Main UI (popover view)
│   └── TouchBarManager.swift   # Core logic for Touch Bar restart
├── Tests/
│   └── TouchBarManagerTests.swift # Unit tests
├── Resources/
│   ├── Info.plist              # App metadata
│   └── TouchBarRestarter.entitlements # Security permissions
├── Package.swift               # Swift Package Manager config
├── build-app.sh               # Creates .app bundle
└── create-dmg.sh              # Creates DMG installer
```

## 🔑 Key Features Implemented

### 1. Touch Bar Detection
- Automatically detects if the Mac has a Touch Bar
- Shows appropriate UI based on device capabilities
- Prevents restart attempts on non-Touch Bar Macs

### 2. Enhanced Error Handling
- Custom `TouchBarError` enum with user-friendly messages
- Proper error propagation throughout the app
- Clear user feedback via alerts

### 3. Process Management
- Kills multiple Touch Bar-related processes:
  - TouchBarServer
  - NowPlayingTouchUI
  - ControlStrip
- Better process detection using exact name matching
- Graceful handling of already-stopped processes

### 4. Persistence
- Tracks total restart count
- Remembers last restart time
- Persists data using UserDefaults

## 🔐 Security & Distribution

### Code Signing
The app includes an entitlements file for proper code signing. To sign:

1. Get an Apple Developer ID
2. Run `./build-app.sh` (automatically signs if ID found)
3. Notarize for distribution:
```bash
xcrun notarytool submit Release/TouchBarRestarter-1.0.0.dmg \
  --apple-id YOUR_APPLE_ID \
  --password YOUR_APP_PASSWORD \
  --team-id YOUR_TEAM_ID
```

### Non-Sandboxed Distribution
Currently configured for non-sandboxed distribution because:
- Needs to kill system processes (TouchBarServer)
- Requires broader system access
- App Store would require significant limitations

## 🧪 Testing

### Unit Tests
- Touch Bar detection
- Process checking
- Error handling
- Data persistence

### Manual Testing Checklist
- [ ] App appears in menu bar
- [ ] Popover opens/closes correctly
- [ ] Touch Bar detection works
- [ ] Restart button disabled on non-Touch Bar Macs
- [ ] Restart successfully kills/restarts processes
- [ ] Error messages display correctly
- [ ] Restart count persists between launches
- [ ] Last restart time shows correctly

## 🐛 Known Issues & Limitations

1. **Requires Admin Privileges**: Killing system processes may require admin access
2. **Not Sandboxed**: Can't be distributed via Mac App Store in current form
3. **Process Names**: Hardcoded process names may change in future macOS versions
4. **M1 Pro/Max Detection**: Touch Bar detection might need updates for newer models

## 🚧 Future Improvements

### High Priority
- [ ] Add app icon (AppIcon.icns)
- [ ] Implement Sparkle for auto-updates
- [ ] Add crash reporting (Sentry/Crashlytics)
- [ ] Create landing page

### Medium Priority
- [ ] Auto-restart when Touch Bar becomes unresponsive
- [ ] Logging system for debugging
- [ ] Keyboard shortcut support
- [ ] Preferences window

### Low Priority
- [ ] Touch Bar health monitoring
- [ ] Schedule automatic restarts
- [ ] Export logs feature
- [ ] Multiple UI themes

## 📝 Development Notes

### Adding New Features
1. Update `TouchBarManager.swift` for core logic
2. Update `ContentView.swift` for UI changes
3. Add tests in `TouchBarManagerTests.swift`
4. Update entitlements if new permissions needed

### Release Checklist
1. [ ] Update version in Info.plist
2. [ ] Update version in build scripts
3. [ ] Run all tests
4. [ ] Build release version
5. [ ] Test on Touch Bar Mac
6. [ ] Test on non-Touch Bar Mac
7. [ ] Create signed app bundle
8. [ ] Create DMG
9. [ ] Notarize for distribution
10. [ ] Update documentation

## 🤝 Contributing

Before submitting changes:
1. Run `swift test` to ensure tests pass
2. Test on both Touch Bar and non-Touch Bar Macs
3. Update documentation if needed
4. Follow existing code style

## 📄 License

Copyright © 2024 ProduktEntdecker. All rights reserved.