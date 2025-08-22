# TouchBarFix

A macOS utility app that helps restart your Touch Bar when it becomes unresponsive. Built with SwiftUI and distributed as a status bar app.

## 🚀 Features

- **One-click Touch Bar restart** - Quickly restart your Touch Bar when it's unresponsive
- **Status bar integration** - Runs in the background without cluttering your dock
- **Touch Bar status monitoring** - See if your Touch Bar is currently running
- **Restart history** - Track how many times you've restarted and when
- **Modern SwiftUI interface** - Clean, native macOS design

## 🛠️ Development Setup

### Prerequisites

- macOS 13.0 or later
- Swift 5.9 or later
- Xcode 15.0+ (for building and distribution) OR VS Code with Swift extensions

### VS Code Setup (Recommended for Development)

1. **Install Swift Extensions:**
   - Open VS Code
   - Go to Extensions (Cmd+Shift+X)
   - Search for and install:
     - "Swift" by Swift Foundation
     - "Swift Language" by Swift Foundation
     - "Swift for Visual Studio Code"

2. **Install Swift Language Server:**
   ```bash
   git clone https://github.com/apple/sourcekit-lsp.git
   cd sourcekit-lsp
   swift build
   ```

### Building the App

1. **Navigate to the project:**
   ```bash
   cd TouchBarFix
   ```

2. **Build the project:**
   ```bash
   swift build
   ```
   
   Or use the build script:
   ```bash
   ./build.sh
   ```

3. **Run the app:**
   ```bash
   swift run
   ```

### Project Structure

```
TouchBarFix/
├── Package.swift              # Swift Package Manager configuration
├── Sources/
│   ├── main.swift            # App entry point and status bar setup
│   ├── ContentView.swift     # Main SwiftUI interface
│   └── TouchBarManager.swift # Touch Bar restart logic
├── Tests/                    # Unit tests
└── Resources/                # App resources
```

## 🔧 How It Works

The app uses several methods to restart the Touch Bar:

1. **Kill Touch Bar Process** - Terminates the TouchBarServer process
2. **Reset Preferences** - Clears Touch Bar configuration
3. **Restart Services** - Restarts ControlCenter to reinitialize Touch Bar

## 📱 App Architecture

- **SwiftUI-based interface** with modern macOS design patterns
- **Status bar integration** using AppKit for system-level access
- **Asynchronous Touch Bar management** with proper error handling
- **Persistent data storage** using UserDefaults for restart history

## 🚀 Building for Distribution

### Code Signing and Notarization

1. **Get Apple Developer ID:**
   - Enroll in Apple Developer Program ($99/year)
   - Generate Developer ID certificate

2. **Code Sign the App:**
   ```bash
   codesign --force --deep --sign "Developer ID Application: Your Name" TouchBarFix
   ```

3. **Notarize the App:**
   ```bash
   xcrun notarytool submit TouchBarFix.zip --apple-id "your@email.com" --password "app-specific-password"
   ```

### Creating DMG Package

1. **Install create-dmg:**
   ```bash
   brew install create-dmg
   ```

2. **Create DMG:**
   ```bash
   create-dmg \
     --volname "Touch Bar Restarter" \
     --window-pos 200 120 \
     --window-size 800 400 \
     --icon-size 100 \
     --icon "Touch Bar Restarter.app" 200 190 \
     --hide-extension "Touch Bar Restarter.app" \
     --app-drop-link 600 185 \
     "Touch Bar Restarter.dmg" \
     "source_folder/"
   ```

## 🧪 Testing

Run the test suite:
```bash
swift test
```

## 📋 TODO

- [ ] Add Touch Bar state detection
- [ ] Implement auto-restart scheduling
- [ ] Add notification preferences
- [ ] Create preferences window
- [ ] Add Touch Bar widget
- [ ] Implement crash reporting
- [ ] Add analytics integration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This app modifies system processes and preferences. Use at your own risk. The developers are not responsible for any system issues that may arise from using this utility.

## 🆘 Support

If you encounter issues:
1. Check the macOS Console app for error logs
2. Ensure you have the latest macOS version
3. Try restarting your Mac if the Touch Bar remains unresponsive
4. Open an issue on GitHub with detailed error information
