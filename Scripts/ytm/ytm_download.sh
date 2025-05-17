#!/usr/bin/env bash

# Take the full query string as input
QUERY="$*"
if [ -z "$QUERY" ]; then
  echo "Usage: $0 <search terms or YouTube URL>"
  exit 1
fi

# Check if the input is a URL or needs to be searched
if [[ "$QUERY" =~ ^https:// ]]; then
  URL="$QUERY"
else
  # Get the YouTube Music URL from your Python script
  URL=$(python3 ytm_search.py "$QUERY")
fi

# Exit if the URL is invalid
[[ "$URL" =~ ^https:// ]] || {
  echo "Failed to get a valid URL."
  exit 1
}

echo "Found: $URL"
echo "Downloading and tagging..."

# Use a temporary folder for download
TMPDIR="$HOME/Music/_temp_dl"
mkdir -p "$TMPDIR"

# Download audio, extract metadata and thumbnail, save info.json
yt-dlp \
  -x \
  --audio-format mp3 \
  --embed-thumbnail \
  --embed-metadata \
  --metadata-from-title "%(artist)s - %(title)s" \
  --output "%(artist)s - %(title)s.%(ext)s" \
  --paths "$TMPDIR" \
  --no-playlist \
  --write-info-json \
  "$URL"

# Find the downloaded metadata file
INFOFILE=$(find "$TMPDIR" -name "*.info.json" | head -n 1)
if [ ! -f "$INFOFILE" ]; then
  echo "Could not find metadata file."
  exit 1
fi

# Extract the main artist (first one) and clean up whitespace
MAIN_ARTIST=$(jq -r '.artist' "$INFOFILE" | cut -d',' -f1 | xargs)

# Define final destination folder
DESTDIR="$HOME/Music/$MAIN_ARTIST"
mkdir -p "$DESTDIR"

# Move all downloaded files into the artist's folder
mv "$TMPDIR"/* "$DESTDIR/"

# Delete the .info.json file
rm -f "$DESTDIR"/*.info.json

# Remove the temporary directory if empty
rmdir "$TMPDIR" 2>/dev/null || true

echo "Saved to: $DESTDIR"
