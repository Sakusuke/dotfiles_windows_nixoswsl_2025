from ytmusicapi import YTMusic
import sys

def get_first_youtube_music_url(query):
    ytmusic = YTMusic()
    results = ytmusic.search(query, filter="songs")

    if results:
        video_id = results[0].get("videoId")
        if video_id:
            print(f"https://music.youtube.com/watch?v={video_id}")
        else:
            print("No video ID found.", file=sys.stderr)
    else:
        print("No results found.", file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python ytm_search.py <query>", file=sys.stderr)
        sys.exit(1)
    query = " ".join(sys.argv[1:])
    get_first_youtube_music_url(query)
