#!/usr/bin/env bash

QUERY="$*"
if [ -z "$QUERY" ]; then
  echo "Usage: $0 <search terms or YouTube URL>"
  exit 1
fi

# Check if the input is a URL
if [[ "$QUERY" =~ ^https:// ]]; then
  URL="$QUERY"
else
  # Get the YouTube Music URL from your Python script
  URL=$(python3 ytm_search.py "$QUERY")
fi

# Exit if the URL is invalid
if [[ ! "$URL" =~ ^https:// ]]; then
  echo "Failed to get a valid URL."
  exit 1
fi

echo "Found: $URL"
echo "Downloading and tagging..."

yt-dlp \
  -x \
  --audio-format mp3 \
  --embed-thumbnail \
  --embed-metadata \
  --metadata-from-title "%(artist)s - %(title)s" \
  --output "%(artist)s/%(artist)s - %(title)s.%(ext)s" \
  --paths "$HOME/Music" \
  --no-playlist \
  "$URL"