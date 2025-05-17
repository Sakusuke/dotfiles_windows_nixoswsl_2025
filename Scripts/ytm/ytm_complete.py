#!/usr/bin/env python3
import os, subprocess, sys
from ytmusicapi import YTMusic

query = " ".join(sys.argv[1:])
url = query if query.startswith('http') else (
    f"https://music.youtube.com/watch?v={YTMusic().search(query, filter='songs')[0]['videoId']}"
)
subprocess.run([
    "yt-dlp", "-x", "--audio-format", "mp3", "--embed-thumbnail", "--embed-metadata",
    "--metadata-from-title", "%(artist)s - %(title)s",
    "--output", "~/Music/%(artist)s/%(title)s.%(ext)s", url
], check=True)