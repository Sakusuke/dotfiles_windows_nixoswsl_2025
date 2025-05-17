#!/usr/bin/env python3

import os
import sys
import subprocess
import json
from ytmusicapi import YTMusic

def get_youtube_music_url(query):
    """Get YouTube Music URL from a search query."""
    ytmusic = YTMusic()
    results = ytmusic.search(query, filter="songs")

    if not results:
        raise ValueError("No results found.")
    
    video_id = results[0].get("videoId")
    if not video_id:
        raise ValueError("No video ID found.")
    
    return f"https://music.youtube.com/watch?v={video_id}"

def download_and_tag_audio(url, temp_dir, music_dir):
    """Download audio using yt-dlp and organize files."""
    # Create temporary directory if it doesn't exist
    os.makedirs(temp_dir, exist_ok=True)
    
    # Download audio with yt-dlp
    cmd = [
        "yt-dlp",
        "-x",
        "--audio-format", "mp3",
        "--embed-thumbnail",
        "--embed-metadata",
        "--metadata-from-title", "%(artist)s - %(title)s",
        "--output", "%(artist)s - %(title)s.%(ext)s",
        "--paths", temp_dir,
        "--no-playlist",
        "--write-info-json",
        url
    ]
    
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Download failed: {e}")

def process_downloaded_files(temp_dir, music_dir):
    """Process downloaded files and move to artist directory."""
    # Find the info.json file
    info_files = [f for f in os.listdir(temp_dir) if f.endswith('.info.json')]
    if not info_files:
        raise FileNotFoundError("Could not find metadata file.")
    
    info_file = os.path.join(temp_dir, info_files[0])
    
    # Extract main artist (first one)
    with open(info_file, 'r') as f:
        metadata = json.load(f)
    
    main_artist = metadata.get('artist', '').split(',')[0].strip()
    if not main_artist:
        raise ValueError("Could not determine artist from metadata.")
    
    # Create artist directory
    dest_dir = os.path.join(music_dir, main_artist)
    os.makedirs(dest_dir, exist_ok=True)
    
    # Move all files to artist directory
    for filename in os.listdir(temp_dir):
        src = os.path.join(temp_dir, filename)
        dst = os.path.join(dest_dir, filename)
        
        # Skip if moving to same file (shouldn't happen)
        if src == dst:
            continue
            
        os.rename(src, dst)
    
    # Remove info.json file
    os.remove(os.path.join(dest_dir, info_files[0]))
    
    # Remove temp directory if empty
    try:
        os.rmdir(temp_dir)
    except OSError:
        pass  # Directory not empty or already deleted
    
    return dest_dir

def main():
    if len(sys.argv) < 2:
        print("Usage: python ytm_download.py <search terms or YouTube URL>")
        sys.exit(1)
    
    query = " ".join(sys.argv[1:])
    url = query if query.startswith('https://') else None
    
    try:
        # If not a URL, search for it
        if not url:
            print(f"Searching for: {query}")
            url = get_youtube_music_url(query)
        
        print(f"Found: {url}")
        print("Downloading and tagging...")
        
        # Setup directories
        home_dir = os.path.expanduser("~")
        temp_dir = os.path.join(home_dir, "Music", "_temp_dl")
        music_dir = os.path.join(home_dir, "Music")
        
        # Download and process
        download_and_tag_audio(url, temp_dir, music_dir)
        dest_dir = process_downloaded_files(temp_dir, music_dir)
        
        print(f"Saved to: {dest_dir}")
        
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()