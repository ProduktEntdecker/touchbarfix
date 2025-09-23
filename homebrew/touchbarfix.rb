cask "touchbarfix" do
  version "1.2.1"
  sha256 "YOUR_SHA256_HERE"

  url "https://github.com/ProduktEntdecker/touchbarfix/releases/download/v#{version}/TouchBarFix-#{version}.dmg"
  name "TouchBarFix"
  desc "Simple Touch Bar reset tool for MacBook Pro"
  homepage "https://touchbarfix.com"

  auto_updates false

  app "TouchBarFix.app"

  uninstall quit: "com.produktentdecker.touchbarfix"

  zap trash: [
    "~/Library/Preferences/com.produktentdecker.touchbarfix.plist",
    "~/Library/Application Support/TouchBarFix",
  ]

  caveats <<~EOS
    TouchBarFix is a trial version when installed via Homebrew.
    For the full version with unlimited use, please purchase at:
    https://touchbarfix.com
  EOS
end