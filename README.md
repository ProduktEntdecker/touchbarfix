# TouchBarFix

A simple macOS utility that fixes frozen Touch Bar issues on MacBook Pro (2016-2021).

## What it does

TouchBarFix restarts the Touch Bar software processes when they become unresponsive. It's essentially a GUI wrapper for the Terminal command `pkill -x TouchBarServer`, providing a one-click solution.

## Installation

### Option 1: Download Pre-built App
Download the latest release from the [Releases](https://github.com/ProduktEntdecker/touchbarfix/releases) page.

### Option 2: Build from Source
```bash
git clone https://github.com/ProduktEntdecker/touchbarfix.git
cd touchbarfix/App
swift build -c release
```

## Usage

1. Launch TouchBarFix when your Touch Bar freezes
2. Click "Fix Touch Bar"
3. The Touch Bar will restart automatically

## System Requirements

- macOS 11.0 (Big Sur) or later
- MacBook Pro with Touch Bar (2016-2021 models)
- No administrator privileges required

## Security

- **Notarized by Apple** - Every release is notarized for security
- **No Admin Access** - Runs entirely in user space
- **No Data Collection** - Works completely offline
- **Open Source** - Review the code yourself

## Website

Visit [touchbarfix.com](https://touchbarfix.com) for more information.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Support

For issues or questions, please use the [GitHub Issues](https://github.com/ProduktEntdecker/touchbarfix/issues) page.

---

Made with ❤️ by [Florian Steiner](https://linkedin.com/in/floriansteiner)