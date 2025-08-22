#!/bin/bash

# Navigate to project directory
cd /Users/floriansteiner/Documents/GitHub/touchbarfix

# Submit for notarization
xcrun notarytool submit App/Release/TouchBarFix-1.2.1.dmg --apple-id florian.steiner@mac.com --password kylb-kkqz-sjtp-ciap --team-id D3SM7HA325 --wait

# If successful, staple the notarization
if [ $? -eq 0 ]; then
    echo "Notarization successful! Now stapling..."
    xcrun stapler staple App/Release/TouchBarFix-1.2.1.dmg
    echo "✅ Notarization complete!"
else
    echo "❌ Notarization failed"
fi