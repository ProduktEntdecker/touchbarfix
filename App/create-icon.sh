#!/bin/bash

# === Configuration ===
ICON_NAME="TouchBarRestartIcon"
SOURCE_DIR="../Assets"
ICONSET_DIR="$SOURCE_DIR/AppIcon.iconset"
OUTPUT_ICNS="$SOURCE_DIR/AppIcon.icns"
SOURCE_IMAGE="$SOURCE_DIR/${ICON_NAME}.png"

# === Validate input ===
if [ ! -f "$SOURCE_IMAGE" ]; then
  echo "❌ PNG-Datei nicht gefunden: $SOURCE_IMAGE"
  echo "Suche nach JPG-Alternative..."
  SOURCE_IMAGE="$SOURCE_DIR/${ICON_NAME}.jpg"
  if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "❌ Auch JPG-Datei nicht gefunden: $SOURCE_IMAGE"
    exit 1
  else
    echo "✅ JPG-Datei gefunden: $SOURCE_IMAGE"
  fi
fi

# === Cleanup old files ===
rm -rf "$ICONSET_DIR"
mkdir "$ICONSET_DIR"

echo "🚀 Erzeuge Iconset aus $SOURCE_IMAGE ..."

# === Generate all icon sizes ===
sips -z 16 16     "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_16x16.png"
sips -z 32 32     "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_16x16@2x.png"
sips -z 32 32     "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_32x32.png"
sips -z 64 64     "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_32x32@2x.png"
sips -z 128 128   "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_128x128.png"
sips -z 256 256   "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_128x128@2x.png"
sips -z 256 256   "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_256x256.png"
sips -z 512 512   "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_256x256@2x.png"
sips -z 512 512   "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_512x512.png"
cp "$SOURCE_IMAGE" "$ICONSET_DIR/icon_512x512@2x.png"

# === Generate .icns file ===
echo "🎯 Erzeuge .icns-Datei ..."
iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_ICNS"

# === Cleanup iconset directory ===
rm -rf "$ICONSET_DIR"

# === Done ===
if [ $? -eq 0 ]; then
  echo "✅ Erfolgreich erstellt: $OUTPUT_ICNS"
  echo "📄 Dateigröße: $(du -h "$OUTPUT_ICNS" | cut -f1)"
else
  echo "❌ Fehler beim Erzeugen der .icns-Datei"
  exit 1
fi